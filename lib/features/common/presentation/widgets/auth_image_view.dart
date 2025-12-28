import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';

class AuthImageView extends StatelessWidget {
  final OAuthEntity oauth;
  final double size;
  const AuthImageView({super.key, required this.oauth, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            child: Container(
              decoration: BoxDecoration(color: context.outline, borderRadius: BorderRadius.circular(size / 3)),
            ),
          ),
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(size / 20, size / 20),
              child: ProxyNetworkImage(
                imageUrl: oauth.notificationUrl ?? '',
                width: size,
                height: size,
                fit: BoxFit.contain,
                oauth: oauth,
                errorWidget: (context, url, error) {
                  return AdvancedAvatar(
                    name: oauth.name ?? oauth.email,
                    image: AssetImage('assets/place_holder/img_default_profile.png') as ImageProvider,
                    size: size,
                    autoTextSize: true,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                    style: TextStyle(color: context.onPrimary),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
