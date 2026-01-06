#!/usr/bin/env node

/**
 * Advanced SEO Checker
 * Comprehensive SEO analysis with additional checks
 */

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

// 고급 SEO 체크 항목들
const advancedChecks = {
  // 1. 콘텐츠 구조 체크
  contentStructure: {
    name: '콘텐츠 구조',
    checks: [
      {
        name: 'H1 태그',
        check: (html) => {
          const h1Matches = html.match(/<h1[^>]*>.*?<\/h1>/gi);
          const count = h1Matches ? h1Matches.length : 0;
          if (count === 0) return { pass: false, message: 'H1 태그가 없습니다.' };
          if (count > 1) return { pass: false, message: `H1 태그가 ${count}개입니다 (권장: 1개)` };
          return { pass: true, message: 'H1 태그: 1개' };
        }
      },
      {
        name: 'H2-H6 태그 구조',
        check: (html) => {
          const h2Matches = html.match(/<h2[^>]*>/gi);
          const h3Matches = html.match(/<h3[^>]*>/gi);
          const h2Count = h2Matches ? h2Matches.length : 0;
          const h3Count = h3Matches ? h3Matches.length : 0;
          if (h2Count === 0 && h3Count === 0) return { pass: false, message: 'H2-H6 태그가 없습니다 (콘텐츠 구조화 필요)' };
          return { pass: true, message: `H2: ${h2Count}개, H3: ${h3Count}개` };
        }
      },
      {
        name: '키워드 밀도 (Title)',
        check: (html) => {
          const titleMatch = html.match(/<title>(.*?)<\/title>/i);
          if (!titleMatch) return { pass: false, message: 'Title 태그가 없습니다.' };
          const title = titleMatch[1].toLowerCase();
          const keywords = ['visir', 'productivity', 'email', 'slack', 'calendar', 'task'];
          const foundKeywords = keywords.filter(kw => title.includes(kw));
          if (foundKeywords.length === 0) return { pass: false, message: 'Title에 주요 키워드가 없습니다.' };
          return { pass: true, message: `주요 키워드: ${foundKeywords.join(', ')}` };
        }
      },
      {
        name: '키워드 밀도 (Description)',
        check: (html) => {
          const descMatch = html.match(/<meta\s+name=["']description["']\s+content=["'](.*?)["']/i);
          if (!descMatch) return { pass: false, message: 'Meta description이 없습니다.' };
          const desc = descMatch[1].toLowerCase();
          const keywords = ['visir', 'productivity', 'email', 'slack', 'calendar'];
          const foundKeywords = keywords.filter(kw => desc.includes(kw));
          if (foundKeywords.length < 2) return { pass: false, message: 'Description에 주요 키워드가 부족합니다.' };
          return { pass: true, message: `주요 키워드: ${foundKeywords.join(', ')}` };
        }
      },
    ]
  },

  // 2. 링크 최적화 체크
  linkOptimization: {
    name: '링크 최적화',
    checks: [
      {
        name: '내부 링크 구조',
        check: (html) => {
          const internalLinks = html.match(/href=["']\/(?!\/)[^"']+["']/gi);
          const count = internalLinks ? internalLinks.length : 0;
          if (count === 0) return { pass: false, message: '내부 링크가 없습니다.' };
          if (count < 5) return { pass: false, message: `내부 링크가 부족합니다 (${count}개, 권장: 5개 이상)` };
          return { pass: true, message: `내부 링크: ${count}개` };
        }
      },
      {
        name: '외부 링크 보안',
        check: (html) => {
          // <a> 태그의 외부 링크만 체크 (구조화된 데이터 제외)
          const anchorTags = html.match(/<a[^>]*href=["']https?:\/\/(?!visir\.pro|fonts\.googleapis|fonts\.gstatic|cdn\.jsdelivr)[^"']+["'][^>]*>/gi);
          if (!anchorTags || anchorTags.length === 0) return { pass: true, message: '외부 링크 없음' };
          const linksWithNoopener = anchorTags.filter(link => /rel=["'][^"']*noopener[^"']*["']/i.test(link));
          const totalExternal = anchorTags.length;
          if (linksWithNoopener.length < totalExternal) {
            return { pass: false, message: `외부 링크 중 ${totalExternal - linksWithNoopener.length}개에 rel="noopener"가 없습니다.` };
          }
          return { pass: true, message: `외부 링크 보안: ${linksWithNoopener.length}/${totalExternal}` };
        }
      },
      {
        name: '앵커 텍스트 품질',
        check: (html) => {
          // href가 있는 <a> 태그만 체크
          const links = html.match(/<a[^>]*href=["'][^"']+["'][^>]*>.*?<\/a>/gi);
          if (!links || links.length === 0) {
            // 구조화된 데이터나 다른 형태의 링크가 있을 수 있으므로 경고만
            return { pass: true, message: '앵커 링크 없음 (SPA이므로 정상일 수 있음)' };
          }
          const badAnchors = links.filter(link => {
            const text = link.replace(/<[^>]+>/g, '').trim();
            return text === '' || text === 'click here' || text === 'here' || text === 'read more' || text.length < 3;
          });
          if (badAnchors.length > 0) {
            return { pass: false, message: `명확하지 않은 앵커 텍스트: ${badAnchors.length}개` };
          }
          return { pass: true, message: `앵커 텍스트 품질: 양호 (${links.length}개 링크)` };
        }
      },
    ]
  },

  // 3. 이미지 최적화 체크
  imageOptimization: {
    name: '이미지 최적화',
    checks: [
      {
        name: '이미지 Alt 속성',
        check: (html) => {
          const images = html.match(/<img[^>]*>/gi);
          if (!images || images.length === 0) return { pass: true, message: '이미지 없음' };
          const imagesWithAlt = images.filter(img => /alt=["'][^"']+["']/i.test(img));
          const totalImages = images.length;
          if (imagesWithAlt.length < totalImages) {
            return { pass: false, message: `이미지 중 ${totalImages - imagesWithAlt.length}개에 alt 속성이 없습니다.` };
          }
          return { pass: true, message: `이미지 alt 속성: ${imagesWithAlt.length}/${totalImages}` };
        }
      },
      {
        name: '이미지 Lazy Loading',
        check: (html) => {
          const images = html.match(/<img[^>]*>/gi);
          if (!images || images.length === 0) return { pass: true, message: '이미지 없음' };
          const lazyImages = images.filter(img => /loading=["']lazy["']/i.test(img));
          const totalImages = images.length;
          // 첫 번째 이미지는 eager일 수 있으므로 80% 이상 lazy면 통과
          if (lazyImages.length < totalImages * 0.8) {
            return { pass: false, message: `이미지 중 ${totalImages - lazyImages.length}개에 lazy loading이 없습니다.` };
          }
          return { pass: true, message: `Lazy loading: ${lazyImages.length}/${totalImages}` };
        }
      },
      {
        name: '이미지 포맷 최적화',
        check: (html) => {
          // <img> 태그의 이미지만 체크 (favicon 제외)
          const imgTags = html.match(/<img[^>]*src=["']([^"']+)["']/gi);
          if (!imgTags || imgTags.length === 0) return { pass: true, message: '이미지 없음' };
          // favicon은 PNG가 정상이므로 제외
          const contentImages = imgTags.filter(img => !/favicon|icon|logo.*\.png/i.test(img));
          if (contentImages.length === 0) return { pass: true, message: '콘텐츠 이미지 없음 (favicon만 있음)' };
          const modernFormats = contentImages.filter(img => /\.(webp|avif|svg)/i.test(img));
          const totalImages = contentImages.length;
          if (modernFormats.length < totalImages * 0.5) {
            return { pass: false, message: `콘텐츠 이미지 중 ${totalImages - modernFormats.length}개가 최신 포맷이 아닙니다 (WebP/AVIF 권장)` };
          }
          return { pass: true, message: `최신 포맷: ${modernFormats.length}/${totalImages}` };
        }
      },
    ]
  },

  // 4. 모바일 최적화 체크
  mobileOptimization: {
    name: '모바일 최적화',
    checks: [
      {
        name: 'Viewport 설정',
        check: (html) => {
          const viewport = html.match(/<meta\s+name=["']viewport["']\s+content=["']([^"']+)["']/i);
          if (!viewport) return { pass: false, message: 'Viewport 메타 태그가 없습니다.' };
          const content = viewport[1];
          if (!content.includes('width=device-width')) {
            return { pass: false, message: 'Viewport에 width=device-width가 없습니다.' };
          }
          return { pass: true, message: 'Viewport 설정 완료' };
        }
      },
      {
        name: '터치 아이콘',
        check: (html) => {
          const appleTouchIcon = html.match(/<link[^>]*rel=["']apple-touch-icon["']/i);
          return appleTouchIcon 
            ? { pass: true, message: 'Apple Touch Icon 있음' }
            : { pass: false, message: 'Apple Touch Icon이 없습니다.' };
        }
      },
      {
        name: '모바일 웹앱 메타 태그',
        check: (html) => {
          const mobileWebApp = html.match(/<meta\s+name=["']apple-mobile-web-app-capable["']/i);
          return mobileWebApp 
            ? { pass: true, message: '모바일 웹앱 메타 태그 있음' }
            : { pass: false, message: '모바일 웹앱 메타 태그가 없습니다.' };
        }
      },
    ]
  },

  // 5. 기술적 SEO 체크
  technicalSEO: {
    name: '기술적 SEO',
    checks: [
      {
        name: 'XML Sitemap',
        check: (html) => {
          const sitemapLink = html.match(/<link[^>]*rel=["']sitemap["']/i);
          const robotsTxt = existsSync(join(rootDir, 'public', 'robots.txt'));
          const sitemapXml = existsSync(join(rootDir, 'public', 'sitemap.xml'));
          if (sitemapXml) return { pass: true, message: 'sitemap.xml 파일 있음' };
          return { pass: false, message: 'sitemap.xml 파일이 없습니다.' };
        }
      },
      {
        name: 'Robots.txt',
        check: (html) => {
          const robotsTxt = existsSync(join(rootDir, 'public', 'robots.txt'));
          return robotsTxt 
            ? { pass: true, message: 'robots.txt 파일 있음' }
            : { pass: false, message: 'robots.txt 파일이 없습니다.' };
        }
      },
      {
        name: 'Favicon 설정',
        check: (html) => {
          const favicon = html.match(/<link[^>]*rel=["'](icon|shortcut icon)["']/i);
          return favicon 
            ? { pass: true, message: 'Favicon 설정 완료' }
            : { pass: false, message: 'Favicon이 설정되지 않았습니다.' };
        }
      },
      {
        name: '언어 설정',
        check: (html) => {
          const lang = html.match(/<html[^>]*\s+lang=["']([^"']+)["']/i);
          if (!lang) return { pass: false, message: 'HTML lang 속성이 없습니다.' };
          return { pass: true, message: `Lang: ${lang[1]}` };
        }
      },
    ]
  },

  // 6. 소셜 미디어 최적화
  socialMedia: {
    name: '소셜 미디어 최적화',
    checks: [
      {
        name: 'Open Graph 완전성',
        check: (html) => {
          const required = ['og:title', 'og:description', 'og:image', 'og:url', 'og:type'];
          const found = required.filter(tag => html.match(new RegExp(`<meta\\s+property=["']${tag}["']`, 'i')));
          if (found.length < required.length) {
            return { pass: false, message: `Open Graph 태그 불완전 (${found.length}/${required.length})` };
          }
          return { pass: true, message: `Open Graph 태그 완료 (${found.length}/${required.length})` };
        }
      },
      {
        name: 'Twitter Card 완전성',
        check: (html) => {
          const required = ['twitter:card', 'twitter:title', 'twitter:description', 'twitter:image'];
          const found = required.filter(tag => html.match(new RegExp(`<meta\\s+name=["']${tag}["']`, 'i')));
          if (found.length < required.length) {
            return { pass: false, message: `Twitter Card 태그 불완전 (${found.length}/${required.length})` };
          }
          return { pass: true, message: `Twitter Card 태그 완료 (${found.length}/${required.length})` };
        }
      },
      {
        name: 'OG 이미지 크기',
        check: (html) => {
          const ogImageWidth = html.match(/<meta\s+property=["']og:image:width["']\s+content=["'](\d+)["']/i);
          const ogImageHeight = html.match(/<meta\s+property=["']og:image:height["']\s+content=["'](\d+)["']/i);
          if (!ogImageWidth || !ogImageHeight) {
            return { pass: false, message: 'OG 이미지 크기 정보가 없습니다.' };
          }
          const width = parseInt(ogImageWidth[1]);
          const height = parseInt(ogImageHeight[1]);
          // 권장: 1200x630
          if (width < 1200 || height < 600) {
            return { pass: false, message: `OG 이미지 크기가 작습니다 (${width}x${height}, 권장: 1200x630)` };
          }
          return { pass: true, message: `OG 이미지 크기: ${width}x${height}` };
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

  for (const [categoryKey, category] of Object.entries(advancedChecks)) {
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
  log('\n📊 고급 SEO 체크 리포트', 'bright');
  log('='.repeat(50), 'bright');

  let totalScore = 0;
  let totalWeight = 0;
  const weights = {
    contentStructure: 0.20,
    linkOptimization: 0.15,
    imageOptimization: 0.15,
    mobileOptimization: 0.15,
    technicalSEO: 0.20,
    socialMedia: 0.15,
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
  
  log('\n🚀 고급 SEO 체크 도구', 'bright');
  log('='.repeat(50), 'bright');
  log(`HTML: ${htmlPath}`, 'blue');

  const results = runChecks(htmlPath);
  if (!results) {
    process.exit(1);
  }

  const report = generateReport(results);

  // 리포트 저장
  const reportPath = join(rootDir, 'seo-advanced-report.json');
  writeFileSync(reportPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    score: report.finalScore,
    results,
    improvements: report.improvements,
  }, null, 2));
  log(`\n📄 리포트 저장: ${reportPath}`, 'blue');

  log('\n✅ 고급 SEO 체크 완료!', 'green');
}

main().catch(console.error);

