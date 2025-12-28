import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/presentation/screens/ai_credits_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgentPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;

  final VoidCallback? onClose;

  const AgentPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgentPrefScreenState();
}

class _AgentPrefScreenState extends ConsumerState<AgentPrefScreen> {
  ScrollController? _scrollController;
  final Map<AiProvider, TextEditingController> _controllers = {};
  final Map<AiProvider, FocusNode> _focusNodes = {};
  final Map<AiProvider, bool> _isObscured = {};
  late final TextEditingController _systemPromptController;
  late final FocusNode _systemPromptFocusNode;

  @override
  void initState() {
    super.initState();
    for (final provider in AiProvider.values) {
      _controllers[provider] = TextEditingController();
      _focusNodes[provider] = FocusNode();
      _isObscured[provider] = true;
    }
    _systemPromptController = TextEditingController();
    _systemPromptFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _systemPromptController.dispose();
    _systemPromptFocusNode.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final aiApiKeys = ref.watch(aiApiKeysProvider);
    final systemPrompt = ref.watch(agentSystemPromptProvider);

    // Initialize controllers with current values
    for (final provider in AiProvider.values) {
      final apiKey = aiApiKeys[provider.key];
      final controller = _controllers[provider];
      if (controller != null && apiKey != null && controller.text.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.text = apiKey;
          }
        });
      }
    }

    // Initialize system prompt controller with current value
    if (systemPrompt != null && _systemPromptController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _systemPromptController.text = systemPrompt;
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DetailsItem(
          title: widget.isSmall ? context.tr.agent_pref_title : null,
          hideBackButton: !widget.isSmall,
          appbarColor: context.background,
          bodyColor: context.background,
          scrollController: _scrollController,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          children: [
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
                      TextSpan(text: context.tr.agent_pref_description, style: baseStyle),
                    ],
                  ),
                );
              },
            ),
            VisirListSection(
              removeTopMargin: true,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.agent_pref_api_key, style: baseStyle),
            ),

            ...AiProvider.values.map((provider) {
              final controller = _controllers[provider]!;
              final focusNode = _focusNodes[provider]!;
              final isObscured = _isObscured[provider] ?? true;
              return VisirListItem(
                verticalPaddingOverride: 3,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) =>
                    TextSpan(text: '${provider.getDisplayName(context)} API Key', style: context.labelMedium?.textColor(context.onBackground).appFont(context)),
                detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                  padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          obscureText: isObscured,
                          style: baseStyle?.textColor(context.onBackground),
                          decoration: InputDecoration(
                            hintText: provider.getApiKeyHint(context),
                            hintStyle: baseStyle?.textColor(context.outlineVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: context.outline.withValues(alpha: 0.2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: context.outline.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: context.primary),
                            ),
                            filled: true,
                            fillColor: context.surface,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    cursor: SystemMouseCursors.click,
                                    height: 32,
                                    width: 32,
                                    borderRadius: BorderRadius.circular(6),
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.all(0),
                                  ),

                                  onTap: () {
                                    setState(() {
                                      _isObscured[provider] = !isObscured;
                                    });
                                  },
                                  child: VisirIcon(type: isObscured ? VisirIconType.hide : VisirIconType.show, size: 16, color: context.onBackground, isSelected: true),
                                ),
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    cursor: SystemMouseCursors.click,
                                    height: 32,
                                    width: 32,
                                    borderRadius: BorderRadius.circular(6),
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.all(0),
                                  ),
                                  options: VisirButtonOptions(
                                    shortcuts: [
                                      VisirButtonKeyboardShortcut(
                                        message: context.tr.save,
                                        keys: [LogicalKeyboardKey.enter],
                                        onTrigger: () {
                                          if (!focusNode.hasFocus) return false;
                                          _saveApiKey(provider);
                                          return true;
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () => _saveApiKey(provider),
                                  child: VisirIcon(type: VisirIconType.check, size: 16, color: context.onBackground, isSelected: true),
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                          ),
                          onSubmitted: (value) {
                            _saveApiKey(provider);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // System Prompt Section
            SizedBox(height: 24),
            VisirListSection(
              removeTopMargin: true,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.agent_pref_system_prompt, style: baseStyle),
            ),

            VisirListItem(
              verticalMarginOverride: 0,
              verticalPaddingOverride: 0,
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) =>
                  Text(context.tr.agent_pref_system_prompt_description, style: baseStyle?.textColor(context.inverseSurface)),
            ),
            SizedBox(height: 6),

            VisirListItem(
              verticalPaddingOverride: 3,
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _systemPromptController,
                        focusNode: _systemPromptFocusNode,
                        style: baseStyle?.textColor(context.onBackground),
                        maxLines: 5,
                        onChanged: (string) {
                          _saveSystemPrompt();
                        },
                        decoration: InputDecoration(
                          hintText: context.tr.agent_pref_system_prompt_hint,
                          hintStyle: baseStyle?.textColor(context.outlineVariant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: context.outline.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: context.outline.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: context.primary),
                          ),
                          filled: true,
                          fillColor: context.surface,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        ),
                        onSubmitted: (value) {
                          _saveSystemPrompt();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            VisirListSection(
              removeTopMargin: true,
              bottomMarginOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.agent_pref_default_ai_provider, style: baseStyle),
            ),

            VisirListItem(
              verticalMarginOverride: 0,
              verticalPaddingOverride: 0,
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                child: Text(context.tr.agent_pref_default_ai_provider_description, style: baseStyle?.textColor(context.inverseSurface)),
              ),
            ),
            SizedBox(height: 6),

            // Default Agent AI Provider Selection
            Builder(
              builder: (context) {
                // Filter providers that have API keys, and add "none" option
                final availableProviders = <AiProvider?>[null]; // null = "none"
                for (final provider in AiProvider.values) {
                  if (aiApiKeys[provider.key] != null && aiApiKeys[provider.key]!.isNotEmpty) {
                    availableProviders.add(provider);
                  }
                }

                if (availableProviders.length <= 1) {
                  // Only "none" option available
                  return VisirListItem(
                    verticalPaddingOverride: 0,
                    detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                      padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                      child: Text(context.tr.agent_pref_no_api_keys, style: baseStyle?.textColor(context.outlineVariant)),
                    ),
                  );
                }

                final currentProvider = ref.watch(defaultAgentAiProviderProvider);

                final buttonHeight = PreferenceScreen.buttonHeight;
                final buttonWidth = constraints.maxWidth / availableProviders.length;

                return VisirListItem(
                  verticalPaddingOverride: 0,
                  titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                    children: [
                      WidgetSpan(
                        child: AnimatedToggleSwitch<AiProvider?>.rolling(
                          current: currentProvider,
                          values: availableProviders,
                          height: buttonHeight,
                          indicatorSize: Size(buttonWidth, buttonHeight),
                          indicatorIconScale: 1,
                          iconOpacity: 0.5,
                          borderWidth: 0,
                          onChanged: (provider) async {
                            await ref.read(defaultAgentAiProviderProvider.notifier).setProvider(provider);
                          },
                          iconBuilder: (provider, selected) {
                            if (provider == null) {
                              return Text(context.tr.agent_pref_none, style: context.bodyMedium?.textColor(selected ? context.onBackground : null));
                            }
                            return Text(provider.getDisplayName(context), style: context.bodyMedium?.textColor(selected ? context.onBackground : null));
                          },
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
                );
              },
            ),

            // Additional Tokens Section
            SizedBox(height: 24),

            VisirListSection(
              removeTopMargin: true,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.agent_pref_additional_tokens, style: baseStyle),
            ),

            VisirListItem(
              verticalMarginOverride: 0,
              verticalPaddingOverride: 0,
              detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Padding(
                padding: EdgeInsets.symmetric(vertical: horizontalSpacing),
                child: Text(context.tr.agent_pref_additional_tokens_description, style: baseStyle?.textColor(context.inverseSurface)),
              ),
            ),
            SizedBox(height: 6),

            AiCreditsScreen(isSmall: false, isInPrefScreen: true, scrollController: _scrollController),
          ],
        );
      },
    );
  }

  Future<void> _saveApiKey(AiProvider provider) async {
    final controller = _controllers[provider];
    if (controller == null) return;
    final apiKey = controller.text.trim();
    if (apiKey.isNotEmpty) {
      await ref.read(aiApiKeysProvider.notifier).setApiKey(provider, apiKey);
    } else {
      await ref.read(aiApiKeysProvider.notifier).removeApiKey(provider);
    }
  }

  Future<void> _saveSystemPrompt() async {
    final systemPrompt = _systemPromptController.text.trim();
    await ref.read(agentSystemPromptProvider.notifier).setSystemPrompt(systemPrompt.isNotEmpty ? systemPrompt : null);
  }
}
