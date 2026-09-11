import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controllers/task_management_controller.dart';
import '../../Models/task_model.dart';
import '../../common/app_toast.dart';
import 'task_theme.dart';

class TaskCompletionSheet extends StatefulWidget {
  final TaskItem task;

  const TaskCompletionSheet({super.key, required this.task});

  static Future<bool?> show(BuildContext context, TaskItem task) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskCompletionSheet(task: task),
    );
  }

  @override
  State<TaskCompletionSheet> createState() => _TaskCompletionSheetState();
}

class _TaskCompletionSheetState extends State<TaskCompletionSheet> {
  final TaskManagementController _controller = TaskManagementController.to;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerRemarkController = TextEditingController(
    text: 'Service completed to full satisfaction.',
  );

  late List<String> _selectedImages;
  bool _isCustomerSignedOff = true;

  @override
  void initState() {
    super.initState();
    _selectedImages = List<String>.from(widget.task.evidenceImages);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerRemarkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _controller.pickEvidenceImage(source);
    if (path != null) {
      setState(() {
        _selectedImages.add(path);
      });
    }
  }

  void _submitCompletion() async {
    if (_notesController.text.trim().isEmpty) {
      AppToast.error(
        'Notes Required',
        'Please enter service completion summary & notes.',
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      AppToast.error(
        'Photo Proof Required',
        'Please upload at least 1 image proof of completed work.',
      );
      return;
    }

    if (!_isCustomerSignedOff) {
      AppToast.error(
        'Customer Confirmation Required',
        'The customer must verify the work before completion.',
      );
      return;
    }

    final success = await _controller.completeTask(
      taskId: widget.task.id,
      completionNote: _notesController.text.trim(),
      images: _selectedImages,
      customerRemark: _customerRemarkController.text.trim(),
      isCustomerConfirmed: _isCustomerSignedOff,
    );

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        top: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: TaskTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: TaskTheme.statusCompletedBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: TaskTheme.statusCompleted,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Work Order',
                        style: TaskTheme.headingBold(size: 16.sp),
                      ),
                      Text(
                        widget.task.taskNumber,
                        style: TaskTheme.bodyRegular(size: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 1. Completion Notes
            Text(
              '1. Service Completion Notes *',
              style: TaskTheme.headingSemiBold(size: 13.sp),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TaskTheme.bodyMedium(size: 13.sp),
              decoration: InputDecoration(
                hintText:
                    'Describe work performed, parts replaced, or tests done...',
                hintStyle: TaskTheme.bodyRegular(
                  size: 12.sp,
                  color: TaskTheme.textMuted,
                ),
                filled: true,
                fillColor: TaskTheme.background,
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: TaskTheme.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: TaskTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: TaskTheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // 2. Photo Evidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2. Image Evidence (${_selectedImages.length} attached) *',
                  style: TaskTheme.headingSemiBold(size: 13.sp),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: Icon(Icons.camera_alt_outlined, size: 16.sp),
                      onPressed: () => _pickImage(ImageSource.camera),
                      tooltip: 'Take Photo',
                    ),
                    SizedBox(width: 4.w),
                    IconButton.filledTonal(
                      icon: Icon(Icons.photo_library_outlined, size: 16.sp),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      tooltip: 'Gallery',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (_selectedImages.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  color: TaskTheme.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: TaskTheme.borderSubtle,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: TaskTheme.textMuted,
                      size: 28.sp,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'No photo evidence added yet',
                      style: TaskTheme.bodyRegular(size: 12.sp),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final img = _selectedImages[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: img.startsWith('http')
                              ? Image.network(
                                  img,
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(img),
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 4.w,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 16.h),

            // 3. Customer Sign-off
            Text(
              '3. Customer Confirmation Remark',
              style: TaskTheme.headingSemiBold(size: 13.sp),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _customerRemarkController,
              style: TaskTheme.bodyMedium(size: 12.5.sp),
              decoration: InputDecoration(
                hintText: 'Customer feedback or signature notes',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                filled: true,
                fillColor: TaskTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: TaskTheme.borderSubtle),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                SizedBox(
                  height: 20.w,
                  width: 20.w,
                  child: Checkbox(
                    value: _isCustomerSignedOff,
                    activeColor: TaskTheme.statusCompleted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _isCustomerSignedOff = val ?? true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Customer has verified completed work & confirmed satisfaction',
                    style: TaskTheme.bodyRegular(size: 11.5.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _controller.isLoading.value
                      ? null
                      : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaskTheme.statusCompleted,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Confirm & Complete Work Order',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
