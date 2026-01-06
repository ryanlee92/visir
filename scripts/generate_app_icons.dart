import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() async {
  // 경로 설정
  final assetsDir = Directory('assets/app_icon');
  final darkDefaultPath = '${assetsDir.path}/visir_icon_dark_default.png';

  // 이미지 로드
  final darkDefaultBytes = await File(darkDefaultPath).readAsBytes();
  final darkDefault = img.decodeImage(darkDefaultBytes);
  if (darkDefault == null) {
    exit(1);
  }

  // Android 아이콘 생성 (visir_icon_dark_default 사용)
  await generateAndroidIcons(darkDefault);

  // Windows 아이콘 생성 (visir_icon_dark_default 사용)
  await generateWindowsIcons(darkDefault);
}

Future<void> generateAndroidIcons(img.Image darkDefaultIcon) async {
  final androidResDir = Directory('android/app/src/main/res');
  if (!await androidResDir.exists()) {
    return;
  }

  // Android 밀도별 크기
  final androidDensities = [
    {'density': 'mipmap-mdpi', 'size': 48},
    {'density': 'mipmap-hdpi', 'size': 72},
    {'density': 'mipmap-xhdpi', 'size': 96},
    {'density': 'mipmap-xxhdpi', 'size': 144},
    {'density': 'mipmap-xxxhdpi', 'size': 192},
  ];

  // visir_icon_dark_default를 사용하여 아이콘 생성
  for (final density in androidDensities) {
    final densityDir = Directory('${androidResDir.path}/${density['density']}');
    if (!await densityDir.exists()) {
      await densityDir.create(recursive: true);
    }

    final size = density['size'] as int;

    // visir_icon_dark_default를 리사이즈하고 rounded 처리
    final resizedIcon = img.copyResize(darkDefaultIcon, width: size, height: size);
    final roundedIcon = applyRoundedCorners(resizedIcon, size);

    // 라운드 아이콘
    await File('${densityDir.path}/ic_launcher_round.png').writeAsBytes(img.encodePng(roundedIcon));

    // 일반 아이콘
    await File('${densityDir.path}/ic_launcher.png').writeAsBytes(img.encodePng(roundedIcon));
  }

  // Adaptive icon은 XML로 정의되므로, mipmap-anydpi-v26 폴더에는 이미지 파일을 생성하지 않음
  // 실제 이미지 파일들은 각 밀도별 폴더에 있어야 함 (icons_launcher 패키지가 생성)
}

Future<void> generateWindowsIcons(img.Image darkDefaultIcon) async {
  final windowsDir = Directory('windows/runner/resources');
  if (!await windowsDir.exists()) {
    return;
  }

  // ICO 파일 생성은 복잡하므로, 대신 PNG 파일들을 생성
  // 실제로는 iconutil이나 다른 도구를 사용해야 하지만, 여기서는 PNG로 생성
  final largestSize = 256;

  // visir_icon_dark_default를 리사이즈하고 rounded 처리
  final resizedIcon = img.copyResize(darkDefaultIcon, width: largestSize, height: largestSize);
  final roundedIcon = applyRoundedCorners(resizedIcon, largestSize);

  // Windows 아이콘 (다크 모드만, 하나로 통합)
  await File('${windowsDir.path}/app_icon.png').writeAsBytes(img.encodePng(roundedIcon));
}

/// 배경 이미지와 포그라운드 이미지를 합성하여 아이콘 생성
img.Image createIconWithBackground(img.Image foreground, int size, dynamic background, [bool rounded = false]) {
  // 배경 이미지 생성
  img.Image backgroundImage;
  if (background is img.Image) {
    // dark_background를 리사이즈
    backgroundImage = img.copyResize(background, width: size, height: size);
  } else {
    // 흰색 배경 생성
    backgroundImage = img.Image(width: size, height: size);
    img.fill(backgroundImage, color: img.ColorRgb8(255, 255, 255));
  }

  // 포그라운드 이미지를 리사이즈 (약간 작게 하여 여백 추가)
  final foregroundSize = (size * 0.85).round();
  final resizedForeground = img.copyResize(foreground, width: foregroundSize, height: foregroundSize);

  // 중앙에 포그라운드 배치
  final offsetX = (size - foregroundSize) ~/ 2;
  final offsetY = (size - foregroundSize) ~/ 2;

  img.compositeImage(backgroundImage, resizedForeground, dstX: offsetX, dstY: offsetY);

  // macOS용 rounded 처리 (iOS 스타일의 둥근 모서리)
  if (rounded) {
    backgroundImage = applyRoundedCorners(backgroundImage, size);
  }

  return backgroundImage;
}

