import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/ai_api_usage_log_entity.dart';
import 'package:Visir/features/auth/infrastructure/datasources/supabase_ai_usage_log_datasource.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/utils/ai_pricing_calculator.dart';
import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Token Package Variant IDs
final Map<double, Map<bool, String>> tokenPackageVariantIds = {
  // Test Mode, Production Mode
  5.0: {
    true: '1139724', // Test Mode
    false: '1139736', // Production Mode
  },
  10.0: {true: '1139728', false: '1139737'},
  20.0: {true: '1139729', false: '1139738'},
  50.0: {true: '1139731', false: '1139739'},
};

// Token Package Product IDs
final Map<bool, String> tokenPackageProductIds = {
  true: '724119', // Test Mode
  false: '724123', // Production Mode
};

class AiCreditsScreen extends ConsumerStatefulWidget {
  final bool isInPrefScreen;
  final bool isSmall;
  final String? warning;
  final VoidCallback? onClose;
  final ScrollController? scrollController;

  const AiCreditsScreen({super.key, required this.isSmall, required this.isInPrefScreen, this.warning, this.onClose, this.scrollController});

  @override
  ConsumerState<AiCreditsScreen> createState() => _AiCreditsScreenState();
}

class _AiCreditsScreenState extends ConsumerState<AiCreditsScreen> {
  // 히스토리 레이지 로딩 관련 상태
  late ScrollController _historyScrollController;
  List<AiApiUsageLogEntity> _historyLogs = [];
  bool _isLoadingHistory = false;
  bool _hasMoreHistory = true;
  bool _hasAttemptedInitialLoad = false;
  int _historyOffset = 0;
  static const int _historyPageSize = 20;

  @override
  void initState() {
    super.initState();
    _historyScrollController = widget.scrollController ?? ScrollController();
    // 히스토리 스크롤 리스너 추가
    _historyScrollController.addListener(_onHistoryScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _historyScrollController.dispose();
    }
    super.dispose();
  }

