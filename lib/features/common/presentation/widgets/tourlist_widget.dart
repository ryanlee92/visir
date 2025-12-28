import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/dependency/showcase_tutorial/src/showcase_widget.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:flutter/material.dart';

class TourListWidget extends StatefulWidget {
  static bool isOpened = false;
  final List<String> showcaseKeys;
  const TourListWidget({Key? key, required this.showcaseKeys}) : super(key: key);

  @override
  _TourListWidgetState createState() => _TourListWidgetState();
}

class _TourListWidgetState extends State<TourListWidget> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    TourListWidget.isOpened = true;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    TourListWidget.isOpened = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final entity = widget.showcaseKeys.map((e) => getShowcaseEntities()[e]!).toList();
    double buttonSize = 24;
    double iconSize = 16;
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Text(context.tr.tour_list_title, style: context.titleLarge?.textColor(context.onBackground).textBold),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
              child: Column(
                children: [
                  ...entity.map(
                    (e) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.listTitle, style: context.bodyLarge?.textColor(context.onBackground))),
                              SizedBox(width: 12),
                              VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  backgroundColor: context.primary,
                                  borderRadius: BorderRadius.circular(buttonSize / 2),
                                  width: buttonSize,
                                  height: buttonSize,
                                ),
                                onTap: () async {
                                  await Future.wait([
                                    Utils.ref
                                        .read(calendarTaskListControllerProvider(tabType: TabType.home).notifier)
                                        .refresh(showLoading: true, isChunkUpdate: true),
                                    Utils.ref
                                        .read(calendarEventListControllerProvider(tabType: TabType.home).notifier)
                                        .refresh(showLoading: true, isChunkUpdate: true),
                                  ]);
                                  await Future.delayed(Duration(milliseconds: 1000));
                                  Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
                                  ShowCaseWidget.of(Utils.mainContext).startShowCase([e.key]);
                                },
                                child: VisirIcon(type: VisirIconType.play, size: iconSize, color: context.onPrimary, isSelected: true),
                              ),
                            ],
                          ),
                        ),
                        if (e != entity.last)
                          Container(height: 1, color: context.outlineVariant.withValues(alpha: 0.2), margin: EdgeInsets.symmetric(horizontal: 16)),
                      ],
                    ),
                  ),
                  SizedBox(height: PlatformX.isMobileView ? context.padding.bottom : 8.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
