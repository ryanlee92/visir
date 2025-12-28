import { execSync } from 'child_process';
import { readFileSync, existsSync, statSync, readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const projectRoot = join(__dirname, '..');
const distPath = join(projectRoot, 'dist');

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

function analyzeBuildSize() {
  log('\n📦 빌드 크기 분석', 'cyan');
  log('='.repeat(50), 'cyan');

  if (!existsSync(distPath)) {
    log('❌ dist 폴더를 찾을 수 없습니다. 먼저 빌드를 실행하세요.', 'red');
    return null;
  }

  const results = {
    totalSize: 0,
    jsFiles: [],
    cssFiles: [],
    imageFiles: [],
    videoFiles: [],
    otherFiles: [],
  };

  // 재귀적으로 디렉토리 탐색
  function walkDirectory(dir, basePath = '') {
    try {
      const entries = readdirSync(dir, { withFileTypes: true });
      
      entries.forEach(entry => {
        const fullPath = join(dir, entry.name);
        const relativePath = basePath ? join(basePath, entry.name) : entry.name;
        
        if (entry.isDirectory()) {
          walkDirectory(fullPath, relativePath);
        } else if (entry.isFile()) {
          try {
            const stats = statSync(fullPath);
            const size = stats.size;
            results.totalSize += size;

            if (entry.name.endsWith('.js')) {
              results.jsFiles.push({ name: relativePath, size });
            } else if (entry.name.endsWith('.css')) {
              results.cssFiles.push({ name: relativePath, size });
            } else if (entry.name.match(/\.(webp|png|jpg|jpeg|svg|gif)$/i)) {
              results.imageFiles.push({ name: relativePath, size });
            } else if (entry.name.match(/\.(webm|mp4|mov)$/i)) {
              results.videoFiles.push({ name: relativePath, size });
            } else {
              results.otherFiles.push({ name: relativePath, size });
            }
          } catch (error) {
            // 파일 읽기 오류 무시
          }
        }
      });
    } catch (error) {
      log(`⚠️  디렉토리 탐색 중 오류: ${error.message}`, 'yellow');
    }
  }

  // dist 폴더의 모든 파일 찾기
  try {
    walkDirectory(distPath);
  } catch (error) {
    log(`⚠️  파일 분석 중 오류: ${error.message}`, 'yellow');
  }

  // 결과 출력
  log(`\n총 빌드 크기: ${formatBytes(results.totalSize)}`, 'bright');

  if (results.jsFiles.length > 0) {
    const jsTotal = results.jsFiles.reduce((sum, f) => sum + f.size, 0);
    log(`\n📄 JavaScript 파일 (${results.jsFiles.length}개):`, 'blue');
    results.jsFiles
      .sort((a, b) => b.size - a.size)
      .forEach(file => {
        const size = file.size;
        const gzipEstimate = size * 0.3;
        let description = '';
        
        // 청크 설명 추가
        if (file.name.includes('svelte-core')) {
          description = ' (Svelte 프레임워크 코어)';
        } else if (file.name.includes('supabase')) {
          description = ' (Supabase 클라이언트)';
        } else if (file.name.includes('svelte-vendor')) {
          description = ' (Svelte 관련 라이브러리)';
        } else if (file.name.includes('icons-vendor')) {
          description = ' (아이콘 라이브러리)';
        } else if (file.name.includes('markdown-vendor')) {
          description = ' (마크다운 파서)';
        } else if (file.name.includes('router-vendor')) {
          description = ' (라우터)';
        } else if (file.name.includes('vendor')) {
          description = ' (기타 라이브러리)';
        } else if (file.name.includes('index')) {
          description = ' (메인 엔트리)';
        }
        
        log(`  - ${file.name}: ${formatBytes(size)}${description}`, 'reset');
        if (size > 100 * 1024) {
          log(`    └─ gzip 예상: ${formatBytes(gzipEstimate)}`, 'cyan');
        }
      });
    log(`  총합: ${formatBytes(jsTotal)}`, 'bright');
    log(`  gzip 압축 후 예상: ${formatBytes(jsTotal * 0.3)}`, 'cyan');
  }

  if (results.cssFiles.length > 0) {
    const cssTotal = results.cssFiles.reduce((sum, f) => sum + f.size, 0);
    log(`\n🎨 CSS 파일 (${results.cssFiles.length}개):`, 'blue');
    results.cssFiles.forEach(file => {
      log(`  - ${file.name}: ${formatBytes(file.size)}`, 'reset');
    });
    log(`  총합: ${formatBytes(cssTotal)}`, 'bright');
  }

  if (results.imageFiles.length > 0) {
    const imgTotal = results.imageFiles.reduce((sum, f) => sum + f.size, 0);
    log(`\n🖼️  이미지 파일 (${results.imageFiles.length}개):`, 'blue');
    const largeImages = [];
    results.imageFiles
      .sort((a, b) => b.size - a.size)
      .forEach(file => {
        const size = file.size;
        log(`  - ${file.name}: ${formatBytes(size)}`, 'reset');
        
        // 큰 이미지 식별 (100KB 이상)
        if (size > 100 * 1024) {
          largeImages.push({ name: file.name, size });
          if (file.name.includes('.png') && !file.name.includes('.webp')) {
            log(`    ⚠️  PNG 파일입니다. WebP 변환 고려`, 'yellow');
          }
        }
      });
    log(`  총합: ${formatBytes(imgTotal)}`, 'bright');
    
    if (largeImages.length > 0) {
      log(`\n  🔍 큰 이미지 파일 (100KB 이상, ${largeImages.length}개):`, 'yellow');
      largeImages.forEach(img => {
        log(`    - ${img.name}: ${formatBytes(img.size)}`, 'yellow');
      });
    }
  }

  const vidTotal = results.videoFiles.reduce((sum, f) => sum + f.size, 0);
  if (results.videoFiles.length > 0) {
    log(`\n🎥 비디오 파일 (${results.videoFiles.length}개):`, 'blue');
    results.videoFiles.forEach(file => {
      log(`  - ${file.name}: ${formatBytes(file.size)}`, 'reset');
    });
    log(`  총합: ${formatBytes(vidTotal)}`, 'bright');
  }

  // 권장사항
  log('\n💡 권장사항:', 'yellow');
  const jsTotal = results.jsFiles.reduce((sum, f) => sum + f.size, 0);
  const jsGzipEstimate = jsTotal * 0.3; // gzip 압축률 약 70% 가정
  if (jsTotal > 500 * 1024) {
    log(`  ⚠️  JavaScript 번들이 ${formatBytes(jsTotal)} (gzip 예상: ${formatBytes(jsGzipEstimate)})로 500KB를 초과합니다.`, 'yellow');
    log('     - 코드 스플리팅이 이미 적용되어 있지만 추가 최적화 고려', 'yellow');
    log('     - 사용하지 않는 의존성 제거 검토', 'yellow');
    log('     - Tree shaking 확인', 'yellow');
  } else {
    log(`  ✅ JavaScript 번들 크기 양호: ${formatBytes(jsTotal)} (gzip 예상: ${formatBytes(jsGzipEstimate)})`, 'green');
  }
  
  const imgTotal = results.imageFiles.reduce((sum, f) => sum + f.size, 0);
  const pngFiles = results.imageFiles.filter(f => f.name.includes('.png') && !f.name.includes('.webp'));
  const largePng = pngFiles.filter(f => f.size > 100 * 1024);
  
  if (imgTotal > 5 * 1024 * 1024) {
    log(`  ⚠️  이미지 총 크기가 ${formatBytes(imgTotal)}로 5MB를 초과합니다.`, 'yellow');
    log('     - WebP 변환 확인 (이미 적용됨)', 'yellow');
    log('     - 이미지 압축 품질 조정 고려', 'yellow');
    log('     - CDN 사용 검토', 'yellow');
  } else if (imgTotal > 2 * 1024 * 1024) {
    log(`  ⚠️  이미지 총 크기가 ${formatBytes(imgTotal)}입니다. 추가 최적화 고려.`, 'yellow');
    if (largePng.length > 0) {
      log(`     ⚠️  큰 PNG 파일 ${largePng.length}개 발견 (WebP 변환 권장):`, 'yellow');
      largePng.forEach(img => {
        log(`       - ${img.name}: ${formatBytes(img.size)}`, 'yellow');
      });
    }
  } else {
    log(`  ✅ 이미지 크기 양호: ${formatBytes(imgTotal)}`, 'green');
    if (largePng.length > 0) {
      log(`     ⚠️  큰 PNG 파일 ${largePng.length}개 발견 (WebP 변환 권장)`, 'yellow');
    }
  }
  
  if (vidTotal > 10 * 1024 * 1024) {
    log(`  ⚠️  비디오 총 크기가 ${formatBytes(vidTotal)}로 10MB를 초과합니다.`, 'yellow');
    log('     - 비디오 압축 강화 고려', 'yellow');
    log('     - 더 낮은 비트레이트 사용 검토', 'yellow');
  } else if (vidTotal > 5 * 1024 * 1024) {
    log(`  ⚠️  비디오 총 크기가 ${formatBytes(vidTotal)}입니다. 추가 압축 고려.`, 'yellow');
    log('     - 현재 Intersection Observer로 지연 로딩 적용됨', 'yellow');
    log('     - 비디오 품질/해상도 조정 검토', 'yellow');
  } else {
    log(`  ✅ 비디오 크기 양호: ${formatBytes(vidTotal)}`, 'green');
  }

  // 초기 로딩 크기 추정
  const cssTotal = results.cssFiles.reduce((sum, f) => sum + f.size, 0);
  const initialLoadEstimate = jsTotal + cssTotal;
  const initialLoadGzip = initialLoadEstimate * 0.3;
  
  log(`\n📊 초기 로딩 크기 추정:`, 'cyan');
  log(`   JavaScript: ${formatBytes(jsTotal)} → gzip: ${formatBytes(jsTotal * 0.3)}`, 'cyan');
  log(`   CSS: ${formatBytes(cssTotal)} → gzip: ${formatBytes(cssTotal * 0.3)}`, 'cyan');
  log(`   총합: ${formatBytes(initialLoadEstimate)} → gzip: ${formatBytes(initialLoadGzip)}`, 'bright');
  
  // 성능 평가
  if (initialLoadGzip < 200 * 1024) {
    log(`   ✅ 초기 로딩 크기 우수 (200KB 미만)`, 'green');
  } else if (initialLoadGzip < 300 * 1024) {
    log(`   ⚠️  초기 로딩 크기 양호 (200-300KB)`, 'yellow');
  } else {
    log(`   ⚠️  초기 로딩 크기 개선 필요 (300KB 이상)`, 'yellow');
  }
  
  // 최적화 가능한 부분 요약
  log(`\n🎯 최적화 우선순위:`, 'bright');
  const optimizations = [];
  
  if (jsTotal > 500 * 1024) {
    optimizations.push({ priority: 1, item: 'JavaScript 번들 최적화', impact: '높음' });
  }
  if (largePng.length > 0) {
    optimizations.push({ priority: 2, item: `PNG → WebP 변환 (${largePng.length}개)`, impact: '높음' });
  }
  if (vidTotal > 5 * 1024 * 1024) {
    optimizations.push({ priority: 3, item: '비디오 압축 강화', impact: '중간' });
  }
  if (imgTotal > 2 * 1024 * 1024) {
    optimizations.push({ priority: 4, item: '이미지 품질 조정', impact: '중간' });
  }
  
  if (optimizations.length === 0) {
    log(`   ✅ 추가 최적화가 필요하지 않습니다!`, 'green');
  } else {
    optimizations.forEach(opt => {
      log(`   ${opt.priority}. ${opt.item} (영향도: ${opt.impact})`, 'yellow');
    });
  }

  return results;
}

async function runLighthouse(url = 'http://localhost:4173') {
  log('\n🔍 Lighthouse 성능 측정', 'cyan');
  log('='.repeat(50), 'cyan');

  try {
    // Lighthouse가 설치되어 있는지 확인
    try {
      execSync('lighthouse --version', { stdio: 'ignore' });
    } catch (error) {
      log('⚠️  Lighthouse가 설치되어 있지 않습니다.', 'yellow');
      log('   설치하려면: npm install -g lighthouse', 'yellow');
      log('   또는: npm install --save-dev lighthouse', 'yellow');
      return null;
    }

    log(`\n측정 URL: ${url}`, 'blue');
    log('Lighthouse 실행 중... (약 30-60초 소요)', 'blue');

    const outputPath = join(projectRoot, 'lighthouse-report.html');
    const command = `lighthouse "${url}" --output=html --output-path="${outputPath}" --chrome-flags="--headless" --quiet`;

    execSync(command, { stdio: 'inherit' });

    if (existsSync(outputPath)) {
      log(`\n✅ Lighthouse 리포트가 생성되었습니다: ${outputPath}`, 'green');
      
      // 리포트 파일 읽어서 점수 추출 시도
      try {
        const report = readFileSync(outputPath, 'utf-8');
        const performanceMatch = report.match(/"performance":\s*(\d+)/);
        const accessibilityMatch = report.match(/"accessibility":\s*(\d+)/);
        const bestPracticesMatch = report.match(/"best-practices":\s*(\d+)/);
        const seoMatch = report.match(/"seo":\s*(\d+)/);

        if (performanceMatch) {
          const score = parseInt(performanceMatch[1]);
          const color = score >= 90 ? 'green' : score >= 50 ? 'yellow' : 'red';
          log(`\n📊 성능 점수: ${score}/100`, color);
        }
        if (accessibilityMatch) {
          const score = parseInt(accessibilityMatch[1]);
          log(`📊 접근성 점수: ${score}/100`, 'blue');
        }
        if (bestPracticesMatch) {
          const score = parseInt(bestPracticesMatch[1]);
          log(`📊 모범 사례 점수: ${score}/100`, 'blue');
        }
        if (seoMatch) {
          const score = parseInt(seoMatch[1]);
          log(`📊 SEO 점수: ${score}/100`, 'blue');
        }
      } catch (error) {
        log('⚠️  리포트 파싱 중 오류 발생', 'yellow');
      }
    }

    return outputPath;
  } catch (error) {
    log(`\n❌ Lighthouse 실행 중 오류: ${error.message}`, 'red');
    return null;
  }
}

async function main() {
  log('\n🚀 브랜딩 페이지 성능 체크', 'bright');
  log('='.repeat(50), 'bright');

  const args = process.argv.slice(2);
  const url = args[0] || 'http://localhost:4173';
  const skipBuild = args.includes('--skip-build');
  const skipLighthouse = args.includes('--skip-lighthouse');

  // 1. 빌드 확인
  if (!skipBuild) {
    log('\n1️⃣ 빌드 확인 중...', 'cyan');
    if (!existsSync(distPath)) {
      log('❌ dist 폴더가 없습니다. 빌드를 실행합니다...', 'yellow');
      try {
        execSync('npm run build', { cwd: projectRoot, stdio: 'inherit' });
        log('✅ 빌드 완료', 'green');
      } catch (error) {
        log('❌ 빌드 실패', 'red');
        process.exit(1);
      }
    } else {
      log('✅ 빌드 폴더 확인됨', 'green');
    }
  }

  // 2. 빌드 크기 분석
  const buildAnalysis = analyzeBuildSize();

  // 3. Lighthouse 실행
  if (!skipLighthouse) {
    log('\n2️⃣ Lighthouse 성능 측정...', 'cyan');
    log('💡 팁: vite preview 서버가 실행 중이어야 합니다.', 'yellow');
    log('   실행하려면: npm run preview', 'yellow');
    log('   또는 --skip-lighthouse 옵션으로 건너뛸 수 있습니다.\n', 'yellow');

    // 서버가 실행 중인지 확인
    try {
      const response = await fetch(url);
      if (response.ok) {
        await runLighthouse(url);
      } else {
        log(`⚠️  ${url}에 연결할 수 없습니다.`, 'yellow');
        log('   vite preview 서버를 실행하거나 --skip-lighthouse 옵션을 사용하세요.', 'yellow');
      }
    } catch (error) {
      log(`⚠️  ${url}에 연결할 수 없습니다.`, 'yellow');
      log('   vite preview 서버를 실행하거나 --skip-lighthouse 옵션을 사용하세요.', 'yellow');
      log('   예: npm run preview (별도 터미널에서)', 'yellow');
    }
  }

  log('\n✅ 성능 체크 완료!', 'green');
  log('\n사용법:', 'bright');
  log('  npm run perf              # 전체 체크 (빌드 + Lighthouse)');
  log('  npm run perf -- --skip-build      # 빌드 건너뛰기');
  log('  npm run perf -- --skip-lighthouse # Lighthouse 건너뛰기');
  log('  npm run perf -- http://localhost:3000  # 다른 URL 사용');
}

main().catch(error => {
  log(`\n❌ 오류 발생: ${error.message}`, 'red');
  process.exit(1);
});
