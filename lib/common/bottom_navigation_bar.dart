import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../App Configuration/app_config.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor:AppConfig.primaryColor,
        unselectedItemColor: const Color(0xFF666666),
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        iconSize: 24,
        items: const [
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome03,
              color: Colors.black,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome03,
              color: AppConfig.primaryColor,
            ),
            label: 'Home',

          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUserMultiple03,
              color: Color(0xFF666666),
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedUserMultiple03,
              color: AppConfig.primaryColor,
            ),
            label: 'Matches',
          ),
          // BottomNavigationBarItem(
          //   icon: HugeIcon(
          //     icon: HugeIcons.strokeRoundedMail01,
          //     color: Color(0xFF666666),
          //   ),
          //   activeIcon: HugeIcon(
          //     icon: HugeIcons.strokeRoundedMail01,
          //     color:AppConfig.primaryColor,
          //   ),
          //   label: 'Inbox',
          // ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedBubbleChat,
              color: Color(0xFF666666),
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedBubbleChat,
              color: AppConfig.primaryColor,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCouponPercent,
              color: Color(0xFF666666),
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedCouponPercent,
              color: AppConfig.primaryColor,
            ),
            label: 'Premium',
          ),
        ],
      ),
    );
  }
}
