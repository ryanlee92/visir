#!/usr/bin/env node

/**
 * 이미지 리사이징 스크립트
 * Lighthouse 리포트에 따라 이미지를 최적화된 크기로 리사이즈
 * 
 * 사용 방법:
 * npm run resize:images
 */

import { readdirSync, statSync, existsSync, mkdirSync } from 'fs';
import { join, dirname, basename, extname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');
const assetsDir = join(rootDir, 'assets');

// sharp 라이브러리 로드
let sharp;
try {
  sharp = (await import('sharp')).default;
} catch (error) {
  console.error('❌ sharp 패키지가 설치되지 않았습니다.');
  console.log('설치 방법: npm install sharp');
  process.exit(1);
}

// 이미지 리사이징 설정
const resizeConfigs = {
  // Desktop 이미지들: 표시 크기에 맞춰 리사이즈
  'unified-inbox-dark.webp': { width: 616, height: 504 },
  'unified-inbox-light.webp': { width: 616, height: 504 },
  'ai-assistant-dark.webp': { width: 616, height: 461 },
  'ai-assistant-light.webp': { width: 616, height: 461 },
  
  // Mobile 이미지들: 표시 크기에 맞춰 리사이즈
  'mobile/mobile_home_dark.webp': { width: 392, height: 852 },
  'mobile/mobile_home_light.webp': { width: 392, height: 852 },
  'mobile/mobile_mail_dark.webp': { width: 392, height: 852 },
  'mobile/mobile_mail_light.webp': { width: 392, height: 852 },
  'mobile/mobile_chat_dark.webp': { width: 392, height: 852 },
  'mobile/mobile_chat_light.webp': { width: 392, height: 852 },
  'mobile/mobile_task_dark.webp': { width: 392, height: 852 },
  'mobile/mobile_task_light.webp': { width: 392, height: 852 },
  'mobile/mobile_cal_dark.webp': { width: 392, height: 852 },
  'mobile/mobile_cal_light.webp': { width: 392, height: 852 },
  
  // 로고 이미지: 작은 크기로 리사이즈 (여러 크기 생성)
  'visir/visir_foreground.webp': [
    { width: 32, height: 32, suffix: '-32' },
    { width: 64, height: 64, suffix: '-64' },
    { width: 128, height: 128, suffix: '-128' },
  ],
  'visir/visir_foreground.png': [
    { width: 32, height: 32, suffix: '-32' },
    { width: 64, height: 64, suffix: '-64' },
    { width: 128, height: 128, suffix: '-128' },
  ],
};

async function resizeImage(inputPath, outputPath, config) {
  try {
    const image = sharp(inputPath);
    const metadata = await image.metadata();
    
    // 이미 최적화된 크기인지 확인
    if (metadata.width <= config.width && metadata.height <= config.height) {
      console.log(`  ⏭️  이미 최적화됨: ${basename(inputPath)} (${metadata.width}x${metadata.height})`);
      return false;
    }
    
    // 리사이즈 - 정확한 크기로 리사이즈 (비율 유지하면서 크롭)
    await image
      .resize(config.width, config.height, {
        fit: 'cover', // 정확한 크기로 리사이즈 (비율 유지하면서 크롭)
        position: 'center', // 중앙 정렬
      })
      .webp({ quality: 85, effort: 6 }) // WebP 최적화
      .toFile(outputPath);
    
    const originalSize = statSync(inputPath).size;
    const newSize = statSync(outputPath).size;
    const savings = ((originalSize - newSize) / originalSize * 100).toFixed(1);
    
    console.log(`  ✅ ${basename(inputPath)}: ${metadata.width}x${metadata.height} → ${config.width}x${config.height}`);
    console.log(`     크기: ${(originalSize / 1024).toFixed(1)} KB → ${(newSize / 1024).toFixed(1)} KB (${savings}% 절감)`);
    
    return true;
  } catch (error) {
    console.error(`  ❌ 오류: ${basename(inputPath)} - ${error.message}`);
    return false;
  }
}

async function processImageConfig(imagePath, config) {
  const fullPath = join(assetsDir, imagePath);
  
  if (!existsSync(fullPath)) {
    console.log(`  ⚠️  파일 없음: ${imagePath}`);
    return false;
  }
  
  let processed = false;
  
  // 여러 크기 생성 (로고 이미지)
  if (Array.isArray(config)) {
    for (const sizeConfig of config) {
      const ext = extname(imagePath);
      const baseName = basename(imagePath, ext);
      const dir = dirname(imagePath);
      const outputPath = join(assetsDir, dir, `${baseName}${sizeConfig.suffix}${ext}`);
      
      const resized = await resizeImage(fullPath, outputPath, sizeConfig);
      if (resized) processed = true;
    }
  } else {
    // 단일 크기로 리사이즈 (임시 파일 사용 후 교체)
    const ext = extname(imagePath);
    const tempPath = fullPath.replace(ext, `.temp${ext}`);
    const resized = await resizeImage(fullPath, tempPath, config);
    
    if (resized) {
      // 임시 파일을 원본 파일로 교체
      const { unlinkSync, renameSync } = await import('fs');
      unlinkSync(fullPath);
      renameSync(tempPath, fullPath);
      processed = true;
    } else if (existsSync(tempPath)) {
      // 리사이즈가 필요 없었지만 임시 파일이 생성된 경우 삭제
      const { unlinkSync } = await import('fs');
      unlinkSync(tempPath);
    }
  }
  
  return processed;
}

async function main() {
  console.log('🖼️  이미지 리사이징 시작...\n');
  
  let totalProcessed = 0;
  let totalSaved = 0;
  
  for (const [imagePath, config] of Object.entries(resizeConfigs)) {
    console.log(`📸 처리 중: ${imagePath}`);
    
    const fullPath = join(assetsDir, imagePath);
    if (existsSync(fullPath)) {
      const originalSize = statSync(fullPath).size;
      const processed = await processImageConfig(imagePath, config);
      
      if (processed) {
        totalProcessed++;
        if (Array.isArray(config)) {
          // 여러 크기 생성한 경우, 첫 번째 크기의 절감량 추정
          const estimatedSize = originalSize * 0.1; // 약 90% 절감 추정
          totalSaved += originalSize - estimatedSize;
        } else {
          const newSize = statSync(fullPath).size;
          totalSaved += originalSize - newSize;
        }
      }
    } else {
      console.log(`  ⚠️  파일 없음: ${imagePath}`);
    }
    console.log('');
  }
  
  console.log('📊 요약:');
  console.log(`  처리된 이미지: ${totalProcessed}개`);
  console.log(`  예상 절감량: ${(totalSaved / 1024).toFixed(1)} KB`);
  console.log('\n✅ 이미지 리사이징 완료!');
  console.log('\n다음 단계:');
  console.log('1. 리사이즈된 이미지 확인');
  console.log('2. 코드에서 width/height 속성 제거 (이미 완료)');
  console.log('3. 빌드 및 테스트: npm run build');
}

main().catch(error => {
  console.error('❌ 오류:', error);
  process.exit(1);
});

