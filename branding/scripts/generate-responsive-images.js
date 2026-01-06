#!/usr/bin/env node

/**
 * 반응형 이미지 생성 스크립트
 * Lighthouse 리포트에 따라 이미지를 여러 크기로 생성하여 srcset에 사용
 * 
 * 사용 방법:
 * npm run generate:responsive-images
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

// 반응형 이미지 생성 설정
// 각 이미지에 대해 표시 크기와 실제 크기를 기반으로 여러 크기 생성
const responsiveConfigs = {
  // Desktop 이미지들: 표시 크기 약 300-400px, 실제 2160px
  // 1x: 표시 크기, 2x: 표시 크기 * 2, 3x: 표시 크기 * 3 (최대 실제 크기까지)
  'mail_dark.webp': { 
    displayWidth: 400, // 표시되는 최대 너비 (실제로는 더 작을 수 있음)
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'mail_light.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'chat_dark.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'chat_light.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'task_dark.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'task_light.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'calendar_dark.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  'calendar_light.webp': { 
    displayWidth: 400,
    displayHeight: 240,
    maxWidth: 2160,
    maxHeight: 1280
  },
  
  // Mobile 이미지들: 표시 크기 224-392px, 실제 392px
  'mobile/mobile_home_dark.webp': { 
    displayWidth: 392,
    displayHeight: 852,
    maxWidth: 392,
    maxHeight: 852
  },
  'mobile/mobile_home_light.webp': { 
    displayWidth: 392,
    displayHeight: 852,
    maxWidth: 392,
    maxHeight: 852
  },
  
  // Desktop 큰 이미지들: 표시 크기 약 540-616px, 실제 616px
  'ai-assistant-dark.webp': { 
    displayWidth: 616,
    displayHeight: 461,
    maxWidth: 616,
    maxHeight: 461
  },
  'ai-assistant-light.webp': { 
    displayWidth: 616,
    displayHeight: 461,
    maxWidth: 616,
    maxHeight: 461
  },
  'unified-inbox-dark.webp': { 
    displayWidth: 616,
    displayHeight: 504,
    maxWidth: 616,
    maxHeight: 504
  },
  'unified-inbox-light.webp': { 
    displayWidth: 616,
    displayHeight: 504,
    maxWidth: 616,
    maxHeight: 504
  },
};

/**
 * 이미지의 실제 비율을 계산하여 높이를 결정
 */
async function calculateDimensions(inputPath, targetWidth, targetHeight) {
  const image = sharp(inputPath);
  const metadata = await image.metadata();
  
  const aspectRatio = metadata.width / metadata.height;
  let width = targetWidth;
  let height = targetHeight;
  
  // 비율 유지하면서 크기 조정
  if (targetWidth / targetHeight > aspectRatio) {
    // 너비 기준으로 높이 조정
    width = Math.round(targetHeight * aspectRatio);
  } else {
    // 높이 기준으로 너비 조정
    height = Math.round(targetWidth / aspectRatio);
  }
  
  return { width, height };
}

/**
 * 반응형 이미지 생성
 */
