import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controllers/task_management_controller.dart';
import 'task_dashboard_view.dart';
import 'task_list_view.dart';
import 'task_profile_view.dart';
import 'task_sync_queue_view.dart';
import 'task_theme.dart';

class TaskMainShell extends StatefulWidget {
  const TaskMainShell({super.key});

  @override
  State<TaskMainShell> createState() => _TaskMainShellState();
}

class _TaskMainShellState extends State<TaskMainShell> {
  int _currentIndex = 0;
  final TaskManagementController _controller =
      Get.put(TaskManagementController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TaskDashboardView(
        onNavigateTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const TaskListView(),
      const TaskSyncQueueView(),
      const TaskProfileView(),
    ];

    return Scaffold(
      backgroundColor: TaskTheme.background,
      body: Column(
        children: [
          // Offline persistent indicator banner
          Obx(() => !_controller.isOnline.value
              ? Container(
                  width: double.infinity,
                  color: const Color(0xFFB45309), // Amber 700
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: Colors.white, size: 14.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Offline Mode • All changes saving locally',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment_rounded,
                  label: 'Work Orders',
                  badgeCount: _controller.inProgressCount + _controller.assignedCount,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.cloud_upload_outlined,
                  activeIcon: Icons.cloud_upload_rounded,
                  label: 'Sync Queue',
                  badgeCount: _controller.pendingSyncCount,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? TaskTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 21.sp,
                  color: isSelected ? TaskTheme.primary : TaskTheme.textMuted,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: index == 2 ? TaskTheme.statusInProgress : TaskTheme.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(minWidth: 15.w),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? TaskTheme.primary : TaskTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
