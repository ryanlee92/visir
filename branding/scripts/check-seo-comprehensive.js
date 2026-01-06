#!/usr/bin/env node

/**
 * Comprehensive SEO Checker
 * Checks multiple SEO aspects using different methods
 */

import { execSync } from 'child_process';
import { readFileSync, existsSync } from 'fs';
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

function checkMetaTags(htmlPath) {
  log('\n📋 메타 태그 체크', 'cyan');
  log('='.repeat(50), 'cyan');
  
  if (!existsSync(htmlPath)) {
    log('❌ index.html을 찾을 수 없습니다.', 'red');
    return { score: 0, issues: [] };
  }
  
  const html = readFileSync(htmlPath, 'utf-8');
  const issues = [];
  let score = 100;
  
  // Title 체크
  const titleMatch = html.match(/<title>(.*?)<\/title>/i);
  if (!titleMatch) {
    issues.push('❌ Title 태그가 없습니다.');
    score -= 20;
  } else {
    const titleLength = titleMatch[1].length;
    if (titleLength > 60) {
      issues.push(`⚠️  Title이 너무 깁니다 (${titleLength}자, 권장: 60자 이하)`);
      score -= 10;
    } else if (titleLength < 30) {
      issues.push(`⚠️  Title이 너무 짧습니다 (${titleLength}자, 권장: 30-60자)`);
      score -= 5;
    } else {
      log(`✅ Title: ${titleMatch[1]} (${titleLength}자)`, 'green');
    }
  }
  
  // Meta description 체크
  const descMatch = html.match(/<meta\s+name=["']description["']\s+content=["'](.*?)["']/i);
  if (!descMatch) {
    issues.push('❌ Meta description이 없습니다.');
    score -= 20;
  } else {
    const descLength = descMatch[1].length;
    if (descLength > 160) {
      issues.push(`⚠️  Meta description이 너무 깁니다 (${descLength}자, 권장: 160자 이하)`);
      score -= 10;
    } else if (descLength < 50) {
      issues.push(`⚠️  Meta description이 너무 짧습니다 (${descLength}자, 권장: 50-160자)`);
      score -= 5;
    } else {
      log(`✅ Meta description: ${descLength}자`, 'green');
    }
  }
  
  // Open Graph 체크
  const ogTitle = html.match(/<meta\s+property=["']og:title["']/i);
  const ogDesc = html.match(/<meta\s+property=["']og:description["']/i);
  const ogImage = html.match(/<meta\s+property=["']og:image["']/i);
  
  if (!ogTitle) issues.push('⚠️  og:title이 없습니다.');
  if (!ogDesc) issues.push('⚠️  og:description이 없습니다.');
  if (!ogImage) issues.push('⚠️  og:image가 없습니다.');
  
  if (ogTitle && ogDesc && ogImage) {
    log('✅ Open Graph 태그 완료', 'green');
  } else {
    score -= 5;
  }
  
  // Canonical 체크
  const canonical = html.match(/<link\s+rel=["']canonical["']/i);
  if (!canonical) {
    issues.push('⚠️  Canonical URL이 없습니다.');
    score -= 5;
  } else {
    log('✅ Canonical URL 있음', 'green');
  }
  
  // Structured Data 체크
  const structuredData = html.match(/<script\s+type=["']application\/ld\+json["']/i);
  if (!structuredData) {
    issues.push('⚠️  구조화된 데이터(JSON-LD)가 없습니다.');
    score -= 10;
  } else {
    log('✅ 구조화된 데이터 있음', 'green');
  }
  
  // Robots 체크
  const robots = html.match(/<meta\s+name=["']robots["']/i);
  if (!robots) {
    issues.push('⚠️  Robots 메타 태그가 없습니다.');
    score -= 5;
  } else {
    log('✅ Robots 메타 태그 있음', 'green');
  }
  
  if (issues.length > 0) {
    log('\n발견된 문제:', 'yellow');
    issues.forEach(issue => log(`  ${issue}`, 'yellow'));
  }
  
  return { score: Math.max(0, score), issues };
}

function checkImages(htmlPath) {
  log('\n🖼️  이미지 최적화 체크', 'cyan');
  log('='.repeat(50), 'cyan');
  
  if (!existsSync(htmlPath)) {
    return { score: 0, issues: [] };
  }
  
  const html = readFileSync(htmlPath, 'utf-8');
  const issues = [];
  let score = 100;
  
  // Alt 속성 체크는 동적 콘텐츠이므로 건너뜀
  log('ℹ️  이미지 alt 속성은 런타임에 확인해야 합니다.', 'blue');
  
  return { score, issues };
}

function checkPerformance(htmlPath) {
  log('\n⚡ 성능 체크', 'cyan');
  log('='.repeat(50), 'cyan');
  
  if (!existsSync(htmlPath)) {
    return { score: 0, issues: [] };
  }
  
  const html = readFileSync(htmlPath, 'utf-8');
  const issues = [];
  let score = 100;
  
  // 폰트 preconnect 체크
  const preconnect = html.match(/<link\s+rel=["']preconnect["']/gi);
  if (!preconnect || preconnect.length < 2) {
    issues.push('⚠️  폰트 리소스에 대한 preconnect가 부족합니다.');
    score -= 5;
  } else {
    log(`✅ Preconnect: ${preconnect.length}개`, 'green');
  }
  
  // DNS prefetch 체크
  const dnsPrefetch = html.match(/<link\s+rel=["']dns-prefetch["']/gi);
  if (!dnsPrefetch) {
    issues.push('⚠️  DNS prefetch가 없습니다.');
    score -= 5;
  } else {
    log(`✅ DNS prefetch: ${dnsPrefetch.length}개`, 'green');
  }
  
  if (issues.length > 0) {
    log('\n발견된 문제:', 'yellow');
    issues.forEach(issue => log(`  ${issue}`, 'yellow'));
  }
  
  return { score: Math.max(0, score), issues };
}

function checkAccessibility(htmlPath) {
  log('\n♿ 접근성 체크', 'cyan');
  log('='.repeat(50), 'cyan');
  
  if (!existsSync(htmlPath)) {
    return { score: 0, issues: [] };
  }
  
  const html = readFileSync(htmlPath, 'utf-8');
  const issues = [];
  let score = 100;
  
  // Lang 속성 체크
  const lang = html.match(/<html[^>]*\s+lang=["']([^"']+)["']/i);
  if (!lang) {
    issues.push('❌ HTML lang 속성이 없습니다.');
    score -= 10;
  } else {
    log(`✅ Lang 속성: ${lang[1]}`, 'green');
  }
  
  // Viewport 체크
  const viewport = html.match(/<meta\s+name=["']viewport["']/i);
  if (!viewport) {
    issues.push('❌ Viewport 메타 태그가 없습니다.');
    score -= 10;
  } else {
    log('✅ Viewport 메타 태그 있음', 'green');
  }
  
  if (issues.length > 0) {
    log('\n발견된 문제:', 'yellow');
    issues.forEach(issue => log(`  ${issue}`, 'yellow'));
  }
  
  return { score: Math.max(0, score), issues };
}

async function main() {
  // 인자 파싱: URL과 플래그 분리
  const args = process.argv.slice(2);
  const urlArg = args.find(arg => !arg.startsWith('--') && arg.startsWith('http'));
  const url = urlArg || 'http://localhost:4173';
  const runLighthouse = args.includes('--lighthouse');
  
  const htmlPath = join(rootDir, 'index.html');
  
  log('\n🚀 종합 SEO 체크', 'bright');
  log('='.repeat(50), 'bright');
  log(`URL: ${url}`, 'blue');
  log(`HTML: ${htmlPath}`, 'blue');
  
  const results = {
    metaTags: checkMetaTags(htmlPath),
    images: checkImages(htmlPath),
    performance: checkPerformance(htmlPath),
    accessibility: checkAccessibility(htmlPath),
  };
  
  // Lighthouse 실행 (선택사항)
  if (runLighthouse) {
    try {
      log('\n🔍 Lighthouse 실행 중...', 'cyan');
      log('⚠️  서버가 실행 중인지 확인하세요: npm run preview', 'yellow');
      execSync(`npm run check:seo ${url}`, { stdio: 'inherit', cwd: rootDir });
    } catch (error) {
      log('⚠️  Lighthouse 실행 실패', 'yellow');
      log('   서버가 실행 중인지 확인하세요: npm run preview', 'yellow');
      log('   또는 URL을 직접 지정하세요: npm run check:seo:all http://localhost:4173', 'yellow');
    }
  }
  
  // 최종 점수 계산
  const totalScore = Math.round(
    (results.metaTags.score * 0.4 +
     results.images.score * 0.1 +
     results.performance.score * 0.2 +
     results.accessibility.score * 0.3)
  );
  
  log('\n📊 최종 SEO 점수', 'bright');
  log('='.repeat(50), 'bright');
  log(`메타 태그: ${results.metaTags.score}/100`, results.metaTags.score >= 80 ? 'green' : 'yellow');
  log(`이미지: ${results.images.score}/100`, results.images.score >= 80 ? 'green' : 'yellow');
  log(`성능: ${results.performance.score}/100`, results.performance.score >= 80 ? 'green' : 'yellow');
  log(`접근성: ${results.accessibility.score}/100`, results.accessibility.score >= 80 ? 'green' : 'yellow');
  log(`\n총점: ${totalScore}/100`, totalScore >= 80 ? 'green' : totalScore >= 60 ? 'yellow' : 'red');
  
  log('\n💡 개선 사항:', 'cyan');
  const allIssues = [
    ...results.metaTags.issues,
    ...results.images.issues,
    ...results.performance.issues,
    ...results.accessibility.issues,
  ];
  
  if (allIssues.length === 0) {
    log('  ✅ 모든 체크를 통과했습니다!', 'green');
  } else {
    allIssues.forEach(issue => log(`  ${issue}`, 'yellow'));
  }
  
  log('\n✅ SEO 체크 완료!', 'green');
  log('\n사용법:', 'blue');
  log('  npm run check:seo:full              # 기본 체크', 'blue');
  log('  npm run check:seo:full --lighthouse # Lighthouse 포함', 'blue');
}

main().catch(console.error);