async function generateResponsiveImage(imagePath, config) {
  const fullPath = join(assetsDir, imagePath);
  
  if (!existsSync(fullPath)) {
    console.log(`  ⚠️  파일 없음: ${imagePath}`);
    return null;
  }
  
  const ext = extname(imagePath);
  const baseName = basename(imagePath, ext);
  const dir = dirname(imagePath);
  const image = sharp(fullPath);
  const metadata = await image.metadata();
  
  // 원본 이미지 크기 확인
  const originalSize = statSync(fullPath).size;
  
  // 생성할 크기들: 2x, 3x (1x는 원본 사용)
  const sizes = [];
  
  // 2x 크기 (고해상도 디스플레이용)
  const width2x = Math.min(config.displayWidth * 2, config.maxWidth);
  const height2x = Math.min(config.displayHeight * 2, config.maxHeight);
  if (width2x <= metadata.width && height2x <= metadata.height) {
    sizes.push({
      width: width2x,
      height: height2x,
      suffix: '@2x',
      descriptor: '2x'
    });
  }
  
  // 원본이 2x보다 크면 원본도 포함 (3x로)
  if (metadata.width > width2x || metadata.height > height2x) {
    sizes.push({
      width: metadata.width,
      height: metadata.height,
      suffix: '@3x',
      descriptor: '3x'
    });
  }
  
  const generatedFiles = [];
  let totalNewSize = 0;
  
  for (const size of sizes) {
    const { width, height } = await calculateDimensions(fullPath, size.width, size.height);
    const outputPath = join(assetsDir, dir, `${baseName}${size.suffix}${ext}`);
    
    // 1x는 원본을 사용하므로 생성하지 않음
    if (size.suffix === '') {
      continue;
    }
    
    // 이미 존재하는 파일은 건너뛰기 (선택적)
    if (existsSync(outputPath)) {
      console.log(`  ⏭️  이미 존재: ${basename(outputPath)}`);
      const existingSize = statSync(outputPath).size;
      totalNewSize += existingSize;
      generatedFiles.push({
        path: outputPath,
        width,
        height,
        descriptor: size.descriptor,
        size: existingSize
      });
      continue;
    }
    
    try {
      await image
        .clone()
        .resize(width, height, {
          fit: 'inside', // 비율 유지하면서 안쪽에 맞춤
          withoutEnlargement: true // 확대하지 않음
        })
        .webp({ quality: 85, effort: 6 })
        .toFile(outputPath);
      
      const newSize = statSync(outputPath).size;
      totalNewSize += newSize;
      
      generatedFiles.push({
        path: outputPath,
        width,
        height,
        descriptor: size.descriptor,
        size: newSize
      });
      
      console.log(`  ✅ 생성: ${basename(outputPath)} (${width}x${height}, ${size.descriptor}) - ${(newSize / 1024).toFixed(1)} KB`);
    } catch (error) {
      console.error(`  ❌ 오류: ${basename(outputPath)} - ${error.message}`);
    }
  }
  
  // srcset 문자열 생성 (1x는 원본, 2x, 3x는 생성된 파일)
  const fullSrcset = [
    `../assets/${imagePath} 1x`,
    ...generatedFiles.map(f => {
      const relativePath = f.path.replace(assetsDir + '/', '');
      return `../assets/${relativePath} ${f.descriptor}`;
    })
  ].join(', ');
  
  return {
    originalSize,
    totalNewSize,
    generatedFiles,
    srcset: fullSrcset,
    basePath: imagePath,
    baseImportPath: imagePath.replace(/\.webp$/, '')
  };
}

async function main() {
  console.log('🖼️  반응형 이미지 생성 시작...\n');
  
  let totalProcessed = 0;
  let totalOriginalSize = 0;
  let totalNewSize = 0;
  const results = [];
  
  for (const [imagePath, config] of Object.entries(responsiveConfigs)) {
    console.log(`📸 처리 중: ${imagePath}`);
    
    const result = await generateResponsiveImage(imagePath, config);
    
    if (result) {
      totalProcessed++;
      totalOriginalSize += result.originalSize;
      totalNewSize += result.totalNewSize;
      results.push(result);
      
      console.log(`  📊 원본: ${(result.originalSize / 1024).toFixed(1)} KB`);
      console.log(`  📊 생성된 파일들 총합: ${(result.totalNewSize / 1024).toFixed(1)} KB`);
      console.log(`  📝 srcset: ${result.srcset || '원본만 사용'}`);
    }
    console.log('');
  }
  
  console.log('📊 요약:');
  console.log(`  처리된 이미지: ${totalProcessed}개`);
  console.log(`  원본 총 크기: ${(totalOriginalSize / 1024).toFixed(1)} KB`);
  console.log(`  생성된 파일들 총합: ${(totalNewSize / 1024).toFixed(1)} KB`);
  console.log(`  예상 절감량: ${((totalOriginalSize - totalNewSize) / 1024).toFixed(1)} KB`);
  console.log('\n✅ 반응형 이미지 생성 완료!');
  console.log('\n다음 단계:');
  console.log('1. FeatureSection.svelte에서 srcset 속성 추가');
  console.log('2. 빌드 및 테스트: npm run build');
  console.log('\n생성된 srcset 예시:');
  results.slice(0, 3).forEach(result => {
    if (result.srcset) {
      console.log(`  ${result.basePath}:`);
      console.log(`    srcset="${result.srcset}"`);
    }
  });
}

main().catch(error => {
  console.error('❌ 오류:', error);
  process.exit(1);
});

