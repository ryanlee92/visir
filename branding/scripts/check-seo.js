import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';
import { readFileSync, existsSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const projectRoot = join(__dirname, '..');

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

async function runSEOAudit(url = 'http://localhost:4173') {
  log('\n🔍 SEO 감사 실행 중...', 'cyan');
  log('='.repeat(50), 'cyan');

  let chrome;
  try {
    // Chrome 실행
    chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
    const options = {
      logLevel: 'info',
      output: 'json',
      onlyCategories: ['seo'],
      port: chrome.port,
    };

    log(`\n측정 URL: ${url}`, 'blue');
    log('Lighthouse 실행 중...', 'blue');

    const runnerResult = await lighthouse(url, options);
    const report = runnerResult.lhr;

    // SEO 점수 추출
    const seoScore = Math.round(report.categories.seo.score * 100);
    const color = seoScore >= 90 ? 'green' : seoScore >= 70 ? 'yellow' : 'red';
    log(`\n📊 SEO 점수: ${seoScore}/100`, color);

    // SEO 감사 결과 추출
    const audits = report.audits;
    const seoAudits = Object.values(audits).filter(audit => 
      audit.details && audit.details.type === 'table' && 
      audit.category === 'seo'
    );

    // 문제점 추출
    const opportunities = [];
    const warnings = [];
    const passed = [];

    Object.values(audits).forEach(audit => {
      if (audit.score === null) return;
      
      const score = Math.round(audit.score * 100);
      const item = {
        id: audit.id,
        title: audit.title,
        description: audit.description,
        score,
        displayValue: audit.displayValue,
      };

      if (score < 1) {
        opportunities.push(item);
      } else if (score < 0.9) {
        warnings.push(item);
      } else {
        passed.push(item);
      }
    });

    // 결과 출력
    log('\n📋 SEO 감사 결과:', 'bright');
    
    if (opportunities.length > 0) {
      log(`\n❌ 개선 필요 (${opportunities.length}개):`, 'red');
      opportunities.forEach(item => {
        log(`  - ${item.title}`, 'red');
        log(`    ${item.description}`, 'yellow');
        if (item.displayValue) {
          log(`    현재: ${item.displayValue}`, 'yellow');
        }
      });
    }

    if (warnings.length > 0) {
      log(`\n⚠️  주의 필요 (${warnings.length}개):`, 'yellow');
      warnings.forEach(item => {
        log(`  - ${item.title}`, 'yellow');
        log(`    ${item.description}`, 'reset');
      });
    }

    if (passed.length > 0) {
      log(`\n✅ 통과 (${passed.length}개):`, 'green');
      passed.slice(0, 5).forEach(item => {
        log(`  - ${item.title}`, 'green');
      });
      if (passed.length > 5) {
        log(`  ... 외 ${passed.length - 5}개`, 'green');
      }
    }

    // 주요 문제점 분석
    log('\n🎯 주요 개선 사항:', 'bright');
    
    const criticalIssues = [];
    
    // 메타 태그 관련
    if (audits['meta-description'] && audits['meta-description'].score < 1) {
      criticalIssues.push({
        type: 'meta-description',
        issue: '메타 설명이 없거나 최적화되지 않음',
        fix: 'index.html과 seo.ts의 description 확인',
      });
    }

    if (audits['document-title'] && audits['document-title'].score < 1) {
      criticalIssues.push({
        type: 'document-title',
        issue: '문서 제목이 없거나 최적화되지 않음',
        fix: 'index.html과 seo.ts의 title 확인',
      });
    }

    // 링크 관련
    if (audits['link-text'] && audits['link-text'].score < 1) {
      criticalIssues.push({
        type: 'link-text',
        issue: '링크 텍스트가 명확하지 않음',
        fix: '모든 링크에 명확한 텍스트 추가',
      });
    }

    // 이미지 관련
    if (audits['image-alt'] && audits['image-alt'].score < 1) {
      criticalIssues.push({
        type: 'image-alt',
        issue: '이미지에 alt 속성이 없음',
        fix: '모든 이미지에 alt 속성 추가',
      });
    }

    // 구조화된 데이터 (수동 감사 항목이므로 score가 null일 수 있음)
    const structuredDataAudit = audits['structured-data'];
    if (structuredDataAudit) {
      // 구조화된 데이터가 있는지 확인
      const hasStructuredData = structuredDataAudit.details?.items?.length > 0 || 
                                 structuredDataAudit.details?.type === 'table';
      
      if (!hasStructuredData && structuredDataAudit.score === null) {
        // 수동 감사 항목이므로 경고만 표시
        log(`\n  ⚠️  구조화된 데이터는 수동으로 확인해야 합니다`, 'yellow');
        log(`     Google Structured Data Testing Tool 사용: https://search.google.com/test/rich-results`, 'yellow');
        log(`     Schema.org Validator 사용: https://validator.schema.org/`, 'yellow');
      }
    }

    // 언어 설정
    if (audits['html-lang'] && audits['html-lang'].score < 1) {
      criticalIssues.push({
        type: 'html-lang',
        issue: 'HTML lang 속성이 없거나 잘못됨',
        fix: 'index.html의 <html lang="en"> 확인',
      });
    }

    // 폰트 크기
    if (audits['font-size'] && audits['font-size'].score < 1) {
      criticalIssues.push({
        type: 'font-size',
        issue: '텍스트 크기가 너무 작음',
        fix: 'CSS에서 최소 폰트 크기 12px 이상 확인',
      });
    }

    // 탭 순서
    if (audits['tap-targets'] && audits['tap-targets'].score < 1) {
      criticalIssues.push({
        type: 'tap-targets',
        issue: '터치 타겟이 너무 작음',
        fix: '모바일 버튼 크기 최소 48x48px 확인',
      });
    }

    criticalIssues.forEach(issue => {
      log(`\n  🔴 ${issue.issue}`, 'red');
      log(`     해결: ${issue.fix}`, 'yellow');
    });

    // 리포트 저장
    const reportPath = join(projectRoot, 'lighthouse-seo-report.json');
    writeFileSync(reportPath, JSON.stringify(report, null, 2));
    log(`\n📄 상세 리포트 저장: ${reportPath}`, 'blue');

    return {
      score: seoScore,
      opportunities,
      warnings,
      passed,
      criticalIssues,
    };
  } catch (error) {
    log(`\n❌ 오류 발생: ${error.message}`, 'red');
    return null;
  } finally {
    if (chrome) {
      await chrome.kill();
    }
  }
}

async function main() {
  const url = process.argv[2] || 'http://localhost:4173';
  
  log('\n🚀 SEO 점수 체크', 'bright');
  log('='.repeat(50), 'bright');
  
  const result = await runSEOAudit(url);
  
  if (result) {
    log('\n✅ SEO 감사 완료!', 'green');
    log('\n다음 단계:', 'bright');
    log('  1. 위의 개선 사항을 확인하세요', 'blue');
    log('  2. 코드를 수정하세요', 'blue');
    log('  3. 다시 실행하여 점수가 개선되었는지 확인하세요', 'blue');
  }
}

main().catch(error => {
  log(`\n❌ 오류 발생: ${error.message}`, 'red');
  process.exit(1);
});

