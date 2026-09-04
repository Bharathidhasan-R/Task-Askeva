import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../Controllers/Login_controller.dart';
import '../../Routes/app_routes.dart';
import '../../common/DropDown Field.dart';
import '../../common/Text Fields.dart';
import '../../common/button.dart';
import '../../common/dropdown_item.dart';
import '../../common/export.dart' hide common;

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  var loginController = Get.put(LoginController());

  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _isLoading = false;

  // Error text variables
  String? _profileImageError;
  String? _fullNameError;
  String? _stateError;
  String? _cityError;
  String? _pincodeError;
  String? _addressError;

  // Validation Methods
  String? _validateProfileImage() {
    if (loginController.profileImage == null &&
        (loginController.profileImageUrl.value.isEmpty ||
            loginController.profileImageUrl.value == 'null')) {
      return 'Please upload a profile photo';
    }
    return null;
  }

  String? _validateFullName(String value) {
    if (value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    // Check if name contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name should contain only letters';
    }
    return null;
  }

  String? _validateState() {
    if (loginController.selectedState == null) {
      return 'Please select a state';
    }
    return null;
  }

  String? _validateCity() {
    if (loginController.selectedCity == null) {
      return 'Please select a city';
    }
    return null;
  }

  String? _validatePincode(String value) {
    if (value.isEmpty) {
      return 'Pincode is required';
    }

    // Remove any spaces
    String cleanPincode = value.replaceAll(' ', '');

    // Check if pincode contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPincode)) {
      return 'Pincode should contain only numbers';
    }

    // Check pincode length (typically 6 digits in India)
    if (cleanPincode.length != 6) {
      return 'Pincode must be 6 digits';
    }

    return null;
  }

  String? _validateAddress(String value) {
    if (value.isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address (at least 10 characters)';
    }
    return null;
  }

  Future<void> _validateForm() async {
    // Don't allow multiple submissions
    if (_isLoading) return;

    setState(() {
      _profileImageError = _validateProfileImage();
      _fullNameError = _validateFullName(
        loginController.fullNameController.text.trim(),
      );
      _stateError = _validateState();
      _cityError = _validateCity();
      _pincodeError = _validatePincode(
        loginController.pincodeController.text.trim(),
      );
      _addressError = _validateAddress(
        loginController.addressController.text.trim(),
      );
    });

    // Check if there are any errors
    if (_profileImageError == null &&
        _fullNameError == null &&
        _stateError == null &&
        _cityError == null &&
        _pincodeError == null &&
        _addressError == null) {
      // Set loading state
      setState(() {
        _isLoading = true;
      });

      try {
        String profilePhotoUrl;

        // Check if user selected a new image (local file)
        if (loginController.profileImage != null) {
          // Step 1: Upload the new file
          await loginController.getFileUpload(
            "upload_files",
            imageFile: loginController.profileImage,
          );

          // Step 2: Check if file upload was successful
          if (loginController.fileUploadData.value.success == true &&
              loginController.fileUploadData.value.uploadedUrls?.uploadFiles !=
                  null &&
              loginController
                  .fileUploadData
                  .value
                  .uploadedUrls!
                  .uploadFiles!
                  .isNotEmpty) {
            profilePhotoUrl = loginController
                .fileUploadData
                .value
                .uploadedUrls!
                .uploadFiles![0];
          } else {
            // Reset loading state
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          // Use existing network URL
          profilePhotoUrl = loginController.profileImageUrl.value;
        }

        // Step 3: Call step1 insert API with profile photo URL
        await loginController.getStep1Insert("saveCustomerInfo", {
          "name": loginController.fullNameController.text.trim(),
          "state": loginController.selectedState?.id,
          "city": loginController.selectedCity?.id,
          "pincode": loginController.pincodeController.text.trim(),
          "address": loginController.addressController.text.trim(),
          "profile_photo_url": profilePhotoUrl,
        });
        // Step 4: Check if step1 insert was successful
        if (loginController.step1Data.value["success"] == true) {
          _performContinue();
        } else {
          // Reset loading state
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _performContinue() {
    // Clear any existing errors
    setState(() {
      _profileImageError = null;
      _fullNameError = null;
      _stateError = null;
      _cityError = null;
      _pincodeError = null;
      _addressError = null;
      _isLoading = false;
    });

    // Navigate to service selection screen
    Get.toNamed(AppRoutes.bucketListScreen);
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF183954),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF183954)),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  preferredCameraDevice: CameraDevice.front,
                );
                if (photo != null) {
                  setState(() {
                    loginController.profileImage = File(photo.path);
                    _profileImageError =
                        null; // Clear error when image is selected
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF183954),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    loginController.profileImage = File(image.path);
                    loginController.profileImageUrl.value =
                        ''; // Clear network URL
                    _profileImageError =
                        null; // Clear error when image is selected
                  });
                }
              },
            ),
            if (loginController.profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    loginController.profileImage = null;
                  });
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: AppSafeArea(
          backgroundColor: Colors.white,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F4EE),
          surfaceTintColor: const Color(0xFFF7F4EE),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              'assets/img/logo.png',
              width: 89.37,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
          leadingWidth: 100,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section with error indication
                Center(
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4EE),
                            shape: BoxShape.circle,
                            border: _profileImageError != null
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                          ),
                          child: ClipOval(
                            child: loginController.profileImage != null
                                ? Image.file(
                                    loginController.profileImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Obx(
                                    () =>
                                        loginController
                                            .profileImageUrl
                                            .isNotEmpty
                                        ? Image.network(
                                            loginController
                                                .profileImageUrl
                                                .value,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value:
                                                      loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  );
                                                },
                                          )
                                        : const SizedBox(),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 27.64,
                            height: 27.64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8943A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 17.73,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Full name with validation
                Text('Full name', style: common.fieldTextStyle(size: 14)),
                const SizedBox(height: 10),
                CustomTextField(
                  fieldHeight: 46,
                  controller: loginController.fullNameController,
                  hintText: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  fontSize: 12,
                  borderRadius: 8,
                  textInputAction: TextInputAction.next,
                  errorText: _fullNameError,
                  onChanged: (value) {
                    if (_fullNameError != null) {
                      setState(() {
                        _fullNameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // State with validation
                Text('State', style: common.fieldTextStyle(size: 14)),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      // Get unique state items
                      final stateItems =
                          loginController.stateListData.value.statesList
                              ?.map(
                                (category) => DropdownItem(
                                  id: category.id.toString(),
                                  name: category.name ?? '',
                                ),
                              )
                              .toList() ??
                          [];

                      // Remove duplicates based on id
                      final uniqueStateItems = <String, DropdownItem>{};
                      for (var item in stateItems) {
                        uniqueStateItems[item.id] = item;
                      }
                      final finalStateItems = uniqueStateItems.values.toList();

                      // Validate if selected value exists in items
                      final validSelectedState =
                          loginController.selectedState != null &&
                              finalStateItems.any(
                                (item) =>
                                    item.id ==
                                    loginController.selectedState!.id,
                              )
                          ? loginController.selectedState
                          : null;

                      return CustomDropdownField(
                        items: finalStateItems,
                        value: validSelectedState,
                        hintText: "Select",
                        height: 46,
                        borderRadius: 8,
                        fontSize: 12,
                        onChanged: (selected) {
                          setState(() {
                            loginController.selectedState = selected;
                            _stateError = null;
                            // Reset city when state changes
                            loginController.selectedCity = null;

                            loginController.getCityList("get_city", {
                              "state_name": selected?.name,
                            });
                          });
                          print("Selected ID: ${selected?.id}");
                          print("Selected Name: ${selected?.name}");
                        },
                      );
                    }),
                    if (_stateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          _stateError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City with validation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City', style: common.fieldTextStyle()),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                // Get unique city items
                                final cityItems =
                                    loginController.cityListData.value.city
                                        ?.map(
                                          (category) => DropdownItem(
                                            id: category.cityId.toString(),
                                            name: category.cityName ?? '',
                                          ),
                                        )
                                        .toList() ??
                                    [];

                                // Remove duplicates based on id
                                final uniqueCityItems =
                                    <String, DropdownItem>{};
                                for (var item in cityItems) {
                                  uniqueCityItems[item.id] = item;
                                }
                                final finalCityItems = uniqueCityItems.values
                                    .toList();

                                // Validate if selected value exists in items
                                final validSelectedCity =
                                    loginController.selectedCity != null &&
                                        finalCityItems.any(
                                          (item) =>
                                              item.id ==
                                              loginController.selectedCity!.id,
                                        )
                                    ? loginController.selectedCity
                                    : null;

                                return CustomDropdownField(
                                  items: finalCityItems,
                                  value: validSelectedCity,
                                  hintText: "Select",
                                  height: 46,
                                  borderRadius: 8,
                                  fontSize: 12,
                                  onChanged: (selected) {
                                    setState(() {
                                      loginController.selectedCity = selected;
                                      _cityError = null;
                                    });
                                    print("Selected ID: ${selected?.id}");
                                    print("Selected Name: ${selected?.name}");
                                  },
                                );
                              }),
                              if (_cityError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    left: 4,
                                  ),
                                  child: Text(
                                    _cityError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Pincode with validation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pincode', style: common.fieldTextStyle()),
                          const SizedBox(height: 10),
                          CustomTextField(
                            fieldHeight: 46,
                            fontSize: 12,
                            borderRadius: 8,
                            controller: loginController.pincodeController,
                            hintText: 'enter',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            errorText: _pincodeError,
                            onChanged: (value) {
                              if (_pincodeError != null) {
                                setState(() {
                                  _pincodeError = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Address with validation
                Text('Address', style: common.fieldTextStyle(size: 14)),
                const SizedBox(height: 10),
                CustomTextField(
                  fieldHeight: 46,
                  fontSize: 12,
                  borderRadius: 8,
                  controller: loginController.addressController,
                  hintText: 'Enter your full address',
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.done,
                  errorText: _addressError,
                  onChanged: (value) {
                    if (_addressError != null) {
                      setState(() {
                        _addressError = null;
                      });
                    }
                  },
                  onSubmitted: (value) {
                    // Trigger validation when user presses Done
                    _validateForm();
                  },
                ),
                const SizedBox(height: 350),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(color: Colors.white),
          child: CustomButton(
            text: _isLoading ? "Please wait..." : "Continue",
            fontSize: 16,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            borderRadius: BorderRadius.circular(12),
            onPressed: _isLoading
                ? null
                : _validateForm, // Disable button when loading
          ),
        ),
      ),
    ));
  }
}