/// 둥근 모서리 적용 (macOS/iOS 스타일)
img.Image applyRoundedCorners(img.Image image, int size) {
  // macOS/iOS 아이콘의 둥근 모서리 반경은 약 22% (iOS와 동일)
  final radius = (size * 0.22).round();

  // 마스크 이미지 생성 (둥근 사각형)
  final mask = img.Image(width: size, height: size);

  // 둥근 사각형 마스크 그리기
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      // 모서리 영역 확인
      bool isInCorner = false;
      int cornerX = 0;
      int cornerY = 0;

      // 왼쪽 위 모서리
      if (x < radius && y < radius) {
        isInCorner = true;
        cornerX = radius - x;
        cornerY = radius - y;
      }
      // 오른쪽 위 모서리
      else if (x >= size - radius && y < radius) {
        isInCorner = true;
        cornerX = x - (size - radius);
        cornerY = radius - y;
      }
      // 왼쪽 아래 모서리
      else if (x < radius && y >= size - radius) {
        isInCorner = true;
        cornerX = radius - x;
        cornerY = y - (size - radius);
      }
      // 오른쪽 아래 모서리
      else if (x >= size - radius && y >= size - radius) {
        isInCorner = true;
        cornerX = x - (size - radius);
        cornerY = y - (size - radius);
      }

      if (isInCorner) {
        // 원의 중심에서 거리 계산
        final distance = (cornerX * cornerX + cornerY * cornerY).toDouble();
        final maxDistance = radius * radius;

        if (distance > maxDistance) {
          // 모서리 밖이면 투명하게
          mask.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        } else {
          // 모서리 안이면 불투명하게
          mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
        }
      } else {
        // 중앙 영역은 모두 불투명
        mask.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
      }
    }
  }

  // 마스크를 적용하여 둥근 모서리 생성
  final result = img.Image(width: size, height: size);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final maskPixel = mask.getPixel(x, y);
      final alpha = maskPixel.a;

      if (alpha == 0) {
        // 투명하게
        result.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      } else {
        // 원본 픽셀 복사
        final originalPixel = image.getPixel(x, y);
        result.setPixel(x, y, originalPixel);
      }
    }
  }

  return result;
}

/// macOS Contents.json 업데이트 (더 이상 사용되지 않음 - iOS/macOS 아이콘은 다른 프로그램으로 제작)
Future<void> regenerateMacOSContentsJson(String dirPath, List<Map<String, dynamic>> allEntries) async {
  final contentsFile = File('$dirPath/Contents.json');

  try {
    // 기존 Contents.json 읽기 (language-direction 엔트리만 추출)
    List<Map<String, dynamic>> languageDirectionEntries = [];

    if (await contentsFile.exists()) {
      final contentsJson = jsonDecode(await contentsFile.readAsString()) as Map<String, dynamic>;
      final images = (contentsJson['images'] as List).cast<Map<String, dynamic>>();

      // language-direction 엔트리만 추출 (보존)
      languageDirectionEntries = images.where((img) => img.containsKey('language-direction')).toList();
    }

    // 새로운 엔트리 추가 (라이트/다크 모드 모두 포함)
    // macOS의 경우 라이트 모드 엔트리 바로 다음에 다크 모드 엔트리가 와야 함
    // language-direction 엔트리는 라이트/다크 모드 쌍 다음에 배치
    final newImages = <Map<String, dynamic>>[];

    // 라이트 모드와 다크 모드 엔트리를 size/scale로 그룹화
    final groupedEntries = <String, Map<String, dynamic>>{}; // key: "size_scale", value: 라이트 모드 엔트리
    final darkEntries = <String, Map<String, dynamic>>{}; // key: "size_scale", value: 다크 모드 엔트리

    for (final entry in allEntries) {
      final size = entry['size'] as String;
      final scale = entry['scale'] as String;
      final key = '${size}_${scale}';

      if (!entry.containsKey('appearances')) {
        groupedEntries[key] = entry;
      } else {
        darkEntries[key] = entry;
      }
    }

    // size/scale 순서대로 정렬하여 라이트/다크 쌍을 인접하게 배치
    final sortedKeys = groupedEntries.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('_');
        final bParts = b.split('_');
        final aSize = int.parse(aParts[0].replaceAll('x', ''));
        final bSize = int.parse(bParts[0].replaceAll('x', ''));
        if (aSize != bSize) return aSize.compareTo(bSize);
        final aScale = int.parse(aParts[1].replaceAll('x', ''));
        final bScale = int.parse(bParts[1].replaceAll('x', ''));
        return aScale.compareTo(bScale);
      });

    for (final key in sortedKeys) {
      // 라이트 모드 엔트리 추가
      if (groupedEntries.containsKey(key)) {
        newImages.add(groupedEntries[key]!);
      }

      // 다크 모드 엔트리 추가 (라이트 모드 바로 다음에)
      if (darkEntries.containsKey(key)) {
        newImages.add(darkEntries[key]!);
      }

      // language-direction 엔트리 추가 (라이트/다크 쌍 다음에)
      final size = groupedEntries[key]!['size'] as String;
      final scale = groupedEntries[key]!['scale'] as String;
      for (final langEntry in languageDirectionEntries) {
        if (langEntry['size'] == size && langEntry['scale'] == scale) {
          // 중복 방지
          if (!newImages.any((e) => e['size'] == langEntry['size'] && e['scale'] == langEntry['scale'] && e.containsKey('language-direction'))) {
            newImages.add(Map<String, dynamic>.from(langEntry));
          }
        }
      }
    }

    // Contents.json 완전히 재생성
    final contentsJson = {
      'images': newImages,
      'info': {'author': 'xcode', 'version': 1},
    };

    await contentsFile.writeAsString(const JsonEncoder.withIndent('  ').convert(contentsJson));
    final lightCount = allEntries.where((e) => !e.containsKey('appearances')).length;
    final darkCount = allEntries.where((e) => e.containsKey('appearances')).length;
      } catch (e) {
        // Error updating Contents.json
      }
}

