import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/presentation/widgets/url_viewer_widget.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const TermsScreen({super.key, required this.isSmall, this.onClose});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    widget.onClose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    return LayoutBuilder(
      builder: (context, constraints) {
        return DetailsItem(
          title: widget.isSmall ? context.tr.pref_terms : null,
          appbarColor: PlatformX.isDesktopView ? context.surface : context.background,
          scrollController: _scrollController,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          child: UrlViewer(
            url: Constants.tosUrl,
            isMobileView: PlatformX.isMobileView,
            initialWidth: constraints.maxWidth,
            isDarkTheme: context.isDarkMode,
            close: false,
          ),
        );
      },
    );
  }
}
