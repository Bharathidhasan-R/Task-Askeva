import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../Controllers/task_management_controller.dart';
import '../../Models/task_model.dart';
import 'task_completion_dialog.dart';
import 'task_theme.dart';

class TaskDetailView extends StatelessWidget {
  final String taskId;

  const TaskDetailView({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final TaskManagementController controller = TaskManagementController.to;

    return Scaffold(
      backgroundColor: TaskTheme.background,
      appBar: AppBar(
        title: Text(
          'Work Order Details',
          style: TaskTheme.headingSemiBold(size: 16.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: TaskTheme.textPrimary, size: 22.sp),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                  controller.isOnline.value
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  color: controller.isOnline.value
                      ? TaskTheme.statusCompleted
                      : TaskTheme.statusInProgress,
                )),
            onPressed: () => controller.toggleOnlineStatus(),
            tooltip: 'Network & Cloud Status',
          ),
        ],
      ),
      body: Obx(() {
        final task = controller.getTaskById(taskId);
        if (task == null) {
          return const Center(child: Text('Task not found'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Overview Card
                    _buildTaskOverviewCard(task),
                    SizedBox(height: 16.h),

                    // Step Progress Indicator
                    _buildStepProgressIndicator(task),
                    SizedBox(height: 16.h),

                    // Customer Details & Quick Actions
                    _buildCustomerCard(task, controller),
                    SizedBox(height: 16.h),

                    // Location & Navigation Card
                    _buildLocationCard(task, controller),
                    SizedBox(height: 16.h),

                    // Location Tracking Coordinates
                    _buildGpsTrackingCard(task),
                    SizedBox(height: 16.h),

                    // Notes Timeline
                    _buildNotesCard(context, task, controller),
                    SizedBox(height: 16.h),

                    // Photo Evidence Gallery
                    _buildEvidenceCard(task, controller),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar
            _buildBottomActionBar(context, task, controller),
          ],
        );
      }),
    );
  }

  Widget _buildTaskOverviewCard(TaskItem task) {
    Color priorityColor;
    Color priorityBg;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = TaskTheme.priorityUrgent;
        priorityBg = TaskTheme.priorityUrgentBg;
        break;
      case TaskPriority.high:
        priorityColor = TaskTheme.priorityHigh;
        priorityBg = TaskTheme.priorityHighBg;
        break;
      case TaskPriority.medium:
        priorityColor = TaskTheme.priorityMedium;
        priorityBg = TaskTheme.priorityMediumBg;
        break;
      case TaskPriority.low:
        priorityColor = TaskTheme.priorityLow;
        priorityBg = TaskTheme.priorityLowBg;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: TaskTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  task.taskNumber,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: TaskTheme.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${task.priority.label} Priority',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            task.title,
            style: TaskTheme.headingBold(size: 17.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            task.description,
            style: TaskTheme.bodyRegular(size: 13.sp, color: TaskTheme.textSecondary),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 15.sp, color: TaskTheme.textMuted),
              SizedBox(width: 6.w),
              Text(
                'Scheduled: ${DateFormat('MMM dd, yyyy • hh:mm a').format(task.scheduledDateTime)}',
                style: TaskTheme.bodyMedium(size: 12.sp, color: TaskTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator(TaskItem task) {
    final steps = [
      TaskStatus.assigned,
      TaskStatus.accepted,
      TaskStatus.inProgress,
      TaskStatus.completed,
    ];

    final currentIndex = steps.indexOf(task.status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Order Status Timeline',
            style: TaskTheme.headingSemiBold(size: 14.sp),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isDone = index <= currentIndex;
              final isCurrent = index == currentIndex;

              Color stepColor;
              if (isCurrent) {
                stepColor = task.status == TaskStatus.completed
                    ? TaskTheme.statusCompleted
                    : task.status == TaskStatus.inProgress
                        ? TaskTheme.statusInProgress
                        : task.status == TaskStatus.accepted
                            ? TaskTheme.statusAccepted
                            : TaskTheme.statusAssigned;
              } else if (isDone) {
                stepColor = TaskTheme.statusCompleted;
              } else {
                stepColor = TaskTheme.borderSubtle;
              }

              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: BoxDecoration(
                            color: isDone ? stepColor : TaskTheme.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? stepColor : TaskTheme.borderSubtle,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isDone && !isCurrent
                                ? Icon(Icons.check, size: 13.sp, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDone ? Colors.white : TaskTheme.textMuted,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            steps[index].label,
                            style: GoogleFonts.inter(
                              fontSize: 9.5.sp,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent ? TaskTheme.textPrimary : TaskTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          margin: EdgeInsets.only(bottom: 14.h),
                          color: index < currentIndex
                              ? TaskTheme.statusCompleted
                              : TaskTheme.borderSubtle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(TaskItem task, TaskManagementController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      color: TaskTheme.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Customer Details',
                    style: TaskTheme.headingSemiBold(size: 14.sp),
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: () => controller.makePhoneCall(task.customerPhone),
                icon: Icon(Icons.call_outlined, size: 14.sp),
                label: Text('Call Now', style: GoogleFonts.inter(fontSize: 12.sp)),
                style: FilledButton.styleFrom(
                  backgroundColor: TaskTheme.statusCompletedBg,
                  foregroundColor: TaskTheme.statusCompleted,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            task.customerName,
            style: TaskTheme.headingSemiBold(size: 15.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            task.customerPhone,
            style: TaskTheme.bodyMedium(size: 13.sp, color: TaskTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(TaskItem task, TaskManagementController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: TaskTheme.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Service Address & Navigation',
                    style: TaskTheme.headingSemiBold(size: 14.sp),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => controller.openMapNavigation(
                  lat: task.customerLatitude,
                  lng: task.customerLongitude,
                  address: task.customerAddress,
                ),
                icon: Icon(Icons.navigation_outlined, size: 14.sp),
                label: Text('Navigate',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TaskTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  elevation: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            task.customerAddress,
            style: TaskTheme.bodyRegular(size: 13.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: TaskTheme.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location_rounded,
                    size: 14.sp, color: TaskTheme.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  'GPS: ${task.customerLatitude.toStringAsFixed(4)}, ${task.customerLongitude.toStringAsFixed(4)}',
                  style: GoogleFonts.inter(
                      fontSize: 11.sp, color: TaskTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsTrackingCard(TaskItem task) {
    if (task.startedAt == null && task.completedAt == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_toggle_off_rounded,
                  color: TaskTheme.primary, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Job Location & Timestamp Tracking',
                style: TaskTheme.headingSemiBold(size: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (task.startedAt != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: TaskTheme.statusInProgress,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Started: ${DateFormat('hh:mm a').format(task.startedAt!)} (GPS: ${task.startLatitude?.toStringAsFixed(4)}, ${task.startLongitude?.toStringAsFixed(4)})',
                      style: TaskTheme.bodyRegular(size: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
          if (task.completedAt != null)
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: TaskTheme.statusCompleted,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Completed: ${DateFormat('hh:mm a').format(task.completedAt!)} (GPS: ${task.completeLatitude?.toStringAsFixed(4)}, ${task.completeLongitude?.toStringAsFixed(4)})',
                    style: TaskTheme.bodyRegular(size: 12.sp),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(
      BuildContext context, TaskItem task, TaskManagementController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notes_rounded,
                      color: TaskTheme.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Job Activity & Notes (${task.notes.length})',
                    style: TaskTheme.headingSemiBold(size: 14.sp),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showAddNoteDialog(context, task, controller),
                icon: Icon(Icons.add_rounded, size: 14.sp),
                label: Text('Add Note', style: GoogleFonts.inter(fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (task.notes.isEmpty)
            Text(
              'No notes recorded yet.',
              style: TaskTheme.bodyRegular(size: 13.sp, color: TaskTheme.textMuted),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.notes.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final note = task.notes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note.authorName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: TaskTheme.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a • dd MMM').format(note.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: TaskTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      note.content,
                      style: TaskTheme.bodyRegular(size: 13.sp),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(TaskItem task, TaskManagementController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_camera_back_outlined,
                      color: TaskTheme.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Photo Evidence (${task.evidenceImages.length})',
                    style: TaskTheme.headingSemiBold(size: 14.sp),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: Icon(Icons.camera_alt_outlined, size: 16.sp),
                    onPressed: () =>
                        controller.attachPhotoToTask(task.id, ImageSource.camera),
                    tooltip: 'Take Photo',
                  ),
                  SizedBox(width: 4.w),
                  IconButton.filledTonal(
                    icon: Icon(Icons.photo_library_outlined, size: 16.sp),
                    onPressed: () =>
                        controller.attachPhotoToTask(task.id, ImageSource.gallery),
                    tooltip: 'Gallery',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (task.evidenceImages.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: TaskTheme.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  'No photos captured yet.',
                  style: TaskTheme.bodyRegular(
                      size: 13.sp, color: TaskTheme.textMuted),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.evidenceImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final img = task.evidenceImages[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: img.startsWith('http')
                      ? Image.network(img, fit: BoxFit.cover)
                      : Image.file(File(img), fit: BoxFit.cover),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
      BuildContext context, TaskItem task, TaskManagementController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (task.status == TaskStatus.assigned)
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.acceptTask(task.id),
                    icon: Icon(Icons.check_circle_outline, size: 18.sp),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Accept Work Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
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
                ),
              )
            else if (task.status == TaskStatus.accepted)
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.startTask(task.id),
                    icon: Icon(Icons.play_arrow_rounded, size: 18.sp),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Start Job (Capture GPS)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.statusInProgress,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              )
            else if (task.status == TaskStatus.inProgress)
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => TaskCompletionSheet.show(context, task),
                    icon: Icon(Icons.check_circle_rounded, size: 18.sp),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Complete Work Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaskTheme.statusCompleted,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: TaskTheme.statusCompletedBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: TaskTheme.statusCompleted),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: TaskTheme.statusCompleted, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Work Order Completed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: TaskTheme.statusCompleted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(
      BuildContext context, TaskItem task, TaskManagementController controller) {
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Add Work Note', style: TaskTheme.headingBold(size: 16.sp)),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter observation, customer note, or parts needed...',
            filled: true,
            fillColor: TaskTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: TaskTheme.borderSubtle),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addNote(task.id, noteController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TaskTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}