/// Mesh background 생성 (라이트/다크 모드)
img.Image createMeshBackground(int size, {required bool isDark}) {
  final image = img.Image(width: size, height: size);

  // 기본 배경 색상
  final baseColor = isDark
      ? img.ColorRgb8(28, 28, 27) // 다크 모드: #1C1C1B
      : img.ColorRgb8(245, 247, 251); // 라이트 모드: #F5F7FB

  img.fill(image, color: baseColor);

  // Mesh gradient 색상 (라이트/다크 모드에 따라)
  final colors = isDark
      ? [
          img.ColorRgb8(124, 93, 255), // primary (보라색)
          img.ColorRgb8(93, 133, 255), // secondary (파란색)
          img.ColorRgb8(255, 87, 87), // error (빨간색)
          img.ColorRgb8(255, 152, 0), // errorContainer (주황색)
        ]
      : [
          img.ColorRgb8(124, 93, 255), // primary (보라색)
          img.ColorRgb8(93, 133, 255), // secondary (파란색)
          img.ColorRgb8(255, 87, 87), // error (빨간색)
          img.ColorRgb8(255, 152, 0), // errorContainer (주황색)
        ];

  // Mesh gradient 위치 (랜덤하지만 일관성 있게)
  final offsets = [
    {'x': 0.2, 'y': 0.2}, // 왼쪽 위
    {'x': 0.8, 'y': 0.8}, // 오른쪽 아래
    {'x': 0.3, 'y': 0.7}, // 왼쪽 아래
    {'x': 0.7, 'y': 0.3}, // 오른쪽 위
  ];

  final sigmas = [0.5, 0.2, 0.3, 0.2];
  final strengths = [1.0, 1.0, 1.0, 1.0];

  // 각 픽셀에 대해 mesh gradient 계산
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final nx = x / size;
      final ny = y / size;

      double r = 0, g = 0, b = 0;
      double totalWeight = 0;

      // 각 색상 포인트의 영향 계산
      for (int i = 0; i < colors.length; i++) {
        final offset = offsets[i];
        final dx = nx - offset['x']!;
        final dy = ny - offset['y']!;
        final distance = dx * dx + dy * dy;
        final sigma = sigmas[i];
        final weight = strengths[i] * math.exp(-distance / (2 * sigma * sigma));

        final color = colors[i];
        r += color.r * weight;
        g += color.g * weight;
        b += color.b * weight;
        totalWeight += weight;
      }

      // 정규화
      if (totalWeight > 0) {
        r /= totalWeight;
        g /= totalWeight;
        b /= totalWeight;
      }

      // 기본 색상과 블렌드
      final blendFactor = isDark ? 0.08 : 0.15; // 다크 모드는 더 약하게
      final finalR = (baseColor.r * (1 - blendFactor) + r * blendFactor).round().clamp(0, 255);
      final finalG = (baseColor.g * (1 - blendFactor) + g * blendFactor).round().clamp(0, 255);
      final finalB = (baseColor.b * (1 - blendFactor) + b * blendFactor).round().clamp(0, 255);

      image.setPixel(x, y, img.ColorRgb8(finalR, finalG, finalB));
    }
  }

  return image;
}

/// 간단한 Color 클래스 (흰색용)
class Colors {
  static const white = 0xFFFFFFFF;
}
