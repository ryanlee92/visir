import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final assetsDir = Directory('assets/app_icon');
  final foregroundPath = '${assetsDir.path}/visir_foreground.png';
  final backgroundPath = '${assetsDir.path}/visir_background.png';

  // 이미지 로드
  final foregroundBytes = await File(foregroundPath).readAsBytes();
  final backgroundBytes = await File(backgroundPath).readAsBytes();
  
  final foreground = img.decodeImage(foregroundBytes);
  final background = img.decodeImage(backgroundBytes);
  
  if (foreground == null || background == null) {
    exit(1);
  }

  final androidResDir = Directory('android/app/src/main/res');
  if (!await androidResDir.exists()) {
    exit(1);
  }

  // Android adaptive icon 밀도별 크기
  // Background와 Foreground는 모두 108dp 크기여야 함
  final androidDensities = [
    {'density': 'mipmap-mdpi', 'size': 108},    // 108dp * 1.0
    {'density': 'mipmap-hdpi', 'size': 162},   // 108dp * 1.5
    {'density': 'mipmap-xhdpi', 'size': 216},  // 108dp * 2.0
    {'density': 'mipmap-xxhdpi', 'size': 324}, // 108dp * 3.0
    {'density': 'mipmap-xxxhdpi', 'size': 432}, // 108dp * 4.0
  ];

  for (final density in androidDensities) {
    final densityDir = Directory('${androidResDir.path}/${density['density']}');
    if (!await densityDir.exists()) {
      await densityDir.create(recursive: true);
    }

    final size = density['size'] as int;

    // Background 이미지 생성 (전체 크기)
    // Background는 108dp 전체 영역을 채워야 함
    final resizedBackground = img.copyResize(background, width: size, height: size);
    final backgroundFile = File('${densityDir.path}/ic_launcher_background.png');
    await backgroundFile.writeAsBytes(img.encodePng(resizedBackground));
    
    // 파일이 제대로 생성되었는지 확인
    if (await backgroundFile.exists()) {
      final fileSize = await backgroundFile.length();
      if (fileSize == 0) {
        // 다시 생성 시도
        await backgroundFile.writeAsBytes(img.encodePng(resizedBackground));
      }
    }

    // Foreground 이미지 생성 (안전 영역 내에 배치)
    // Foreground는 108dp 안전 영역 내에 있어야 하므로, 1/2 크기로 만들어서 중앙에 배치
    final safeSize = (size * 0.5).round(); // 50% 크기 사용
    final resizedForeground = img.copyResize(foreground, width: safeSize, height: safeSize);
    
    // 투명 배경에 중앙 배치
    final foregroundCanvas = img.Image(width: size, height: size);
    final offset = (size - safeSize) ~/ 2;
    img.compositeImage(foregroundCanvas, resizedForeground, dstX: offset, dstY: offset);
    
    await File('${densityDir.path}/ic_launcher_foreground.png')
        .writeAsBytes(img.encodePng(foregroundCanvas));

    // 생성된 파일 확인
    final bgFile = File('${densityDir.path}/ic_launcher_background.png');
    final fgFile = File('${densityDir.path}/ic_launcher_foreground.png');
    final bgExists = await bgFile.exists();
    final fgExists = await fgFile.exists();
    final bgSize = bgExists ? await bgFile.length() : 0;
    final fgSize = fgExists ? await fgFile.length() : 0;
  }
}

