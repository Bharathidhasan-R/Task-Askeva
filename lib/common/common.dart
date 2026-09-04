import 'export.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'app_toast.dart';

// var settingController = Get.put(SettingsController());
class Common {
  var primaryColor =  Colors.blue.shade900;
  var secondaryColor = Colors.orange;
  var titleColor = const Color(0xff000000);
  var textColor = const Color(0xff000000);
  var backGroundColor = const Color(0xffffffff);

  var currencySymbol = "¥";

  static String? hotelCode;
  static String? total;

  ButtonStyle buttonStyle() {
    return ButtonStyle(

      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return primaryColor;
          }
          return primaryColor;
        },
      ),
    );
  }

  TextStyle buttonTextStyle({double size=16}) {
    return  TextStyle(
      color: Colors.white,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle buttonTextStyle1() {
    return TextStyle(
      fontSize: 18,
      color: secondaryColor,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
    );
  }

  Widget buildInputField(String hintText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.grey[500]),
      decoration:  InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        labelStyle: const TextStyle(color: Color(0xff4B5563)),
        hintText: hintText,
        border: InputBorder.none,
      ),
    );

  }

  Widget card(Widget card) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: card,
    );
  }
}

class CommonFunctions {
  apiError(String e) {
    debugPrint("apiError: $e");
    var array = e.toString().split(': ');
    if (array.length > 1) {
      var secondArray = array[1].split(' [');
      if (secondArray.length > 1) {
        AppToast.error('Error', secondArray[0]);
      } else {
        AppToast.error('Error', 'Something went wrong');
      }
    } else {
      AppToast.error('Error', 'Something went wrong');
    }
  }

  successSnackBar(BuildContext context, String msg) {
    return InteractiveToast.slideSuccess(
      context: context,
      title: Text(msg.toString()),
      toastSetting: const SlidingToastSetting(
        toastStartPosition: ToastPosition.right,
        toastAlignment: Alignment.topCenter,
        displayDuration: Duration(seconds: 2),
      ),
    );
  }

  errorSnackBar(BuildContext context, String msg) {
    return InteractiveToast.slideError(
      context: context,
      title: Text(msg.toString()),
      toastSetting: const SlidingToastSetting(
        toastStartPosition: ToastPosition.left,
        toastAlignment: Alignment.topCenter,
        displayDuration: Duration(seconds: 2),
      ),
    );
  }

  // ScaffoldMessenger.of(context).showSnackBar(
  // SnackBar(
  // content: Row(
  // children: const [
  // Icon(Icons.check_circle, color: Colors.white, size: 20),
  // SizedBox(width: 12),
  // Text(
  // 'Note saved successfully!',
  // style: TextStyle(
  // fontSize: 14,
  // fontFamily: 'Figtree-Medium',
  // fontWeight: FontWeight.w500,
  // ),
  // ),
  // ],
  // ),
  // backgroundColor: const Color(0xFF038153),
  // duration: const Duration(seconds: 2),
  // behavior: SnackBarBehavior.floating,
  // shape: RoundedRectangleBorder(
  // borderRadius: BorderRadius.circular(8),
  // ),
  // margin: const EdgeInsets.all(16),
  // ),
  // );
}

CommonFunctions commonFunctions = CommonFunctions();
Common common = Common();
// appBar: AppBar(
//   toolbarHeight: 70,
//   automaticallyImplyLeading: true,
//   backgroundColor: Colors.white,
//   title: const Text(
//     "APP",
//     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//   ),
//   actions: <Widget>[
//     IconButton(
//       icon: const Icon(IconlyLight.heart),
//       tooltip: 'favorites',
//       onPressed: () {
//         commonFunctions.successSnackBar(context, "Hi there! I'm a success toast 🦁");
//       },
//     ), //IconButton
//     IconButton(
//       icon: const Icon(IconlyLight.bag),
//       tooltip: 'Orders',
//       onPressed: () {
//         commonFunctions.errorSnackBar(context, "Hi there! I'm a error toast 😈.");
//       },
//     ), //IconButton
//   ], //<W
// ),
// appBar:const CustomAppBar(title: "My Listings"),

// decoration: InputDecoration(
//   hintText: hintText,
//   hintStyle: const TextStyle(color: Colors.grey),
//   filled: true,
//   fillColor: Colors.white,
//   border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: const BorderSide(color: Colors.grey), // Gray border
//   ),
//   enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: BorderSide(
//         color: Colors.grey.shade500), // Gray border when not focused
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: BorderSide(
//         color: Colors.grey.shade500), // Gray border when focused
//   ),
//   contentPadding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//   errorBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: const BorderSide(
//         color: Colors.red), // Red border for validation error
//   ),
//   focusedErrorBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: const BorderSide(
//         color: Colors.red), // Red border when focused with error
//   ),
// ),