import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Controllers/task_management_controller.dart';
import '../../Models/task_model.dart';
import 'task_theme.dart';

class TaskSyncQueueView extends StatelessWidget {
  const TaskSyncQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskManagementController controller = TaskManagementController.to;

    return Scaffold(
      backgroundColor: TaskTheme.background,
      appBar: AppBar(
        title: Text(
          'Offline Sync Queue',
          style: TaskTheme.headingBold(size: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                  controller.isOnline.value
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: controller.isOnline.value
                      ? TaskTheme.statusCompleted
                      : TaskTheme.statusInProgress,
                )),
            onPressed: () => controller.toggleOnlineStatus(),
            tooltip: 'Simulate Connection',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Status Banner
            _buildNetworkStatusBanner(controller),
            SizedBox(height: 16.h),

            // Sync Summary Metrics
            _buildSyncMetrics(controller),
            SizedBox(height: 20.h),

            // Manual Sync Trigger Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSyncing.value
                        ? null
                        : () => controller.syncAllPending(),
                    icon: controller.isSyncing.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.cloud_upload_outlined, size: 20.sp),
                    label: Text(
                      controller.isSyncing.value
                          ? 'Synchronizing...'
                          : 'Sync All Pending Changes Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                )),
            SizedBox(height: 24.h),

            // Queue List Section Header
            Text(
              'Local Storage & Queue Activity',
              style: TaskTheme.headingSemiBold(size: 15.sp),
            ),
            SizedBox(height: 10.h),

            // Task Sync Items List
            Obx(() {
              final tasks = controller.tasks;
              if (tasks.isEmpty) {
                return const Center(child: Text('No offline activity.'));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildQueueItem(task, controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusBanner(TaskManagementController controller) {
    return Obx(() {
      final isOnline = controller.isOnline.value;

      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isOnline ? TaskTheme.statusCompletedBg : TaskTheme.statusInProgressBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isOnline
                ? TaskTheme.statusCompleted.withValues(alpha: 0.3)
                : TaskTheme.statusInProgress.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isOnline ? TaskTheme.statusCompleted : TaskTheme.statusInProgress,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnline
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? 'Online Mode - Auto Cloud Sync Active' : 'Offline Mode Enabled',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isOnline ? TaskTheme.statusCompleted : const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isOnline
                        ? 'All local edits, notes, and photos are being synced.'
                        : 'Changes are cached safely in local Hive DB.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: isOnline ? TaskTheme.statusCompleted : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSyncMetrics(TaskManagementController controller) {
    return Obx(() => Row(
          children: [
            _buildMetricBox(
              title: 'Synced Items',
              count: controller.tasks
                  .where((t) => t.syncState == SyncState.synced)
                  .length,
              color: TaskTheme.statusCompleted,
              bg: TaskTheme.statusCompletedBg,
            ),
            SizedBox(width: 10.w),
            _buildMetricBox(
              title: 'Pending Sync',
              count: controller.pendingSyncCount,
              color: TaskTheme.statusInProgress,
              bg: TaskTheme.statusInProgressBg,
            ),
            SizedBox(width: 10.w),
            _buildMetricBox(
              title: 'Failed',
              count: controller.failedSyncCount,
              color: TaskTheme.priorityUrgent,
              bg: TaskTheme.priorityUrgentBg,
            ),
          ],
        ));
  }

  Widget _buildMetricBox({
    required String title,
    required int count,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: TaskTheme.shadowSoft,
        ),
        child: Column(
          children: [
            Text(
              count.toString().padLeft(2, '0'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: TaskTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueItem(TaskItem task, TaskManagementController controller) {
    Color syncColor;
    Color syncBg;
    IconData syncIcon;

    switch (task.syncState) {
      case SyncState.synced:
        syncColor = TaskTheme.statusCompleted;
        syncBg = TaskTheme.statusCompletedBg;
        syncIcon = Icons.check_circle_outline_rounded;
        break;
      case SyncState.pending:
        syncColor = TaskTheme.statusInProgress;
        syncBg = TaskTheme.statusInProgressBg;
        syncIcon = Icons.cloud_upload_outlined;
        break;
      case SyncState.failed:
        syncColor = TaskTheme.priorityUrgent;
        syncBg = TaskTheme.priorityUrgentBg;
        syncIcon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: syncBg,
              shape: BoxShape.circle,
            ),
            child: Icon(syncIcon, color: syncColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.taskNumber,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: TaskTheme.textPrimary,
                      ),
                    ),
                    Text(
                      task.syncState.label,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: syncColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  task.title,
                  style: TaskTheme.bodyRegular(size: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Status: ${task.status.label} • Photos: ${task.evidenceImages.length} • Modified: ${DateFormat('hh:mm a').format(task.lastModified)}',
                  style: GoogleFonts.inter(
                      fontSize: 10.sp, color: TaskTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
