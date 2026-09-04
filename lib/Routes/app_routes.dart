import '../View/Login Module/OTP Verification Screen.dart';
import '../View/Login Module/Profile Creation Screen.dart';
import '../View/Login Module/Sign Up Screen.dart';
import '../View/Notification_List.dart';
import '../View/Splash screen.dart';
import '../View/TaskModule/task_login_screen.dart';
import '../View/TaskModule/task_detail_view.dart';
import '../View/TaskModule/task_main_shell.dart';
import '../common/export.dart';

class AppRoutes {
  static const String initialRoute = '/initialRoute';
  static const String splashScreen = '/splash_screen';
  static const String home = '/home';
  static const String bucketListScreen = '/BucketListScreen';
  static const String profileScreen = '/ProfileScreen';
  static const String projectDetailsScreen = '/ProjectDetailsScreen';
  static const String ratingPage = '/RatingPage';
  static const String landingPage = '/landingPage';
  static const String organizationPage = '/organizationPage';
  static const String servicePage = '/servicePage';
  static const String quotationPage = '/quotationPage';
  static const String login = '/login';
  static const String taskDetail = '/tasks/:taskId';
  static const String signUpScreen = '/SignUpScreen';
  static const String oTPVerificationScreen = '/OTPVerificationScreen';
  static const String profileCreationScreen = '/ProfileCreationScreen';
  static const String orderConfirmationPaymentScreen =
      '/OrderConfirmationPaymentScreen';
  static const String portfolioDetailsPage = '/portfolioDetailsPage';
  static const String paymentPlanMaterial = '/PaymentPlanMaterial';
  static const String notificationListPage = '/NotificationListPage';

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
    ),
    GetPage(
      name: signUpScreen,
      page: () => const SignUpScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: oTPVerificationScreen,
      page: () => const OTPVerificationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: profileCreationScreen,
      page: () => const ProfileCreationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: notificationListPage,
      page: () => const NotificationListPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
