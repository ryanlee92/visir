#!/usr/bin/env node

/**
 * Multi-tool SEO Checker
 * Uses multiple SEO checking methods for comprehensive analysis
 */

import { execSync } from 'child_process';
import { readFileSync, existsSync, writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// SEO 체크 항목들
const seoChecks = {
  // 1. 메타 태그 체크
  metaTags: {
    name: '메타 태그',
    checks: [
      {
        name: 'Title 태그',
        check: (html) => {
          const match = html.match(/<title>(.*?)<\/title>/i);
          if (!match) return { pass: false, message: 'Title 태그가 없습니다.' };
          const length = match[1].length;
          if (length > 60) return { pass: false, message: `Title이 너무 깁니다 (${length}자, 권장: 60자 이하)` };
          if (length < 30) return { pass: false, message: `Title이 너무 짧습니다 (${length}자, 권장: 30-60자)` };
          return { pass: true, message: `Title: ${match[1]} (${length}자)` };
        }
      },
      {
        name: 'Meta Description',
        check: (html) => {
          const match = html.match(/<meta\s+name=["']description["']\s+content=["'](.*?)["']/i);
          if (!match) return { pass: false, message: 'Meta description이 없습니다.' };
          const length = match[1].length;
          if (length > 160) return { pass: false, message: `Meta description이 너무 깁니다 (${length}자, 권장: 160자 이하)` };
          if (length < 50) return { pass: false, message: `Meta description이 너무 짧습니다 (${length}자, 권장: 50-160자)` };
          return { pass: true, message: `Meta description: ${length}자` };
        }
      },
      {
        name: 'Meta Keywords',
        check: (html) => {
          const match = html.match(/<meta\s+name=["']keywords["']/i);
          return match 
            ? { pass: true, message: 'Meta keywords 있음' }
            : { pass: false, message: 'Meta keywords가 없습니다 (선택사항이지만 권장)' };
        }
      },
      {
        name: 'Open Graph 태그',
        check: (html) => {
          const hasOgTitle = html.match(/<meta\s+property=["']og:title["']/i);
          const hasOgDesc = html.match(/<meta\s+property=["']og:description["']/i);
          const hasOgImage = html.match(/<meta\s+property=["']og:image["']/i);
          const count = [hasOgTitle, hasOgDesc, hasOgImage].filter(Boolean).length;
          if (count === 3) return { pass: true, message: 'Open Graph 태그 완료' };
          return { pass: false, message: `Open Graph 태그 불완전 (${count}/3)` };
        }
      },
      {
        name: 'Twitter Card 태그',
        check: (html) => {
          const hasTwitterCard = html.match(/<meta\s+name=["']twitter:card["']/i);
          const hasTwitterTitle = html.match(/<meta\s+name=["']twitter:title["']/i);
          const count = [hasTwitterCard, hasTwitterTitle].filter(Boolean).length;
          if (count === 2) return { pass: true, message: 'Twitter Card 태그 완료' };
          return { pass: false, message: `Twitter Card 태그 불완전 (${count}/2)` };
        }
      },
      {
        name: 'Canonical URL',
        check: (html) => {
          const match = html.match(/<link\s+rel=["']canonical["']/i);
          return match 
            ? { pass: true, message: 'Canonical URL 있음' }
            : { pass: false, message: 'Canonical URL이 없습니다.' };
        }
      },
      {
        name: 'Robots 메타 태그',
        check: (html) => {
          const match = html.match(/<meta\s+name=["']robots["']/i);
          return match 
            ? { pass: true, message: 'Robots 메타 태그 있음' }
            : { pass: false, message: 'Robots 메타 태그가 없습니다.' };
        }
      },
    ]
  },

  // 2. 구조화된 데이터 체크
  structuredData: {
    name: '구조화된 데이터',
    checks: [
      {
        name: 'JSON-LD 스키마',
        check: (html) => {
          const match = html.match(/<script\s+type=["']application\/ld\+json["']/gi);
          const count = match ? match.length : 0;
          if (count === 0) return { pass: false, message: '구조화된 데이터(JSON-LD)가 없습니다.' };
          return { pass: true, message: `구조화된 데이터: ${count}개` };
        }
      },
      {
        name: 'WebSite 스키마',
        check: (html) => {
          const match = html.match(/"@type"\s*:\s*"WebSite"/i);
          return match 
            ? { pass: true, message: 'WebSite 스키마 있음' }
            : { pass: false, message: 'WebSite 스키마가 없습니다.' };
        }
      },
      {
        name: 'SoftwareApplication 스키마',
        check: (html) => {
          const match = html.match(/"@type"\s*:\s*"SoftwareApplication"/i);
          return match 
            ? { pass: true, message: 'SoftwareApplication 스키마 있음' }
            : { pass: false, message: 'SoftwareApplication 스키마가 없습니다 (선택사항)' };
        }
      },
      {
        name: 'Organization 스키마',
        check: (html) => {
          const match = html.match(/"@type"\s*:\s*"Organization"/i);
          return match 
            ? { pass: true, message: 'Organization 스키마 있음' }
            : { pass: false, message: 'Organization 스키마가 없습니다.' };
        }
      },
    ]
  },

  // 3. 성능 최적화 체크
  performance: {
    name: '성능 최적화',
    checks: [
      {
        name: 'DNS Prefetch',
        check: (html) => {
          const match = html.match(/<link\s+rel=["']dns-prefetch["']/gi);
          const count = match ? match.length : 0;
          if (count === 0) return { pass: false, message: 'DNS prefetch가 없습니다.' };
          return { pass: true, message: `DNS prefetch: ${count}개` };
        }
      },
      {
        name: 'Preconnect',
        check: (html) => {
          const match = html.match(/<link\s+rel=["']preconnect["']/gi);
          const count = match ? match.length : 0;
          if (count < 2) return { pass: false, message: `Preconnect가 부족합니다 (${count}개, 권장: 2개 이상)` };
          return { pass: true, message: `Preconnect: ${count}개` };
        }
      },
      {
        name: '폰트 최적화',
        check: (html) => {
          const hasDisplaySwap = html.match(/display=swap/i);
          const hasSubset = html.match(/subset=latin/i);
          if (hasDisplaySwap && hasSubset) return { pass: true, message: '폰트 최적화 완료 (display=swap, subset=latin)' };
          if (!hasDisplaySwap) return { pass: false, message: '폰트에 display=swap이 없습니다.' };
          return { pass: false, message: '폰트에 subset=latin이 없습니다.' };
        }
      },
    ]
  },

  // 4. 접근성 체크
  accessibility: {
    name: '접근성',
    checks: [
      {
        name: 'HTML Lang 속성',
        check: (html) => {
          const match = html.match(/<html[^>]*\s+lang=["']([^"']+)["']/i);
          if (!match) return { pass: false, message: 'HTML lang 속성이 없습니다.' };
          return { pass: true, message: `Lang 속성: ${match[1]}` };
        }
      },
      {
        name: 'Viewport 메타 태그',
        check: (html) => {
          const match = html.match(/<meta\s+name=["']viewport["']/i);
          return match 
            ? { pass: true, message: 'Viewport 메타 태그 있음' }
            : { pass: false, message: 'Viewport 메타 태그가 없습니다.' };
        }
      },
      {
        name: 'Charset 메타 태그',
        check: (html) => {
          const match = html.match(/<meta\s+charset=["']utf-8["']/i);
          return match 
            ? { pass: true, message: 'Charset 메타 태그 있음' }
            : { pass: false, message: 'Charset 메타 태그가 없습니다.' };
        }
      },
    ]
  },

  // 5. 보안 체크
  security: {
    name: '보안',
    checks: [
      {
        name: 'HTTPS (Canonical URL)',
        check: (html) => {
          const match = html.match(/<link\s+rel=["']canonical["']\s+href=["']https:\/\//i);
          return match 
            ? { pass: true, message: 'Canonical URL이 HTTPS를 사용합니다.' }
            : { pass: false, message: 'Canonical URL이 HTTPS를 사용하지 않습니다.' };
        }
      },
      {
        name: 'Open Graph Secure URL',
        check: (html) => {
          const match = html.match(/<meta\s+property=["']og:image:secure_url["']/i);
          return match 
            ? { pass: true, message: 'og:image:secure_url 있음' }
            : { pass: false, message: 'og:image:secure_url이 없습니다.' };
        }
      },
    ]
  },
};

function runChecks(htmlPath) {
  if (!existsSync(htmlPath)) {
    log('❌ index.html을 찾을 수 없습니다.', 'red');
    return null;
  }

  const html = readFileSync(htmlPath, 'utf-8');
  const results = {};

  for (const [categoryKey, category] of Object.entries(seoChecks)) {
    log(`\n📋 ${category.name} 체크`, 'cyan');
    log('='.repeat(50), 'cyan');
    
    const categoryResults = [];
    let categoryScore = 0;

    for (const check of category.checks) {
      const result = check.check(html);
      categoryResults.push({ ...check, result });
      
      if (result.pass) {
        log(`  ✅ ${check.name}: ${result.message}`, 'green');
        categoryScore += 100 / category.checks.length;
      } else {
        log(`  ${result.message.includes('선택사항') ? '⚠️' : '❌'} ${check.name}: ${result.message}`, 
            result.message.includes('선택사항') ? 'yellow' : 'red');
        if (!result.message.includes('선택사항')) {
          categoryScore += (100 / category.checks.length) * 0.5; // 부분 점수
        }
      }
    }

    results[categoryKey] = {
      name: category.name,
      score: Math.round(categoryScore),
      checks: categoryResults,
    };
  }

  return results;
}

function generateReport(results) {
  log('\n📊 SEO 체크 리포트', 'bright');
  log('='.repeat(50), 'bright');

  let totalScore = 0;
  let totalWeight = 0;
  const weights = {
    metaTags: 0.35,
    structuredData: 0.25,
    performance: 0.15,
    accessibility: 0.15,
    security: 0.10,
  };

  for (const [key, result] of Object.entries(results)) {
    const weight = weights[key] || 0;
    const weightedScore = result.score * weight;
    totalScore += weightedScore;
    totalWeight += weight;

    const color = result.score >= 80 ? 'green' : result.score >= 60 ? 'yellow' : 'red';
    log(`${result.name}: ${result.score}/100 (가중치: ${(weight * 100).toFixed(0)}%)`, color);
  }

  const finalScore = Math.round(totalScore / totalWeight);
  const finalColor = finalScore >= 80 ? 'green' : finalScore >= 60 ? 'yellow' : 'red';
  
  log(`\n총점: ${finalScore}/100`, finalColor);

  // 개선 사항 정리
  const improvements = [];
  for (const [key, result] of Object.entries(results)) {
    for (const check of result.checks) {
      if (!check.result.pass && !check.result.message.includes('선택사항')) {
        improvements.push(`  ${check.name}: ${check.result.message}`);
      }
    }
  }

  if (improvements.length > 0) {
    log('\n💡 개선 사항:', 'yellow');
    improvements.forEach(imp => log(imp, 'yellow'));
  } else {
    log('\n✅ 모든 체크를 통과했습니다!', 'green');
  }

  return { finalScore, improvements };
}

async function main() {
  const args = process.argv.slice(2);
  const urlArg = args.find(arg => !arg.startsWith('--') && arg.startsWith('http'));
  const url = urlArg || 'http://localhost:4173';
  const htmlPath = join(rootDir, 'index.html');
  
  log('\n🚀 다중 SEO 체크 도구', 'bright');
  log('='.repeat(50), 'bright');
  log(`HTML: ${htmlPath}`, 'blue');
  if (urlArg) log(`URL: ${url}`, 'blue');

  // 정적 HTML 체크
  const results = runChecks(htmlPath);
  if (!results) {
    process.exit(1);
  }

  const report = generateReport(results);

  // Lighthouse 실행 (선택사항)
  const runLighthouse = args.includes('--lighthouse');
  if (runLighthouse) {
    try {
      log('\n🔍 Lighthouse 실행 중...', 'cyan');
      log('⚠️  서버가 실행 중인지 확인하세요: npm run preview', 'yellow');
      execSync(`npm run check:seo ${url}`, { stdio: 'inherit', cwd: rootDir });
    } catch (error) {
      log('⚠️  Lighthouse 실행 실패', 'yellow');
      log('   서버가 실행 중인지 확인하세요: npm run preview', 'yellow');
    }
  }

  // 리포트 저장
  const reportPath = join(rootDir, 'seo-report.json');
  writeFileSync(reportPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    score: report.finalScore,
    results,
    improvements: report.improvements,
  }, null, 2));
  log(`\n📄 리포트 저장: ${reportPath}`, 'blue');

  log('\n✅ SEO 체크 완료!', 'green');
}

main().catch(console.error);

