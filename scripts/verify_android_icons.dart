import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('🔍 Verifying Android icon files...\n');

  final androidResDir = Directory('android/app/src/main/res');
  if (!await androidResDir.exists()) {
    print('❌ Error: Android res directory not found');
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
      print('❌ $density: Directory not found');
      allGood = false;
      continue;
    }

    print('📁 Checking $density...');
    
    // Check background
    final bgFile = File('${densityDir.path}/ic_launcher_background.png');
    if (await bgFile.exists()) {
      final bgBytes = await bgFile.readAsBytes();
      if (bgBytes.isEmpty) {
        print('  ❌ ic_launcher_background.png is empty');
        allGood = false;
      } else {
        final bgImage = img.decodeImage(bgBytes);
        if (bgImage == null) {
          print('  ❌ ic_launcher_background.png is corrupted');
          allGood = false;
        } else {
          print('  ✅ ic_launcher_background.png: ${bgImage.width}x${bgImage.height}px');
        }
      }
    } else {
      print('  ❌ ic_launcher_background.png not found');
      allGood = false;
    }

    // Check foreground
    final fgFile = File('${densityDir.path}/ic_launcher_foreground.png');
    if (await fgFile.exists()) {
      final fgBytes = await fgFile.readAsBytes();
      if (fgBytes.isEmpty) {
        print('  ❌ ic_launcher_foreground.png is empty');
        allGood = false;
      } else {
        final fgImage = img.decodeImage(fgBytes);
        if (fgImage == null) {
          print('  ❌ ic_launcher_foreground.png is corrupted');
          allGood = false;
        } else {
          print('  ✅ ic_launcher_foreground.png: ${fgImage.width}x${fgImage.height}px');
        }
      }
    } else {
      print('  ❌ ic_launcher_foreground.png not found');
      allGood = false;
    }

    // Check regular icon
    final iconFile = File('${densityDir.path}/ic_launcher.png');
    if (await iconFile.exists()) {
      final iconBytes = await iconFile.readAsBytes();
      if (iconBytes.isEmpty) {
        print('  ⚠️  ic_launcher.png is empty (may be OK for adaptive icons)');
      } else {
        final iconImage = img.decodeImage(iconBytes);
        if (iconImage == null) {
          print('  ⚠️  ic_launcher.png is corrupted (may be OK for adaptive icons)');
        } else {
          print('  ✅ ic_launcher.png: ${iconImage.width}x${iconImage.height}px');
        }
      }
    }
    
    print('');
  }

  // Check adaptive icon XML
  final adaptiveDir = Directory('${androidResDir.path}/mipmap-anydpi-v26');
  if (await adaptiveDir.exists()) {
    final xmlFile = File('${adaptiveDir.path}/ic_launcher.xml');
    if (await xmlFile.exists()) {
      print('✅ Adaptive icon XML found');
    } else {
      print('❌ Adaptive icon XML not found');
      allGood = false;
    }
  } else {
    print('❌ Adaptive icon directory not found');
    allGood = false;
  }

  print('\n${allGood ? "✅" : "❌"} Icon verification ${allGood ? "passed" : "failed"}');
  
  if (!allGood) {
    print('\n💡 Try running: dart run scripts/fix_android_icons.dart');
  } else {
    print('\n💡 If icons still don\'t show:');
    print('   1. Clear launcher cache on your device');
    print('   2. Completely uninstall the app');
    print('   3. Reboot your device');
    print('   4. Reinstall the app');
  }
}

