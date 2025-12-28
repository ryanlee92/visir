/**
 * SEO용 Open Graph 이미지 생성 스크립트
 * 
 * 사용 방법:
 * 1. Node.js와 canvas 패키지 설치 필요: npm install canvas
 * 2. 실행: node scripts/generate-og-image.js
 * 
 * 생성된 이미지: branding/public/og-image.png
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Canvas 패키지가 설치되어 있는지 확인
let createCanvas, loadImage;
try {
  const canvas = await import('canvas');
  createCanvas = canvas.createCanvas;
  loadImage = canvas.loadImage;
} catch (error) {
  console.error('❌ canvas 패키지가 설치되지 않았습니다.');
  console.log('설치 방법: npm install canvas');
  console.log('\n또는 다음 방법을 사용하세요:');
  console.log('1. Figma에서 1200x630px 이미지 생성');
  console.log('2. Canva (https://www.canva.com/) 사용');
  console.log('3. 온라인 OG 이미지 생성 도구 사용');
  process.exit(1);
}

async function extractVideoFrame(videoPath, outputPath) {
  try {
    // FFmpeg로 첫 프레임 추출 (검은색 여백 제거: 상하좌우 5%씩 크롭)
    // crop=iw*0.9:ih*0.9:iw*0.05:ih*0.05 (너비 90%, 높이 90%, 시작점 5%, 5%)
    await execAsync(`ffmpeg -i "${videoPath}" -ss 00:00:00 -vframes 1 -vf "crop=iw*0.9:ih*0.9:iw*0.05:ih*0.05" -y "${outputPath}"`);
    return true;
  } catch (error) {
    console.warn('⚠️  비디오 프레임 추출 실패:', error.message);
    // 크롭 실패 시 원본 추출 시도
    try {
      await execAsync(`ffmpeg -i "${videoPath}" -ss 00:00:00 -vframes 1 -y "${outputPath}"`);
      return true;
    } catch (error2) {
      return false;
    }
  }
}

async function generateOGImage() {
  const width = 1200;
  const height = 630;
  const canvas = createCanvas(width, height);
  const ctx = canvas.getContext('2d');

  // 비디오 첫 프레임 추출
  const videoPath = path.join(__dirname, '../assets/app-demo-dark.webm');
  const tempFramePath = path.join(__dirname, '../temp-frame.png');
  let hasScreenshot = false;
  
  if (fs.existsSync(videoPath)) {
    hasScreenshot = await extractVideoFrame(videoPath, tempFramePath);
  } else {
    // 최적화된 버전 시도
    const optimizedVideoPath = path.join(__dirname, '../assets/app-demo-dark-optimized.webm');
    if (fs.existsSync(optimizedVideoPath)) {
      hasScreenshot = await extractVideoFrame(optimizedVideoPath, tempFramePath);
    }
  }

  // 배경: 다크 배경
  ctx.fillStyle = '#1C1C1B';
  ctx.fillRect(0, 0, width, height);

  // 비디오 프레임을 하단에 배치 (히어로 섹션처럼 max-w-7xl 크기)
  let videoContainerY = 0;
  let videoHeight = 0;
  let videoContainerWidth = 0;
  
  if (hasScreenshot && fs.existsSync(tempFramePath)) {
    try {
      const screenshot = await loadImage(tempFramePath);
      
      // 비디오 컨테이너: max-w-7xl과 유사한 크기 (전체 너비의 약 80%)
      videoContainerWidth = width * 0.80;
      const videoContainerX = (width - videoContainerWidth) / 2;
      const aspectRatio = 16 / 10;
      videoHeight = videoContainerWidth / aspectRatio;
      videoContainerY = height - videoHeight - 20; // 하단에서 20px 위
      
      // Glow 효과 (히어로 섹션의 blur-[100px] bg-visir-primary/20)
      ctx.fillStyle = 'rgba(124, 93, 255, 0.2)';
      ctx.filter = 'blur(100px)';
      ctx.beginPath();
      ctx.arc(
        videoContainerX + videoContainerWidth / 2,
        videoContainerY + videoHeight / 2,
        videoContainerWidth * 0.45,
        0,
        Math.PI * 2
      );
      ctx.fill();
      ctx.filter = 'none';
      
      const videoWidth = videoContainerWidth;
      const videoX = videoContainerX;
      const videoY = videoContainerY;
      
      // Rounded rectangle 배경 (rounded-2xl, border, shadow)
      const borderRadius = 16;
      ctx.fillStyle = 'rgba(47, 47, 47, 0.05)';
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
      ctx.lineWidth = 1;
      
      // Rounded rectangle 그리기
      ctx.beginPath();
      ctx.moveTo(videoX + borderRadius, videoY);
      ctx.lineTo(videoX + videoWidth - borderRadius, videoY);
      ctx.quadraticCurveTo(videoX + videoWidth, videoY, videoX + videoWidth, videoY + borderRadius);
      ctx.lineTo(videoX + videoWidth, videoY + videoHeight - borderRadius);
      ctx.quadraticCurveTo(videoX + videoWidth, videoY + videoHeight, videoX + videoWidth - borderRadius, videoY + videoHeight);
      ctx.lineTo(videoX + borderRadius, videoY + videoHeight);
      ctx.quadraticCurveTo(videoX, videoY + videoHeight, videoX, videoY + videoHeight - borderRadius);
      ctx.lineTo(videoX, videoY + borderRadius);
      ctx.quadraticCurveTo(videoX, videoY, videoX + borderRadius, videoY);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();
      
      // 비디오 프레임 그리기 (약간의 scale과 brightness/contrast)
      // FFmpeg에서 이미 크롭되었으므로 전체 이미지 사용
      const scale = 1.065;
      const scaledWidth = videoWidth * scale;
      const scaledHeight = videoHeight * scale;
      const scaledX = videoX - (scaledWidth - videoWidth) / 2;
      const scaledY = videoY - (scaledHeight - videoHeight) / 2 + videoHeight * 0.01;
      
      // 그림자 효과
      ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
      ctx.shadowBlur = 30;
      ctx.shadowOffsetX = 0;
      ctx.shadowOffsetY = 10;
      
      // 비디오 그리기 (FFmpeg에서 이미 크롭됨)
      ctx.drawImage(screenshot, scaledX, scaledY, scaledWidth, scaledHeight);
      
      // 그림자 리셋
      ctx.shadowColor = 'transparent';
      ctx.shadowBlur = 0;
      ctx.shadowOffsetX = 0;
      ctx.shadowOffsetY = 0;
      
      // 상단에 그라데이션 오버레이
      const overlayGradient = ctx.createLinearGradient(0, 0, 0, videoContainerY);
      overlayGradient.addColorStop(0, 'rgba(28, 28, 27, 0)');
      overlayGradient.addColorStop(0.6, 'rgba(28, 28, 27, 0.3)');
      overlayGradient.addColorStop(1, 'rgba(28, 28, 27, 0.7)');
      ctx.fillStyle = overlayGradient;
      ctx.fillRect(0, 0, width, videoContainerY);
    } catch (error) {
      console.warn('⚠️  스크린샷 로드 실패:', error.message);
      hasScreenshot = false;
      videoContainerY = height * 0.6;
    }
  } else {
    videoContainerY = height * 0.6;
  }

  // 텍스트: 중앙 정렬
  ctx.textAlign = 'center';
  ctx.textBaseline = 'top';
  const centerX = width / 2;
  
  // 상단: Visir 로고와 텍스트 (더 크고 예쁘게)
  let logoY = 60;
  try {
    let logoPath = path.join(__dirname, '../assets/visir/visir_foreground.png');
    if (!fs.existsSync(logoPath)) {
      logoPath = path.join(__dirname, '../assets/visir/visir_foreground.webp');
    }
    if (fs.existsSync(logoPath)) {
      const logo = await loadImage(logoPath);
      const logoSize = 56;
      const logoX = centerX - 80; // 로고와 텍스트 사이 간격
      
      ctx.drawImage(logo, logoX, logoY, logoSize, logoSize);
      
      // "Visir" 텍스트 (Playfair Display, 더 크게)
      ctx.fillStyle = '#FFFFFF';
      ctx.font = '600 52px "Playfair Display", "Times New Roman", serif';
      const visirTextX = logoX + logoSize + 16;
      ctx.textAlign = 'left';
      ctx.fillText('Visir', visirTextX, logoY + 6);
      ctx.textAlign = 'center';
      
      logoY += logoSize + 50; // 로고 아래 여백
    } else {
      ctx.fillStyle = '#FFFFFF';
      ctx.font = '600 52px "Playfair Display", "Times New Roman", serif';
      ctx.fillText('Visir', centerX, logoY);
      logoY += 70;
    }
  } catch (error) {
    ctx.fillStyle = '#FFFFFF';
    ctx.font = '600 52px "Playfair Display", "Times New Roman", serif';
    ctx.fillText('Visir', centerX, logoY);
    logoY += 70;
  }
  
  // 메인 제목: "Stop juggling apps." (비디오 바로 위, 더 크게)
  ctx.fillStyle = '#FFFFFF';
  ctx.font = '500 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';
  const titleY = videoContainerY - 140; // 비디오 위 충분한 여백
  ctx.fillText('Stop juggling apps.', centerX, titleY);
  
  // 그라데이션 텍스트: "Reclaim your focus."
  const gradientTextY = titleY + 70;
  const gradient = ctx.createLinearGradient(centerX - 250, gradientTextY, centerX + 250, gradientTextY);
  gradient.addColorStop(0, '#818cf8'); // indigo-400
  gradient.addColorStop(0.5, '#a78bfa'); // purple-400
  gradient.addColorStop(1, '#f472b6'); // pink-400
  ctx.fillStyle = gradient;
  ctx.font = '500 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';
  ctx.fillText('Reclaim your focus.', centerX, gradientTextY);
  
  // 임시 프레임 파일 정리
  if (fs.existsSync(tempFramePath)) {
    try {
      fs.unlinkSync(tempFramePath);
    } catch (error) {
      // 정리 실패해도 계속 진행
    }
  }

  // 저장
  const outputDir = path.join(__dirname, '../public');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const outputPathPNG = path.join(outputDir, 'og-image.png');
  const outputPathWebP = path.join(outputDir, 'og-image.webp');
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(outputPathPNG, buffer);
  
  // WebP 변환 (sharp 사용)
  try {
    const sharp = (await import('sharp')).default;
    await sharp(buffer)
      .webp({ quality: 85 })
      .toFile(outputPathWebP);
    const webpStats = fs.statSync(outputPathWebP);
    console.log('✅ SEO 이미지 생성 완료:');
    console.log('   PNG:', outputPathPNG, `(${(buffer.length / 1024).toFixed(2)} KB)`);
    console.log('   WebP:', outputPathWebP, `(${(webpStats.size / 1024).toFixed(2)} KB)`);
  } catch (error) {
    console.log('✅ SEO 이미지 생성 완료:', outputPathPNG);
    console.log('⚠️  WebP 변환 실패:', error.message);
    console.log('   수동 변환: cwebp -q 85 public/og-image.png -o public/og-image.webp');
  }
  
  console.log('📏 크기: 1200x630px');
  console.log('\n다음 단계:');
  console.log('1. 이미지를 확인하세요');
  console.log('2. SEO 설정 확인: lib/seo.ts의 ogImage 경로');
  console.log('3. 테스트: Facebook Debugger에서 URL 확인');
}

// 실행
generateOGImage().catch(error => {
  console.error('❌ 이미지 생성 실패:', error);
  process.exit(1);
});
