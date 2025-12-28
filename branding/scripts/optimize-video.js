import { execSync } from 'child_process';
import { existsSync, statSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const assetsDir = join(__dirname, '../assets');

// ANSI 색상 코드
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
}

async function optimizeVideo(inputPath, outputPath, quality = 30) {
  try {
    // ffmpeg가 설치되어 있는지 확인
    try {
      execSync('ffmpeg -version', { stdio: 'ignore' });
    } catch (error) {
      log('❌ ffmpeg가 설치되어 있지 않습니다.', 'red');
      log('   설치 방법:', 'yellow');
      log('   - macOS: brew install ffmpeg', 'yellow');
      log('   - Ubuntu: sudo apt install ffmpeg', 'yellow');
      log('   - Windows: https://ffmpeg.org/download.html', 'yellow');
      return false;
    }

    const inputSize = statSync(inputPath).size;
    
    log(`\n🔄 비디오 최적화 중: ${inputPath}`, 'cyan');
    log(`   입력 크기: ${formatBytes(inputSize)}`, 'blue');
    
    // WebM VP9 코덱으로 압축
    const command = `ffmpeg -i "${inputPath}" -c:v libvpx-vp9 -crf ${quality} -b:v 0 -c:a libopus -b:a 64k -y "${outputPath}"`;
    
    execSync(command, { stdio: 'inherit' });
    
    if (existsSync(outputPath)) {
      const outputSize = statSync(outputPath).size;
      const reduction = ((1 - outputSize / inputSize) * 100).toFixed(1);
      
      log(`\n✅ 최적화 완료:`, 'green');
      log(`   출력 크기: ${formatBytes(outputSize)}`, 'green');
      log(`   크기 감소: ${reduction}%`, 'green');
      
      return true;
    }
    
    return false;
  } catch (error) {
    log(`\n❌ 오류 발생: ${error.message}`, 'red');
    return false;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const quality = parseInt(args[0]) || 30; // 기본값 30 (낮을수록 높은 품질, 높을수록 작은 파일)
  
  log('🎥 비디오 최적화 스크립트', 'bright');
  log('='.repeat(50), 'bright');
  
  log(`\n품질 설정: ${quality} (권장: 30-35)`, 'cyan');
  log('낮은 값 = 높은 품질, 큰 파일', 'yellow');
  log('높은 값 = 낮은 품질, 작은 파일', 'yellow');
  
  const videoFiles = [
    join(assetsDir, 'app-demo-dark.webm'),
    join(assetsDir, 'app-demo-light.webm'),
  ];
  
  let successCount = 0;
  
  for (const videoFile of videoFiles) {
    if (!existsSync(videoFile)) {
      log(`\n⚠️  파일을 찾을 수 없습니다: ${videoFile}`, 'yellow');
      continue;
    }
    
    const outputPath = videoFile.replace('.webm', '-optimized.webm');
    const success = await optimizeVideo(videoFile, outputPath, quality);
    
    if (success) {
      successCount++;
    }
  }
  
  log(`\n✨ 완료! ${successCount}/${videoFiles.length}개 파일 최적화됨`, 'green');
  log('\n💡 다음 단계:', 'bright');
  log('1. 최적화된 파일을 확인하세요', 'yellow');
  log('2. 품질이 만족스러우면 원본 파일을 교체하세요', 'yellow');
  log('3. 코드에서 파일명을 업데이트하세요', 'yellow');
}

main().catch(error => {
  log(`\n❌ 오류 발생: ${error.message}`, 'red');
  process.exit(1);
});

