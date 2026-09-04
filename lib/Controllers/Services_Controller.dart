import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../Api_config/api/api_service.dart';
import '../Models/CartDetailsModel.dart';
import '../Models/Category_List_Model.dart';
import '../Models/Customer_Details_Model.dart';
import '../Models/Customer_Payment_summary_Model.dart';
import '../Models/Enquiry_Details_model.dart';
import '../Models/Need_to_Pay_Model.dart';
import '../Models/On_going_Project_Details_Model.dart';
import '../Models/Orgaization_Details_Model.dart';
import '../Models/Quotelist_Ongoinglist_Model.dart';
import '../Models/Service_Details_Model.dart';
import '../Models/Service_List_Model.dart' show ServiceListModel;
import '../common/export.dart' hide FormData, MultipartFile;
import 'Hive_controller.dart';

class ServiceController extends GetxController {
  var hiveMethod = Get.put(HiveMethods());
  static const String hiveBox = 'itemsDB';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCategoryList("ServiceCategories");
  }

  // /// --------------------------file Upload List------------------------------------------
  //
  // var fileUploadResponseStatus = false.obs;
  // var fileUploadData = FileUploadModel().obs;
  //
  // Future getFileUpload(String endPoint, {File? imageFile, List<File>? imageFiles}) async {
  //   fileUploadResponseStatus.value = true;
  //   update();
  //
  //   try {
  //     FormData formData = FormData();
  //
  //     // Collect all files to upload
  //     List<File> filesToUpload = [];
  //
  //     // Add single file if provided
  //     if (imageFile != null) {
  //       filesToUpload.add(imageFile);
  //     }
  //
  //     // Add multiple files if provided
  //     if (imageFiles != null && imageFiles.isNotEmpty) {
  //       filesToUpload.addAll(imageFiles);
  //     }
  //
  //     // Check if there are any files to upload
  //     if (filesToUpload.isEmpty) {
  //       debugPrint("No files to upload");
  //       commonFunctions.errorSnackBar(
  //         Get.overlayContext!,
  //         "No files selected for upload",
  //       );
  //       return;
  //     }
  //
  //     // Add all files to FormData
  //     for (var file in filesToUpload) {
  //       String fileName = file.path.split("/").last;
  //
  //       formData.files.add(
  //         MapEntry(
  //           "upload_files", // Note: Added [] for array - adjust based on your API requirements
  //           await MultipartFile.fromFile(file.path, filename: fileName),
  //         ),
  //       );
  //
  //       debugPrint("Image added: $fileName");
  //     }
  //
  //     debugPrint("Total files to upload: ${filesToUpload.length}");
  //
  //     // Send the request
  //     var homeResponse = await ApiService().postMultipart(
  //       endpoint: endPoint,
  //       formData: formData,
  //     );
  //
  //     debugPrint("Response Status Code: ${homeResponse.statusCode}");
  //     debugPrint("Response Data: ${homeResponse.data}");
  //
  //     if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
  //       var result = FileUploadModel.fromJson(homeResponse.data);
  //       fileUploadData.value = result;
  //     } else {
  //       debugPrint("Server returned status: ${homeResponse.statusCode}");
  //       commonFunctions.errorSnackBar(
  //         Get.overlayContext!,
  //         "Server error occurred",
  //       );
  //     }
  //   } on DioException catch (dioError) {
  //     debugPrint("DioException: ${dioError.type}");
  //     debugPrint("DioException Message: ${dioError.message}");
  //     debugPrint("DioException Response: ${dioError.response?.data}");
  //
  //     String errorMessage = "Something went wrong";
  //
  //     switch (dioError.type) {
  //       case DioExceptionType.connectionTimeout:
  //       case DioExceptionType.sendTimeout:
  //       case DioExceptionType.receiveTimeout:
  //         errorMessage = 'Connection timeout. Please try again.';
  //         break;
  //
  //       case DioExceptionType.badResponse:
  //         if (dioError.response?.statusCode == 404) {
  //           errorMessage = 'API endpoint not found.';
  //         } else if (dioError.response?.statusCode == 500) {
  //           errorMessage = 'Server error. Please try later.';
  //         } else {
  //           if (dioError.response?.data != null &&
  //               dioError.response?.data is Map &&
  //               dioError.response?.data["msg"] != null) {
  //             errorMessage = dioError.response?.data["msg"];
  //           }
  //         }
  //         break;
  //
  //       case DioExceptionType.cancel:
  //         errorMessage = 'Request cancelled';
  //         break;
  //
  //       case DioExceptionType.connectionError:
  //         errorMessage = 'No internet connection';
  //         break;
  //
  //       default:
  //         errorMessage = 'Network error occurred';
  //     }
  //
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } catch (e) {
  //     debugPrint("General Exception: ${e.toString()}");
  //
  //     String errorMessage = "Something went wrong";
  //
  //     // Extract readable error
  //     var parts = e.toString().split(": ");
  //     if (parts.length > 1) errorMessage = parts[1];
  //
  //     commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
  //   } finally {
  //     fileUploadResponseStatus.value = false;
  //     update();
  //   }
  // }


  /// --------------------------Category List ------------------------------------------

  var categoryListResponseStatus = false.obs;
  var  categoryListData = CategoryListModel().obs;

  Future getCategoryList(String endPoint) async {
    categoryListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().get(endpoint: endPoint);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CategoryListModel.fromJson(homeResponse.data);
        categoryListData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      categoryListResponseStatus.value = false;
      update();
    }
  }



  /// --------------------------Service List ------------------------------------------

  var serviceListResponseStatus = false.obs;
  var serviceListData = ServiceListModel().obs;

  Future getServiceList(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    serviceListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = ServiceListModel.fromJson(homeResponse.data);
        serviceListData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      serviceListResponseStatus.value = false;
      update();
    }
  }



  /// --------------------------Service Details ------------------------------------------

  var serviceDetailsResponseStatus = false.obs;
  var serviceDetailsData = ServiceDetailsModel().obs;

  Future getServiceDetails(String endPoint, Map<String, dynamic> queryParameters,) async {
    debugPrint("Service Details: ${queryParameters.toString()}");
    serviceDetailsResponseStatus.value = true;
    addBucketData.value = {};
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = ServiceDetailsModel.fromJson(homeResponse.data);
        serviceDetailsData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      serviceDetailsResponseStatus.value = false;
      update();
    }
  }



  /// --------------------------Organization Details ------------------------------------------

  var organizationDetailsResponseStatus = false.obs;
  var organizationDetailsData = VendorDetailsModel().obs;

  Future getOrganizationDetails(String endPoint, Map<String, dynamic> queryParameters,) async {
    organizationDetailsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = VendorDetailsModel.fromJson(homeResponse.data);
        organizationDetailsData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      organizationDetailsResponseStatus.value = false;
      update();
    }
  }

  /// -------------------------- Add Bucket------------------------------------------
  var addBucketResponseStatus = false.obs;
  var addBucketData = <String, dynamic>{}.obs;

  Future getAddBucket(String endPoint, Map<String, dynamic> queryParameters,) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    addBucketResponseStatus.value = true;
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
          addBucketData.value = result;

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
      addBucketResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------Bucket Details ------------------------------------------

  var bucketDetailsResponseStatus = false.obs;
  var bucketDetailsData = CartDetailsModel().obs;

  Future getBucketDetails(String endPoint, Map<String, dynamic> queryParameters,) async {
    bucketDetailsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CartDetailsModel.fromJson(homeResponse.data);
        bucketDetailsData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      bucketDetailsResponseStatus.value = false;
      update();
    }
  }


  /// -------------------------- Quote Submit------------------------------------------

    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController messageController = TextEditingController();

  final TextEditingController noteController = TextEditingController();

    final ImagePicker picker = ImagePicker();
    List<File> selectedFiles = []; // Changed to list for multiple files
  var quoteSubmitResponseStatus = false.obs;
  var quoteSubmitData = <String, dynamic>{}.obs;

  Future getQuoteSubmit(String endPoint, Map<String, dynamic> queryParameters,) async {
    debugPrint("Email Account Creation: ${queryParameters.toString()}");

    // Set loading to true at the start
    quoteSubmitResponseStatus.value = true;
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
          quoteSubmitData.value = result;

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
      quoteSubmitResponseStatus.value = false;
      update();
    }
  }



  /// --------------------------Customer Details ------------------------------------------

  var customerDetailsResponseStatus = false.obs;
  var  customerDetailsData = CustomerDetailsModel().obs;

  Future getCustomerDetails(String endPoint) async {
    customerDetailsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().get(endpoint: endPoint);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CustomerDetailsModel.fromJson(homeResponse.data);
        customerDetailsData.value = result;
        firstNameController.text=result.data![0].name.toString()??"";
        phoneController.text=result.data![0].phone.toString()??"";
        emailController.text=result.data![0].email.toString()??"";
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      customerDetailsResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------Enquire Ongoing List  ------------------------------------------

  var enquireOngoingListResponseStatus = false.obs;
  var enquireOngoingListData = EnquireListAndOngoingListModel().obs;

  Future getEnquireListOngoingList(String endPoint, Map<String, dynamic> queryParameters,) async {
    enquireOngoingListResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = EnquireListAndOngoingListModel.fromJson(homeResponse.data);
        enquireOngoingListData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      enquireOngoingListResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Enquire Details  ------------------------------------------

  var enquireDetailsResponseStatus = false.obs;
  var enquireDetailsData = EnquireDetailsModel().obs;

  Future getEnquireDetails(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    enquireDetailsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = EnquireDetailsModel.fromJson(homeResponse.data);
        enquireDetailsData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      enquireDetailsResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Place Order------------------------------------------

  var placeOrderResponseStatus = false.obs;
  var placeOrderData = <String, dynamic>{}.obs;

  Future getPlaceOrder(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    placeOrderResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;
        if (result is Map<String, dynamic>) {
          placeOrderData.value = result;
          // if (result["success"] == true) {
          //   commonFunctions.successSnackBar(
          //     Get.overlayContext!,
          //     result["message"],
          //   );
          // } else {
          //   // API returned false status - DON'T close bottom sheet
          //   commonFunctions.errorSnackBar(
          //     Get.overlayContext!,
          //     result["message"],
          //   );
          // }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      placeOrderResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------OnGoing Project Details------------------------------------------
  ///
  var onGoingProjectDetailsResponseStatus = false.obs;
  var onGoingProjectDetailsData = OngoingProjectDetailsModel().obs;

  Future getOnGoingProjectDetails(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    onGoingProjectDetailsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = OngoingProjectDetailsModel.fromJson(homeResponse.data);
        onGoingProjectDetailsData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      onGoingProjectDetailsResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Design Finalized------------------------------------------

  var designFinalizedResponseStatus = false.obs;
  var designFinalizedData = <String, dynamic>{}.obs;

  Future getDesignFinalized(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    designFinalizedResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;
        if (result is Map<String, dynamic>) {
          designFinalizedData.value = result;
          // if (result["success"] == true) {
          //   commonFunctions.successSnackBar(
          //     Get.overlayContext!,
          //     result["message"],
          //   );
          // } else {
          //   // API returned false status - DON'T close bottom sheet
          //   commonFunctions.errorSnackBar(
          //     Get.overlayContext!,
          //     result["message"],
          //   );
          // }
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      designFinalizedResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------material Payment Order------------------------------------------

  var materialPaymentOrderResponseStatus = false.obs;
  var materialPaymentOrderData = <String, dynamic>{}.obs;

  Future getMaterialPaymentOrder(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    materialPaymentOrderResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;
        if (result is Map<String, dynamic>) {
          materialPaymentOrderData.value = result;
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      materialPaymentOrderResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------Payment Summary ------------------------------------------
  ///
  var paymentSummaryResponseStatus = false.obs;
  var paymentSummaryData = CustomerPaymentSummaryModel().obs;

  Future getPaymentSummary(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    paymentSummaryResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = CustomerPaymentSummaryModel.fromJson(homeResponse.data);
        paymentSummaryData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      paymentSummaryResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Need to Pay  ------------------------------------------
  ///
  var needToPayResponseStatus = false.obs;
  var needToPayData = NeedToPayModel().obs;

  Future getNeedToPay(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    needToPayResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = NeedToPayModel.fromJson(homeResponse.data);
        needToPayData.value = result;
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      needToPayResponseStatus.value = false;
      update();
    }
  }


  /// --------------------------Add Review------------------------------------------
  // Rating states
  int overallRating = 0; // Default rating
  String? vendorFeedback; // 'good' or 'not_good'
  int worker1Rating = 4;
  int worker2Rating = 4;

  var addReviewResponseStatus = false.obs;
  var addReviewData = <String, dynamic>{}.obs;

  Future getAddReview(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    addReviewResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;
        if (result is Map<String, dynamic>) {
          addReviewData.value = result;
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      addReviewResponseStatus.value = false;
      update();
    }
  }

  /// --------------------------Verify Designs------------------------------------------
  var verifyDesignsResponseStatus = false.obs;
  var verifyDesignsData = <String, dynamic>{}.obs;

  Future getVerifyMilestone(String endPoint, Map<String, dynamic> queryParameters,) async {
    print(queryParameters);
    verifyDesignsResponseStatus.value = true;
    update();

    try {
      var homeResponse = await ApiService().post(endpoint: endPoint,queryParameters: queryParameters,);

      debugPrint("Response Status Code: ${homeResponse.statusCode}");
      debugPrint("Response Data: ${homeResponse.data}");

      if (homeResponse.statusCode == 200 || homeResponse.statusCode == 201) {
        var result = homeResponse.data;
        if (result is Map<String, dynamic>) {
          verifyDesignsData.value = result;
        } else {
          // Invalid format - DON'T close bottom sheet
          commonFunctions.errorSnackBar(
            Get.overlayContext!,
            "Invalid response format",
          );
        }
      } else {
        debugPrint("Server returned status code: ${homeResponse.statusCode}");
        String errorMessage = "Server error occurred";
        commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
      }
    } on DioException catch (dioError) {
      debugPrint("DioException: ${dioError.type}");
      debugPrint("DioException Message: ${dioError.message}");

      String errorMessage = 'Something went wrong';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }

      commonFunctions.errorSnackBar(Get.overlayContext!, errorMessage);
    } catch (e) {
      debugPrint("General Exception: ${e.toString()}");
      commonFunctions.errorSnackBar(Get.overlayContext!, 'Something went wrong');
    } finally {
      verifyDesignsResponseStatus.value = false;
      update();
    }
  }

}






