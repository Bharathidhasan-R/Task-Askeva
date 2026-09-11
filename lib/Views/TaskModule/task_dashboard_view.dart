import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Controllers/task_management_controller.dart';
import '../../Models/task_model.dart';
import 'task_theme.dart';

class TaskDashboardView extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;

  const TaskDashboardView({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final TaskManagementController controller = TaskManagementController.to;

    return Scaffold(
      backgroundColor: TaskTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchTasksFromApi(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Profile & Status Bar
                _buildHeader(controller),
                SizedBox(height: 18.h),

                // Status Metrics Grid
                _buildMetricsGrid(controller),
                SizedBox(height: 20.h),

                // Active Job Spotlight
                _buildSpotlightCard(context, controller),
                SizedBox(height: 20.h),

                // Quick Actions Row
                _buildQuickActions(context, controller),
                SizedBox(height: 24.h),

                // Recent Assigned Tasks Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Today's Work Orders",
                        style: TaskTheme.headingBold(size: 16.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(1); // Go to Task List Tab
                        }
                      },
                      child: Text(
                        'View All (${controller.totalCount})',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: TaskTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Recent Task Items
                Obx(() {
                  final recentTasks = controller.tasks.take(3).toList();
                  if (recentTasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks assigned today.'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTasks.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final task = recentTasks[index];
                      return _buildRecentTaskTile(context, task, controller);
                    },
                  );
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TaskManagementController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Obx(() {
                final name = controller.userName.value.isNotEmpty
                    ? controller.userName.value
                    : 'Bharathi';
                final initials = name
                    .trim()
                    .split(' ')
                    .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                    .take(2)
                    .join();
                return CircleAvatar(
                  radius: 20.r,
                  backgroundColor: TaskTheme.primary,
                  child: Text(
                    initials.isNotEmpty ? initials : 'BR',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                );
              }),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${controller.userName.value.isNotEmpty ? controller.userName.value : 'Bharathi'} 👋',
                        style: TaskTheme.headingBold(size: 15.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${controller.userRole.value.toUpperCase()} • On Duty',
                        style: TaskTheme.bodyRegular(size: 11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Obx(
          () => InkWell(
            onTap: () => controller.toggleOnlineStatus(),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: controller.isOnline.value
                    ? TaskTheme.statusCompletedBg
                    : TaskTheme.statusInProgressBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: controller.isOnline.value
                      ? TaskTheme.statusCompleted.withValues(alpha: 0.3)
                      : TaskTheme.statusInProgress.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: controller.isOnline.value
                          ? TaskTheme.statusCompleted
                          : TaskTheme.statusInProgress,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    controller.isOnline.value ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: controller.isOnline.value
                          ? TaskTheme.statusCompleted
                          : TaskTheme.statusInProgress,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(TaskManagementController controller) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.85,
        children: [
          _buildMetricCard(
            title: 'Assigned',
            count: controller.assignedCount,
            icon: Icons.assignment_outlined,
            color: TaskTheme.statusAssigned,
            bg: TaskTheme.statusAssignedBg,
            onTap: () {
              controller.selectedStatusFilter.value = 'Assigned';
              if (onNavigateTab != null) onNavigateTab!(1);
            },
          ),
          _buildMetricCard(
            title: 'Accepted',
            count: controller.acceptedCount,
            icon: Icons.check_circle_outline_rounded,
            color: TaskTheme.statusAccepted,
            bg: TaskTheme.statusAcceptedBg,
            onTap: () {
              controller.selectedStatusFilter.value = 'Accepted';
              if (onNavigateTab != null) onNavigateTab!(1);
            },
          ),
          _buildMetricCard(
            title: 'In Progress',
            count: controller.inProgressCount,
            icon: Icons.play_circle_outline_rounded,
            color: TaskTheme.statusInProgress,
            bg: TaskTheme.statusInProgressBg,
            onTap: () {
              controller.selectedStatusFilter.value = 'In Progress';
              if (onNavigateTab != null) onNavigateTab!(1);
            },
          ),
          _buildMetricCard(
            title: 'Completed',
            count: controller.completedCount,
            icon: Icons.task_alt_rounded,
            color: TaskTheme.statusCompleted,
            bg: TaskTheme.statusCompletedBg,
            onTap: () {
              controller.selectedStatusFilter.value = 'Completed';
              if (onNavigateTab != null) onNavigateTab!(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: TaskTheme.shadowSoft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count.toString().padLeft(2, '0'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: TaskTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightCard(
    BuildContext context,
    TaskManagementController controller,
  ) {
    return Obx(() {
      final active = controller.activeSpotlightTask;
      if (active == null) return const SizedBox.shrink();

      final isInProgress = active.status == TaskStatus.inProgress;

      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: TaskTheme.headerGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isInProgress
                        ? TaskTheme.statusInProgress
                        : TaskTheme.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInProgress
                            ? Icons.play_arrow_rounded
                            : Icons.info_outline_rounded,
                        size: 13.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isInProgress ? 'ACTIVE IN PROGRESS' : 'NEXT UP',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  active.taskNumber,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              active.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${active.customerName} • ${active.customerAddress}',
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                color: Colors.white60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        controller.makePhoneCall(active.customerPhone),
                    icon: Icon(
                      Icons.call_outlined,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Call Customer',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 4.w,
                      ),
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.toNamed('/tasks/${Uri.encodeComponent(active.id)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInProgress
                          ? TaskTheme.statusInProgress
                          : TaskTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 4.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Open Job',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions(
    BuildContext context,
    TaskManagementController controller,
  ) {
    return Row(
      children: [
        _buildActionPill(
          icon: Icons.cloud_upload_outlined,
          label: 'Sync Queue (${controller.pendingSyncCount})',
          color: TaskTheme.primary,
          onTap: () {
            if (onNavigateTab != null) onNavigateTab!(2); // Go to Sync tab
          },
        ),
        SizedBox(width: 8.w),
        _buildActionPill(
          icon: Icons.support_agent_rounded,
          label: 'Helpdesk Support',
          color: TaskTheme.secondary,
          onTap: () => controller.makePhoneCall('+914224000111'),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: TaskTheme.shadowSoft,
            border: Border.all(color: TaskTheme.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15.sp, color: color),
              SizedBox(width: 5.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: TaskTheme.textPrimary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTaskTile(
    BuildContext context,
    TaskItem task,
    TaskManagementController controller,
  ) {
    Color statusColor;
    switch (task.status) {
      case TaskStatus.assigned:
        statusColor = TaskTheme.statusAssigned;
        break;
      case TaskStatus.accepted:
        statusColor = TaskTheme.statusAccepted;
        break;
      case TaskStatus.inProgress:
        statusColor = TaskTheme.statusInProgress;
        break;
      case TaskStatus.completed:
        statusColor = TaskTheme.statusCompleted;
        break;
    }

    return InkWell(
      onTap: () => Get.toNamed('/tasks/${Uri.encodeComponent(task.id)}'),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: TaskTheme.shadowSoft,
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TaskTheme.headingSemiBold(size: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${task.customerName} • ${DateFormat('hh:mm a').format(task.scheduledDateTime)}',
                    style: TaskTheme.bodyRegular(size: 11.sp),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TaskTheme.textMuted,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
