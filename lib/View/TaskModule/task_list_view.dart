import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Controllers/task_management_controller.dart';
import '../../Models/task_model.dart';
import 'task_completion_dialog.dart';
import 'task_theme.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskManagementController controller = TaskManagementController.to;

    final statusTabs = [
      'All',
      'Assigned',
      'Accepted',
      'In Progress',
      'Completed',
      'Pending Sync',
    ];

    return Scaffold(
      backgroundColor: TaskTheme.background,
      appBar: AppBar(
        title: Text('Work Orders', style: TaskTheme.headingBold(size: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                color: controller.isOnline.value
                    ? TaskTheme.statusCompleted
                    : TaskTheme.statusInProgress,
              ),
            ),
            onPressed: () => controller.toggleOnlineStatus(),
            tooltip: 'Toggle Network Mode',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: TaskTheme.bodyMedium(size: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, customer, service, address...',
                    hintStyle: TaskTheme.bodyRegular(
                      size: 13.sp,
                      color: TaskTheme.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: TaskTheme.textSecondary,
                      size: 20.sp,
                    ),
                    suffixIcon: Obx(
                      () => controller.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  controller.searchQuery.value = '',
                            )
                          : const SizedBox.shrink(),
                    ),
                    filled: true,
                    fillColor: TaskTheme.background,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Status Tabs
                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusTabs.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final tab = statusTabs[index];
                      return Obx(() {
                        final isSelected =
                            controller.selectedStatusFilter.value == tab;
                        return ChoiceChip(
                          label: Text(tab),
                          selected: isSelected,
                          onSelected: (_) =>
                              controller.selectedStatusFilter.value = tab,
                          selectedColor: TaskTheme.primary,
                          backgroundColor: Colors.white,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : TaskTheme.textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected
                                  ? TaskTheme.primary
                                  : TaskTheme.borderSubtle,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Task List Content
          Expanded(
            child: Obx(() {
              final tasks = controller.filteredTasks;

              if (tasks.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchTasksFromApi(),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(context, task, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskItem task,
    TaskManagementController controller,
  ) {
    Color statusBg;
    Color statusColor;
    switch (task.status) {
      case TaskStatus.assigned:
        statusBg = TaskTheme.statusAssignedBg;
        statusColor = TaskTheme.statusAssigned;
        break;
      case TaskStatus.accepted:
        statusBg = TaskTheme.statusAcceptedBg;
        statusColor = TaskTheme.statusAccepted;
        break;
      case TaskStatus.inProgress:
        statusBg = TaskTheme.statusInProgressBg;
        statusColor = TaskTheme.statusInProgress;
        break;
      case TaskStatus.completed:
        statusBg = TaskTheme.statusCompletedBg;
        statusColor = TaskTheme.statusCompleted;
        break;
    }

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = TaskTheme.priorityUrgent;
        break;
      case TaskPriority.high:
        priorityColor = TaskTheme.priorityHigh;
        break;
      case TaskPriority.medium:
        priorityColor = TaskTheme.priorityMedium;
        break;
      case TaskPriority.low:
        priorityColor = TaskTheme.priorityLow;
        break;
    }

    return InkWell(
      onTap: () => Get.toNamed('/tasks/${Uri.encodeComponent(task.id)}'),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: TaskTheme.shadowSoft,
          border: Border.all(
            color: task.status == TaskStatus.inProgress
                ? TaskTheme.statusInProgress.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID, Priority Dot, Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      task.taskNumber,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: TaskTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (task.syncState == SyncState.pending)
                      Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: TaskTheme.statusInProgressBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 13.sp,
                            color: TaskTheme.statusInProgress,
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        task.status.label,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Service Category & Title
            Text(
              task.serviceCategory,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: TaskTheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              task.title,
              style: TaskTheme.headingSemiBold(size: 15.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.h),

            // Customer & Location
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 15.sp,
                  color: TaskTheme.textMuted,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    task.customerName,
                    style: TaskTheme.bodyMedium(
                      size: 12.sp,
                      color: TaskTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.access_time_rounded,
                  size: 15.sp,
                  color: TaskTheme.textMuted,
                ),
                SizedBox(width: 4.w),
                Text(
                  DateFormat('hh:mm a').format(task.scheduledDateTime),
                  style: TaskTheme.bodyRegular(size: 12.sp),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15.sp,
                  color: TaskTheme.textMuted,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    task.customerAddress,
                    style: TaskTheme.bodyRegular(size: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Quick Actions Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.call_outlined,
                        color: TaskTheme.statusCompleted,
                        size: 20.sp,
                      ),
                      onPressed: () =>
                          controller.makePhoneCall(task.customerPhone),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 14.w),
                    IconButton(
                      icon: Icon(
                        Icons.navigation_outlined,
                        color: TaskTheme.primary,
                        size: 20.sp,
                      ),
                      onPressed: () => controller.openMapNavigation(
                        lat: task.customerLatitude,
                        lng: task.customerLongitude,
                        address: task.customerAddress,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                // Dynamic Status Action Button
                if (task.status == TaskStatus.assigned)
                  ElevatedButton(
                    onPressed: () => controller.acceptTask(task.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Accept',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else if (task.status == TaskStatus.accepted)
                  ElevatedButton(
                    onPressed: () => controller.startTask(task.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.statusInProgress,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Start Job',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else if (task.status == TaskStatus.inProgress)
                  ElevatedButton(
                    onPressed: () => TaskCompletionSheet.show(context, task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.statusCompleted,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Complete',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Completed',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: TaskTheme.statusCompleted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 56.sp,
            color: TaskTheme.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'No work orders found',
            style: TaskTheme.headingSemiBold(size: 16.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'Try adjusting your search or status filter.',
            style: TaskTheme.bodyRegular(size: 13.sp),
          ),
        ],
      ),
    );
  }
}
