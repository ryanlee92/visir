import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart' show ImageRenderMethodForWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ProxyNetworkImage extends ConsumerWidget {
  final String imageUrl;
  final String? cacheKey;
  final ImageWidgetBuilder? imageBuilder;
  final PlaceholderWidgetBuilder? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final Duration? placeholderFadeInDuration;
  final Duration? fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool useOldImageOnUrlChange;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final ValueChanged<Object>? errorListener;
  final OAuthEntity? oauth;
  final LoadingErrorWidgetBuilder? errorWidget;

  const ProxyNetworkImage({
    super.key,
    required this.imageUrl,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,

    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.useOldImageOnUrlChange = false,
    this.color,
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.errorListener,
    this.errorWidget,
    this.oauth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorizationHeaders = oauth?.authorizationHeaders;

    // 화면 크기 기반 메모리 캐시 크기 자동 설정
    final screenSize = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final defaultMemCacheWidth = memCacheWidth ?? (width != null ? (width! * devicePixelRatio).round() : (screenSize.width * devicePixelRatio).round());
    final defaultMemCacheHeight = memCacheHeight ?? (height != null ? (height! * devicePixelRatio).round() : (screenSize.height * devicePixelRatio).round());

    if (imageUrl.contains('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        headers: authorizationHeaders,
        placeholderBuilder: placeholder != null ? (context) => placeholder!.call(context, '') : null,
        errorBuilder: (context, _, __) =>
            errorWidget?.call(context, '', '') ??
            VisirIcon(type: VisirIconType.caution, size: max(16, min(width ?? 0, height ?? 0) / 3), color: context.error),
      );
    }
    return CachedNetworkImage(
      imageUrl: proxyUrl(imageUrl),
      cacheKey: cacheKey,
      imageBuilder: imageBuilder,
      placeholder: placeholder,
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget:
          errorWidget ??
          (context, url, object) {
            return VisirIcon(type: VisirIconType.caution, size: max(16, min(width ?? 0, height ?? 0) / 3), color: context.error);
          },
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      httpHeaders: authorizationHeaders,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      placeholderFadeInDuration: placeholderFadeInDuration,
      memCacheWidth: defaultMemCacheWidth,
      memCacheHeight: defaultMemCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      errorListener: errorListener,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
    );
  }
}
