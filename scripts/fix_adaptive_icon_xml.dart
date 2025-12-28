import 'dart:io';

void main() async {
  print('🔧 Fixing Android adaptive icon XML files...\n');

  final androidResDir = Directory('android/app/src/main/res');
  if (!await androidResDir.exists()) {
    print('❌ Error: Android res directory not found');
    exit(1);
  }

  final adaptiveDir = Directory('${androidResDir.path}/mipmap-anydpi-v26');
  if (!await adaptiveDir.exists()) {
    print('❌ Error: mipmap-anydpi-v26 directory not found');
    exit(1);
  }

  // ic_launcher_foreground.png 파일 삭제 (잘못된 위치)
  final foregroundPng = File('${adaptiveDir.path}/ic_launcher_foreground.png');
  if (await foregroundPng.exists()) {
    await foregroundPng.delete();
    print('✅ Deleted ic_launcher_foreground.png from mipmap-anydpi-v26');
  }

  // ic_launcher.xml 수정
  final launcherXml = File('${adaptiveDir.path}/ic_launcher.xml');
  if (await launcherXml.exists()) {
    String content = await launcherXml.readAsString();
    
    // monochrome 속성 제거
    content = content.replaceAll(
      RegExp(r'\s*<monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\s*'),
      '',
    );
    
    // 올바른 형식으로 수정
    if (!content.contains('<background') || !content.contains('<foreground')) {
      content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@mipmap/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>''';
    } else {
      // 기존 내용 유지하되 monochrome만 제거
      final lines = content.split('\n');
      final filteredLines = lines.where((line) => 
        !line.contains('monochrome') && 
        line.trim().isNotEmpty
      ).toList();
      content = filteredLines.join('\n');
    }
    
    await launcherXml.writeAsString(content);
    print('✅ Fixed ic_launcher.xml');
  } else {
    print('⚠️  ic_launcher.xml not found');
  }

  // ic_launcher_round.xml 수정
  final roundXml = File('${adaptiveDir.path}/ic_launcher_round.xml');
  if (await roundXml.exists()) {
    String content = await roundXml.readAsString();
    
    // monochrome 속성 제거
    content = content.replaceAll(
      RegExp(r'\s*<monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\s*'),
      '',
    );
    
    // 올바른 형식으로 수정
    if (!content.contains('<background') || !content.contains('<foreground')) {
      content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@mipmap/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>''';
    } else {
      // 기존 내용 유지하되 monochrome만 제거
      final lines = content.split('\n');
      final filteredLines = lines.where((line) => 
        !line.contains('monochrome') && 
        line.trim().isNotEmpty
      ).toList();
      content = filteredLines.join('\n');
    }
    
    await roundXml.writeAsString(content);
    print('✅ Fixed ic_launcher_round.xml');
  } else {
    print('⚠️  ic_launcher_round.xml not found');
  }

  print('\n🎉 Adaptive icon XML files fixed successfully!');
}

