import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final androidResDir = Directory('android/app/src/main/res');
  if (!await androidResDir.exists()) {
    exit(1);
  }

  final densities = [
    'mipmap-mdpi',
    'mipmap-hdpi',
    'mipmap-xhdpi',
    'mipmap-xxhdpi',
    'mipmap-xxxhdpi',
  ];

  bool allGood = true;

  for (final density in densities) {
    final densityDir = Directory('${androidResDir.path}/$density');
    if (!await densityDir.exists()) {
      allGood = false;
      continue;
    }
    
    // Check background
    final bgFile = File('${densityDir.path}/ic_launcher_background.png');
    if (await bgFile.exists()) {
      final bgBytes = await bgFile.readAsBytes();
      if (bgBytes.isEmpty) {
        allGood = false;
      } else {
        final bgImage = img.decodeImage(bgBytes);
        if (bgImage == null) {
          allGood = false;
        }
      }
    } else {
      allGood = false;
    }

    // Check foreground
    final fgFile = File('${densityDir.path}/ic_launcher_foreground.png');
    if (await fgFile.exists()) {
      final fgBytes = await fgFile.readAsBytes();
      if (fgBytes.isEmpty) {
        allGood = false;
      } else {
        final fgImage = img.decodeImage(fgBytes);
        if (fgImage == null) {
          allGood = false;
        }
      }
    } else {
      allGood = false;
    }

    // Check regular icon
    final iconFile = File('${densityDir.path}/ic_launcher.png');
    if (await iconFile.exists()) {
      final iconBytes = await iconFile.readAsBytes();
      if (iconBytes.isNotEmpty) {
        final iconImage = img.decodeImage(iconBytes);
      }
    }
  }

  // Check adaptive icon XML
  final adaptiveDir = Directory('${androidResDir.path}/mipmap-anydpi-v26');
  if (await adaptiveDir.exists()) {
    final xmlFile = File('${adaptiveDir.path}/ic_launcher.xml');
    if (!await xmlFile.exists()) {
      allGood = false;
    }
  } else {
    allGood = false;
  }
}

