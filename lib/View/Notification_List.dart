import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../Controllers/Login_controller.dart';
import '../common/app_safe_area.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  var mainController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    mainController.getNotificationList("customerNotificationList", {});
  }

  // Helper method to get notification style based on title
  Map<String, dynamic> _getNotificationStyle(String title) {
    if (title.toLowerCase().contains("payment successful")) {
      return {
        'icon': HugeIcons.strokeRoundedMoneyReceive01,
        'iconColor': const Color(0xFF12B669),
        'backgroundColor': const Color(0xFFECFDF3),
      };
    } else if (title.toLowerCase().contains("ask payment")) {
      return {
        'icon': HugeIcons.strokeRoundedMoneyNotFound02,
        'iconColor': const Color(0xFFF79009),
        'backgroundColor': const Color(0xFFFEF0C7),
      };
    } else {
      // Default style for other notifications
      return {
        'icon': HugeIcons.strokeRoundedMail01,
        'iconColor': const Color(0xFF0BA5EC),
        'backgroundColor': const Color(0xFFF0F9FF),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      backgroundColor: const Color(0xFFF7FAFC),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        body: Column(
          children: [
            // Fixed Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Color(0xFF183954),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF183954),
                        fontSize: 18,
                        fontFamily: 'Figtree-Bold',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            // Scrollable Notification List with Obx
            Expanded(
              child: Obx(() {
                // Check if loading
                if (mainController.notificationListResponseStatus.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF183954),
                    ),
                  );
                }

                // Check if notifications list is empty
                if (mainController.notificationListData.value.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification01,
                          color: Color(0xFF98A2B3),
                          size: 64.0,
                          strokeWidth: 2.0,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: Color(0xFF475467),
                            fontSize: 16,
                            fontFamily: 'Figtree-Medium',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Display notifications
                return RefreshIndicator(
                  onRefresh: () async {
                    await mainController.getNotificationList(
                        "vendorNotificationList", {});
                  },
                  color: const Color(0xFF183954),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: mainController.notificationListData.value.data!.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification =
                      mainController.notificationListData.value.data![index];

                      // Get notification style based on title
                      final notificationStyle = _getNotificationStyle(
                          notification.title ?? '');

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: notification.readStatus == 0
                              ? Colors.white
                              : const Color(0xFFFAFAFA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0xFF000000).withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Container - Dynamic based on notification type
                            Container(
                              width: 44,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: notificationStyle['backgroundColor'],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: notificationStyle['icon'],
                                  size: 22.0,
                                  color: notificationStyle['iconColor'],
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title.toString(),
                                          style: const TextStyle(
                                            color: Color(0xFF183954),
                                            fontSize: 14,
                                            fontFamily: 'Figtree-SemiBold',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // Unread indicator
                                      if (notification.readStatus == 0)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF6B2C),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notification.description.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF475467),
                                      fontSize: 13,
                                      fontFamily: 'Figtree-Regular',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDateTime(notification.createdAt.toString()),
                                    style: const TextStyle(
                                      color: Color(0xFF98A2B3),
                                      fontSize: 11,
                                      fontFamily: 'Figtree-Medium',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(String dateTimeStr) {
  try {
    final dateTime = DateTime.parse(dateTimeStr);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  } catch (e) {
    return '';
  }
}
