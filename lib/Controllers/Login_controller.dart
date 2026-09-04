import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/adapters.dart';
import '../Api_config/api/api_service.dart';
import '../App Configuration/app_config.dart';
import '../Models/City_list_model.dart';
import '../Models/Customer_Setting_Model.dart';
import '../Models/File_upload_model.dart';
import '../Models/Notification_List_Model.dart';
import '../Models/State_list_model.dart';
import '../View/notification.dart';
import '../common/dropdown_item.dart';
import '../common/export.dart' hide FormData, MultipartFile;
import 'Hive_controller.dart';

class LoginController extends GetxController {
  var hiveMethod = Get.put(HiveMethods());
  static const String hiveBox = 'itemsDB';

  /// --------------------------Vendor Login  ------------------------------------------
  final TextEditingController loginPhoneController = TextEditingController();
  var loginResponseStatus = false.obs;
  var loginData = <String, dynamic>{}.obs;

  Future getVendorLogin(
    String endPoint,
    Map<String, dynamic> queryParameters,
  )
  async
  {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    loginResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          loginData.value = result;

          if (result["success"] == true) {
            // Success case

            await saveVendorData(result);
            // commonFunctions.successSnackBar(
            //     Get.overlayContext!, result["message"]);
            // OtpNotification.show(
            //   Get.overlayContext!,
            //   result["otp"].toString(),
            // );
            otpController.clear();
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      loginResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  Future<void> saveVendorData(result) async {
    try {
      final box = await Hive.openBox(hiveBox);
      // Fixed: Changed OR to AND for proper null/empty check
      if (result['customerId'] != null && result['customerId'] != "") {
        await box.put('customerId', result['customerId'].toString());
        await box.put('phone', loginPhoneController.text);
        debugPrint("User ID saved: ${result['customerId'].toString()}");
      } else {
        debugPrint("Warning: User ID is null or empty");
      }
    } catch (e) {
      debugPrint("Error saving user data: ${e.toString()}");
      // Don't throw error, just log it - login can still proceed
    }
  }

  /// --------------------------Sign Up ------------------------------------------

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedCountryCode = '+91';

  var signUpResponseStatus = false.obs;
  var signUpData = <String, dynamic>{}.obs;

  Future getSignUp(
    String endPoint,
    Map<String, dynamic> queryParameters,
  )
  async
  {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    signUpResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          signUpData.value = result;

          if (result["success"] == true) {
            // Success case

            await _saveUserData(result);
            // commonFunctions.successSnackBar(
            //     Get.overlayContext!, result["message"]);
            // OtpNotification.show(
            //   Get.overlayContext!,
            //   result["otp"].toString(),
            // );
            nameController.clear();
            emailController.clear();
            phoneController.clear();
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      signUpResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  Future<void> _saveUserData(result) async {
    try {
      final box = await Hive.openBox(hiveBox);
      // Fixed: Changed OR to AND for proper null/empty check
      if (result['customerId'] != null && result['customerId'] != "") {
        await box.put('customerId', result['customerId'].toString());
        await box.put('phone', phoneController.text);
        debugPrint("User ID saved: ${result['customerId'].toString()}");
      } else {
        debugPrint("Warning: User ID is null or empty");
      }
    } catch (e) {
      debugPrint("Error saving user data: ${e.toString()}");
      // Don't throw error, just log it - login can still proceed
    }
  }

  /// --------------------------verify Otp ------------------------------------------
  final TextEditingController otpController = TextEditingController();

  var verifyOtpResponseStatus = false.obs;
  var verifyOtpData = <String, dynamic>{}.obs;

  Future getVerifyOtp(
    String endPoint,
    Map<String, dynamic> queryParameters,
  )
  async
  {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    verifyOtpResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          verifyOtpData.value = result;

          if (result["success"] == true) {
            // Success case

            await saveUserToken(result);
            // commonFunctions.successSnackBar(
            //     Get.overlayContext!, result["message"]);
            commonFunctions.successSnackBar(
              Get.overlayContext!,
              result["message"],
            );
            otpController.clear();
            loginPhoneController.clear();
           // await getVendorInfoDetails("vendorInfo");
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      verifyOtpResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  Future<void> saveUserToken(result) async {
    try {
      final box = await Hive.openBox(hiveBox);
      // Fixed: Changed OR to AND for proper null/empty check
      if (result['token'] != null && result['token'] != "") {
        await box.put('token', result['token'].toString());
        await box.put('userId', result['customerId'].toString());
        debugPrint("User ID saved: ${result['customerId']}");
      } else {
        debugPrint("Warning: User ID is null or empty");
      }
    } catch (e) {
      debugPrint("Error saving user data: ${e.toString()}");
      // Don't throw error, just log it - login can still proceed
    }
  }

  /// --------------------------Re Send Otp ------------------------------------------

  var reSendOtpResponseStatus = false.obs;
  var reSendOtpData = <String, dynamic>{}.obs;

  Future getResendOtp(
    String endPoint,
    Map<String, dynamic> queryParameters,
  )
  async
  {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    reSendOtpResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          reSendOtpData.value = result;

          if (result["success"] == true) {
            // OtpNotification.show(
            //   Get.overlayContext!,
            //   result["otp"].toString(),
            // );
            otpController.clear();
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      reSendOtpResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  /// --------------------------State List ------------------------------------------

  var stateListResponseStatus = false.obs;
  var stateListData = StateListModel().obs;

  Future getStateList(String endPoint) async {
    // Set loading to true at the start
    stateListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().get(endpoint: endPoint);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = StateListModel.fromJson(homeResponse.data);
        stateListData.value = result;
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }
      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      stateListResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------City List ------------------------------------------

  var cityListResponseStatus = false.obs;
  var cityListData = CityListModel().obs;

  Future getCityList(
    String endPoint,
    Map<String, dynamic> queryParameters,
  )
  async
  {
    // Set loading to true at the start
    cityListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CityListModel.fromJson(homeResponse.data);
        cityListData.value = result;
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }
      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      cityListResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Proof List ------------------------------------------

  // var proofListResponseStatus = false.obs;
  // var proofListData = ProofListModel().obs;
  //
  // Future getProofList( String endPoint,
  //     Map<String, dynamic> queryParameters,)
  // async
  // {
  //   // Set loading to true at the start
  //   proofListResponseStatus.value = true;
  //   update();
  //
  //   try {
  //     var homeResponse = await ApiService().post(
  //       endpoint: endPoint,
  //       queryParameters: queryParameters,
  //     );
  //
  //     debugPrint("Response Status Code: ${homeResponse.statusCode}");
  //     debugPrint("Response Data: ${homeResponse.data}");
  //
  //     if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
  //       var result = ProofListModel.fromJson(homeResponse.data);
  //       proofListData.value = result;
  //     } else {
  //       // Handle other status codes (400, 404, 500, etc.)
  //       debugPrint("Server returned status code: ${homeResponse.statusCode}");
  //       String errorMessage = "Server error occurred";
  //
  //       commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //     }
  //   } on DioException catch (dioError) {
  //     // Handle Dio-specific errors (network, timeout, 404, etc.)
  //     debugPrint("DioException: ${dioError.type}");
  //     debugPrint("DioException Message: ${dioError.message}");
  //     debugPrint("DioException Response: ${dioError.response?.data}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     switch (dioError.type) {
  //       case DioExceptionType.connectionTimeout:
  //       case DioExceptionType.sendTimeout:
  //       case DioExceptionType.receiveTimeout:
  //         errorMessage = 'Connection timeout. Please try again.';
  //         break;
  //       case DioExceptionType.badResponse:
  //       // Handle 404, 500, etc.
  //         if (dioError.response?.statusCode == 404) {
  //           errorMessage = 'API endpoint not found. Please contact support.';
  //         } else if (dioError.response?.statusCode == 500) {
  //           errorMessage = 'Server error. Please try again later.';
  //         } else {
  //           // Try to extract error message from response
  //           if (dioError.response?.data != null) {
  //             if (dioError.response?.data is Map &&
  //                 dioError.response?.data["msg"] != null) {
  //               errorMessage = dioError.response?.data["msg"];
  //             } else if (dioError.response?.data is String) {
  //               errorMessage = dioError.response?.data;
  //             } else {
  //               errorMessage = 'Error: ${dioError.response?.statusCode}';
  //             }
  //           }
  //         }
  //         break;
  //       case DioExceptionType.cancel:
  //         errorMessage = 'Request cancelled';
  //         break;
  //       case DioExceptionType.connectionError:
  //         errorMessage = 'No internet connection';
  //         break;
  //       default:
  //         errorMessage = 'Network error. Please check your connection.';
  //     }
  //
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } catch (e) {
  //     // Handle any other exceptions
  //     debugPrint("General Exception: ${e.toString()}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     // Try to parse error message
  //     var array = e.toString().split(': ');
  //     if (array.length > 1) {
  //       var secondArray = array[1].split(' [');
  //       if (secondArray.isNotEmpty) {
  //         errorMessage = secondArray[0];
  //       }
  //     }
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } finally {
  //     proofListResponseStatus.value = false;
  //     update();
  //   }
  // }

  /// --------------------------file Upload List------------------------------------------

  var fileUploadResponseStatus = false.obs;
  var fileUploadData = FileUploadModel().obs;

  Future getFileUpload(String endPoint, {File? imageFile, List<File>? imageFiles}) async {
    fileUploadResponseStatus.value = true;
    update();

    try {
      FormData formData = FormData();

      // Collect all files to upload
      List<File> filesToUpload = [];

      // Add single file if provided
      if (imageFile != null) {
        filesToUpload.add(imageFile);
      }

      // Add multiple files if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        filesToUpload.addAll(imageFiles);
      }

      // Check if there are any files to upload
      if (filesToUpload.isEmpty) {
        debugPrint("No files to upload");
        commonFunctions.errorSnackBar(
          Get.overlayContext!,
          "No files selected for upload",
        );
        return;
      }

      // Add all files to FormData
      for (var file in filesToUpload) {
        String fileName = file.path.split("/").last;

        formData.files.add(
          MapEntry(
            "upload_files", // Note: Added [] for array - adjust based on your API requirements
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );

        debugPrint("Image added: $fileName");
      }

      debugPrint("Total files to upload: ${filesToUpload.length}");

      // Send the request
      var homeResponse = await ApiService().postMultipart(
        endpoint: endPoint,
        formData: formData,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = FileUploadModel.fromJson(homeResponse.data);
        fileUploadData.value = result;
      } else {
        debugPrint("Server returned status: ${homeResponse.statusCode}");
        commonFunctions.errorSnackBar(
          Get.overlayContext!,
          "Server error occurred",
        );
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = "Something went wrong";

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;

        case DioExceptionType.badResponse:
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try later.';
          } else {
            if (dioError.response?.data != null &&
                dioError.response?.data is Map &&
                dioError.response?.data["msg"] != null) {
              errorMessage = dioError.response?.data["msg"];
            }
          }
          break;

        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;

        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;

        default:
          errorMessage = 'Network error occurred';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = "Something went wrong";

      // Extract readable error
      var parts = e.toString().split(": ");
      if (parts.length > 1) errorMessage = parts[1];

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      fileUploadResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------Service Tags List ------------------------------------------

  // var serviceTagsListResponseStatus = false.obs;
  // var serviceTagsListData = ServiceTagsModel().obs;
  //
  // Future getServiceTags(String endPoint) async {
  //   // Set loading to true at the start
  //   serviceTagsListResponseStatus.value = true;
  //   update();
  //
  //   try {
  //     var homeResponse = await ApiService().get(endpoint: endPoint);
  //
  //     debugPrint("Response Status Code: ${homeResponse.statusCode}");
  //     debugPrint("Response Data: ${homeResponse.data}");
  //
  //     if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
  //       var result = ServiceTagsModel.fromJson(homeResponse.data);
  //       serviceTagsListData.value = result;
  //     } else {
  //       // Handle other status codes (400, 404, 500, etc.)
  //       debugPrint("Server returned status code: ${homeResponse.statusCode}");
  //       String errorMessage = "Server error occurred";
  //
  //       commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //     }
  //   } on DioException catch (dioError) {
  //     // Handle Dio-specific errors (network, timeout, 404, etc.)
  //     debugPrint("DioException: ${dioError.type}");
  //     debugPrint("DioException Message: ${dioError.message}");
  //     debugPrint("DioException Response: ${dioError.response?.data}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     switch (dioError.type) {
  //       case DioExceptionType.connectionTimeout:
  //       case DioExceptionType.sendTimeout:
  //       case DioExceptionType.receiveTimeout:
  //         errorMessage = 'Connection timeout. Please try again.';
  //         break;
  //       case DioExceptionType.badResponse:
  //         // Handle 404, 500, etc.
  //         if (dioError.response?.statusCode == 404) {
  //           errorMessage = 'API endpoint not found. Please contact support.';
  //         } else if (dioError.response?.statusCode == 500) {
  //           errorMessage = 'Server error. Please try again later.';
  //         } else {
  //           // Try to extract error message from response
  //           if (dioError.response?.data != null) {
  //             if (dioError.response?.data is Map &&
  //                 dioError.response?.data["msg"] != null) {
  //               errorMessage = dioError.response?.data["msg"];
  //             } else if (dioError.response?.data is String) {
  //               errorMessage = dioError.response?.data;
  //             } else {
  //               errorMessage = 'Error: ${dioError.response?.statusCode}';
  //             }
  //           }
  //         }
  //         break;
  //       case DioExceptionType.cancel:
  //         errorMessage = 'Request cancelled';
  //         break;
  //       case DioExceptionType.connectionError:
  //         errorMessage = 'No internet connection';
  //         break;
  //       default:
  //         errorMessage = 'Network error. Please check your connection.';
  //     }
  //
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } catch (e) {
  //     // Handle any other exceptions
  //     debugPrint("General Exception: ${e.toString()}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     // Try to parse error message
  //     var array = e.toString().split(': ');
  //     if (array.length > 1) {
  //       var secondArray = array[1].split(' [');
  //       if (secondArray.isNotEmpty) {
  //         errorMessage = secondArray[0];
  //       }
  //     }
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } finally {
  //     serviceTagsListResponseStatus.value = false;
  //     update();
  //   }
  // }

  /// --------------------------Step 1 Insert ------------------------------------------
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  DropdownItem? selectedState;
  DropdownItem? selectedCity;

  File? profileImage;
  var profileImageUrl = ''.obs; // Add this if not already present

  var step1ResponseStatus = false.obs;
  var step1Data = <String, dynamic>{}.obs;

  Future getStep1Insert(
    String endPoint,
    Map<String, dynamic> queryParameters,
  ) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    step1ResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201||homeResponse.statusCode == 500) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          step1Data.value = result;

          if (result["success"] == true) {
            // commonFunctions.successSnackBar(
            //   Get.overlayContext!,
            //   result["message"],
            // );
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      step1ResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  /// --------------------------Service Tag Step Insert ------------------------------------------
  List<String> selectedServices = [];

  var serviceTagStepResponseStatus = false.obs;
  var serviceTagStepData = <String, dynamic>{}.obs;

  Future getServiceTagInsertInsert(
      String endPoint,
      Map<String, dynamic> queryParameters,
      ) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    serviceTagStepResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201 ||homeResponse.statusCode == 500) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          serviceTagStepData.value = result;

          if (result["success"] != true) {
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
        // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      serviceTagStepResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  /// --------------------------Step 2 Insert ------------------------------------------

  final TextEditingController yearsController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  File? certificateImage;
  String? certificateFileName;

  DropdownItem? selectedCategory1;
  DropdownItem? selectedSubService;

  var step2ResponseStatus = false.obs;
  var step2Data = <String, dynamic>{}.obs;

  Future getStep2Insert(
    String endPoint,
    Map<String, dynamic> queryParameters,
  ) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    step2ResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201||homeResponse.statusCode == 500) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          step2Data.value = result;

          if (result["success"] == true) {
            // commonFunctions.successSnackBar(
            //   Get.overlayContext!,
            //   result["message"],
            // );
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      step2ResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }


  /// --------------------------Step 3 Insert ------------------------------------------
  final TextEditingController locationController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController toolsController = TextEditingController();

  String fromTime = '9 Am';
  String toTime = '5 Pm';
  bool? willingToTravel=false;
   List<String> languages = [];
   List<String> tools = [];
  List<String> locationSuggestions = [];
  bool showSuggestions = false;


  var step3ResponseStatus = false.obs;
  var step3Data = <String, dynamic>{}.obs;

  Future getStep3Insert(
      String endPoint,
      Map<String, dynamic> queryParameters,
      ) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    step3ResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201||homeResponse.statusCode == 500) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          step3Data.value = result;

          if (result["success"] == true) {
            // commonFunctions.successSnackBar(
            //   Get.overlayContext!,
            //   result["message"],
            // );
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
        // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      step3ResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }

  /// --------------------------Step 4 Insert ------------------------------------------
  File? idImage;
  String? idImageFileName;
  File? selfieImage;
  String? selfieImageFileName;

  DropdownItem? selectedDocument;
  bool consentChecked = true;
  final TextEditingController idNumberController = TextEditingController();

  var step4ResponseStatus = false.obs;
  var step4Data = <String, dynamic>{}.obs;

  Future getStep4Insert(
      String endPoint,
      Map<String, dynamic> queryParameters,
      ) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    step4ResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(
        endpoint: endPoint,
        queryParameters: queryParameters,
      );

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201||homeResponse.statusCode == 500) {
        var result = homeResponse.data;

        if (result is Map<String, dynamic>) {
          step4Data.value = result;

          if (result["success"] == true) {
            commonFunctions.successSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          } else {
            // API returned false status - DON'T close bottom sheet
            commonFunctions.errorSnackBar(
              Get.overlayContext!,
              result["message"],
            );
          }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        // Try to extract error message from response
        if (homeResponse.data != null) {
          if (homeResponse.data is Map &&
              homeResponse.data["message"] != null) {
            errorMessage = homeResponse.data["message"];
          } else if (homeResponse.data is String) {
            errorMessage = homeResponse.data;
          }
        }

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
        // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      // CRITICAL: Always set loading to false, no matter what
      // debugPrint("email Account Creation Response Status to false");
      step4ResponseStatus.value = false;
      update();
      // debugPrint("Current forgotPasswordResponseStatus: ${signUpResponseStatus.value}");
    }
  }




  /// --------------------------Vendor Info Details ------------------------------------------
  // var certificateImageUrl = ''.obs; // Add this to store network URL
  //
  //
  // var idImageUrl = ''.obs; // Add this to store network URL for ID image
  // var selfieImageUrl = ''.obs; // Add this to store network URL for selfie
  //
  //
  // var vendorInfoResponseStatus = false.obs;
  // var vendorInfoData = VendorInfoModel().obs;
  //
  // Future getVendorInfoDetails(String endPoint) async {
  //   // Set loading to true at the start
  //   vendorInfoResponseStatus.value = true;
  //   update();
  //
  //   try {
  //     var homeResponse = await ApiService().get(endpoint: endPoint);
  //     debugPrint("Response Status Code: ${homeResponse.statusCode}");
  //     debugPrint("Response Data: ${homeResponse.data}");
  //     if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201|| homeResponse.statusCode == 500) {
  //       var result = VendorInfoModel.fromJson(homeResponse.data);
  //       vendorInfoData.value = result;
  //       if(vendorInfoData.value.success==true){
  //         if (vendorInfoData.value.data![0].profilePhoto != null) {
  //           //Step 1
  //           profileImageUrl.value =
  //               vendorInfoData.value.data![0].profilePhoto.toString();
  //         }
  //         companyNameController.text=vendorInfoData.value.data![0].companyName.toString();
  //         fullNameController.text=vendorInfoData.value.data![0].fullName.toString();
  //         if (vendorInfoData.value.data![0].state != null) {
  //           final stateId = vendorInfoData.value.data![0].state.toString();
  //           selectedState = stateListData.value.statesList?.firstWhere(
  //                 (state) => state.id.toString() == stateId,
  //             orElse: () => null as dynamic,
  //           ) != null
  //               ? DropdownItem(
  //             id: stateId,
  //             name: stateListData.value.statesList!
  //                 .firstWhere((state) => state.id.toString() == stateId)
  //                 .name ?? '',
  //           )
  //               : null;
  //         }
  //
  //         // Set city - need to fetch city list first, then set the selected city
  //         if (vendorInfoData.value.data![0].city != null && vendorInfoData.value.data![0].state != null) {
  //           final cityId = vendorInfoData.value.data![0].city.toString();
  //           final stateName = stateListData.value.statesList?.firstWhere(
  //                 (state) => state.id.toString() == vendorInfoData.value.data![0].state.toString(),
  //             orElse: () => null as dynamic,
  //           )?.name;
  //
  //           if (stateName != null) {
  //             // Fetch cities for the state first
  //             await getCityList("get_city", {"state_name": stateName});
  //
  //             // Then set the selected city
  //             selectedCity = cityListData.value.city?.firstWhere(
  //                   (city) => city.cityId.toString() == cityId,
  //               orElse: () => null as dynamic,
  //             ) != null
  //                 ? DropdownItem(
  //               id: cityId,
  //               name: cityListData.value.city!
  //                   .firstWhere((city) => city.cityId.toString() == cityId)
  //                   .cityName ?? '',
  //             )
  //                 : null;
  //           }
  //         }
  //         pincodeController.text=vendorInfoData.value.data![0].pincode.toString();
  //         addressController.text=vendorInfoData.value.data![0].address.toString();
  //
  //         //tag Selection Step
  //         selectedServices = vendorInfoData.value.data![0].serviceTag!
  //             .split(',')
  //             .map((e) => e.trim())
  //             .where((e) => e.isNotEmpty)  // Add this line
  //             .toList();
  //         debugPrint("Selected Services: $selectedServices");
  //         debugPrint("Selected Services: ${selectedServices.length}");
  //
  //
  //        // Step 2
  //         selectedCategory1=vendorInfoData.value.data![0].serviceCategory!=null?DropdownItem( id: vendorInfoData.value.data![0].serviceCategory.toString(), name:""):selectedCategory1;
  //         selectedSubService=vendorInfoData.value.data![0].subService!=null?DropdownItem( id: vendorInfoData.value.data![0].subService.toString(), name:""):selectedSubService;
  //         yearsController.text=vendorInfoData.value.data![0].yearsOfExperience!=null?vendorInfoData.value.data![0].yearsOfExperience.toString():"";
  //         if (vendorInfoData.value.data![0].certifications != null) {
  //           certificateImageUrl.value = vendorInfoData.value.data![0].certifications.toString();
  //         }
  //         bioController.text=vendorInfoData.value.data![0].shortBio.toString();
  //
  //
  //         // Step 3
  //         locationController.text=vendorInfoData.value.data![0].areaOfService.toString();
  //         languages=vendorInfoData.value.data![0].languages!=null?vendorInfoData.value.data![0].languages!.split(',')
  //             .map((e) => e.trim())
  //             .toList():languages;
  //         tools=vendorInfoData.value.data![0].toolsAvailable!=null?vendorInfoData.value.data![0].toolsAvailable!.split(',')
  //             .map((e) => e.trim())
  //             .toList():tools;
  //         fromTime=vendorInfoData.value.data![0].workingHoursFrom!=null?vendorInfoData.value.data![0].workingHoursFrom.toString():fromTime;
  //         toTime=vendorInfoData.value.data![0].workingHoursTo!=null?vendorInfoData.value.data![0].workingHoursTo.toString():toTime;
  //         willingToTravel=vendorInfoData.value.data![0].willingToTravel==1?true:false;
  //
  //
  //         // Step 4
  //         idNumberController.text=vendorInfoData.value.data![0].kycIdNumber.toString();
  //         selectedDocument=vendorInfoData.value.data![0].kycIdType!=null?DropdownItem( id:vendorInfoData.value.data![0].kycIdType.toString() , name:""):selectedDocument;
  //         if (vendorInfoData.value.data![0].kycIdImage != null) {
  //           idImageUrl.value = vendorInfoData.value.data![0].kycIdImage.toString();
  //         }
  //         if (vendorInfoData.value.data![0].kycSelfie != null) {
  //           selfieImageUrl.value = vendorInfoData.value.data![0].kycSelfie.toString();
  //         }
  //       }
  //     } else {
  //       // Handle other status codes (400, 404, 500, etc.)
  //       debugPrint("Server returned status code: ${homeResponse.statusCode}");
  //       String errorMessage = "Server error occurred";
  //       commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //     }
  //   } on DioException catch (dioError) {
  //     // Handle Dio-specific errors (network, timeout, 404, etc.)
  //     debugPrint("DioException: ${dioError.type}");
  //     debugPrint("DioException Message: ${dioError.message}");
  //     debugPrint("DioException Response: ${dioError.response?.data}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     switch (dioError.type) {
  //       case DioExceptionType.connectionTimeout:
  //       case DioExceptionType.sendTimeout:
  //       case DioExceptionType.receiveTimeout:
  //         errorMessage = 'Connection timeout. Please try again.';
  //         break;
  //       case DioExceptionType.badResponse:
  //       // Handle 404, 500, etc.
  //         if (dioError.response?.statusCode == 404) {
  //           errorMessage = 'API endpoint not found. Please contact support.';
  //         } else if (dioError.response?.statusCode == 500) {
  //           errorMessage = 'Server error. Please try again later.';
  //         } else {
  //           // Try to extract error message from response
  //           if (dioError.response?.data != null) {
  //             if (dioError.response?.data is Map &&
  //                 dioError.response?.data["msg"] != null) {
  //               errorMessage = dioError.response?.data["msg"];
  //             } else if (dioError.response?.data is String) {
  //               errorMessage = dioError.response?.data;
  //             } else {
  //               errorMessage = 'Error: ${dioError.response?.statusCode}';
  //             }
  //           }
  //         }
  //         break;
  //       case DioExceptionType.cancel:
  //         errorMessage = 'Request cancelled';
  //         break;
  //       case DioExceptionType.connectionError:
  //         errorMessage = 'No internet connection';
  //         break;
  //       default:
  //         errorMessage = 'Network error. Please check your connection.';
  //     }
  //
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } catch (e) {
  //     // Handle any other exceptions
  //     debugPrint("General Exception: ${e.toString()}");
  //
  //     String errorMessage = 'Something went wrong';
  //
  //     // Try to parse error message
  //     var array = e.toString().split(': ');
  //     if (array.length > 1) {
  //       var secondArray = array[1].split(' [');
  //       if (secondArray.isNotEmpty) {
  //         errorMessage = secondArray[0];
  //       }
  //     }
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } finally {
  //     vendorInfoResponseStatus.value = false;
  //     update();
  //   }
  // }

  /// --------------------------Customer Settings ------------------------------------------


var settingResponseStatus = false.obs;
var settingData = CustomerSettingModel().obs;

  Future getSetting(String endPoint) async {
    // Set loading to true at the start
    settingResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().get(endpoint: endPoint);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CustomerSettingModel.fromJson(homeResponse.data);
        settingData.value = result;

        // Store basic fees
        AppConfig.convenienceFee = result.categories!.first.convenienceFeePercentage.toString();
        AppConfig.platformFee = result.categories!.first.platformFee.toString();
        AppConfig.paymentKey =result.categories!.first.paymentKey!.isNotEmpty? result.categories!.first.paymentKey.toString():"rzp_test_0VhW5kvbe3uCFF";

        // Parse and store tax options separately
        if (result.categories!.first.taxOption != null &&
            result.categories!.first.taxOption!.isNotEmpty) {
          try {
            // Parse the tax_option JSON string
            var taxOptionData = jsonDecode(result.categories!.first.taxOption!);

            // Extract tax_options array
            List<dynamic> taxOptions = taxOptionData['tax_options'] ?? [];

            // Loop through and assign values
            for (var tax in taxOptions) {
              String taxName = tax['tax_name'] ?? '';
              String taxPercentage = tax['tax_percentage']?.toString() ?? '0';

              switch (taxName.toUpperCase()) {
                case 'CGST':
                  AppConfig.cGST = taxPercentage;
                  break;
                case 'SGST':
                  AppConfig.sGST = taxPercentage;
                  break;
                case 'IGST':
                  AppConfig.iGST = taxPercentage;
                  break;
              }
            }

            debugPrint("CGST: ${AppConfig.cGST}");
            debugPrint("SGST: ${AppConfig.sGST}");
            debugPrint("IGST: ${AppConfig.iGST}");

          } catch (jsonError) {
            debugPrint("Error parsing tax_option: $jsonError");
            // Set default values if parsing fails
            AppConfig.cGST = '0';
            AppConfig.sGST = '0';
            AppConfig.iGST = '0';
          }
        }

      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
        // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }
      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      settingResponseStatus.value = false;
      update();
    }
  }


  /// -------------------------- Notification List ------------------------------------------


  var notificationListResponseStatus = false.obs;
  var notificationListData = NotificationListModel().obs;

  Future getNotificationList(String endPoint, Map<String, dynamic> queryParameters,) async {
    // Set loading to true at the start
    notificationListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint, queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = NotificationListModel.fromJson(homeResponse.data);
        notificationListData.value = result;

      } else {
        // Handle other status codes (400, 404, 500, etc.)
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";

        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, 404, etc.)
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");
      debugPrint("DioException Response: ${dioError.response?.data}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
        // Handle 404, 500, etc.
          if (dioError.response?.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please contact support.';
          } else if (dioError.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            // Try to extract error message from response
            if (dioError.response?.data != null) {
              if (dioError.response?.data is Map &&
                  dioError.response?.data["msg"] != null) {
                errorMessage = dioError.response?.data["msg"];
              } else if (dioError.response?.data is String) {
                errorMessage = dioError.response?.data;
              } else {
                errorMessage = 'Error: ${dioError.response?.statusCode}';
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      debugPrint("General Exception: ${e.toString()}");

      String errorMessage = 'Something went wrong';

      // Try to parse error message
      var array = e.toString().split(': ');
      if (array.length > 1) {
        var secondArray = array[1].split(' [');
        if (secondArray.isNotEmpty) {
          errorMessage = secondArray[0];
        }
      }
      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } finally {
      notificationListResponseStatus.value = false;
      update();
    }
  }
}
