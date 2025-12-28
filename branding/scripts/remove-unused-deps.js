import { readFileSync, writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const packageJsonPath = join(__dirname, '../package.json');

// 사용하지 않는 의존성 목록 (Svelte 앱에서 사용하지 않는 React 관련)
const unusedDeps = [
  '@fortawesome/fontawesome-svg-core',
  '@fortawesome/free-brands-svg-icons',
];

console.log('🔍 사용하지 않는 의존성 확인 중...\n');

const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf-8'));
const deps = packageJson.dependencies || {};
const unused = [];

unusedDeps.forEach(dep => {
  if (deps[dep]) {
    unused.push(dep);
    console.log(`⚠️  발견: ${dep}`);
  }
});

if (unused.length === 0) {
  console.log('✅ 사용하지 않는 의존성이 없습니다.');
  process.exit(0);
}

console.log(`\n📦 ${unused.length}개의 사용하지 않는 의존성을 발견했습니다.`);
console.log('\n💡 제거하려면 다음 명령어를 실행하세요:');
console.log(`   npm uninstall ${unused.join(' ')}`);
console.log('\n⚠️  주의: React 컴포넌트를 나중에 사용할 계획이 있다면 제거하지 마세요.');

