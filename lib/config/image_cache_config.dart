import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Global image cache manager for Visir app
///
/// Optimized cache settings to reduce memory usage:
/// - Maximum 100 cached images
/// - 7 days cache retention
/// - Centralized cache management
class VisirImageCacheManager {
  static const key = 'taskeyImageCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Cache retention period
      maxNrOfCacheObjects: 100, // Maximum number of cached images
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  // Maximum dimensions for cached images to reduce memory usage
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
}
