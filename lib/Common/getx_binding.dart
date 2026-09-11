import 'package:get/get.dart';

import '../Controllers/hive_controller.dart';

class CommonBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(HiveMethods(), permanent: true);
  }
}

