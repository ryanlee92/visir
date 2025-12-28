import sharp from 'sharp';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const assetsDir = path.join(__dirname, '../assets');

// 변환할 이미지 확장자
const imageExtensions = ['.webp', '.png', '.jpg', '.jpeg'];

// 재귀적으로 디렉토리 탐색
function getAllImageFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      getAllImageFiles(filePath, fileList);
    } else {
      const ext = path.extname(file).toLowerCase();
      if (imageExtensions.includes(ext)) {
        fileList.push(filePath);
      }
    }
  });
  
  return fileList;
}

// 이미지를 AVIF로 변환
async function convertToAVIF(inputPath, force = false) {
  try {
    const outputPath = inputPath.replace(/\.(webp|png|jpg|jpeg)$/i, '.avif');
    
    // 이미 AVIF 파일이 있고 force가 false면 스킵
    if (!force && fs.existsSync(outputPath)) {
      console.log(`⏭️  Skipping (already exists): ${path.relative(assetsDir, outputPath)}`);
      return;
    }
    
    // 로고 파일은 더 높은 품질로 변환
    const isLogo = inputPath.includes('visir_foreground');
    // Features 섹션 이미지들은 더 높은 품질로 변환
    const isFeatureImage = inputPath.includes('unified-inbox') || 
                          inputPath.includes('ai-assistant') || 
                          inputPath.includes('mail_') || 
                          inputPath.includes('chat_') || 
                          inputPath.includes('task_') || 
                          inputPath.includes('calendar_') ||
                          inputPath.includes('mobile/');
    const quality = isLogo ? 90 : isFeatureImage ? 92 : 85;
    
    await sharp(inputPath)
      .avif({ quality, effort: 4 })
      .toFile(outputPath);
    
    const inputSize = fs.statSync(inputPath).size;
    const outputSize = fs.existsSync(outputPath) ? fs.statSync(outputPath).size : 0;
    const reduction = outputSize > 0 ? ((1 - outputSize / inputSize) * 100).toFixed(1) : 0;
    
    console.log(`✅ Converted: ${path.relative(assetsDir, inputPath)} → ${path.relative(assetsDir, outputPath)} (${reduction}% smaller)`);
    return { inputPath, outputPath, reduction: parseFloat(reduction) };
  } catch (error) {
    console.error(`❌ Error converting ${inputPath}:`, error.message);
    return null;
  }
}

// 메인 실행
async function main() {
  const args = process.argv.slice(2);
  const force = args.includes('--force') || args.includes('-f');
  
  console.log('🔄 Starting AVIF conversion...\n');
  
  const imageFiles = getAllImageFiles(assetsDir);
  
  if (imageFiles.length === 0) {
    console.log('No image files found to convert.');
    return;
  }
  
  console.log(`Found ${imageFiles.length} image file(s) to convert.\n`);
  
  for (const file of imageFiles) {
    await convertToAVIF(file, force);
  }
  
  console.log('\n✨ Conversion complete!');
  console.log('\n💡 Tip: Run "npm run convert:avif -- --force" to reconvert existing files.');
}

main().catch(console.error);

