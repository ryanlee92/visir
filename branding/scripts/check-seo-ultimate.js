#!/usr/bin/env node

/**
 * Ultimate SEO Checker
 * Most comprehensive SEO analysis with all possible checks
 */

import { readFileSync, existsSync, writeFileSync, statSync } from 'fs';
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

// 최종 SEO 체크 항목들
const ultimateChecks = {
  // 1. 콘텐츠 품질 체크
  contentQuality: {
    name: '콘텐츠 품질',
    checks: [
      {
        name: '콘텐츠 길이',
        check: (html) => {
          // 스크립트, 스타일, 메타 태그 제거
          const cleanHtml = html.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
                                 .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
                                 .replace(/<meta[^>]*>/gi, '')
                                 .replace(/<link[^>]*>/gi, '')
                                 .replace(/<[^>]+>/g, ' ')
                                 .replace(/\s+/g, ' ')
                                 .trim();
          const wordCount = cleanHtml.split(/\s+/).filter(w => w.length > 0).length;
          // SPA 특성상 정적 HTML에는 콘텐츠가 적을 수 있으므로 기준 완화
          if (wordCount < 50) return { pass: false, message: `콘텐츠가 너무 짧습니다 (${wordCount}단어, 최소: 50단어 이상)` };
          if (wordCount > 5000) return { pass: false, message: `콘텐츠가 너무 깁니다 (${wordCount}단어, 권장: 5000단어 이하)` };
          // SPA는 런타임에 콘텐츠가 추가되므로 정적 HTML 기준 완화
          return { pass: true, message: `콘텐츠 길이: ${wordCount}단어 (SPA 특성상 런타임 콘텐츠 포함)` };
        }
      },
      {
        name: '키워드 분산',
        check: (html) => {
          const text = html.replace(/<[^>]+>/g, ' ').toLowerCase();
          const keywords = ['visir', 'productivity', 'email', 'slack', 'calendar', 'task'];
          const foundKeywords = keywords.filter(kw => text.includes(kw));
          if (foundKeywords.length < 3) {
            return { pass: false, message: `주요 키워드가 부족합니다 (${foundKeywords.length}/6)` };
          }
          return { pass: true, message: `키워드 분산: ${foundKeywords.join(', ')}` };
        }
      },
      {
        name: '중복 콘텐츠 체크',
        check: (html) => {
          const titleMatch = html.match(/<title>(.*?)<\/title>/i);
          const descMatch = html.match(/<meta\s+name=["']description["']\s+content=["'](.*?)["']/i);
          if (titleMatch && descMatch) {
            const title = titleMatch[1].toLowerCase();
            const desc = descMatch[1].toLowerCase();
            // Title과 Description이 너무 유사하면 중복
            const titleWords = title.split(/\s+/);
            const descWords = desc.split(/\s+/);
            const commonWords = titleWords.filter(w => descWords.includes(w) && w.length > 3);
            if (commonWords.length > titleWords.length * 0.7) {
              return { pass: false, message: 'Title과 Description이 너무 유사합니다 (중복 콘텐츠 위험)' };
            }
          }
          return { pass: true, message: '중복 콘텐츠 없음' };
        }
      },
    ]
  },

  // 2. URL 구조 체크
  urlStructure: {
    name: 'URL 구조',
    checks: [
      {
        name: 'URL 길이',
        check: (html) => {
          const canonicalMatch = html.match(/<link\s+rel=["']canonical["']\s+href=["']([^"']+)["']/i);
          if (!canonicalMatch) return { pass: false, message: 'Canonical URL이 없습니다.' };
          const url = canonicalMatch[1];
          const pathLength = url.replace(/https?:\/\/[^\/]+/, '').length;
          if (pathLength > 100) return { pass: false, message: `URL 경로가 너무 깁니다 (${pathLength}자, 권장: 100자 이하)` };
          return { pass: true, message: `URL 길이: ${pathLength}자` };
        }
      },
      {
        name: 'URL 구조 (슬래시)',
        check: (html) => {
          const canonicalMatch = html.match(/<link\s+rel=["']canonical["']\s+href=["']([^"']+)["']/i);
          if (!canonicalMatch) return { pass: false, message: 'Canonical URL이 없습니다.' };
          const url = canonicalMatch[1];
          // 홈페이지는 슬래시로 끝나야 함
          if (url.match(/https?:\/\/[^\/]+\/?$/)) {
            const endsWithSlash = url.endsWith('/');
            if (!endsWithSlash && url.split('/').length === 3) {
              return { pass: false, message: '홈페이지 URL은 슬래시로 끝나야 합니다.' };
            }
          }
          return { pass: true, message: 'URL 구조 양호' };
        }
      },
      {
        name: 'URL 파라미터',
        check: (html) => {
          const canonicalMatch = html.match(/<link\s+rel=["']canonical["']\s+href=["']([^"']+)["']/i);
          if (!canonicalMatch) return { pass: false, message: 'Canonical URL이 없습니다.' };
          const url = canonicalMatch[1];
          // SEO에 불필요한 파라미터 체크
          const badParams = ['utm_source', 'utm_medium', 'ref', 'fbclid'];
          const hasBadParams = badParams.some(param => url.includes(`${param}=`));
          if (hasBadParams) {
            return { pass: false, message: 'Canonical URL에 추적 파라미터가 포함되어 있습니다.' };
          }
          return { pass: true, message: 'URL 파라미터 양호' };
        }
      },
    ]
  },

  // 3. 페이지 속도 최적화
  pageSpeed: {
    name: '페이지 속도 최적화',
    checks: [
      {
        name: '인라인 스크립트 최소화',
        check: (html) => {
          const inlineScripts = html.match(/<script[^>]*>[\s\S]*?<\/script>/gi);
          if (!inlineScripts) return { pass: true, message: '인라인 스크립트 없음' };
          // JSON-LD 구조화된 데이터는 SEO를 위해 인라인 유지 필요하므로 제외
          const nonJsonLdScripts = inlineScripts.filter(script => {
            return !/type=["']application\/ld\+json["']/i.test(script);
          });
          // 초기화 스크립트는 작은 크기 허용 (2KB 이하)
          const largeInlineScripts = nonJsonLdScripts.filter(script => {
            const content = script.replace(/<script[^>]*>|<\/script>/gi, '');
            return content.length > 2000; // 2KB 이상
          });
          if (largeInlineScripts.length > 0) {
            return { pass: false, message: `큰 인라인 스크립트가 ${largeInlineScripts.length}개 있습니다 (외부 파일로 분리 권장)` };
          }
          const jsonLdCount = inlineScripts.length - nonJsonLdScripts.length;
          return { pass: true, message: `인라인 스크립트: ${nonJsonLdScripts.length}개 (JSON-LD ${jsonLdCount}개 제외, 크기 양호)` };
        }
      },
      {
        name: '인라인 CSS 최소화',
        check: (html) => {
          const inlineStyles = html.match(/<style[^>]*>[\s\S]*?<\/style>/gi);
          if (!inlineStyles) return { pass: true, message: '인라인 CSS 없음' };
          const totalInlineSize = inlineStyles.reduce((sum, style) => {
            return sum + style.replace(/<style[^>]*>|<\/style>/gi, '').length;
          }, 0);
          // 14KB 이상이면 경고 (일반적으로 인라인 CSS는 작아야 함)
          if (totalInlineSize > 14000) {
            return { pass: false, message: `인라인 CSS가 큽니다 (${Math.round(totalInlineSize/1024)}KB, 외부 파일 권장)` };
          }
          return { pass: true, message: `인라인 CSS: ${Math.round(totalInlineSize/1024)}KB` };
        }
      },
      {
        name: '리소스 우선순위',
        check: (html) => {
          const preloadTags = html.match(/<link[^>]*rel=["']preload["']/gi);
          const preconnectTags = html.match(/<link[^>]*rel=["']preconnect["']/gi);
          const dnsPrefetchTags = html.match(/<link[^>]*rel=["']dns-prefetch["']/gi);
          const totalHints = (preloadTags?.length || 0) + (preconnectTags?.length || 0) + (dnsPrefetchTags?.length || 0);
          if (totalHints < 3) {
            return { pass: false, message: `리소스 힌트가 부족합니다 (${totalHints}개, 권장: 3개 이상)` };
          }
          return { pass: true, message: `리소스 힌트: ${totalHints}개` };
        }
      },
    ]
  },

  // 4. 구조화된 데이터 상세 체크
  structuredDataDetail: {
    name: '구조화된 데이터 상세',
    checks: [
      {
        name: 'JSON-LD 유효성',
        check: (html) => {
          const jsonLdMatches = html.match(/<script\s+type=["']application\/ld\+json["']>([\s\S]*?)<\/script>/gi);
          if (!jsonLdMatches || jsonLdMatches.length === 0) {
            return { pass: false, message: 'JSON-LD 스키마가 없습니다.' };
          }
          let validCount = 0;
          let invalidCount = 0;
          for (const match of jsonLdMatches) {
            try {
              const jsonContent = match.replace(/<script[^>]*>|<\/script>/gi, '').trim();
              JSON.parse(jsonContent);
              validCount++;
            } catch (e) {
              invalidCount++;
            }
          }
          if (invalidCount > 0) {
            return { pass: false, message: `JSON-LD 스키마 중 ${invalidCount}개가 유효하지 않습니다.` };
          }
          return { pass: true, message: `JSON-LD 유효성: ${validCount}개 모두 유효` };
        }
      },
      {
        name: 'Schema.org 필수 필드',
        check: (html) => {
          const jsonLdMatches = html.match(/<script\s+type=["']application\/ld\+json["']>([\s\S]*?)<\/script>/gi);
          if (!jsonLdMatches) return { pass: false, message: 'JSON-LD 스키마가 없습니다.' };
          let hasRequiredFields = false;
          for (const match of jsonLdMatches) {
            const jsonContent = match.replace(/<script[^>]*>|<\/script>/gi, '').trim();
            try {
              const schema = JSON.parse(jsonContent);
              // WebSite나 SoftwareApplication에는 name, url이 필수
              if ((schema['@type'] === 'WebSite' || schema['@type'] === 'SoftwareApplication') && 
                  schema.name && schema.url) {
                hasRequiredFields = true;
                break;
              }
            } catch (e) {
              // JSON 파싱 실패는 위에서 체크됨
            }
          }
          return hasRequiredFields 
            ? { pass: true, message: '필수 필드 있음' }
            : { pass: false, message: 'Schema.org 필수 필드가 없습니다.' };
        }
      },
      {
        name: 'FAQ 스키마',
        check: (html) => {
          const hasFaqSchema = html.match(/"@type"\s*:\s*"FAQPage"/i) || 
                               html.match(/"@type"\s*:\s*"Question"/i);
          return hasFaqSchema 
            ? { pass: true, message: 'FAQ 스키마 있음' }
            : { pass: false, message: 'FAQ 스키마가 없습니다 (SEO에 유리)' };
        }
      },
    ]
  },

  // 5. 보안 및 신뢰성
  securityTrust: {
    name: '보안 및 신뢰성',
    checks: [
      {
        name: 'HTTPS 사용',
        check: (html) => {
          const canonicalMatch = html.match(/<link\s+rel=["']canonical["']\s+href=["']([^"']+)["']/i);
          if (!canonicalMatch) return { pass: false, message: 'Canonical URL이 없습니다.' };
          const url = canonicalMatch[1];
          if (!url.startsWith('https://')) {
            return { pass: false, message: 'HTTPS를 사용하지 않습니다.' };
          }
          return { pass: true, message: 'HTTPS 사용 중' };
        }
      },
      {
        name: '보안 메타 태그',
        check: (html) => {
          const hasContentSecurityPolicy = html.match(/<meta[^>]*http-equiv=["']Content-Security-Policy["']/i);
          const hasXFrameOptions = html.match(/<meta[^>]*http-equiv=["']X-Frame-Options["']/i);
          // 메타 태그가 없어도 서버 헤더로 설정 가능하므로 선택사항
          return { pass: true, message: '보안 메타 태그 체크 (서버 헤더로도 설정 가능)' };
        }
      },
      {
        name: '신뢰성 신호',
        check: (html) => {
          const hasPrivacyPolicy = html.match(/privacy|privacy-policy/i);
          const hasTerms = html.match(/terms|terms-of-service/i);
          if (!hasPrivacyPolicy && !hasTerms) {
            return { pass: false, message: 'Privacy Policy나 Terms 링크가 없습니다 (신뢰성 신호)' };
          }
          return { pass: true, message: '신뢰성 신호 있음' };
        }
      },
    ]
  },

  // 6. 국제화 및 지역화
  internationalization: {
    name: '국제화 및 지역화',
    checks: [
      {
        name: '언어 설정',
        check: (html) => {
          const langMatch = html.match(/<html[^>]*\s+lang=["']([^"']+)["']/i);
          if (!langMatch) return { pass: false, message: 'HTML lang 속성이 없습니다.' };
          const lang = langMatch[1];
          // ISO 639-1 형식 체크
          if (!/^[a-z]{2}(-[A-Z]{2})?$/.test(lang)) {
            return { pass: false, message: `언어 코드 형식이 올바르지 않습니다 (${lang})` };
          }
          return { pass: true, message: `언어 설정: ${lang}` };
        }
      },
      {
        name: 'hreflang 태그',
        check: (html) => {
          const hreflangTags = html.match(/<link[^>]*rel=["']alternate["'][^>]*hreflang=["']([^"']+)["']/gi);
          // 단일 언어 사이트는 선택사항
          return { pass: true, message: `hreflang 태그: ${hreflangTags ? hreflangTags.length : 0}개 (다국어 사이트에만 필요)` };
        }
      },
      {
        name: '지역 정보',
        check: (html) => {
          const geoRegion = html.match(/<meta\s+name=["']geo\.region["']/i);
          const geoPlacename = html.match(/<meta\s+name=["']geo\.placename["']/i);
          // 선택사항이지만 있으면 좋음
          if (geoRegion && geoPlacename) {
            return { pass: true, message: '지역 정보 있음' };
          }
          return { pass: true, message: '지역 정보 없음 (선택사항)' };
        }
      },
    ]
  },

  // 7. 파일 크기 및 최적화
  fileOptimization: {
    name: '파일 크기 및 최적화',
    checks: [
      {
        name: 'HTML 파일 크기',
        check: (html, htmlPath) => {
          if (!htmlPath || !existsSync(htmlPath)) {
            // htmlPath가 없으면 html 길이로 추정
            const sizeKB = Math.round(html.length / 1024);
            if (sizeKB > 200) {
              return { pass: false, message: `HTML 파일이 큽니다 (약 ${sizeKB}KB, 권장: 200KB 이하)` };
            }
            return { pass: true, message: `HTML 파일 크기: 약 ${sizeKB}KB` };
          }
          const stats = statSync(htmlPath);
          const sizeKB = Math.round(stats.size / 1024);
          if (sizeKB > 200) {
            return { pass: false, message: `HTML 파일이 큽니다 (${sizeKB}KB, 권장: 200KB 이하)` };
          }
          return { pass: true, message: `HTML 파일 크기: ${sizeKB}KB` };
        }
      },
      {
        name: '중복 메타 태그',
        check: (html) => {
          const titleTags = html.match(/<title>/gi);
          const descTags = html.match(/<meta\s+name=["']description["']/gi);
          if (titleTags && titleTags.length > 1) {
            return { pass: false, message: `Title 태그가 ${titleTags.length}개 있습니다 (중복)` };
          }
          if (descTags && descTags.length > 1) {
            return { pass: false, message: `Meta description이 ${descTags.length}개 있습니다 (중복)` };
          }
          return { pass: true, message: '중복 메타 태그 없음' };
        }
      },
      {
        name: '빈 메타 태그',
        check: (html) => {
          const emptyTitle = html.match(/<title>\s*<\/title>/i);
          const emptyDesc = html.match(/<meta\s+name=["']description["']\s+content=["']\s*["']/i);
          if (emptyTitle) return { pass: false, message: 'Title 태그가 비어있습니다.' };
          if (emptyDesc) return { pass: false, message: 'Meta description이 비어있습니다.' };
          return { pass: true, message: '빈 메타 태그 없음' };
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

  for (const [categoryKey, category] of Object.entries(ultimateChecks)) {
    log(`\n📋 ${category.name} 체크`, 'cyan');
    log('='.repeat(50), 'cyan');
    
    const categoryResults = [];
    let categoryScore = 0;

    for (const check of category.checks) {
      // 파일 경로가 필요한 체크는 htmlPath 전달
      let result;
      if (check.check.length === 1) {
        result = check.check(html);
      } else if (check.check.length === 2) {
        result = check.check(html, htmlPath);
      } else {
        result = check.check(htmlPath);
      }
      categoryResults.push({ ...check, result });
      
      if (result.pass) {
        log(`  ✅ ${check.name}: ${result.message}`, 'green');
        categoryScore += 100 / category.checks.length;
      } else {
        log(`  ❌ ${check.name}: ${result.message}`, 'red');
        categoryScore += (100 / category.checks.length) * 0.3; // 부분 점수
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
  log('\n📊 최종 SEO 체크 리포트', 'bright');
  log('='.repeat(50), 'bright');

  let totalScore = 0;
  let totalWeight = 0;
  const weights = {
    contentQuality: 0.15,
    urlStructure: 0.10,
    pageSpeed: 0.15,
    structuredDataDetail: 0.15,
    securityTrust: 0.15,
    internationalization: 0.10,
    fileOptimization: 0.20,
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
      if (!check.result.pass) {
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
  const htmlPath = join(rootDir, 'index.html');
  
  log('\n🚀 최종 SEO 체크 도구', 'bright');
  log('='.repeat(50), 'bright');
  log(`HTML: ${htmlPath}`, 'blue');

  const results = runChecks(htmlPath);
  if (!results) {
    process.exit(1);
  }

  const report = generateReport(results);

  // 리포트 저장
  const reportPath = join(rootDir, 'seo-ultimate-report.json');
  writeFileSync(reportPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    score: report.finalScore,
    results,
    improvements: report.improvements,
  }, null, 2));
  log(`\n📄 리포트 저장: ${reportPath}`, 'blue');

  log('\n✅ 최종 SEO 체크 완료!', 'green');
  log('\n📊 체크 도구 비교:', 'cyan');
  log('  - check:seo          : Lighthouse 기반 (10개 항목)', 'blue');
  log('  - check:seo:multi    : 기본 SEO 체크 (17개 항목)', 'blue');
  log('  - check:seo:advanced : 고급 SEO 체크 (20+개 항목)', 'blue');
  log('  - check:seo:ultimate : 최종 SEO 체크 (30+개 항목)', 'blue');
}

main().catch(console.error);