  void _onHistoryScroll() {
    // Only trigger load more if we have scrollable content
    if (_historyScrollController.position.maxScrollExtent > 0 && _historyScrollController.position.pixels >= _historyScrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingHistory || !_hasMoreHistory) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final datasource = SupabaseAiUsageLogDatasource();
      final newLogs = await datasource.getUsageLogs(userId: user.id, limit: _historyPageSize, offset: _historyOffset);

      if (mounted) {
        setState(() {
          _historyLogs.addAll(newLogs);
          _historyOffset += newLogs.length;
          _hasMoreHistory = newLogs.length == _historyPageSize;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _loadInitialHistory() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() {
      _isLoadingHistory = true;
      _historyLogs = [];
      _historyOffset = 0;
      _hasMoreHistory = true;
      _hasAttemptedInitialLoad = true;
    });

    try {
      final datasource = SupabaseAiUsageLogDatasource();
      final logs = await datasource.getUsageLogs(userId: user.id, limit: _historyPageSize, offset: 0);

      if (mounted) {
        setState(() {
          _historyLogs = logs;
          _historyOffset = logs.length;
          _hasMoreHistory = logs.length == _historyPageSize;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCredits = ref.watch(authControllerProvider.select((state) => state.value?.userAiCredits)) ?? 0.0;
    final tokens = AiPricingCalculator.calculateTokensFromCredits(currentCredits);
    final tokensString = '${Utils.numberFormatter(tokens.toDouble())}';

    final children = [
      // 현재 크레딧 표시
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr.ai_credits_current_tokens, style: context.bodyMedium?.textColor(context.onSurfaceVariant)),
                SizedBox(height: 4),
                Text(tokensString, style: context.headlineMedium?.textColor(context.onSurface)),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 6),

      VisirListSection(
        titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.ai_credits_purchase_packages, style: baseStyle),
      ),
      // 구매 탭
      _buildPurchaseTab(context),

      VisirListSection(
        titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.ai_credits_history, style: baseStyle),
      ),

      _buildHistoryTab(context),
    ];

    if (widget.isInPrefScreen) {
      return Column(children: children);
    }

    return DetailsItem(
      title: null,
      hideBackButton: true,
      appbarColor: context.background,
      bodyColor: context.background,
      scrollController: _historyScrollController,
      leadings: widget.onClose != null ? [VisirAppBarButton(icon: VisirIconType.close, onTap: widget.onClose!)] : null,
      children: [
        if (widget.warning != null)
          VisirListItem(
            detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) {
              return Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0, bottom: 3),
                        child: VisirIcon(type: VisirIconType.caution, size: height, isSelected: true, color: context.error),
                      ),
                    ),
                    TextSpan(text: '\n', style: baseStyle),
                    TextSpan(text: widget.warning!, style: baseStyle),
                  ],
                ),
              );
            },
          ),
        ...children,
      ],
    );
  }

  Widget _buildPurchaseTab(BuildContext context) {
    // 모바일일 경우 데스크탑에서 결제할 수 있다는 안내 문구 표시
    if (PlatformX.isMobile) {
      return VisirListItem(
        detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: VisirIcon(type: VisirIconType.caution, size: height - 2, isSelected: true, color: context.error),
                ),
              ),
              TextSpan(text: context.tr.ai_credits_purchase_on_desktop, style: baseStyle?.textColor(context.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final creditPackages = [
      {'amount': 5.0, 'tokens': AiPricingCalculator.calculateTokensFromPackage(amount: 5.0)},
      {'amount': 10.0, 'tokens': AiPricingCalculator.calculateTokensFromPackage(amount: 10.0)},
      {'amount': 20.0, 'tokens': AiPricingCalculator.calculateTokensFromPackage(amount: 20.0)},
      {'amount': 50.0, 'tokens': AiPricingCalculator.calculateTokensFromPackage(amount: 50.0, includeBonus: true)},
    ];

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ...creditPackages.map((package) {
          final amount = package['amount'] as double;
          final tokens = package['tokens'] as int;
          final isBestValue = amount == 50.0;

          return VisirListItem(
            titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
              children: [
                TextSpan(text: '\$${Utils.numberFormatter(amount)}', style: context.headlineSmall?.textColor(context.onSurface)),
                if (isBestValue) TextSpan(text: '  ${context.tr.ai_credits_best_value}', style: context.bodySmall?.textColor(context.primary)),
              ],
            ),
            detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) =>
                Text('${Utils.numberFormatter(tokens.toDouble())} ${context.tr.ai_credits_tokens}', style: baseStyle?.textColor(context.onSurfaceVariant)),
            titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  child: VisirButton(
                    style: VisirButtonStyle(
                      backgroundColor: isBestValue ? context.primary : context.surface,
                      borderRadius: BorderRadius.circular(6),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () => _purchaseCredits(context, amount),
                    child: Text(context.tr.ai_credits_buy, style: context.bodyMedium?.textColor(isBestValue ? context.onPrimary : context.onSurface)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return SizedBox.shrink();

    // 초기 로딩 시 데이터 가져오기 (한 번만 시도)
    if (!_hasAttemptedInitialLoad && !_isLoadingHistory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialHistory();
      });
    }

    if (_isLoadingHistory && _historyLogs.isEmpty) {
      return VisirListItem(
        titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: context.tr.loading, style: baseStyle?.textColor(context.onSurface)),
      );
    }

    if (_historyLogs.isEmpty) {
      return VisirListItem(
        titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) =>
            TextSpan(text: context.tr.ai_credits_history_empty, style: baseStyle?.textColor(context.onSurface)),
      );
    }

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        ..._historyLogs.map((log) {
          final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
          final isPurchase = log.functionName == 'credit_purchase' || log.functionName == 'subscription_created' || log.functionName == 'subscription_renewal';

          // Determine plan name from model field
          String planName = 'Plan';
          if (log.model == 'ultra_plan') {
            planName = 'Ultra Plan';
          } else if (log.model == 'pro_plan') {
            planName = 'Pro Plan';
          }

          final displayTitle =
              (isPurchase
                      ? (log.functionName == 'credit_purchase'
                            ? 'Token Purchase'
                            : log.functionName == 'subscription_created'
                            ? '$planName Subscription'
                            : '$planName Renewal')
                      : log.functionName)
                  .toSentenceCase();

          return VisirListItem(
            titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: displayTitle, style: baseStyle?.textColor(context.onSurface)),
            detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => Text.rich(
              TextSpan(
                children: [
                  if (!isPurchase) TextSpan(text: '${log.model} • ', style: baseStyle?.textColor(context.onSurfaceVariant)),
                  TextSpan(
                    text: isPurchase
                        ? '+${Utils.numberFormatter(log.totalTokens.toDouble())} ${context.tr.ai_credits_tokens}'
                        : '${Utils.numberFormatter(log.totalTokens.toDouble())} ${context.tr.ai_credits_tokens}',
                    style: baseStyle?.textColor(isPurchase ? context.primary : context.onSurfaceVariant),
                  ),
                  if (!log.usedUserApiKey)
                    TextSpan(
                      text: isPurchase ? ' • +\$${Utils.numberFormatter(log.creditsUsed, fractionDigits: 4)}' : ' • \$${Utils.numberFormatter(log.creditsUsed, fractionDigits: 4)}',
                      style: baseStyle?.textColor(isPurchase ? context.primary : context.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) =>
                TextSpan(text: dateFormat.format(log.createdAt), style: baseStyle?.textColor(context.inverseSurface)),
          );
        }).toList(),
        if (_isLoadingHistory)
          VisirListItem(
            titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: context.tr.loading, style: baseStyle?.textColor(context.onSurface)),
          ),
      ],
    );
  }

  Future<void> _purchaseCredits(BuildContext context, double amount) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final isTestMode = ref.read(authControllerProvider.notifier).isSubscriptionTestMode;

    // Variant ID와 Product ID 가져오기
    final variantIdMap = tokenPackageVariantIds[amount];
    final productId = tokenPackageProductIds[isTestMode];

    if (variantIdMap == null || productId == null) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: 'Token package configuration error. Please contact support.'),
          buttons: [],
        ),
      );
      return;
    }

    final variantId = variantIdMap[isTestMode];
    if (variantId == null) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: 'Token package variant not found. Please contact support.'),
          buttons: [],
        ),
      );
      return;
    }

    // Checkout URL 가져오기
    final url = await ref.read(authControllerProvider.notifier).getSubscriptionCheckoutUrl(productId: productId, variantId: variantId);

    if (url != null) {
      Utils.launchUrlExternal(url: url);
    } else {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: 'Failed to create checkout. Please try again.'),
          buttons: [],
        ),
      );
    }
  }
}
