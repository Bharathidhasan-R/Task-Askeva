import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Views/TaskModule/task_detail_view.dart';
import '../Views/TaskModule/task_login_screen.dart';
import '../Views/TaskModule/task_main_shell.dart';
import '../Views/splash_screen.dart';

class AppRoutes {
  static const String initialRoute = '/initialRoute';
  static const String home = '/home';
  static const String landingPage = '/landingPage';
  static const String login = '/login';
  static const String taskDetail = '/tasks/:taskId';

  static List<GetPage> pages = [
    GetPage(
      name: initialRoute,
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 500),
      page: () => LayoutBuilder(
        builder: (context, constraints) {
          return const SplashScreen();
        },
      ),
    ),
    GetPage(
      name: home,
      page: () => const TaskMainShell(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: landingPage,
      page: () => const TaskMainShell(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: login,
      page: () => const TaskLoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: taskDetail,
      page: () => TaskDetailView(taskId: Get.parameters['taskId'] ?? ''),
      transition: Transition.rightToLeft,
    )
  ];
}
