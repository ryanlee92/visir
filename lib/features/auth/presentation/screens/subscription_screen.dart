import 'dart:math';

import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_discount_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_product_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_variant_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:collection/collection.dart';
import 'package:color_mesh/color_mesh.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum SubscriptionType { monthly, yearly, ultra }

extension SubscriptionTypeX on SubscriptionType {
  String getVariantId(bool isTestMode) {
    switch (this) {
      case SubscriptionType.monthly:
        return isTestMode ? '915989' : '921376';
      case SubscriptionType.yearly:
        return isTestMode ? '881561' : '921377';
      case SubscriptionType.ultra:
        return isTestMode ? '1139396' : '1139389';
    }
  }

  int get months {
    switch (this) {
      case SubscriptionType.monthly:
        return 1;
      case SubscriptionType.yearly:
        return 12;
      case SubscriptionType.ultra:
        return 1;
    }
  }

  double get pricePerMonth {
    switch (this) {
      case SubscriptionType.monthly:
        return 14;
      case SubscriptionType.yearly:
        return 7.5;
      case SubscriptionType.ultra:
        return 24;
    }
  }

  String getTitle(BuildContext context) {
    switch (this) {
      case SubscriptionType.monthly:
        return 'Pro ${context.tr.subscription_monthly}';
      case SubscriptionType.yearly:
        return 'Pro ${context.tr.subscription_yearly}';
      case SubscriptionType.ultra:
        return 'Ultra ${context.tr.subscription_monthly}';
    }
  }

  String getDescription(BuildContext context) {
    switch (this) {
      case SubscriptionType.monthly:
        return '';
      case SubscriptionType.yearly:
        return context.tr.subscription_save_two_months_more;
      case SubscriptionType.ultra:
        return '';
    }
  }

  String? getAdditionalText(BuildContext context) {
    switch (this) {
      case SubscriptionType.monthly:
        return context.tr.per_month_billed_monthly;
      case SubscriptionType.yearly:
        return context.tr.per_month_billed_yearly;
      case SubscriptionType.ultra:
        return context.tr.per_month_billed_monthly;
    }
  }
}

class SubscriptionScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final bool? isFromExpiredScreen;
  final VoidCallback? onClose;

  final ScrollController? scrollController;

  const SubscriptionScreen({super.key, required this.isSmall, this.onClose, this.scrollController, this.isFromExpiredScreen});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool onCancel = false;
  bool onResume = false;
  bool onToggleTestMode = false;
  bool onRefreshSubscriptionProducts = false;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    List<LemonSqueezyProductEntity> subscriptionProducts = ref.read(authControllerProvider.notifier).subscriptionProducts;
    if (subscriptionProducts.isEmpty) {
      refreshSubscriptionProducts();
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> onPressSubscribe({
    required SubscriptionType type,
    required LemonSqueezyProductEntity product,
    required LemonSqueezyVariantEntity variant,
    LemonSqueezyDiscountEntity? discount,
  }) async {
    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(eventName: user.onTrial ? 'subscribe_trial' : 'subscribe_after_trial');

    final url = await ref.read(authControllerProvider.notifier).getSubscriptionCheckoutUrl(productId: product.id, variantId: variant.id, discountCode: discount?.code);
    if (url != null) {
      Utils.launchUrlExternal(url: url);
    }
  }

  Future<void> onPressManageBilling({required SubscriptionType type}) async {
    String? customerPortalUrl = ref.read(authControllerProvider.notifier).subscriptionCustomer?.customerPortalUrl;

    if (customerPortalUrl == null) {
      final customer = await ref.read(authControllerProvider.notifier).getLemonSqueezyCustomer();
      if (customer != null) {
        customerPortalUrl = customer.customerPortalUrl;
      }
    }

    if (customerPortalUrl != null) {
      Utils.launchUrlExternal(url: customerPortalUrl);
    }
  }

  Future<void> onPressSwitchSubscription({required SubscriptionType type}) async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (user.subscription == null) return;

    Utils.launchUrlExternal(url: 'https://taskey.lemonsqueezy.com/billing/${user.subscription?.id}/update');
  }

  Future<void> onPressRestore() async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (user.lemonSqueezyCustomerId == null) return;

    await ref.read(authControllerProvider.notifier).restoreSubscription(lemonSqueezyCustomerId: user.lemonSqueezyCustomerId!);
  }

  Future<void> onPressCancel() async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (user.subscription == null) return;

    setState(() {
      onCancel = true;
    });

    await ref.read(authControllerProvider.notifier).cancelSubscription(subscriptionId: user.subscription!.id);

    setState(() {
      onCancel = false;
    });
  }

  Future<void> onPressResume() async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (user.subscription == null) return;

    setState(() {
      onResume = true;
    });

    await ref.read(authControllerProvider.notifier).resumeSubscription(subscriptionId: user.subscription!.id);

    setState(() {
      onResume = false;
    });
  }

  Future<void> refreshSubscriptionProducts() async {
    setState(() {
      onRefreshSubscriptionProducts = true;
    });
    await ref.read(authControllerProvider.notifier).getLemonSqueezyProducts();
    if (mounted) {
      setState(() {
        onRefreshSubscriptionProducts = false;
      });
    }
  }

  Widget taskeyProFeatureWidget({required String text}) {
    return Row(
      children: [
        VisirIcon(type: VisirIconType.check, size: 14),
        SizedBox(width: 10),
        Text(text, style: context.bodyLarge?.textColor(context.onInverseSurface)),
      ],
    );
  }

  Widget subscriptionWidget({required SubscriptionType type, required LemonSqueezyVariantEntity? bestValueVariant}) {
    final subscription = ref.watch(authControllerProvider.select((v) => v.requireValue.subscription));
    bool isSubscriptionTestMode = ref.watch(subscriptionTestModeProvider);

    List<LemonSqueezyProductEntity> subscriptionProducts = ref.read(authControllerProvider.notifier).subscriptionProducts;
    List<LemonSqueezyVariantEntity> subscriptionVariants = ref.read(authControllerProvider.notifier).subscriptionVariants;

    SubscriptionType? currentSubscriptionType = SubscriptionType.values.where((e) => e.getVariantId(isSubscriptionTestMode) == subscription?.variantId).firstOrNull;

    // Variant ID로 직접 찾기 (모든 product의 variant에서 검색)
    final targetVariantId = type.getVariantId(isSubscriptionTestMode);
    LemonSqueezyVariantEntity? variant = subscriptionVariants.where((t) => t.id == targetVariantId && t.isPublished).firstOrNull;
    if (variant == null) return SizedBox.shrink();

    // Variant에 해당하는 Product 찾기
    LemonSqueezyProductEntity? validProduct = subscriptionProducts.where((p) => p.id == variant.productId.toString()).firstOrNull;
    if (validProduct == null) return SizedBox.shrink();

    bool isExpired = subscription?.isExpired ?? false;
    bool onSubscribe = isExpired ? false : currentSubscriptionType != null;
    bool isCurrent = isExpired ? false : currentSubscriptionType == type;

    double price = variant.priceInDollar.toDouble();

    return VisirListItem(
      verticalMarginOverride: 0,
      verticalPaddingOverride: 3,
      titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: type.getTitle(context), style: baseStyle),
      titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
        style: baseStyle?.textColor(isCurrent ? context.primary : null),
        children: [
          WidgetSpan(
            child: VisirButton(
              type: VisirButtonAnimationType.none,
              style: VisirButtonStyle(
                hoverColor: Colors.transparent,
                backgroundColor: isCurrent ? context.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
              child: Text(isCurrent ? (context.tr.subscription_active) : type.getDescription(context)),
            ),
          ),
        ],
      ),
      detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text('\$${Utils.numberFormatter(price / type.months)}', style: context.headlineLarge?.textColor(context.onBackground)),
                  SizedBox(width: 12),
                  Text(type.getAdditionalText(context) ?? '', style: baseStyle),
                ],
              ),
            ),
            VisirButton(
              style: VisirButtonStyle(
                hoverColor: Colors.transparent,
                height: PreferenceScreen.buttonHeight,
                backgroundColor: bestValueVariant?.id == variant.id ? context.primary : context.surface,
                borderRadius: BorderRadius.circular(6),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              ),
              type: VisirButtonAnimationType.scaleAndOpacity,
              onTap: () async {
                if (onSubscribe) {
                  if (isCurrent) {
                    await onPressManageBilling(type: type);
                  } else {
                    await onPressSwitchSubscription(type: type);
                  }
                } else {
                  await onPressSubscribe(type: type, product: validProduct, variant: variant);
                }
              },
              child: Text(
                isCurrent
                    ? context.tr.subscription_manage_billing
                    : onSubscribe
                    ? context.tr.subscription_switch_subscription
                    : context.tr.subscription_upgrade_to_pro,
                style: context.bodyLarge?.textColor(bestValueVariant?.id == variant.id ? context.onPrimary : context.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.year == DateTime.now().year ? DateFormat('MMM d').format(date) : DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    bool isFromExpiredScreen = widget.isFromExpiredScreen ?? false;

    final onTrial = ref.watch(authControllerProvider.select((v) => v.requireValue.onTrial));
    final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));
    final subscription = ref.watch(authControllerProvider.select((v) => v.requireValue.subscription));
    final isAdmin = ref.watch(authControllerProvider.select((v) => v.requireValue.userIsAdmin));

    bool isSubscriptionTestMode = ref.read(authControllerProvider.notifier).isSubscriptionTestMode;

    List<LemonSqueezyVariantEntity> subscriptionVariants = ref.read(authControllerProvider.notifier).subscriptionVariants;

    SubscriptionType? currentSubscriptionType = SubscriptionType.values.where((e) => e.getVariantId(isSubscriptionTestMode) == subscription?.variantId).firstOrNull;

    // Ultra만 available plans에 표시 (yearly는 제외)
    List<SubscriptionType> subscriptionTypesOnView = [SubscriptionType.monthly, SubscriptionType.ultra].where((e) => e != currentSubscriptionType).toList();

    // Available plans에 해당하는 variant들 찾기 (모든 product에서 검색)
    List<LemonSqueezyVariantEntity> validVariants = subscriptionTypesOnView
        .map((type) {
          final variantId = type.getVariantId(isSubscriptionTestMode);
          return subscriptionVariants.where((v) => v.id == variantId && v.isPublished && subscription?.variantId != v.id).firstOrNull;
        })
        .whereType<LemonSqueezyVariantEntity>()
        .toList();

    final bestPriceVariant = validVariants.isNotEmpty ? validVariants.where((e) => e.priceInDollar == validVariants.map((e) => e.priceInDollar).toList().max).firstOrNull : null;

    String? dateString;
    if (onTrial) {
      final user = ref.read(authControllerProvider).requireValue;
      final date = user.freeTrialEndAt;
      dateString = '${context.tr.subscription_free_trial_ends} ${_formatDate(date)}';
    } else if (subscription?.isTestMode == !onToggleTestMode && (subscription?.isCancelled ?? false)) {
      final date = subscription?.subscriptionEndsAt;
      if (date != null) {
        dateString = '${context.tr.subscription_subscription_ends} ${_formatDate(date)}';
      }
    } else if (subscription?.isTestMode == !onToggleTestMode && ((subscription?.isActive ?? false) || (subscription?.isPaused ?? false))) {
      final date = subscription?.subscriptionRenewsAt;
      if (date != null) {
        dateString = '${context.tr.subscription_next_billing_date} ${_formatDate(date)}';
      }
    }

    return DetailsItem(
      title: isFromExpiredScreen
          ? context.tr.pref_subscription
          : widget.isSmall
          ? context.tr.pref_subscription
          : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: isFromExpiredScreen ? context.outline : context.background,
      leadings: isFromExpiredScreen
          ? [
              VisirAppBarButton(
                icon: VisirIconType.close,
                onTap: () {
                  Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
                },
              ),
            ]
          : null,
      children: [
        VisirListSection(
          removeTopMargin: true,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            text: context.tr.subscription_visir_pro,
            style: baseStyle?.copyWith(
              foreground: Paint()
                ..shader = MeshGradient(
                  colors: [context.primary, context.secondary, context.error, context.errorContainer],
                  offsets: [
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                  ],
                  strengths: [1, 1, 1, 1],
                  sigmas: [0.5, 0.2, 0.3, 0.2],
                ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, height)),
            ),
          ),
        ),

        ...[
          context.tr.subscription_unlimited_integrations,
          // context.tr.subscription_ai_suggestion,
          context.tr.subscription_pro_ai_based_inbox_summary,
          context.tr.subscription_pro_next_schedule_summary,
          context.tr.subscription_pro_100k_ai_tokens,
        ].mapIndexed(
          (index, e) => VisirListItem(
            verticalMarginOverride: 0,
            titleMaxLines: 2,
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(right: horizontalSpacing),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) => MeshGradient(
                        colors: context.isDarkMode
                            ? [context.secondaryContainer, context.onError, context.error, context.primary]
                            : [context.primaryContainer, context.onError, context.error, context.primary],
                        offsets: [
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                        ],
                        strengths: [1, 1, 1, 1],
                        sigmas: [0.5, 0.2, 0.3, 0.2],
                      ).createShader(bounds),
                      child: VisirIcon(type: VisirIconType.checkBadge, size: height, isSelected: true),
                    ),
                  ),
                ),
                TextSpan(text: e, style: baseStyle?.textColor(context.onBackground)),
              ],
            ),
          ),
        ),

        // Ultra Plan Section
        SizedBox(height: 24),
        VisirListSection(
          removeTopMargin: true,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            text: context.tr.subscription_visir_ultra,
            style: baseStyle?.copyWith(
              foreground: Paint()
                ..shader = MeshGradient(
                  colors: [context.primary, context.secondary, context.error, context.errorContainer],
                  offsets: [
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                    Offset(Random().nextDouble(), Random().nextDouble()),
                  ],
                  strengths: [1, 1, 1, 1],
                  sigmas: [0.5, 0.2, 0.3, 0.2],
                ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, height)),
            ),
          ),
        ),

        ...[context.tr.subscription_ultra_all_pro_features, context.tr.subscription_ultra_500k_ai_tokens, context.tr.subscription_ultra_priority_support].mapIndexed(
          (index, e) => VisirListItem(
            verticalMarginOverride: 0,
            titleMaxLines: 2,
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(right: horizontalSpacing),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) => MeshGradient(
                        colors: context.isDarkMode
                            ? [context.secondaryContainer, context.onError, context.error, context.primary]
                            : [context.primaryContainer, context.onError, context.error, context.primary],
                        offsets: [
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                          Offset(Random().nextDouble(), Random().nextDouble()),
                        ],
                        strengths: [1, 1, 1, 1],
                        sigmas: [0.5, 0.2, 0.3, 0.2],
                      ).createShader(bounds),
                      child: VisirIcon(type: VisirIconType.checkBadge, size: height, isSelected: true),
                    ),
                  ),
                ),
                TextSpan(text: e, style: baseStyle?.textColor(context.onBackground)),
              ],
            ),
          ),
        ),

        if (currentSubscriptionType != null)
          VisirListSection(
            titleTrailingOnNextLine: true,
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.current_subscription, style: baseStyle),
            titleTrailingBuilder: dateString == null ? null : (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: dateString, style: subStyle),
          ),

        if (currentSubscriptionType != null) subscriptionWidget(type: currentSubscriptionType, bestValueVariant: null),

        if (validVariants.isNotEmpty)
          VisirListSection(
            titleTrailingOnNextLine: true,
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.available_plans, style: baseStyle),
            titleTrailingBuilder: dateString == null
                ? null
                : currentSubscriptionType == null
                ? (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: dateString, style: subStyle)
                : null,
          ),
        if (validVariants.isNotEmpty) ...subscriptionTypesOnView.mapIndexed((index, type) => subscriptionWidget(type: type, bestValueVariant: bestPriceVariant)),

        SizedBox(height: 12),
        VisirListItem(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            style: context.bodyLarge?.textColor(context.inverseSurface),
            children: [
              if (currentSubscriptionType == null) ...[
                WidgetSpan(
                  child: IntrinsicWidth(
                    child: VisirButton(
                      style: VisirButtonStyle(hoverColor: Colors.transparent),
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      onTap: onPressRestore,
                      builder: (isHover) => Text(
                        context.tr.subscription_restore_subscription,
                        style: context.bodyLarge
                            ?.textColor(isHover ? context.shadow : context.inverseSurface)
                            .copyWith(decoration: isHover ? TextDecoration.underline : TextDecoration.none),
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: ' · '),
              ],
              WidgetSpan(
                child: IntrinsicWidth(
                  child: VisirButton(
                    style: VisirButtonStyle(hoverColor: Colors.transparent),
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () => Utils.launchMailto(to: Constants.supportEmail, subject: '[Visir] billing support', body: userId),
                    builder: (isHover) => Text(
                      context.tr.subscription_contact_billing_support,
                      style: context.bodyLarge
                          ?.textColor(isHover ? context.shadow : context.inverseSurface)
                          .copyWith(decoration: isHover ? TextDecoration.underline : TextDecoration.none),
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (isAdmin)
          VisirListSection(
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Debug', style: baseStyle),
          ),

        if (isAdmin && isSubscriptionTestMode)
          VisirListItem(
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Status : ${subscription?.subscriptionStatus}', style: baseStyle),
            detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) {
              return Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Trial ends at ${subscription?.subscriptionTrialEndsAt?.toString().split('.')[0]}  ', style: baseStyle),
                        WidgetSpan(
                          child: IntrinsicWidth(
                            child: VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(hoverColor: Colors.transparent),
                              onTap: () => ref.read(authControllerProvider.notifier).extendSubscriptionTrial(duration: Duration(days: 1)),
                              child: Text('Extend Trial'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Subscription ends at ${subscription?.subscriptionEndsAt?.toString().split('.')[0]}  ', style: baseStyle),
                  Text('Subscription renews at ${subscription?.subscriptionRenewsAt?.toString().split('.')[0]}  ', style: baseStyle),
                ],
              );
            },
          ),

        if (isAdmin)
          VisirListItem(
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Test Mode', style: baseStyle),
            titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  child: AnimatedToggleSwitch<bool>.rolling(
                    current: isSubscriptionTestMode,
                    values: [true, false],
                    height: PreferenceScreen.buttonHeight,
                    indicatorSize: Size(PreferenceScreen.buttonWidth / 2, PreferenceScreen.buttonHeight),
                    indicatorIconScale: 1,
                    iconOpacity: 0.5,
                    borderWidth: 0,
                    onChanged: (value) async {
                      setState(() {
                        onToggleTestMode = true;
                      });
                      await ref.read(authControllerProvider.notifier).switchSubscriptionTestMode(isTestMode: value);
                      setState(() {
                        onToggleTestMode = false;
                      });
                    },
                    iconBuilder: (testMode, selected) => VisirIcon(
                      type: testMode ? VisirIconType.check : VisirIconType.close,
                      size: 16,
                      color: !selected ? context.onBackground : context.onBackground,
                      isSelected: true,
                    ),
                    style: ToggleStyle(
                      backgroundColor: context.surface,
                      borderRadius: BorderRadius.circular(6),
                      borderColor: context.surface.withValues(alpha: 1),
                      indicatorColor: context.surfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
