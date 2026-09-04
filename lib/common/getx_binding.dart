import '../Controllers/Hive_controller.dart';
import '../Controllers/Services_Controller.dart';
import 'export.dart';

class CommonBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    // await DBService.initDB();
    // var settingController = Get.put(SettingsController());
    Get.put(ServiceController(), permanent: true);
    Get.put(HiveMethods(), permanent: true);
  }
}

