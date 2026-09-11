import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../routes/app_routes.dart';

class HiveMethods extends GetxController {
  String hiveBox = 'itemsDB';

  @override
  void onInit() {
    getUserId();
    getLocation();
    super.onInit();
  }

  dynamic box;
  var userid = "".obs;
  var customerId = "".obs;
  var token = "".obs;
  var location = "".obs;
  var phone = "".obs;

  Future getUserId() async {
    box = await Hive.openBox(hiveBox);
    userid.value = box.get('userId', defaultValue: "");
    customerId.value = box.get('customerId', defaultValue: "");
    token.value = box.get('token', defaultValue: "");
    phone.value = box.get('phone', defaultValue: "");
    location.value = box.get('location', defaultValue: "Coimbatore");
    Get.forceAppUpdate();
    update();
    debugPrint("UserId $userid");
    debugPrint("Location ${location.value}");
  }

  Future<void> deleteUserId() async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    Get.offAllNamed(AppRoutes.home);
    await box.delete('userId');
    await box.delete('customerId');
    await box.delete('token');
    await box.delete('phone');
    // Don't delete location on logout
    userid.value = "";
    debugPrint('User ID deleted');
    update();
    debugPrint(userid.toString());
  }

  // Save location to Hive
  Future<void> saveLocation(String selectedLocation) async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    await box.put('location', selectedLocation);
    location.value = selectedLocation;
    update();
    debugPrint('Location saved: $selectedLocation');
  }

  // Get saved location from Hive
  Future<String> getLocation() async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    String savedLocation = box.get('location', defaultValue: 'Coimbatore');
    location.value = savedLocation;
    return savedLocation;
  }

  // Delete saved location from Hive
  Future<void> deleteLocation() async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    await box.delete('location');
    location.value = 'Coimbatore'; // Reset to default
    update();
    debugPrint('Location deleted');
  }

  // Save full location details (latitude, longitude, city, state, etc.)
  Future<void> saveFullLocationDetails(Map<String, dynamic> details) async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    await box.put('full_location_details', details);

    // Also save the city name to location
    if (details.containsKey('city')) {
      await saveLocation(details['city']);
    }

    debugPrint('Full location details saved: $details');
  }

  // Get full location details
  Map<String, dynamic> getFullLocationDetails() {
    if (!Hive.isBoxOpen(hiveBox)) {
      return {};
    }

    final box = Hive.box(hiveBox);
    return box.get('full_location_details', defaultValue: <String, dynamic>{});
  }

  // Clear full location details
  Future<void> clearFullLocationDetails() async {
    if (!Hive.isBoxOpen(hiveBox)) {
      box = await Hive.openBox(hiveBox);
    } else {
      box = Hive.box(hiveBox);
    }

    await box.delete('full_location_details');
    debugPrint('Full location details cleared');
  }
}