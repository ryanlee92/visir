import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/dependency/master_detail_flow/src/widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/presentation/screens/task_list_screen.dart';
import 'package:Visir/features/task/presentation/widgets/task_list_add_task_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_side_bar.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TaskScreenState();
}

class TaskScreenState extends ConsumerState<TaskScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool get isMobileView => PlatformX.isMobileView;

  bool get isSidebarOpen => adminScaffoldKey.currentState?.isDrawerOpen ?? false;

  GlobalKey<AdminScaffoldState> adminScaffoldKey = GlobalKey<AdminScaffoldState>();

  GlobalKey<TaskListAddTaskWidgetState> addTaskWidgetKey = GlobalKey<TaskListAddTaskWidgetState>();

  DateTime? dateOnAddTask;

  ScrollController scrollController = ScrollController();

  bool get isDarkMode => context.isDarkMode;

  void setDateOnAddTask(DateTime? date) {
    if (isMobileView) return;
    dateOnAddTask = null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
      addTaskWidgetKey.currentState?.initiate(date);
      dateOnAddTask = date;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    });
  }

  GlobalKey<MasterDetailsFlowState> masterDetailsKey = GlobalKey<MasterDetailsFlowState>();

  void openDetails({required String? id}) {
    if (id == null) return;
    masterDetailsKey.currentState?.openDetails(id: id);
    UserActionSwtichAction.onTaskAction();
  }

  void toggleSidebar() {
    adminScaffoldKey.currentState?.toggleSidebar();
  }

  void closeDetails() {
    ref.read(resizableClosableWidgetProvider(TabType.task).notifier).setWidget(null);
    masterDetailsKey.currentState?.closeDetails();
  }

  @override
  void initState() {
    super.initState();
    tabNotifier.addListener(tabNotifierListener);
  }

  void tabNotifierListener() {
    if (tabNotifier.value != TabType.task) setDateOnAddTask(null);
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabNotifier.removeListener(tabNotifierListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen(resizableClosableDrawerProvider(TabType.task), (previous, next) {});

    return AdminScaffold(
      key: adminScaffoldKey,
      tabType: TabType.task,
      sideBar: TaskSideBar(
        tabType: TabType.task,
        onSelected: (item) {
          final taskLabelList = ref.read(taskListControllerProvider).taskLabelList;
          final taskLabel = taskLabelList.firstWhereOrNull((e) => e.id == item.route) ?? taskLabelList.first;
          ref.read(taskLabelProvider.notifier).updateLabel(taskLabel);
          closeDetails();
          setDateOnAddTask(null);
        },
      ),
      body: TaskListScreen(
        addTaskWidgetKey: addTaskWidgetKey,
        dateOnAddTask: dateOnAddTask,
        setDateOnAddTask: setDateOnAddTask,
        masterDetailsKey: masterDetailsKey,
        openDetails: openDetails,
        closeDetails: closeDetails,
        toggleSidebar: toggleSidebar,
        scrollController: scrollController,
      ),
    );
  }
}
