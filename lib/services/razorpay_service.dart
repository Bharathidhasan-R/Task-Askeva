import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../App Configuration/app_config.dart';

class RazorpayService {
  late Razorpay _razorpay;
  BuildContext? _context;

  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  // Singleton pattern
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;

  RazorpayService._internal() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    } else {
      _showDefaultSuccessMessage(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response);
    } else {
      _showDefaultErrorMessage(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    } else {
      _showDefaultWalletMessage(response);
    }
  }

  void _showDefaultSuccessMessage(PaymentSuccessResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! ID: ${response.paymentId}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDefaultErrorMessage(PaymentFailureResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDefaultWalletMessage(ExternalWalletResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('External Wallet: ${response.walletName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Open Razorpay checkout
  ///
  /// [amount] - Amount in rupees (will be converted to paise automatically)
  /// [name] - Business/Company name
  /// [description] - Payment description
  /// [orderId] - Optional order ID from your backend
  /// [prefillContact] - User's contact number
  /// [prefillEmail] - User's email
  /// [notes] - Additional notes/metadata
  /// [context] - BuildContext for showing messages
  void openCheckout({
    required BuildContext context,
    required double amount,
    String name = 'Vayil',
    String description = 'Payment',
    String? orderId,
    String prefillContact = '',
    String prefillEmail = '',
    Map<String, dynamic>? notes,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) {
    _context = context;

    // Set callbacks
    onPaymentSuccess = onSuccess;
    onPaymentError = onError;
    onExternalWallet = onWallet;

    // Convert amount to paise (multiply by 100)
    int amountInPaise = (amount * 100).toInt();

    var options = {
      'key': AppConfig.paymentKey, // Replace with your actual key
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'prefill': {
        'contact': prefillContact,
        'email': prefillEmail,
      },
      'theme': {
        'color': '#183954'
      },
      'notes': notes ?? {},
    };

    // Add order_id if provided
    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Dispose the Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}


// Usage in Other Screens
//
// final RazorpayService _razorpayService = RazorpayService();
//
// void _makePayment(BuildContext context) {
//   _razorpayService.openCheckout(
//     context: context,
//     amount: 500.0, // Amount in rupees
//     description: 'Service Name',
//     notes: {
//       'custom_field': 'value',
//     },
//     onSuccess: (response) {
//       // Handle success
//       print('Payment successful: ${response.paymentId}');
//     },
//     onError: (response) {
//       // Handle error
//       print('Payment failed: ${response.message}');
//     },
//   );
// }