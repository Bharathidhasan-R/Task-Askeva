import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controllers/task_management_controller.dart';
import 'task_theme.dart';

class TaskProfileView extends StatelessWidget {
  const TaskProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskManagementController controller = TaskManagementController.to;

    return Scaffold(
      backgroundColor: TaskTheme.background,
      appBar: AppBar(
        title: Text(
          'Technician Profile',
          style: TaskTheme.headingBold(size: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: TaskTheme.shadowSoft,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36.r,
                    backgroundColor: TaskTheme.primary,
                    child: Text(
                      'BR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    controller.userName.value,
                    style: TaskTheme.headingBold(size: 18.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${controller.userRole.value} • ${controller.employeeId.value}',
                    style: TaskTheme.bodyRegular(size: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: TaskTheme.statusCompletedBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Active & Available on Field',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: TaskTheme.statusCompleted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Performance Metrics
            Row(
              children: [
                _buildStatCard('Jobs Today', '05', Icons.assignment_turned_in_outlined,
                    TaskTheme.primary),
                SizedBox(width: 10.w),
                _buildStatCard('Rating', '4.9 ★', Icons.star_rounded,
                    TaskTheme.statusInProgress),
                SizedBox(width: 10.w),
                _buildStatCard('On-Time', '98%', Icons.access_time_rounded,
                    TaskTheme.statusCompleted),
              ],
            ),
            SizedBox(height: 20.h),

            // Equipment & Service Profile
            _buildSection(
              title: 'Equipment & Vehicle',
              items: [
                _buildListTile(
                  icon: Icons.directions_car_outlined,
                  title: 'Assigned Vehicle',
                  subtitle: 'TN 38 BL 4920 (Service Van)',
                ),
                _buildListTile(
                  icon: Icons.handyman_outlined,
                  title: 'Tool Kit ID',
                  subtitle: 'TK-ELECT-AC-088 (Calibrated)',
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Storage & Local DB
            _buildSection(
              title: 'Local Storage & Data',
              items: [
                _buildListTile(
                  icon: Icons.storage_rounded,
                  title: 'Offline DB Storage',
                  subtitle: 'Hive DB • 2.4 MB Cached',
                ),
                _buildListTile(
                  icon: Icons.cloud_done_outlined,
                  title: 'Last Cloud Sync',
                  subtitle: 'Today at 04:15 PM',
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, controller),
                icon: Icon(Icons.logout_rounded,
                    size: 18.sp, color: TaskTheme.priorityUrgent),
                label: Text(
                  'Sign Out of Work Orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: TaskTheme.priorityUrgent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: TaskTheme.priorityUrgent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: TaskTheme.shadowSoft,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: TaskTheme.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  color: TaskTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TaskTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
            child: Text(
              title,
              style: TaskTheme.headingSemiBold(size: 13.sp),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: const BoxDecoration(
          color: TaskTheme.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: TaskTheme.primary, size: 18.sp),
      ),
      title: Text(title, style: TaskTheme.bodyMedium(size: 13.sp)),
      subtitle: Text(subtitle,
          style: TaskTheme.bodyRegular(size: 12.sp, color: TaskTheme.textMuted)),
    );
  }

  void _confirmLogout(
      BuildContext context, TaskManagementController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
            'Are you sure you want to sign out? Any unsynced data will remain stored locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TaskTheme.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
