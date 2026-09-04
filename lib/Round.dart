
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../App Configuration/app_config.dart';
import '../../Controllers/Services_Controller.dart';
import '../../common/App Bar.dart';
import '../../services/razorpay_service.dart';

class PaymentPlanMaterial extends StatefulWidget {
  const PaymentPlanMaterial({super.key});

  @override
  State<PaymentPlanMaterial> createState() => _PaymentPlanMaterialState();
}

class _PaymentPlanMaterialState extends State<PaymentPlanMaterial> {
  final GlobalKey<TooltipState> _gstTooltipKey = GlobalKey<TooltipState>();
  String selectedPaymentMode = 'pay_now';
  String selectedPaymentOption = 'full'; // 'full', 'minimum', 'custom'
  TextEditingController customAmountController = TextEditingController();
  String? paymentAmountError;
  double apiMinimumFee = 30.0; // Default 30%

  final RazorpayService _razorpayService = RazorpayService();
  var serviceController = Get.put(ServiceController());

  late Map<String, dynamic> paymentData;
  late String paymentType; // 'material' or 'milestone'
  List<dynamic> selectedMaterials = [];
  List<dynamic> selectedMaterialsData = [];
  dynamic milestoneData;
  late double materialCost; // Base material cost
  late int orderId;
  late String serviceName;
  late String vendorName;
  String milestoneTitle = '';

  // Get fee percentages from AppConfig
  double get cGstPercentage {
    try {
      return double.parse(AppConfig.cGST ?? "9.00");
    } catch (e) {
      return 9.0;
    }
  }

  double get sGstPercentage {
    try {
      return double.parse(AppConfig.sGST ?? "9.00");
    } catch (e) {
      return 9.0;
    }
  }

  double get totalGstPercentage => cGstPercentage + sGstPercentage;

  double get platformFeePercentage {
    try {
      return double.parse(AppConfig.platformFee ?? "2.00");
    } catch (e) {
      return 2.0;
    }
  }

  double get convenienceFeePercentage {
    try {
      return double.parse(AppConfig.convenienceFee ?? "2.00");
    } catch (e) {
      return 2.0;
    }
  }

  // Minimum payment percentage from API (only for milestone/plan payments)
  double get minimumPaymentPercentage {
    return apiMinimumFee;
  }

  // Calculate individual fees - keep full precision
  double calculatePlatformFee(double amount) {
    return (amount * platformFeePercentage) / 100;
  }

  double calculateConvenienceFee(double amount) {
    return (amount * convenienceFeePercentage) / 100;
  }

  double calculateCGST(double baseAmount) {
    return (baseAmount * cGstPercentage) / 100;
  }

  double calculateSGST(double baseAmount) {
    return (baseAmount * sGstPercentage) / 100;
  }

  double calculateTotalGST(double baseAmount) {
    return (baseAmount * totalGstPercentage) / 100;
  }

  // Calculate amounts for full payment - maintain precision throughout
  double get platformFee => calculatePlatformFee(materialCost);

  double get convenienceFee => calculateConvenienceFee(materialCost);

  double get baseAmount => materialCost + platformFee + convenienceFee;

  double get cGstAmount => calculateCGST(baseAmount);

  double get sGstAmount => calculateSGST(baseAmount);

  double get totalGstAmount => calculateTotalGST(baseAmount);

  double get totalAmountWithFees => baseAmount + totalGstAmount;

  // Helper method to get display values (rounded)
  Map<String, int> getDisplayValues() {
    final platFeeRounded = platformFee.round();
    final convFeeRounded = convenienceFee.round();
    final baseRounded = materialCost.round() + platFeeRounded + convFeeRounded;
    final gstRounded = (baseRounded * totalGstPercentage / 100).round();
    final totalRounded = baseRounded + gstRounded;
    final cgstRounded = (baseRounded * cGstPercentage / 100).round();
    final sgstRounded = (baseRounded * sGstPercentage / 100).round();

    return {
      'materialCost': materialCost.round(),
      'platformFee': platFeeRounded,
      'convenienceFee': convFeeRounded,
      'baseAmount': baseRounded,
      'cgst': cgstRounded,
      'sgst': sgstRounded,
      'totalGst': gstRounded,
      'total': totalRounded,
    };
  }

  // Helper method to get minimum payment display total
  int _getMinimumDisplayTotal() {
    final minMatCost = (materialCost * minimumPaymentPercentage / 100).round();
    final minPlatFee = (minMatCost * platformFeePercentage / 100).round();
    final minConvFee = (minMatCost * convenienceFeePercentage / 100).round();
    final minBase = minMatCost + minPlatFee + minConvFee;
    final minGst = (minBase * totalGstPercentage / 100).round();
    return minBase + minGst;
  }

  // Helper method to get custom amount display total
  int _getCustomDisplayTotal(double customAmount) {
    final customMatCost = customAmount.round();
    final customPlatFee = (customMatCost * platformFeePercentage / 100).round();
    final customConvFee = (customMatCost * convenienceFeePercentage / 100)
        .round();
    final customBase = customMatCost + customPlatFee + customConvFee;
    final customGst = (customBase * totalGstPercentage / 100).round();
    return customBase + customGst;
  }

  // Helper method to get selected payment display total
  int _getSelectedPaymentDisplayTotal() {
    switch (selectedPaymentOption) {
      case 'full':
        return getDisplayValues()['total']!;
      case 'minimum':
        return _getMinimumDisplayTotal();
      case 'custom':
        double customValue = double.tryParse(customAmountController.text) ?? 0;
        if (customValue > 0) {
          return _getCustomDisplayTotal(customValue);
        }
        return getDisplayValues()['total']!;
      default:
        return getDisplayValues()['total']!;
    }
  }

  // Calculate minimum amount using dynamic percentage
  double get minimumMaterialCost =>
      materialCost * minimumPaymentPercentage / 100;

  double get minimumPlatformFee => calculatePlatformFee(minimumMaterialCost);

  double get minimumConvenienceFee =>
      calculateConvenienceFee(minimumMaterialCost);

  double get minimumBaseAmount =>
      minimumMaterialCost + minimumPlatformFee + minimumConvenienceFee;

  double get minimumGstAmount => calculateTotalGST(minimumBaseAmount);

  double get minimumTotalAmount => minimumBaseAmount + minimumGstAmount;

  // Get selected payment breakdown with rounded values
  Map<String, double> getPaymentBreakdown() {
    double matCost, platFee, convFee, baseAmt, cgst, sgst, totalGst, total;

    switch (selectedPaymentOption) {
      case 'full':
        matCost = materialCost.round().toDouble();
        platFee = (matCost * platformFeePercentage / 100).round().toDouble();
        convFee = (matCost * convenienceFeePercentage / 100).round().toDouble();
        baseAmt = matCost + platFee + convFee;
        totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
        cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
        sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
        total = (baseAmt + totalGst).round().toDouble();
        break;

      case 'minimum':
        matCost = (materialCost * minimumPaymentPercentage / 100)
            .round()
            .toDouble();
        platFee = (matCost * platformFeePercentage / 100).round().toDouble();
        convFee = (matCost * convenienceFeePercentage / 100).round().toDouble();
        baseAmt = matCost + platFee + convFee;
        totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
        cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
        sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
        total = (baseAmt + totalGst).round().toDouble();
        break;

      case 'custom':
        double customValue = double.tryParse(customAmountController.text) ?? 0;
        matCost = customValue.round().toDouble();
        platFee = (matCost * platformFeePercentage / 100).round().toDouble();
        convFee = (matCost * convenienceFeePercentage / 100).round().toDouble();
        baseAmt = matCost + platFee + convFee;
        totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
        cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
        sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
        total = (baseAmt + totalGst).round().toDouble();
        break;

      default:
        matCost = materialCost.round().toDouble();
        platFee = (matCost * platformFeePercentage / 100).round().toDouble();
        convFee = (matCost * convenienceFeePercentage / 100).round().toDouble();
        baseAmt = matCost + platFee + convFee;
        totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
        cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
        sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
        total = (baseAmt + totalGst).round().toDouble();
    }

    return {
      'materialCost': matCost,
      'platformFee': platFee,
      'convenienceFee': convFee,
      'baseAmount': baseAmt,
      'cgst': cgst,
      'sgst': sgst,
      'totalGst': totalGst,
      'total': total,
    };
  }

  double getSelectedPaymentAmount() {
    return getPaymentBreakdown()['total']!;
  }

  @override
  void initState() {
    super.initState();
    paymentData = Get.arguments as Map<String, dynamic>;
    paymentType = paymentData['payment_type'] ?? 'material';

    try {
      String minimumFeeStr = paymentData['minimum_fee']?.toString() ?? "30.00";
      apiMinimumFee = double.parse(minimumFeeStr);
    } catch (e) {
      apiMinimumFee = 30.0; // Default to 30% if parsing fails
    }

    if (paymentType == 'milestone') {
      milestoneData = paymentData['milestone_data'];
      milestoneTitle = paymentData['milestone_title'] ?? 'Milestone Payment';
      materialCost = paymentData['balance_cost'] ?? 0.0;
    } else {
      selectedMaterials = paymentData['selected_materials'] ?? [];
      selectedMaterialsData = paymentData['selected_materials_data'] ?? [];
      materialCost = paymentData['balance_cost'] ?? 0.0;
    }

    orderId = paymentData['order_id'] ?? 0;
    serviceName = paymentData['service_name'] ?? 'Service';
    vendorName = paymentData['vendor_name'] ?? 'Vendor';
  }

  // Show Payment Options Bottom Sheet (only for milestone/plan payments)
  void _showPaymentOptionsBottomSheet() {
    paymentAmountError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Choose Payment Amount',
                              style: TextStyle(
                                color: Color(0xFF183954),
                                fontSize: 20,
                                fontFamily: 'Figtree-Bold',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF49545C),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select how much you want to pay now',
                          style: TextStyle(
                            color: Color(0x99183954),
                            fontSize: 14,
                            fontFamily: 'Figtree-Regular',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Payment Options Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF7F9FC),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFCEDBE8),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Option 1: Pay Full Amount
                              _buildPaymentOptionTile(
                                value: 'full',
                                title: 'Pay Full Amount',
                                amount: '₹${getDisplayValues()['total']}',
                                description: 'Complete payment now',
                                isSelected: selectedPaymentOption == 'full',
                                onTap: () {
                                  setModalState(() {
                                    selectedPaymentOption = 'full';
                                    paymentAmountError = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                              // Option 2: Pay Minimum (30%)
                              _buildPaymentOptionTile(
                                value: 'minimum',
                                title:
                                'Pay Minimum (${minimumPaymentPercentage.toStringAsFixed(0)}%)',
                                amount: '₹${_getMinimumDisplayTotal()}',
                                description: 'Pay remaining amount later',
                                isSelected: selectedPaymentOption == 'minimum',
                                onTap: () {
                                  setModalState(() {
                                    selectedPaymentOption = 'minimum';
                                    paymentAmountError = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                              // Option 3: Enter Custom Amount
                              _buildPaymentOptionTile(
                                value: 'custom',
                                title: 'Enter Custom Amount',
                                amount: '',
                                description: 'Choose your own amount',
                                isSelected: selectedPaymentOption == 'custom',
                                onTap: () {
                                  setModalState(() {
                                    selectedPaymentOption = 'custom';
                                  });
                                },
                                isCustom: true,
                              ),

                              // Custom Amount Input Field
                              if (selectedPaymentOption == 'custom') ...[
                                const SizedBox(height: 16),
                                Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: paymentAmountError != null
                                            ? const Color(0xFFE53E3E)
                                            : const Color(0xFFCEDBE8),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: customAmountController,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      onChanged: (value) {
                                        setModalState(() {
                                          paymentAmountError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                        'Enter amount (min: ₹${minimumMaterialCost.toStringAsFixed(0)})',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFFA0AEC0),
                                          fontSize: 14,
                                          fontFamily: 'Figtree-Regular',
                                        ),
                                        prefixText: '₹ ',
                                        prefixStyle: const TextStyle(
                                          color: Color(0xFF273442),
                                          fontSize: 16,
                                          fontFamily: 'Figtree-Medium',
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF273442),
                                        fontSize: 16,
                                        fontFamily: 'Figtree-Medium',
                                      ),
                                    ),
                                  ),
                                ),
                                if (paymentAmountError != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 16,
                                        color: Color(0xFFE53E3E),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          paymentAmountError!,
                                          style: const TextStyle(
                                            color: Color(0xFFE53E3E),
                                            fontSize: 12,
                                            fontFamily: 'Figtree-Regular',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Color(0xFFE8943A),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Minimum: ₹${minimumMaterialCost.toStringAsFixed(0)} + fees & ${totalGstPercentage.toStringAsFixed(0)}% GST',
                                          style: const TextStyle(
                                            color: Color(0xFF49545C),
                                            fontSize: 12,
                                            fontFamily: 'Figtree-Regular',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Proceed Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate custom amount
                              if (selectedPaymentOption == 'custom') {
                                double customValue =
                                    double.tryParse(
                                      customAmountController.text,
                                    ) ??
                                        0;
                                double minRequired = minimumMaterialCost;

                                if (customAmountController.text
                                    .trim()
                                    .isEmpty) {
                                  setModalState(() {
                                    paymentAmountError =
                                    'Please enter an amount';
                                  });
                                  return;
                                }

                                if (customValue < minRequired) {
                                  setModalState(() {
                                    paymentAmountError =
                                    'Amount must be at least ₹${minRequired.toStringAsFixed(0)}';
                                  });
                                  return;
                                }

                                if (customValue > materialCost) {
                                  setModalState(() {
                                    paymentAmountError =
                                    'Amount cannot exceed ₹${materialCost.toStringAsFixed(0)}';
                                  });
                                  return;
                                }
                              }

                              // Close bottom sheet and proceed to payment
                              Navigator.pop(context);
                              _processPayment();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A202C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Proceed to Pay ₹${_getSelectedPaymentDisplayTotal()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Figtree-Medium',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String value,
    required String title,
    required String amount,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B517E) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1B517E)
                      : const Color(0xFFCEDBE8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1B517E),
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF183954),
                      fontSize: 14,
                      fontFamily: 'Figtree-Medium',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0x99183954),
                      fontSize: 12,
                      fontFamily: 'Figtree-Regular',
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            if (!isCustom)
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFF1B517E),
                  fontSize: 16,
                  fontFamily: 'Figtree-Medium',
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // COMMENTED OUT - FOR FUTURE PARTIAL PAYMENT FEATURE FOR MATERIALS

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Payment successfully Completed!',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Figtree-Medium',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF038153),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Pop back with result to trigger refresh
    Get.back(result: true);
  }

  void _processPayment() {
    if (selectedPaymentMode == 'pay_now') {
      final breakdown = getPaymentBreakdown();
      final paymentAmount = breakdown['total']!;
      final materialAmount = breakdown['materialCost']!;
      final platformFeeAmount = breakdown['platformFee']!;
      final convenienceFeeAmount = breakdown['convenienceFee']!;
      final totalGstAmount = breakdown['totalGst']!;

      String description = paymentType == 'milestone'
          ? 'Milestone Payment - $milestoneTitle'
          : 'Material Payment - ${selectedMaterials.length} items';

      Map<String, dynamic> notes = paymentType == 'milestone'
          ? {'payment_type': 'milestone'}
          : {'payment_type': 'material'};

      _razorpayService.openCheckout(
        context: context,
        amount: paymentAmount,
        description: description,
        notes: notes,
        onSuccess: (response) {
          Map<String, dynamic> successData = {
            "razorpay_order_id": response.orderId ?? '',
            "razorpay_payment_id": response.paymentId ?? '',
            "razorpay_signature": response.signature ?? '',
            "amount_paid": paymentAmount.toString(),
          };

          if (paymentType == 'milestone') {
            serviceController
                .getMaterialPaymentOrder("payment_update", {
              "order_id": orderId,
              "notes": "Plan Payment",
              "payment_data": jsonEncode([milestoneData]),
              "currency": "INR",
              "payment_id": response.paymentId ?? "",
              "payment_json": jsonEncode(successData),
              "payment_status": "success",
              "payment_amount": paymentAmount.toString(),
              "payment_type": "plan",
              'platform_cost': platformFeeAmount.toString(),
              'base_amount': materialAmount.round().toString(),
              'convenience_fee_cost': convenienceFeeAmount
                  .round()
                  .toString(),
              'tax_cost': totalGstAmount.toString(),
            })
                .then((_) {
              _showSuccessMessage();
            });
          } else {
            serviceController
                .getMaterialPaymentOrder("payment_update", {
              "order_id": orderId,
              "notes": "material",
              "payment_data": jsonEncode(selectedMaterialsData),
              "currency": "INR",
              "payment_id": response.paymentId ?? "",
              "payment_json": jsonEncode(successData),
              "payment_status": "success",
              "payment_amount": paymentAmount.toString(),
              "payment_type": "material",
              'base_amount': materialAmount.round().toString(),
              'platform_cost': platformFeeAmount.toString(),
              'convenience_fee_cost': convenienceFeeAmount
                  .round()
                  .toString(),
              'tax_cost': totalGstAmount.toString(),
            })
                .then((_) {
              _showSuccessMessage();
            });
          }
        },
        onError: (response) {
          Map<String, dynamic> errorData = {
            "code": response.code?.toString() ?? "",
            "message": response.message ?? "Payment failed",
          };

          final breakdown = getPaymentBreakdown();
          final paymentAmount = breakdown['total']!;
          final materialAmount = breakdown['materialCost']!;
          final platformFeeAmount = breakdown['platformFee']!;
          final convenienceFeeAmount = breakdown['convenienceFee']!;
          final totalGstAmount = breakdown['totalGst']!;

          if (paymentType == 'milestone') {
            serviceController
                .getMaterialPaymentOrder("payment_update", {
              "order_id": orderId,
              "notes": "Plan Payment",
              "payment_data": jsonEncode([milestoneData]),
              "currency": "INR",
              "payment_id": "",
              "payment_json": jsonEncode(errorData),
              "payment_status": "failed",
              "payment_amount": paymentAmount.toString(),
              "payment_type": "plan",
              'base_amount': materialAmount.round().toString(),
              'platform_cost': platformFeeAmount.toString(),
              'convenience_fee_cost': convenienceFeeAmount
                  .round()
                  .toString(),
              'tax_cost': totalGstAmount.toString(),
            })
                .then((_) {
              Get.back();
            });
          } else {
            serviceController
                .getMaterialPaymentOrder("payment_update", {
              "order_id": orderId,
              "notes": "material",
              "payment_data": jsonEncode(selectedMaterialsData),
              "currency": "INR",
              "payment_id": "",
              "payment_json": jsonEncode(errorData),
              "payment_status": "failed",
              "payment_amount": paymentAmount.toString(),
              "payment_type": "material",
              'base_amount': materialAmount.round().toString(),
              'platform_cost': platformFeeAmount.toString(),
              'convenience_fee_cost': convenienceFeeAmount
                  .round()
                  .toString(),
              'tax_cost': totalGstAmount.toString(),
            })
                .then((_) {
              Get.back();
            });
          }

          _showErrorMessage();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quote request submitted successfully!'),
          backgroundColor: Color(0xFF038153),
        ),
      );
      Get.back();
    }
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Payment Failed!',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Figtree-Medium',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF44336),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getMilestoneDescription() {
    if (milestoneData == null) return '';

    try {
      final desc = milestoneData.description;
      return desc?.toString() ?? '';
    } catch (e) {
      try {
        final details = milestoneData.details;
        return details?.toString() ?? '';
      } catch (e2) {
        try {
          final note = milestoneData.note;
          return note?.toString() ?? '';
        } catch (e3) {
          return '';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        appBar: const CustomAppBar(title: 'Payment'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Service Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0xFFEDF2F6),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                color: Color(0xFF183954),
                                fontSize: 18,
                                fontFamily: 'Figtree-Medium',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vendorName,
                              style: const TextStyle(
                                color: Color(0x99183954),
                                fontSize: 12,
                                fontFamily: 'Figtree-Regular',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '₹${materialCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFE8943A),
                                fontSize: 18,
                                fontFamily: 'Figtree-Medium',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0xFFEDF2F6),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF7F9FC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Icon(
                                      paymentType == 'milestone'
                                          ? Icons.flag_outlined
                                          : Icons.inventory_2_outlined,
                                      color: const Color(0xFF183954),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          paymentType == 'milestone'
                                              ? 'Milestone Details'
                                              : 'Selected Materials',
                                          style: const TextStyle(
                                            color: Color(0xFF183954),
                                            fontSize: 16,
                                            fontFamily: 'Figtree-Medium',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          paymentType == 'milestone'
                                              ? '1 milestone'
                                              : '${selectedMaterials.length} items selected',
                                          style: const TextStyle(
                                            color: Color(0x99183954),
                                            fontSize: 12,
                                            fontFamily: 'Figtree-Regular',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (paymentType == 'milestone') ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9FC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFCEDBE8),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      milestoneTitle,
                                      style: const TextStyle(
                                        color: Color(0xFF183954),
                                        fontSize: 16,
                                        fontFamily: 'Figtree-Medium',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_getMilestoneDescription()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _getMilestoneDescription(),
                                        style: const TextStyle(
                                          color: Color(0xFF49545C),
                                          fontSize: 12,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ] else ...[
                              ...selectedMaterials.map((material) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF7F9FC),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFCEDBE8),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                material.name ?? '',
                                                style: const TextStyle(
                                                  color: Color(0xFF183954),
                                                  fontSize: 14,
                                                  fontFamily: 'Figtree-Medium',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${material.quantity} ${material.unit}',
                                                style: const TextStyle(
                                                  color: Color(0x99183954),
                                                  fontSize: 12,
                                                  fontFamily: 'Figtree-Regular',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₹${double.parse(material.cost.toString()).round().toString()}',
                                          style: const TextStyle(
                                            color: Color(0xFF183954),
                                            fontSize: 14,
                                            fontFamily: 'Lato-Medium',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Payment Mode Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFD9D9D9),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Mode',
                              style: TextStyle(
                                color: Color(0xFF183954),
                                fontSize: 18,
                                fontFamily: 'Figtree-Medium',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Radio Button Options Container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF7F9FC),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCEDBE8),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPaymentMode = 'pay_now';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFF1B517E),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const ShapeDecoration(
                                            color: Color(0xFF1B517E),
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Pay Now',
                                      style: TextStyle(
                                        color: Color(0xFF49545C),
                                        fontSize: 14,
                                        fontFamily: 'Lato-Regular',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Payment Summary
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      paymentType == 'milestone'
                                          ? 'Milestone Amount'
                                          : 'Material Cost',
                                      style: const TextStyle(
                                        color: Color(0xFF49545C),
                                        fontSize: 14,
                                        fontFamily: 'Lato-Regular',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                      ),
                                    ),
                                    Text(
                                      '₹${getDisplayValues()['materialCost']}',
                                      style: const TextStyle(
                                        color: Color(0xFF183954),
                                        fontSize: 14,
                                        fontFamily: 'Lato-Regular',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),
                                CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DottedLinePainter(),
                                ),
                                const SizedBox(height: 10),
                                if (getDisplayValues()['platformFee'] != 0) ...[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Platform fee',
                                        style: TextStyle(
                                          color: Color(0xFF49545C),
                                          fontSize: 12.5,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w500,
                                          height: 1.43,
                                        ),
                                      ),
                                      Text(
                                        '₹${getDisplayValues()['platformFee']}',
                                        style: const TextStyle(
                                          color: Color(0xFF183954),
                                          fontSize: 12.5,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                // Platform Fee

                                // Convenience Fee
                                if (getDisplayValues()['convenienceFee'] !=
                                    0) ...[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Convenience fee',
                                        style: TextStyle(
                                          color: Color(0xFF49545C),
                                          fontSize: 12.5,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w500,
                                          height: 1.43,
                                        ),
                                      ),
                                      Text(
                                        '₹${getDisplayValues()['convenienceFee']}',
                                        style: const TextStyle(
                                          color: Color(0xFF183954),
                                          fontSize: 12.5,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // GST with Tooltip
                                GestureDetector(
                                  onTap: () {
                                    final dynamic tooltip =
                                        _gstTooltipKey.currentState;
                                    tooltip?.ensureTooltipVisible();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'GST ${totalGstPercentage.toStringAsFixed(0)}% ${"of all the line item"}',
                                            style: const TextStyle(
                                              color: Color(0xFF49545C),
                                              fontSize: 12.5,
                                              fontFamily: 'Lato-Regular',
                                              fontWeight: FontWeight.w500,
                                              height: 1.43,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Tooltip(
                                            key: _gstTooltipKey,
                                            message:
                                            'CGST (${cGstPercentage.toStringAsFixed(1)}%): ₹${getDisplayValues()['cgst']}\nSGST (${sGstPercentage.toStringAsFixed(1)}%): ₹${getDisplayValues()['sgst']}\nTotal GST: ₹${getDisplayValues()['totalGst']}',
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF273442),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Lato-Regular',
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            preferBelow: true,
                                            verticalOffset: 10,
                                            waitDuration: Duration.zero,
                                            showDuration: const Duration(
                                              seconds: 5,
                                            ),
                                            triggerMode:
                                            TooltipTriggerMode.manual,
                                            child: const Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: Color(0xFF49545C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹${getDisplayValues()['totalGst']}',
                                        style: const TextStyle(
                                          color: Color(0xFF183954),
                                          fontSize: 12.5,
                                          fontFamily: 'Lato-Regular',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Total
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        color: Color(0xFF183954),
                                        fontSize: 18,
                                        fontFamily: 'Lato-Medium',
                                        fontWeight: FontWeight.w700,
                                        height: 1.11,
                                      ),
                                    ),
                                    Text(
                                      '₹${getDisplayValues()['total']}',
                                      style: const TextStyle(
                                        color: Color(0xFF183954),
                                        fontSize: 18,
                                        fontFamily: 'Lato-Medium',
                                        fontWeight: FontWeight.w700,
                                        height: 1.11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button - CONDITIONAL BASED ON PAYMENT TYPE
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to proceed with payment?',
                    style: TextStyle(
                      color: Color(0xFF0C141C),
                      fontSize: 12,
                      fontFamily: 'Figtree-Medium',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    // For milestone: show options, For material: direct payment
                    onPressed: paymentType == 'milestone'
                        ? _showPaymentOptionsBottomSheet
                        : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A202C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      paymentType == 'milestone'
                          ? 'Choose Payment Option'
                          : 'Pay ₹${getDisplayValues()['total']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Figtree-Medium',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }
}

// Custom Painter for Dotted Line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCEDBE8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




////////////////////////////////////////////////////////////////////////////////

// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vayil_customer/common/common_button.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../App Configuration/app_config.dart';
// import '../../Controllers/Login_controller.dart';
// import '../../Controllers/Services_Controller.dart';
// import '../../Routes/app_routes.dart';
// import '../../Web_view.dart';
// import '../../common/App Bar.dart';
// import '../../common/Escrow tooltip widget.dart';
// import '../../services/payment_data.dart';
// import '../../services/razorpay_service.dart';
//
// class OrderConfirmationPaymentScreen extends StatefulWidget {
//   const OrderConfirmationPaymentScreen({super.key});
//
//   @override
//   State<OrderConfirmationPaymentScreen> createState() =>
//       _OrderConfirmationPaymentScreenState();
// }
//
// class _OrderConfirmationPaymentScreenState
//     extends State<OrderConfirmationPaymentScreen> {
//   final GlobalKey<TooltipState> _gstTooltipKey = GlobalKey<TooltipState>();
//   var serviceController = Get.put(ServiceController());
//   var loginController = Get.put(LoginController());
//   bool _isLoading = false;
//   final GlobalKey<TooltipState> _escrowTooltipKey = GlobalKey<TooltipState>();
//
//
//   String selectedPaymentMode = 'payNow';
//   String selectedPaymentOption = 'full'; // 'full', 'minimum', 'custom'
//   TextEditingController customAmountController = TextEditingController();
//   String? paymentAmountError;
//
//   final RazorpayService _razorpayService = RazorpayService();
//   // Get fee percentages from AppConfig (matching PaymentPlanMaterial)
//
//   double get minimumPaymentPercentage {
//     try {
//       String minimumFee = serviceController
//           .enquireDetailsData
//           .value
//           .data![0]
//           .minimumFee
//           .toString();
//       return double.parse(minimumFee);
//     } catch (e) {
//       return 30.0; // Default to 30% if parsing fails
//     }
//   }
//
//   double get cGstPercentage {
//     try {
//       return double.parse(AppConfig.cGST ?? "9.00");
//     } catch (e) {
//       return 9.0;
//     }
//   }
//
//   double get sGstPercentage {
//     try {
//       return double.parse(AppConfig.sGST ?? "9.00");
//     } catch (e) {
//       return 9.0;
//     }
//   }
//
//   double get totalGstPercentage => cGstPercentage + sGstPercentage;
//
//   double get platformFeePercentage {
//     try {
//       return double.parse(AppConfig.platformFee ?? "2.00");
//     } catch (e) {
//       return 2.0;
//     }
//   }
//
//   double get convenienceFeePercentage {
//     try {
//       return double.parse(AppConfig.convenienceFee ?? "2.00");
//     } catch (e) {
//       return 2.0;
//     }
//   }
//   // Calculate individual fees - keep full precision
//   double calculatePlatformFee(double amount) {
//     return (amount * platformFeePercentage) / 100;
//   }
//
//   double calculateConvenienceFee(double amount) {
//     return (amount * convenienceFeePercentage) / 100;
//   }
//
//   double calculateCGST(double baseAmount) {
//     return (baseAmount * cGstPercentage) / 100;
//   }
//
//   double calculateSGST(double baseAmount) {
//     return (baseAmount * sGstPercentage) / 100;
//   }
//
//   double calculateTotalGST(double baseAmount) {
//     return (baseAmount * totalGstPercentage) / 100;
//   }
//
// // Base order amount from quotation
//   double get orderAmount {
//     return double.parse(
//       serviceController
//           .enquireDetailsData
//           .value
//           .data![0]
//           .quotations!
//           .first
//           .amount
//           .toString(),
//     );
//   }
//
// // Calculate amounts for full payment - maintain precision throughout
//   double get platformFee => calculatePlatformFee(orderAmount);
//   double get convenienceFee => calculateConvenienceFee(orderAmount);
//   double get baseAmount => orderAmount + platformFee + convenienceFee;
//   double get cGstAmount => calculateCGST(baseAmount);
//   double get sGstAmount => calculateSGST(baseAmount);
//   double get totalGstAmount => calculateTotalGST(baseAmount);
//   double get totalAmountWithFees => baseAmount + totalGstAmount;
//
// // Helper method to get display values (rounded)
//   Map<String, int> getDisplayValues() {
//     final platFeeRounded = platformFee.round();
//     final convFeeRounded = convenienceFee.round();
//     final baseRounded = orderAmount.round() + platFeeRounded + convFeeRounded;
//     final gstRounded = (baseRounded * totalGstPercentage / 100).round();
//     final totalRounded = baseRounded + gstRounded;
//     final cgstRounded = (baseRounded * cGstPercentage / 100).round();
//     final sgstRounded = (baseRounded * sGstPercentage / 100).round();
//
//     return {
//       'orderAmount': orderAmount.round(),
//       'platformFee': platFeeRounded,
//       'convenienceFee': convFeeRounded,
//       'baseAmount': baseRounded,
//       'cgst': cgstRounded,
//       'sgst': sgstRounded,
//       'totalGst': gstRounded,
//       'total': totalRounded,
//     };
//   }// Helper method to get minimum payment display total
//   int _getMinimumDisplayTotal() {
//     final minOrderAmount = (orderAmount * minimumPaymentPercentage / 100).round();
//     final minPlatFee = (minOrderAmount * platformFeePercentage / 100).round();
//     final minConvFee = (minOrderAmount * convenienceFeePercentage / 100).round();
//     final minBase = minOrderAmount + minPlatFee + minConvFee;
//     final minGst = (minBase * totalGstPercentage / 100).round();
//     return minBase + minGst;
//   }
//
// // Helper method to get custom amount display total
//   int _getCustomDisplayTotal(double customAmount) {
//     final customOrderAmount = customAmount.round();
//     final customPlatFee = (customOrderAmount * platformFeePercentage / 100).round();
//     final customConvFee = (customOrderAmount * convenienceFeePercentage / 100).round();
//     final customBase = customOrderAmount + customPlatFee + customConvFee;
//     final customGst = (customBase * totalGstPercentage / 100).round();
//     return customBase + customGst;
//   }
//
// // Helper method to get selected payment display total
//   int _getSelectedPaymentDisplayTotal() {
//     switch (selectedPaymentOption) {
//       case 'full':
//         return getDisplayValues()['total']!;
//       case 'minimum':
//         return _getMinimumDisplayTotal();
//       case 'custom':
//         double customValue = double.tryParse(customAmountController.text) ?? 0;
//         if (customValue > 0) {
//           return _getCustomDisplayTotal(customValue);
//         }
//         return getDisplayValues()['total']!;
//       default:
//         return getDisplayValues()['total']!;
//     }
//   }
//
//
//   // Calculate minimum amount (30% of order amount + all fees)
//   double get minimumOrderAmount => orderAmount * minimumPaymentPercentage / 100;
//   double get minimumPlatformFee => calculatePlatformFee(minimumOrderAmount);
//   double get minimumConvenienceFee => calculateConvenienceFee(minimumOrderAmount);
//   double get minimumBaseAmount => minimumOrderAmount + minimumPlatformFee + minimumConvenienceFee;
//   double get minimumGstAmount => calculateTotalGST(minimumBaseAmount);
//   double get minimumTotalAmount => minimumBaseAmount + minimumGstAmount;
//   // Get selected payment breakdown with rounded values
//   Map<String, double> getPaymentBreakdown() {
//     double ordAmt, platFee, convFee, baseAmt, cgst, sgst, totalGst, total;
//
//     switch (selectedPaymentOption) {
//       case 'full':
//         ordAmt = orderAmount.round().toDouble();
//         platFee = (ordAmt * platformFeePercentage / 100).round().toDouble();
//         convFee = (ordAmt * convenienceFeePercentage / 100).round().toDouble();
//         baseAmt = ordAmt + platFee + convFee;
//         totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
//         cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
//         sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
//         total = (baseAmt + totalGst).round().toDouble();
//         break;
//
//       case 'minimum':
//         ordAmt = (orderAmount * minimumPaymentPercentage / 100).round().toDouble();
//         platFee = (ordAmt * platformFeePercentage / 100).round().toDouble();
//         convFee = (ordAmt * convenienceFeePercentage / 100).round().toDouble();
//         baseAmt = ordAmt + platFee + convFee;
//         totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
//         cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
//         sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
//         total = (baseAmt + totalGst).round().toDouble();
//         break;
//
//       case 'custom':
//         double customValue = double.tryParse(customAmountController.text) ?? 0;
//         ordAmt = customValue.round().toDouble();
//         platFee = (ordAmt * platformFeePercentage / 100).round().toDouble();
//         convFee = (ordAmt * convenienceFeePercentage / 100).round().toDouble();
//         baseAmt = ordAmt + platFee + convFee;
//         totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
//         cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
//         sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
//         total = (baseAmt + totalGst).round().toDouble();
//         break;
//
//       default:
//         ordAmt = orderAmount.round().toDouble();
//         platFee = (ordAmt * platformFeePercentage / 100).round().toDouble();
//         convFee = (ordAmt * convenienceFeePercentage / 100).round().toDouble();
//         baseAmt = ordAmt + platFee + convFee;
//         totalGst = (baseAmt * totalGstPercentage / 100).round().toDouble();
//         cgst = (baseAmt * cGstPercentage / 100).round().toDouble();
//         sgst = (baseAmt * sGstPercentage / 100).round().toDouble();
//         total = (baseAmt + totalGst).round().toDouble();
//     }
//
//     return {
//       'orderAmount': ordAmt,
//       'platformFee': platFee,
//       'convenienceFee': convFee,
//       'baseAmount': baseAmt,
//       'cgst': cgst,
//       'sgst': sgst,
//       'totalGst': totalGst,
//       'total': total,
//     };
//   }
//
//   double getSelectedPaymentAmount() {
//     return getPaymentBreakdown()['total']!;
//   }
//
//   double get totalAmount => baseAmount + convenienceFee;
//
//   // CHANGED: Update minimum amount calculation to use dynamic percentage
//   double get minimumAmount => (baseAmount * minimumPaymentPercentage / 100) +
//       calculateConvenienceFee(baseAmount * minimumPaymentPercentage / 100);
//
//
//
//   double getConvenienceFeeForSelectedOption() {
//     switch (selectedPaymentOption) {
//       case 'full':
//         return convenienceFee;
//       case 'minimum':
//       // CHANGED: Use dynamic minimum payment percentage
//         return calculateConvenienceFee(baseAmount * minimumPaymentPercentage / 100);
//       case 'custom':
//         double customValue = double.tryParse(customAmountController.text) ?? 0;
//         return calculateConvenienceFee(customValue);
//       default:
//         return convenienceFee;
//     }
//   }
//
//
//   void _showPaymentOptionsBottomSheet() {
//     // Reset error
//     paymentAmountError = null;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => GestureDetector(
//         onTap: () {
//           // Dismiss keyboard when tapping outside text fields
//           FocusScope.of(context).unfocus();
//         },
//         child: StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Choose Payment Amount',
//                               style: TextStyle(
//                                 color: Color(0xFF183954),
//                                 fontSize: 20,
//                                 fontFamily: 'Figtree-Bold',
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(
//                                 Icons.close,
//                                 color: Color(0xFF49545C),
//                               ),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Select how much you want to pay now',
//                           style: TextStyle(
//                             color: Color(0x99183954),
//                             fontSize: 14,
//                             fontFamily: 'Figtree-Regular',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Payment Options Container
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(16),
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFF7F9FC),
//                             shape: RoundedRectangleBorder(
//                               side: const BorderSide(
//                                 width: 1,
//                                 color: Color(0xFFCEDBE8),
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               // Option 1: Pay Full Amount
//                               _buildPaymentOptionTile(
//                                 value: 'full',
//                                 title: 'Pay Full Amount',
//                                 amount: '₹${getDisplayValues()['total']}',
//                                 description: 'Complete payment now',
//                                 isSelected: selectedPaymentOption == 'full',
//                                 onTap: () {
//                                   setModalState(() {
//                                     selectedPaymentOption = 'full';
//                                     paymentAmountError = null;
//                                   });
//                                 },
//                               ),
//                               const SizedBox(height: 12),
//
//                               // Option 2: Pay Minimum (30%)
//                               _buildPaymentOptionTile(
//                                 value: 'minimum',
//                                 title: 'Pay Minimum (${minimumPaymentPercentage.toStringAsFixed(0)}%)',
//                                 amount: '₹${_getMinimumDisplayTotal()}',
//                                 description: 'Pay remaining amount later',
//                                 isSelected: selectedPaymentOption == 'minimum',
//                                 onTap: () {
//                                   setModalState(() {
//                                     selectedPaymentOption = 'minimum';
//                                     paymentAmountError = null;
//                                   });
//                                 },
//                               ),
//                               const SizedBox(height: 12),
//
//                               // Option 3: Enter Custom Amount
//                               _buildPaymentOptionTile(
//                                 value: 'custom',
//                                 title: 'Enter Custom Amount',
//                                 amount: '',
//                                 description: 'Choose your own amount',
//                                 isSelected: selectedPaymentOption == 'custom',
//                                 onTap: () {
//                                   setModalState(() {
//                                     selectedPaymentOption = 'custom';
//                                   });
//                                 },
//                                 isCustom: true,
//                               ),
//
//                               // Custom Amount Input Field
//                               if (selectedPaymentOption == 'custom') ...[
//                                 const SizedBox(height: 16),
//                                 Container(
//                                   decoration: ShapeDecoration(
//                                     color: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       side: BorderSide(
//                                         width: 1,
//                                         color: paymentAmountError != null
//                                             ? const Color(0xFFE53E3E)
//                                             : const Color(0xFFCEDBE8),
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   child: Center(
//                                     child: TextField(
//                                       controller: customAmountController,
//                                       keyboardType: TextInputType.number,
//                                       autofocus: true,
//                                       onChanged: (value) {
//                                         setModalState(() {
//                                           paymentAmountError = null;
//                                         });
//                                       },
//                                       decoration: InputDecoration(
//                                         hintText: 'Enter amount (min: ₹${minimumOrderAmount.toStringAsFixed(0)})',
//                                         hintStyle: const TextStyle(
//                                           color: Color(0xFFA0AEC0),
//                                           fontSize: 14,
//                                           fontFamily: 'Figtree-Regular',
//                                         ),
//                                         prefixText: '₹ ',
//                                         prefixStyle: const TextStyle(
//                                           color: Color(0xFF273442),
//                                           fontSize: 16,
//                                           fontFamily: 'Figtree-Medium',
//                                         ),
//                                         border: InputBorder.none,
//                                         contentPadding: const EdgeInsets.all(16),
//                                       ),
//                                       style: const TextStyle(
//                                         color: Color(0xFF273442),
//                                         fontSize: 16,
//                                         fontFamily: 'Figtree-Medium',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 if (paymentAmountError != null) ...[
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.error_outline,
//                                         size: 16,
//                                         color: Color(0xFFE53E3E),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           paymentAmountError!,
//                                           style: const TextStyle(
//                                             color: Color(0xFFE53E3E),
//                                             fontSize: 12,
//                                             fontFamily: 'Figtree-Regular',
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFFFF4E5),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.info_outline,
//                                         size: 16,
//                                         color: Color(0xFFE8943A),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           'Minimum: ₹${minimumOrderAmount.toStringAsFixed(0)} + fees & ${totalGstPercentage.toStringAsFixed(0)}% GST',
//                                           style: const TextStyle(
//                                             color: Color(0xFF49545C),
//                                             fontSize: 12,
//                                             fontFamily: 'Figtree-Regular',
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Proceed Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               // Validate custom amount
//                               if (selectedPaymentOption == 'custom') {
//                                 double customValue = double.tryParse(customAmountController.text) ?? 0;
//                                 double minRequired = minimumOrderAmount;
//
//                                 if (customAmountController.text.trim().isEmpty) {
//                                   setModalState(() {
//                                     paymentAmountError = 'Please enter an amount';
//                                   });
//                                   return;
//                                 }
//
//                                 if (customValue < minRequired) {
//                                   setModalState(() {
//                                     paymentAmountError = 'Amount must be at least ₹${minRequired.toStringAsFixed(0)}';
//                                   });
//                                   return;
//                                 }
//
//                                 if (customValue > orderAmount) {
//                                   setModalState(() {
//                                     paymentAmountError = 'Amount cannot exceed ₹${orderAmount.toStringAsFixed(0)}';
//                                   });
//                                   return;
//                                 }
//                               }
//
//                               // Close bottom sheet and proceed to payment
//                               Navigator.pop(context);
//                               _handlePlaceOrder();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF1A202C),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               'Proceed to Pay ₹${_getSelectedPaymentDisplayTotal()}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'Figtree-Medium',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//   Widget _buildPaymentOptionTile({
//     required String value,
//     required String title,
//     required String amount,
//     required String description,
//     required bool isSelected,
//     required VoidCallback onTap,
//     bool isCustom = false,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? AppConfig.primaryColor : Colors.transparent,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             // Radio Button
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected
//                       ? AppConfig.primaryColor
//                       : const Color(0xFFCEDBE8),
//                   width: 2,
//                 ),
//               ),
//               child: isSelected
//                   ? Center(
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppConfig.primaryColor,
//                   ),
//                 ),
//               )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             // Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: const Color(0xFF183954),
//                       fontSize: 14,
//                       fontFamily: 'Figtree-Medium',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       color: const Color(0x99183954),
//                       fontSize: 12,
//                       fontFamily: 'Figtree-Regular',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Amount
//             if (!isCustom)
//               Text(
//                 amount,
//                 style: TextStyle(
//                   color: AppConfig.primaryColor,
//                   fontSize: 16,
//                   fontFamily: 'Figtree-Medium',
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Future<void> _handlePlaceOrder() async {
//     if (_isLoading) return;
// // STEP 2: Get payment breakdown
//     final breakdown = getPaymentBreakdown();
//     final paymentAmount = breakdown['total']!;
//     final orderAmountValue = breakdown['orderAmount']!;
//     final platformFeeAmount = breakdown['platformFee']!;
//     final convenienceFeeAmount = breakdown['convenienceFee']!;
//     final totalGstAmountValue = breakdown['totalGst']!;
//     // Validate note is required
//     // if (serviceController.noteController.text.trim().isEmpty) {
//     //   setState(() {
//     //     showValidation = true;
//     //     noteError = 'Note is required to proceed with your quote';
//     //   });
//     //   _showAddNoteBottomSheet();
//     //   return;
//     // }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     List<String> quoteFiles = [];
//
//     try {
//       // STEP 1: Upload files first (if any)
//       if (serviceController.selectedFiles.isNotEmpty) {
//         await loginController.getFileUpload(
//           "upload_files",
//           imageFiles: serviceController.selectedFiles,
//         );
//
//         if (loginController.fileUploadData.value.success == true &&
//             loginController.fileUploadData.value.uploadedUrls?.uploadFiles !=
//                 null &&
//             loginController
//                 .fileUploadData
//                 .value
//                 .uploadedUrls!
//                 .uploadFiles!
//                 .isNotEmpty) {
//           quoteFiles =
//           loginController.fileUploadData.value.uploadedUrls!.uploadFiles!;
//           debugPrint("Total files uploaded: ${quoteFiles.length}");
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//           Get.snackbar(
//             'Upload Error',
//             'Failed to upload files. Please try again.',
//             backgroundColor: Colors.red.shade100,
//             colorText: Colors.red.shade900,
//             snackPosition: SnackPosition.TOP,
//           );
//           return;
//         }
//       }
//
//       // STEP 2: Initiate Payment with selected amount
//       final paymentAmount = getSelectedPaymentAmount();
//
//       final paymentData = PaymentData.bucketList(
//         total: paymentAmount,
//         serviceName: serviceController
//             .enquireDetailsData
//             .value
//             .data![0]
//             .serviceTitle
//             .toString(),
//         vendorName: serviceController
//             .enquireDetailsData
//             .value
//             .data![0]
//             .companyName
//             .toString(),
//         pricePerSqft: (paymentAmount - convenienceFee).toString(),
//       );
//
//       _razorpayService.openCheckout(
//         context: context,
//         amount: paymentData.amount,
//         description: paymentData.description,
//         notes: paymentData.notes,
//         prefillContact: serviceController.enquireDetailsData.value.data![0].phone.toString(),
//         prefillEmail: serviceController.enquireDetailsData.value.data![0].email.toString(),
//         onSuccess: (response) async {
//           Map<String, dynamic> paymentJson = {
//             "razorpay_order_id": response.orderId ?? '',
//             "razorpay_payment_id": response.paymentId ?? '',
//             "razorpay_signature": response.signature ?? '',
//             "payment_type": selectedPaymentOption,
//             "amount_paid": paymentAmount.toString(),
//           };
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: const [
//                   Icon(Icons.check_circle, color: Colors.white, size: 20),
//                   SizedBox(width: 12),
//                   Text(
//                     'Payment successfully Completed!',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Figtree-Medium',
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: const Color(0xFF038153),
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//
//           await _submitOrderAfterPayment(
//             quoteFiles: quoteFiles,
//             paymentId: response.paymentId ?? '',
//             paymentStatus: 'success',
//             orderAmount: paymentAmount.toString(),
//             paymentJson: paymentJson,
//             baseAmount: orderAmountValue.round().toString(),
//             platformFee: platformFeeAmount.toString(),
//             convenienceFee: convenienceFeeAmount.round().toString(),
//             taxCost: totalGstAmountValue.toString(),
//           );
//
//           Get.offNamedUntil(
//             AppRoutes.profileScreen,
//                 (route) => route.settings.name == AppRoutes.profileScreen,
//           );
//         },
//         onError: (response) async {
//           Map<String, dynamic> paymentJson = {
//             "code": response.code ?? '',
//             "error": response.error ?? '',
//             "message": response.message ?? '',
//           };
//
//           debugPrint("Payment Failed: ${response.message}");
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: const [
//                   Icon(Icons.error, color: Colors.white, size: 20),
//                   SizedBox(width: 12),
//                   Text(
//                     'Payment Failed!',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Figtree-Medium',
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: const Color(0xFFF44336),
//               duration: const Duration(seconds: 2),
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//
//           await _submitOrderAfterPayment(
//             quoteFiles: quoteFiles,
//             paymentId: '',
//             paymentStatus: 'failed',
//             orderAmount: paymentAmount.toString(),
//             paymentJson: paymentJson,
//             baseAmount: orderAmountValue.round().toString(),
//             platformFee: platformFeeAmount.toString(),
//             convenienceFee: convenienceFeeAmount.round().toString(),
//             taxCost: totalGstAmountValue.toString(),
//           );
//
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         onWallet: (response) {
//           debugPrint("External Wallet: ${response.walletName}");
//         },
//       );
//     } catch (e) {
//       debugPrint("Error in _handlePlaceOrder: $e");
//       setState(() {
//         _isLoading = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Something went wrong. Please try again.',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
//
//   Future<void> _submitOrderAfterPayment({
//     required List<String> quoteFiles,
//     required String paymentId,
//     required String paymentStatus,
//     required String orderAmount,
//     required Map<String, dynamic>? paymentJson,
//     required String baseAmount,
//     required String platformFee,
//     required String convenienceFee,
//     required String taxCost,
//   }) async {
//     try {
//       String paymentJsonString = '';
//       if (paymentJson != null) {
//         paymentJsonString = jsonEncode(paymentJson);
//       }
//
//       // await serviceController.getPlaceOrder("placeOrder", {
//       //   "enquiry_id": serviceController.enquireDetailsData.value.data![0].enquiryId,
//       //   "vendor_id": serviceController.enquireDetailsData.value.data![0].vendorId,
//       //   "service_id": serviceController.enquireDetailsData.value.data![0].serviceId,
//       //   "message": serviceController.noteController.text.trim(),
//       //   "files": quoteFiles.join(','),
//       //   "currency": "INR",
//       //   "payment_id": paymentId,
//       //   "payment_json": paymentJsonString,
//       //   "payment_status": paymentStatus,
//       //   "order_amount": orderAmount,
//       //   'payment_type': "place_order",
//       //   'convenience_fee_cost': getConvenienceFeeForSelectedOption(),
//       //   'base_amount': orderAmount.isNotEmpty ? (double.parse(orderAmount) - getConvenienceFeeForSelectedOption()) : 0,
//       //   'payment_option': selectedPaymentOption,
//       //   'platform_cost': platformFee,
//       //   'tax_cost': taxCost,
//       //
//       // });
//
//       await serviceController.getPlaceOrder("placeOrder", {
//         "enquiry_id": serviceController.enquireDetailsData.value.data![0].enquiryId,
//         "vendor_id": serviceController.enquireDetailsData.value.data![0].vendorId,
//         "service_id": serviceController.enquireDetailsData.value.data![0].serviceId,
//         "quote_id": serviceController.enquireDetailsData.value.data![0].quotations!.first.id,
//         "message": serviceController.noteController.text.trim(),
//         "files": quoteFiles.join(','),
//         "currency": "INR",
//         "payment_id": paymentId,
//         "payment_json": paymentJsonString,
//         "payment_status": paymentStatus,
//         "order_amount": orderAmount.isNotEmpty ? double.parse(orderAmount).round() : 0,
//         'payment_type': "place_order",
//         'convenience_fee_cost': getConvenienceFeeForSelectedOption().round(),
//         'base_amount': baseAmount.isNotEmpty ? (double.parse(baseAmount)).round() : 0,
//         'payment_option': selectedPaymentOption,
//         'platform_cost':double.parse(platformFee).round(),
//         'tax_cost':double.parse(taxCost).round(),
//       });
//
//       if (serviceController.quoteSubmitData.value['success'] == true) {
//         if (paymentStatus == 'success') {
//           _submitQuotation(isSuccess: true);
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error in _submitOrderAfterPayment: $e");
//       setState(() {
//         _isLoading = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Failed to submit order. Please try again.',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
//
//   void _submitQuotation({bool isSuccess = false}) {
//     serviceController.noteController.clear();
//     serviceController.selectedFiles.clear();
//
//     setState(() {
//       _isLoading = false;
//       userNote = '';
//     });
//
//     if (isSuccess) {
//       Get.offAndToNamed(AppRoutes.profileScreen);
//     }
//   }
//
//   void _showAddNoteBottomSheet() {
//     // If opening from normal "Add note" button, reset validation
//     if (!showValidation) {
//       noteError = null;
//     } else {
//       // Show initial validation message when opened from Get Quote
//       noteError = 'Note is required to proceed with your quote';
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) {
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Add Note',
//                           style: TextStyle(
//                             color: Color(0xFF183954),
//                             fontSize: 20,
//                             fontFamily: 'Figtree-Bold',
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               showValidation = false;
//                               noteError = null;
//                             });
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(
//                             Icons.close,
//                             color: Color(0xFF49545C),
//                           ),
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//
//                     // Description with required indicator
//                     Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'Add any special instructions or requirements',
//                             style: TextStyle(
//                               color: Color(0x99183954),
//                               fontSize: 14,
//                               fontFamily: 'Figtree-Regular',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                         if (showValidation)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFFEBEE),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: const Text(
//                               'Required',
//                               style: TextStyle(
//                                 color: Color(0xFFD32F2F),
//                                 fontSize: 10,
//                                 fontFamily: 'Figtree-Medium',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Validation Alert Box (if validation is needed)
//                     if (noteError != null && showValidation) ...[
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFFF4E5),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: const Color(0xFFE8943A),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFFE8943A),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.info_outline,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Note Required',
//                                     style: TextStyle(
//                                       color: Color(0xFF183954),
//                                       fontSize: 13,
//                                       fontFamily: 'Figtree-Medium',
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     noteError!,
//                                     style: const TextStyle(
//                                       color: Color(0xFF49545C),
//                                       fontSize: 12,
//                                       fontFamily: 'Figtree-Regular',
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//
//                     // Text Field
//                     Container(
//                       decoration: ShapeDecoration(
//                         color: const Color(0xFFF7F9FC),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                             width: 1.5,
//                             color: noteError != null && showValidation
//                                 ? const Color(0xFFE8943A)
//                                 : const Color(0xFFCEDBE8),
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: TextField(
//                         controller: serviceController.noteController,
//                         maxLines: 5,
//                         autofocus: showValidation,
//                         // Auto-focus if validation is shown
//                         onChanged: (value) {
//                           // Clear error when user starts typing
//                           if (noteError != null && value.trim().isNotEmpty) {
//                             setModalState(() {
//                               noteError = null;
//                             });
//                           }
//                         },
//                         decoration: InputDecoration(
//                           hintText:
//                           'Example: Need painting for 2 bedrooms and living room...',
//                           hintStyle: const TextStyle(
//                             color: Color(0xFFA0AEC0),
//                             fontSize: 14,
//                             fontFamily: 'Figtree-Regular',
//                             fontWeight: FontWeight.w400,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         style: const TextStyle(
//                           color: Color(0xFF273442),
//                           fontSize: 14,
//                           fontFamily: 'Figtree-Regular',
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Save Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: PrimaryButton(
//                         title: "Save Note",
//                         onTap: () {
//                           // Validate note
//                           if (serviceController.noteController.text
//                               .trim()
//                               .isEmpty) {
//                             setModalState(() {
//                               noteError =
//                               'Please enter your requirements or instructions';
//                               showValidation = true;
//                             });
//                             return;
//                           }
//
//                           // Validate minimum length
//                           if (serviceController.noteController.text
//                               .trim()
//                               .length <
//                               10) {
//                             setModalState(() {
//                               noteError =
//                               'Please provide more details (at least 10 characters)';
//                               showValidation = true;
//                             });
//                             return;
//                           }
//
//                           // Save note and close
//                           setState(() {
//                             userNote = serviceController.noteController.text
//                                 .trim();
//                             noteError = null;
//                             showValidation = false;
//                           });
//                           Navigator.pop(context);
//
//                           // // Show success message
//                           // ScaffoldMessenger.of(context).showSnackBar(
//                           //   SnackBar(
//                           //     content: Row(
//                           //       children: const [
//                           //         Icon(Icons.check_circle, color: Colors.white, size: 20),
//                           //         SizedBox(width: 12),
//                           //         Text(
//                           //           'Note saved successfully!',
//                           //           style: TextStyle(
//                           //             fontSize: 14,
//                           //             fontFamily: 'Figtree-Medium',
//                           //             fontWeight: FontWeight.w500,
//                           //           ),
//                           //         ),
//                           //       ],
//                           //     ),
//                           //     backgroundColor: const Color(0xFF038153),
//                           //     duration: const Duration(seconds: 2),
//                           //     behavior: SnackBarBehavior.floating,
//                           //     shape: RoundedRectangleBorder(
//                           //       borderRadius: BorderRadius.circular(8),
//                           //     ),
//                           //     margin: const EdgeInsets.all(16),
//                           //   ),
//                           // );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     ).whenComplete(() {
//       // Reset validation state when bottom sheet closes
//       setState(() {
//         showValidation = false;
//       });
//     });
//   }
//
//   String userNote = '';
//
//   final ImagePicker _imagePicker = ImagePicker();
//
//   String? noteError;
//   bool showValidation = false;
//
//   // Show Add Files Bottom Sheet
//   void _showAddFilesBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Add Files',
//                     style: TextStyle(
//                       color: Color(0xFF183954),
//                       fontSize: 20,
//                       fontFamily: 'Figtree-Bold',
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: Color(0x49545C)),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Upload images or documents',
//                 style: TextStyle(
//                   color: Color(0x99183954),
//                   fontSize: 14,
//                   fontFamily: 'Figtree-Regular',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Option 1: Take Photo
//               _buildFileOption(
//                 icon: Icons.camera_alt_outlined,
//                 title: 'Take Photo',
//                 subtitle: 'Use camera to take a photo',
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final XFile? photo = await _imagePicker.pickImage(
//                     source: ImageSource.camera,
//                   );
//                   if (photo != null) {
//                     setState(() {
//                       serviceController.selectedFiles.add(File(photo.path));
//                     });
//                     _showSuccessMessage('Photo added successfully!');
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),
//
//               // Option 2: Choose from Gallery
//               _buildFileOption(
//                 icon: Icons.photo_library_outlined,
//                 title: 'Choose from Gallery',
//                 subtitle: 'Select images from your gallery',
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final List<XFile> images = await _imagePicker
//                       .pickMultiImage();
//                   if (images.isNotEmpty) {
//                     setState(() {
//                       serviceController.selectedFiles.addAll(
//                         images.map((img) => File(img.path)),
//                       );
//                     });
//                     _showSuccessMessage('${images.length} image(s) added!');
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),
//
//               // Option 3: Choose Documents
//               _buildFileOption(
//                 icon: Icons.insert_drive_file_outlined,
//                 title: 'Choose Documents',
//                 subtitle: 'Select PDF or other documents',
//                 onTap: () async {
//                   Navigator.pop(context);
//                   FilePickerResult? result = await FilePicker.platform
//                       .pickFiles(
//                     allowMultiple: true,
//                     type: FileType.custom,
//                     allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
//                   );
//                   if (result != null) {
//                     setState(() {
//                       serviceController.selectedFiles.addAll(
//                         result.paths.map((path) => File(path!)),
//                       );
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFileOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: ShapeDecoration(
//           color: const Color(0xFFF7F9FC),
//           shape: RoundedRectangleBorder(
//             side: const BorderSide(width: 1, color: Color(0xFFCEDBE8)),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: ShapeDecoration(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Icon(icon, color: const Color(0xFF1A202C), size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Color(0xFF183954),
//                       fontSize: 16,
//                       fontFamily: 'Figtree-Medium',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       color: Color(0x99183954),
//                       fontSize: 12,
//                       fontFamily: 'Figtree-Regular',
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               color: Color(0xFFA0AEC0),
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showSuccessMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   // Remove file from list
//   void _removeFile(int index) {
//     setState(() {
//       serviceController.selectedFiles.removeAt(index);
//     });
//   }
//
//   Future<void> _handleRefresh() async {
//     // Refresh categories
//     await serviceController.getEnquireDetails("enquiryDetails", {
//       "enquiry_id": Get.arguments["enquiryId"],
//       "quotation_id": Get.arguments["quotationId"],
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print(Get.arguments["enquiryId"]);
//
//     serviceController.getEnquireDetails("enquiryDetails", {
//       "enquiry_id": Get.arguments["enquiryId"],
//       "quotation_id": Get.arguments["quotationId"],
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF7FAFC),
//         appBar: const CustomAppBar(title: 'Your Bucket list'),
//         body: Obx(() {
//           if (serviceController.enquireDetailsResponseStatus.value) {
//             return Scaffold(
//               body: const Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (serviceController.enquireDetailsData.value.success != true ||
//               serviceController.enquireDetailsData.value.data!.isEmpty) {
//             return const Scaffold(
//               body: Center(child: Text('No Service available')),
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: _handleRefresh,
//             color: AppConfig.primaryColor,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(16),
//                             decoration: ShapeDecoration(
//                               color: Colors.white /* Grays-White */,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               shadows: [
//                                 BoxShadow(
//                                   color: Color(0xFFEDF2F6),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 4),
//                                   spreadRadius: 0,
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               spacing: 24,
//                               children: [
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     spacing: 26,
//                                     children: [
//                                       SizedBox(
//                                         width: double.infinity,
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           spacing: 16,
//                                           children: [
//                                             SizedBox(
//                                               width: double.infinity,
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                                 spacing: 6,
//                                                 children: [
//                                                   Text(
//                                                     serviceController
//                                                         .enquireDetailsData
//                                                         .value
//                                                         .data![0]
//                                                         .serviceTitle
//                                                         .toString(),
//                                                     style: TextStyle(
//                                                       color: const Color(
//                                                         0xFF183954,
//                                                       ),
//                                                       fontSize: 18,
//                                                       fontFamily:
//                                                       'Figtree-Medium',
//                                                       fontWeight:
//                                                       FontWeight.w700,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     serviceController
//                                                         .enquireDetailsData
//                                                         .value
//                                                         .data![0]
//                                                         .companyName
//                                                         .toString(),
//                                                     style: TextStyle(
//                                                       color: const Color(
//                                                         0x99183954,
//                                                       ),
//                                                       fontSize: 12,
//                                                       fontFamily:
//                                                       'Figtree-Regular',
//                                                       fontWeight:
//                                                       FontWeight.w400,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Text(
//                                               '₹${serviceController.enquireDetailsData.value.data![0].quotations!.first.amount.toString()}',
//                                               style: TextStyle(
//                                                 color: const Color(0xFFE8943A),
//                                                 fontSize: 18,
//                                                 fontFamily: 'Figtree-Medium',
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Row(
//                                 //   children: [
//                                 //     Expanded(
//                                 //       child: GestureDetector(
//                                 //         onTap: _showAddNoteBottomSheet,
//                                 //         child: Container(
//                                 //           padding: const EdgeInsets.symmetric(
//                                 //             horizontal: 11,
//                                 //             vertical: 8,
//                                 //           ),
//                                 //           decoration: ShapeDecoration(
//                                 //             color: const Color(0xFFF7F9FC),
//                                 //             shape: RoundedRectangleBorder(
//                                 //               side: const BorderSide(
//                                 //                 width: 1,
//                                 //                 color: Color(0xFFCEDBE8),
//                                 //               ),
//                                 //               borderRadius:
//                                 //                   BorderRadius.circular(8),
//                                 //             ),
//                                 //           ),
//                                 //           child: Row(
//                                 //             mainAxisAlignment:
//                                 //                 MainAxisAlignment.start,
//                                 //             children: [
//                                 //               const Icon(
//                                 //                 Icons.note_add_outlined,
//                                 //                 size: 20,
//                                 //                 color: Color(0xFF273442),
//                                 //               ),
//                                 //               const SizedBox(width: 12),
//                                 //               Text(
//                                 //                 userNote.isEmpty
//                                 //                     ? 'Add note'
//                                 //                     : 'Edit note',
//                                 //                 style: GoogleFonts.inter(
//                                 //                   color: const Color(
//                                 //                     0xFF273442,
//                                 //                   ),
//                                 //                   fontSize: 14,
//                                 //                   fontWeight: FontWeight.w600,
//                                 //                 ),
//                                 //               ),
//                                 //               if (userNote.isNotEmpty)
//                                 //                 const Padding(
//                                 //                   padding: EdgeInsets.only(
//                                 //                     left: 8,
//                                 //                   ),
//                                 //                   child: Icon(
//                                 //                     Icons.check_circle,
//                                 //                     size: 16,
//                                 //                     color: Color(0xFF038153),
//                                 //                   ),
//                                 //                 ),
//                                 //             ],
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     ),
//                                 //     const SizedBox(width: 16),
//                                 //     Expanded(
//                                 //       child: GestureDetector(
//                                 //         onTap: _showAddFilesBottomSheet,
//                                 //         child: Container(
//                                 //           padding: const EdgeInsets.symmetric(
//                                 //             horizontal: 11,
//                                 //             vertical: 8,
//                                 //           ),
//                                 //           decoration: ShapeDecoration(
//                                 //             color: const Color(0xFFF7F9FC),
//                                 //             shape: RoundedRectangleBorder(
//                                 //               side: const BorderSide(
//                                 //                 width: 1,
//                                 //                 color: Color(0xFFCEDBE8),
//                                 //               ),
//                                 //               borderRadius:
//                                 //                   BorderRadius.circular(8),
//                                 //             ),
//                                 //           ),
//                                 //           child: Row(
//                                 //             mainAxisAlignment:
//                                 //                 MainAxisAlignment.start,
//                                 //             children: [
//                                 //               const Icon(
//                                 //                 Icons.file_upload_outlined,
//                                 //                 size: 20,
//                                 //                 color: Color(0xFF273442),
//                                 //               ),
//                                 //               const SizedBox(width: 12),
//                                 //               Text(
//                                 //                 'Add Files',
//                                 //                 style: GoogleFonts.inter(
//                                 //                   color: const Color(
//                                 //                     0xFF273442,
//                                 //                   ),
//                                 //                   fontSize: 14,
//                                 //                   fontWeight: FontWeight.w600,
//                                 //                 ),
//                                 //               ),
//                                 //               if (serviceController
//                                 //                   .selectedFiles
//                                 //                   .isNotEmpty)
//                                 //                 Padding(
//                                 //                   padding:
//                                 //                       const EdgeInsets.only(
//                                 //                         left: 8,
//                                 //                       ),
//                                 //                   child: Container(
//                                 //                     padding:
//                                 //                         const EdgeInsets.symmetric(
//                                 //                           horizontal: 6,
//                                 //                           vertical: 2,
//                                 //                         ),
//                                 //                     decoration: BoxDecoration(
//                                 //                       color: const Color(
//                                 //                         0xFFE8943A,
//                                 //                       ),
//                                 //                       borderRadius:
//                                 //                           BorderRadius.circular(
//                                 //                             10,
//                                 //                           ),
//                                 //                     ),
//                                 //                     child: Text(
//                                 //                       '${serviceController.selectedFiles.length}',
//                                 //                       style: const TextStyle(
//                                 //                         color: Colors.white,
//                                 //                         fontSize: 10,
//                                 //                         fontWeight:
//                                 //                             FontWeight.w600,
//                                 //                       ),
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //             ],
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     ),
//                                 //   ],
//                                 // ),
//                                 //
//                                 // // Display Note if added
//                                 // if (userNote.isNotEmpty) ...[
//                                 //   Container(
//                                 //     width: double.infinity,
//                                 //     padding: const EdgeInsets.all(12),
//                                 //     decoration: ShapeDecoration(
//                                 //       color: const Color(0xFFF7F9FC),
//                                 //       shape: RoundedRectangleBorder(
//                                 //         side: const BorderSide(
//                                 //           width: 1,
//                                 //           color: Color(0xFFCEDBE8),
//                                 //         ),
//                                 //         borderRadius: BorderRadius.circular(8),
//                                 //       ),
//                                 //     ),
//                                 //     child: Column(
//                                 //       crossAxisAlignment:
//                                 //           CrossAxisAlignment.start,
//                                 //       children: [
//                                 //         Row(
//                                 //           children: [
//                                 //             const Icon(
//                                 //               Icons.note_outlined,
//                                 //               size: 16,
//                                 //               color: Color(0xFF273442),
//                                 //             ),
//                                 //             const SizedBox(width: 8),
//                                 //             const Text(
//                                 //               'Your Note:',
//                                 //               style: TextStyle(
//                                 //                 color: Color(0xFF273442),
//                                 //                 fontSize: 12,
//                                 //                 fontFamily: 'Figtree-Medium',
//                                 //                 fontWeight: FontWeight.w600,
//                                 //               ),
//                                 //             ),
//                                 //           ],
//                                 //         ),
//                                 //         const SizedBox(height: 8),
//                                 //         Text(
//                                 //           userNote,
//                                 //           style: const TextStyle(
//                                 //             color: Color(0xFF49545C),
//                                 //             fontSize: 14,
//                                 //             fontFamily: 'Figtree-Regular',
//                                 //             fontWeight: FontWeight.w400,
//                                 //           ),
//                                 //         ),
//                                 //       ],
//                                 //     ),
//                                 //   ),
//                                 // ],
//                                 //
//                                 // // Display Files if added
//                                 // if (serviceController
//                                 //     .selectedFiles
//                                 //     .isNotEmpty) ...[
//                                 //   Container(
//                                 //     width: double.infinity,
//                                 //     padding: const EdgeInsets.all(12),
//                                 //     decoration: ShapeDecoration(
//                                 //       color: const Color(0xFFF7F9FC),
//                                 //       shape: RoundedRectangleBorder(
//                                 //         side: const BorderSide(
//                                 //           width: 1,
//                                 //           color: Color(0xFFCEDBE8),
//                                 //         ),
//                                 //         borderRadius: BorderRadius.circular(8),
//                                 //       ),
//                                 //     ),
//                                 //     child: Column(
//                                 //       crossAxisAlignment:
//                                 //           CrossAxisAlignment.start,
//                                 //       children: [
//                                 //         Row(
//                                 //           children: [
//                                 //             const Icon(
//                                 //               Icons.attach_file,
//                                 //               size: 16,
//                                 //               color: Color(0xFF273442),
//                                 //             ),
//                                 //             const SizedBox(width: 8),
//                                 //             Text(
//                                 //               'Attached Files (${serviceController.selectedFiles.length}):',
//                                 //               style: const TextStyle(
//                                 //                 color: Color(0xFF273442),
//                                 //                 fontSize: 12,
//                                 //                 fontFamily: 'Figtree-Medium',
//                                 //                 fontWeight: FontWeight.w600,
//                                 //               ),
//                                 //             ),
//                                 //           ],
//                                 //         ),
//                                 //         const SizedBox(height: 12),
//                                 //         Wrap(
//                                 //           spacing: 8,
//                                 //           runSpacing: 8,
//                                 //           children: serviceController
//                                 //               .selectedFiles
//                                 //               .asMap()
//                                 //               .entries
//                                 //               .map((entry) {
//                                 //                 int idx = entry.key;
//                                 //                 File file = entry.value;
//                                 //                 String fileName = file.path
//                                 //                     .split('/')
//                                 //                     .last;
//                                 //                 bool isImage =
//                                 //                     fileName
//                                 //                         .toLowerCase()
//                                 //                         .endsWith('.jpg') ||
//                                 //                     fileName
//                                 //                         .toLowerCase()
//                                 //                         .endsWith('.jpeg') ||
//                                 //                     fileName
//                                 //                         .toLowerCase()
//                                 //                         .endsWith('.png');
//                                 //
//                                 //                 return Container(
//                                 //                   padding:
//                                 //                       const EdgeInsets.symmetric(
//                                 //                         horizontal: 12,
//                                 //                         vertical: 8,
//                                 //                       ),
//                                 //                   decoration: ShapeDecoration(
//                                 //                     color: Colors.white,
//                                 //                     shape: RoundedRectangleBorder(
//                                 //                       borderRadius:
//                                 //                           BorderRadius.circular(
//                                 //                             6,
//                                 //                           ),
//                                 //                     ),
//                                 //                   ),
//                                 //                   child: Row(
//                                 //                     mainAxisSize:
//                                 //                         MainAxisSize.min,
//                                 //                     children: [
//                                 //                       Icon(
//                                 //                         isImage
//                                 //                             ? Icons.image
//                                 //                             : Icons
//                                 //                                   .insert_drive_file,
//                                 //                         size: 16,
//                                 //                         color: const Color(
//                                 //                           0xFFE8943A,
//                                 //                         ),
//                                 //                       ),
//                                 //                       const SizedBox(width: 8),
//                                 //                       ConstrainedBox(
//                                 //                         constraints:
//                                 //                             const BoxConstraints(
//                                 //                               maxWidth: 120,
//                                 //                             ),
//                                 //                         child: Text(
//                                 //                           fileName,
//                                 //                           overflow: TextOverflow
//                                 //                               .ellipsis,
//                                 //                           style: const TextStyle(
//                                 //                             color: Color(
//                                 //                               0xFF49545C,
//                                 //                             ),
//                                 //                             fontSize: 12,
//                                 //                             fontFamily:
//                                 //                                 'Figtree-Regular',
//                                 //                           ),
//                                 //                         ),
//                                 //                       ),
//                                 //                       const SizedBox(width: 8),
//                                 //                       GestureDetector(
//                                 //                         onTap: () =>
//                                 //                             _removeFile(idx),
//                                 //                         child: const Icon(
//                                 //                           Icons.close,
//                                 //                           size: 16,
//                                 //                           color: Color(
//                                 //                             0xFF49545C,
//                                 //                           ),
//                                 //                         ),
//                                 //                       ),
//                                 //                     ],
//                                 //                   ),
//                                 //                 );
//                                 //               })
//                                 //               .toList(),
//                                 //         ),
//                                 //       ],
//                                 //     ),
//                                 //   ),
//                                 // ],
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(16),
//                             decoration: ShapeDecoration(
//                               color: Colors.white /* Grays-White */,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               shadows: [
//                                 BoxShadow(
//                                   color: Color(0xFFEDF2F6),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 4),
//                                   spreadRadius: 0,
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               spacing: 24,
//                               children: [
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     spacing: 26,
//                                     children: [
//                                       SizedBox(
//                                         width: double.infinity,
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           spacing: 16,
//                                           children: [
//                                             SizedBox(
//                                               width: double.infinity,
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                                 spacing: 6,
//                                                 children: [
//                                                   Text(
//                                                     'Would you like to attach a note? ',
//                                                     style: TextStyle(
//                                                       color: const Color(0xFF0C141C),
//                                                       fontSize: 14,
//                                                       fontFamily: 'Inter-Bold',
//                                                       fontWeight: FontWeight.w600,
//                                                       height: 1.43,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: _showAddNoteBottomSheet,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 11,
//                                             vertical: 8,
//                                           ),
//                                           decoration: ShapeDecoration(
//                                             color: const Color(0xFFF7F9FC),
//                                             shape: RoundedRectangleBorder(
//                                               side: const BorderSide(
//                                                 width: 1,
//                                                 color: Color(0xFFCEDBE8),
//                                               ),
//                                               borderRadius:
//                                               BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             children: [
//                                               const Icon(
//                                                 Icons.note_add_outlined,
//                                                 size: 20,
//                                                 color: Color(0xFF273442),
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Expanded( // ✅ ADDED: Wrap Column with Expanded
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       userNote.isEmpty ? 'Add note' : 'Edit note',
//                                                       style: GoogleFonts.inter(
//                                                         color: const Color(0xFF273442),
//                                                         fontSize: 14,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                     Text( // ✅ REMOVED: SizedBox wrapper
//                                                       'Enter a short note for the vendor',
//                                                       style: TextStyle(
//                                                         color: const Color(0x990C141C),
//                                                         fontSize: 8,
//                                                         fontFamily: 'Inter-Light',
//                                                         fontWeight: FontWeight.w400,
//                                                       ),
//                                                       maxLines: 2, // ✅ ADDED: Limit to 1 line
//                                                       overflow: TextOverflow.ellipsis, // ✅ ADDED: Handle overflow
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               if (userNote.isNotEmpty)
//                                                 const Padding(
//                                                   padding: EdgeInsets.only(left: 8),
//                                                   child: Icon(
//                                                     Icons.check_circle,
//                                                     size: 16,
//                                                     color: Color(0xFF038153),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: _showAddFilesBottomSheet,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 11,
//                                             vertical: 8,
//                                           ),
//                                           decoration: ShapeDecoration(
//                                             color: const Color(0xFFF7F9FC),
//                                             shape: RoundedRectangleBorder(
//                                               side: const BorderSide(
//                                                 width: 1,
//                                                 color: Color(0xFFCEDBE8),
//                                               ),
//                                               borderRadius:
//                                               BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             children: [
//                                               const Icon(
//                                                 Icons.file_upload_outlined,
//                                                 size: 20,
//                                                 color: Color(0xFF273442),
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Expanded( // ✅ ADDED: Wrap Column with Expanded
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       'Add Files',
//                                                       style: GoogleFonts.inter(
//                                                         color: const Color(0xFF273442),
//                                                         fontSize: 14,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                     Text( // ✅ REMOVED: SizedBox wrapper
//                                                       'Attach pictures to show the vendor',
//                                                       style: TextStyle(
//                                                         color: const Color(0x990C141C),
//                                                         fontSize: 8,
//                                                         fontFamily: 'Inter-Light',
//                                                         fontWeight: FontWeight.w400,
//                                                       ),
//                                                       maxLines: 2, // ✅ ADDED: Limit to 1 line
//                                                       overflow: TextOverflow.ellipsis, // ✅ ADDED: Handle overflow
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               if (serviceController.selectedFiles.isNotEmpty)
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(left: 8),
//                                                   child: Container(
//                                                     padding: const EdgeInsets.symmetric(
//                                                       horizontal: 6,
//                                                       vertical: 2,
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       color: const Color(0xFFE8943A),
//                                                       borderRadius: BorderRadius.circular(10),
//                                                     ),
//                                                     child: Text(
//                                                       '${serviceController.selectedFiles.length}',
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 10,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 // Display Note if added
//                                 if (userNote.isNotEmpty) ...[
//                                   Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: ShapeDecoration(
//                                       color: const Color(0xFFF7F9FC),
//                                       shape: RoundedRectangleBorder(
//                                         side: const BorderSide(
//                                           width: 1,
//                                           color: Color(0xFFCEDBE8),
//                                         ),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             const Icon(
//                                               Icons.note_outlined,
//                                               size: 16,
//                                               color: Color(0xFF273442),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               'Your Note:',
//                                               style: TextStyle(
//                                                 color: Color(0xFF273442),
//                                                 fontSize: 12,
//                                                 fontFamily: 'Figtree-Medium',
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           userNote,
//                                           style: const TextStyle(
//                                             color: Color(0xFF49545C),
//                                             fontSize: 14,
//                                             fontFamily: 'Figtree-Regular',
//                                             fontWeight: FontWeight.w400,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//
//                                 // Display Files if added
//                                 if (serviceController
//                                     .selectedFiles
//                                     .isNotEmpty) ...[
//                                   Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: ShapeDecoration(
//                                       color: const Color(0xFFF7F9FC),
//                                       shape: RoundedRectangleBorder(
//                                         side: const BorderSide(
//                                           width: 1,
//                                           color: Color(0xFFCEDBE8),
//                                         ),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             const Icon(
//                                               Icons.attach_file,
//                                               size: 16,
//                                               color: Color(0xFF273442),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Text(
//                                               'Attached Files (${serviceController.selectedFiles.length}):',
//                                               style: const TextStyle(
//                                                 color: Color(0xFF273442),
//                                                 fontSize: 12,
//                                                 fontFamily: 'Figtree-Medium',
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 12),
//                                         Wrap(
//                                           spacing: 8,
//                                           runSpacing: 8,
//                                           children: serviceController
//                                               .selectedFiles
//                                               .asMap()
//                                               .entries
//                                               .map((entry) {
//                                             int idx = entry.key;
//                                             File file = entry.value;
//                                             String fileName = file.path
//                                                 .split('/')
//                                                 .last;
//                                             bool isImage =
//                                                 fileName
//                                                     .toLowerCase()
//                                                     .endsWith('.jpg') ||
//                                                     fileName
//                                                         .toLowerCase()
//                                                         .endsWith('.jpeg') ||
//                                                     fileName
//                                                         .toLowerCase()
//                                                         .endsWith('.png');
//
//                                             return Container(
//                                               padding:
//                                               const EdgeInsets.symmetric(
//                                                 horizontal: 12,
//                                                 vertical: 8,
//                                               ),
//                                               decoration: ShapeDecoration(
//                                                 color: Colors.white,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                     6,
//                                                   ),
//                                                 ),
//                                               ),
//                                               child: Row(
//                                                 mainAxisSize:
//                                                 MainAxisSize.min,
//                                                 children: [
//                                                   Icon(
//                                                     isImage
//                                                         ? Icons.image
//                                                         : Icons
//                                                         .insert_drive_file,
//                                                     size: 16,
//                                                     color: const Color(
//                                                       0xFFE8943A,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   ConstrainedBox(
//                                                     constraints:
//                                                     const BoxConstraints(
//                                                       maxWidth: 120,
//                                                     ),
//                                                     child: Text(
//                                                       fileName,
//                                                       overflow: TextOverflow
//                                                           .ellipsis,
//                                                       style: const TextStyle(
//                                                         color: Color(
//                                                           0xFF49545C,
//                                                         ),
//                                                         fontSize: 12,
//                                                         fontFamily:
//                                                         'Figtree-Regular',
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   GestureDetector(
//                                                     onTap: () =>
//                                                         _removeFile(idx),
//                                                     child: const Icon(
//                                                       Icons.close,
//                                                       size: 16,
//                                                       color: Color(
//                                                         0xFF49545C,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           })
//                                               .toList(),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(16),
//                             decoration: ShapeDecoration(
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               shadows: const [
//                                 BoxShadow(
//                                   color: Color(0xFFEDF2F6),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 4),
//                                   spreadRadius: 0,
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//
//                                 if(serviceController
//                                     .enquireDetailsData
//                                     .value
//                                     .data![0]
//                                     .quotations!
//                                     .first
//                                     .files!=null)...[
//                                   // Header Section
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 8,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 40,
//                                           height: 40,
//                                           decoration: ShapeDecoration(
//                                             color: const Color(0xFFF7F9FC),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(
//                                                 8,
//                                               ),
//                                             ),
//                                           ),
//                                           child: const Icon(
//                                             Icons.description_outlined,
//                                             color: Color(0xFF183954),
//                                             size: 20,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         const Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Quote Documents',
//                                                 style: TextStyle(
//                                                   color: Color(0xFF183954),
//                                                   fontSize: 16,
//                                                   fontFamily: 'Figtree-Medium',
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 2),
//                                               Text(
//                                                 '2 documents attached',
//                                                 style: TextStyle(
//                                                   color: Color(0x99183954),
//                                                   fontSize: 12,
//                                                   fontFamily: 'Figtree-Regular',
//                                                   fontWeight: FontWeight.w400,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//
//                                   // Document Cards
//
//                                   ...List.generate(
//                                     serviceController
//                                         .enquireDetailsData
//                                         .value
//                                         .data![0]
//                                         .quotations!
//                                         .first
//                                         .files!
//                                         .split(",")
//                                         .length,
//                                         (index) {
//                                       return Padding(
//                                         padding: EdgeInsets.only(
//                                           bottom: index == 1 ? 0 : 16,
//                                         ),
//                                         child: Container(
//                                           width: double.infinity,
//                                           padding: const EdgeInsets.all(12),
//                                           decoration: ShapeDecoration(
//                                             color: const Color(0xFFF7F9FC),
//                                             shape: RoundedRectangleBorder(
//                                               side: const BorderSide(
//                                                 width: 1,
//                                                 color: Color(0xFFCEDBE8),
//                                               ),
//                                               borderRadius: BorderRadius.circular(
//                                                 12,
//                                               ),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       serviceController
//                                                           .enquireDetailsData
//                                                           .value
//                                                           .data![0]
//                                                           .quotations!
//                                                           .first
//                                                           .files!
//                                                           .split(",")[index],
//                                                       style: const TextStyle(
//                                                         color: Color(0xFF183954),
//                                                         fontSize: 14,
//                                                         fontFamily:
//                                                         'Figtree-Medium',
//                                                         fontWeight:
//                                                         FontWeight.w600,
//                                                       ),
//                                                       maxLines: 1,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//
//                                               // View Button
//                                               GestureDetector(
//                                                 onTap: () async {
//                                                   // Split the comma-separated string into a list
//                                                   List<String> fileUrls =
//                                                   serviceController
//                                                       .enquireDetailsData
//                                                       .value
//                                                       .data![0]
//                                                       .quotations!
//                                                       .first
//                                                       .files!
//                                                       .split(",");
//
//                                                   // Trim whitespace from each URL
//                                                   fileUrls = fileUrls
//                                                       .map((url) => url.trim())
//                                                       .toList();
//
//                                                   // Access the first PDF (index 0) - change index as needed
//                                                   String fileUrl = fileUrls[0];
//
//                                                   print(
//                                                     "Selected file: $fileUrl",
//                                                   );
//
//                                                   // Extract filename from URL
//                                                   String fileName =
//                                                   Uri.decodeComponent(
//                                                     fileUrl
//                                                         .split('/')
//                                                         .last
//                                                         .split('?')
//                                                         .first,
//                                                   );
//
//                                                   _viewFileInWebView(
//                                                     fileUrl,
//                                                     fileName,
//                                                   );
//                                                 },
//                                                 child: Container(
//                                                   padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 12,
//                                                     vertical: 6,
//                                                   ),
//                                                   decoration: ShapeDecoration(
//                                                     color: Colors.white,
//                                                     shape: RoundedRectangleBorder(
//                                                       side: const BorderSide(
//                                                         width: 1,
//                                                         color: Color(0xFFCEDBE8),
//                                                       ),
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                         6,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                     MainAxisSize.min,
//                                                     children: const [
//                                                       Text(
//                                                         'View',
//                                                         style: TextStyle(
//                                                           color: Color(
//                                                             0xFF183954,
//                                                           ),
//                                                           fontSize: 13,
//                                                           fontFamily:
//                                                           'Figtree-Medium',
//                                                           fontWeight:
//                                                           FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(height: 20),
//                                 ],
//
//
//
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 8,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: ShapeDecoration(
//                                           color: const Color(0xFFF7F9FC),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                         ),
//                                         child: const Icon(
//                                           Icons.insert_comment_outlined,
//                                           color: Color(0xFF183954),
//                                           size: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       const Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Vendor Message',
//                                               style: TextStyle(
//                                                 color: Color(0xFF183954),
//                                                 fontSize: 16,
//                                                 fontFamily: 'Figtree-Medium',
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   serviceController
//                                       .enquireDetailsData
//                                       .value
//                                       .data![0]
//                                       .quotations!
//                                       .first
//                                       .message
//                                       .toString(),
//                                   style: TextStyle(
//                                     color: Color(0x99183954),
//                                     fontSize: 12,
//                                     fontFamily: 'Figtree-Regular',
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 8,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: ShapeDecoration(
//                                           color: const Color(0xFFF7F9FC),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                         ),
//                                         child: const Icon(
//                                           Icons.calendar_month,
//                                           color: Color(0xFF183954),
//                                           size: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       const Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Service Completion Period',
//                                               style: TextStyle(
//                                                 color: Color(0xFF183954),
//                                                 fontSize: 16,
//                                                 fontFamily: 'Figtree-Medium',
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   "${serviceController
//                                       .enquireDetailsData
//                                       .value
//                                       .data![0]
//                                       .quotations!
//                                       .first
//                                       .serviceTime} Days",
//                                   style: TextStyle(
//                                     color: Color(0x99183954),
//                                     fontSize: 12,
//                                     fontFamily: 'Figtree-Regular',
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(16),
//                             decoration: ShapeDecoration(
//                               shape: RoundedRectangleBorder(
//                                 side: const BorderSide(
//                                   width: 1,
//                                   color: Color(0xFFD9D9D9),
//                                 ),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Title
//                                 const Text(
//                                   'Payment Mode',
//                                   style: TextStyle(
//                                     color: Color(0xFF183954),
//                                     fontSize: 18,
//                                     fontFamily: 'Figtree-Medium',
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//
//                                 // Payment Options Container
//                                 Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: ShapeDecoration(
//                                     color: const Color(0xFFF7F9FC),
//                                     shape: RoundedRectangleBorder(
//                                       side: const BorderSide(
//                                         width: 1,
//                                         color: Color(0xFFCEDBE8),
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       // Pay Now Option
//                                       InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             selectedPaymentMode = 'payNow';
//                                           });
//                                         },
//                                         borderRadius: BorderRadius.circular(4),
//                                         child: Row(
//                                           children: [
//                                             _buildRadioButton(
//                                               selectedPaymentMode == 'payNow',
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               'Pay Now',
//                                               style: TextStyle(
//                                                 color: Color(0xFF49545C),
//                                                 fontSize: 14,
//                                                 fontFamily: 'Lato-Regular',
//                                                 fontWeight: FontWeight.w500,
//                                                 height: 1.43,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // const SizedBox(height: 12),
//                                       //
//                                       // // Get Quote and Pay Later Option
//                                       // InkWell(
//                                       //   onTap: () {
//                                       //     setState(() {
//                                       //       selectedPaymentMode = 'payLater';
//                                       //     });
//                                       //   },
//                                       //   borderRadius: BorderRadius.circular(
//                                       //       4),
//                                       //   child: Row(
//                                       //     children: [
//                                       //       _buildRadioButton(
//                                       //         selectedPaymentMode ==
//                                       //             'payLater',
//                                       //       ),
//                                       //       const SizedBox(width: 8),
//                                       //       const Text(
//                                       //         'Get Quote and pay later',
//                                       //         style: TextStyle(
//                                       //           color: Color(0xFF49545C),
//                                       //           fontSize: 14,
//                                       //           fontFamily: 'Lato-Regular',
//                                       //           fontWeight: FontWeight.w500,
//                                       //           height: 1.43,
//                                       //         ),
//                                       //       ),
//                                       //     ],
//                                       //   ),
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//
//                                 // Payment Summary
//                                 Column(
//                                   children: [
//                                     // Escrow Wallet
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//                                             final dynamic tooltip = _escrowTooltipKey.currentState;
//                                             tooltip?.ensureTooltipVisible();
//                                           },
//                                           child:Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               EscrowInlineTooltip(tooltipKey: _escrowTooltipKey), // ← replaces old GestureDetector block
//                                             ],
//                                           ),
//                                         ),
//                                         Text(
//                                           '₹${getDisplayValues()['orderAmount']}',
//                                           style: TextStyle(
//                                             color: Color(0xFF183954),
//                                             fontSize: 14,
//                                             fontFamily: 'Lato-Regular',
//                                             fontWeight: FontWeight.w400,
//                                             height: 1.43,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 14),
//                                     CustomPaint(
//                                       size: const Size(double.infinity, 1),
//                                       painter: DottedLinePainter(),
//                                     ),
//                                     const SizedBox(height: 14),
//                                     if(getDisplayValues()['platformFee']!=0)
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             // 'Platform fee (${platformFeePercentage.toStringAsFixed(0)}%)',
//                                             'Platform fee',
//                                             style: const TextStyle(
//                                               color: Color(0xFF49545C),
//                                               fontSize: 10,
//                                               fontFamily: 'Lato-Regular',
//                                               fontWeight: FontWeight.w500,
//                                               height: 1.43,
//                                             ),
//                                           ),
//                                           Text(
//                                             '₹${getDisplayValues()['platformFee']}',
//                                             // '₹${convenienceFee.toStringAsFixed(0)}',
//                                             style: const TextStyle(
//                                               color: Color(0xFF183954),
//                                               fontSize: 14,
//                                               fontFamily: 'Lato-Regular',
//                                               fontWeight: FontWeight.w400,
//                                               height: 1.43,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     if(getDisplayValues()['convenienceFee']!=0)
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             // 'Convenience fee (${convenienceFeePercentage.toStringAsFixed(0)}%)',
//                                             'Convenience fee',
//                                             style: const TextStyle(
//                                               color: Color(0xFF49545C),
//                                               fontSize: 10,
//                                               fontFamily: 'Lato-Regular',
//                                               fontWeight: FontWeight.w500,
//                                               height: 1.43,
//                                             ),
//                                           ),
//                                           Text(
//                                             '₹${getDisplayValues()['convenienceFee']}',
//                                             // '₹${convenienceFee.toStringAsFixed(0)}',
//                                             style: const TextStyle(
//                                               color: Color(0xFF183954),
//                                               fontSize: 14,
//                                               fontFamily: 'Lato-Regular',
//                                               fontWeight: FontWeight.w400,
//                                               height: 1.43,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         final dynamic tooltip = _gstTooltipKey.currentState;
//                                         tooltip?.ensureTooltipVisible();
//                                       },
//                                       child: Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 'GST ${totalGstPercentage.toStringAsFixed(0)}% ${"of all the line item"},',
//                                                 style: const TextStyle(
//                                                   color: Color(0xFF49545C),
//                                                   fontSize: 10,
//                                                   fontFamily: 'Lato-Regular',
//                                                   fontWeight: FontWeight.w500,
//                                                   height: 1.43,
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 6),
//                                               Tooltip(
//                                                 key: _gstTooltipKey,
//                                                 message:
//                                                 'CGST (${cGstPercentage.toStringAsFixed(1)}%): ₹${getDisplayValues()['cgst']}\nSGST (${sGstPercentage.toStringAsFixed(1)}%): ₹${getDisplayValues()['sgst']}\nTotal GST: ₹${getDisplayValues()['totalGst']}',
//                                                 decoration: BoxDecoration(
//                                                   color: const Color(0xFF273442),
//                                                   borderRadius: BorderRadius.circular(8),
//                                                 ),
//                                                 textStyle: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12,
//                                                   fontFamily: 'Lato-Regular',
//                                                 ),
//                                                 padding: const EdgeInsets.symmetric(
//                                                     horizontal: 12, vertical: 8),
//                                                 margin:
//                                                 const EdgeInsets.symmetric(horizontal: 16),
//                                                 preferBelow: true,
//                                                 verticalOffset: 10,
//                                                 waitDuration: Duration.zero,
//                                                 showDuration: const Duration(seconds: 5),
//                                                 triggerMode: TooltipTriggerMode.manual,
//                                                 child: const Icon(
//                                                   Icons.info_outline,
//                                                   size: 16,
//                                                   color: Color(0xFF49545C),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Text(
//                                             '₹${getDisplayValues()['totalGst']}',
//                                             style: const TextStyle(
//                                               color: Color(0xFF183954),
//                                               fontSize: 12.5,
//                                               fontFamily: 'Lato-Regular',
//                                               fontWeight: FontWeight.w400,
//                                               height: 1.43,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Row(
//                                     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     //   children: [
//                                     //     Text(
//                                     //       'GST 18% of all the line item',
//                                     //       style: const TextStyle(
//                                     //         color: Color(0xFF49545C),
//                                     //         fontSize: 10,
//                                     //         fontFamily: 'Lato-Regular',
//                                     //         fontWeight: FontWeight.w500,
//                                     //         height: 1.43,
//                                     //       ),
//                                     //     ),
//                                     //     Text(
//                                     //       '₹${double.parse(convenienceFee.toString()).round().toString()}',
//                                     //       // '₹${convenienceFee.toStringAsFixed(0)}',
//                                     //       style: const TextStyle(
//                                     //         color: Color(0xFF183954),
//                                     //         fontSize: 14,
//                                     //         fontFamily: 'Lato-Regular',
//                                     //         fontWeight: FontWeight.w400,
//                                     //         height: 1.43,
//                                     //       ),
//                                     //     ),
//                                     //   ],
//                                     // ),
//                                     const SizedBox(height: 10),
//                                     // Total
//                                     Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Total',
//                                           style: TextStyle(
//                                             color: Color(0xFF183954),
//                                             fontSize: 18,
//                                             fontFamily: 'Lato-Medium',
//                                             fontWeight: FontWeight.w700,
//                                             height: 1.11,
//                                           ),
//                                         ),
//                                         Text(
//                                           '₹${getDisplayValues()['total']}',
//                                           // '₹${totalAmount.toStringAsFixed(0)}',
//                                           style: const TextStyle(
//                                             color: Color(0xFF183954),
//                                             fontSize: 18,
//                                             fontFamily: 'Lato-Medium',
//                                             fontWeight: FontWeight.w700,
//                                             height: 1.11,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Container(
//                             width: double.infinity,
//                             decoration: ShapeDecoration(
//                               color: const Color(0xFFEEF6FB),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//
//                               shadows: const [
//                                 BoxShadow(
//                                   color: Color(0xFFEDF2F6),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 4),
//                                   spreadRadius: 0,
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Header
//                                   const Text(
//                                     'Next Step',
//                                     style: TextStyle(
//                                       color: Color(0xFF183954),
//                                       fontSize: 18,
//                                       fontFamily: 'Figtree-Bold',
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 26),
//                                   // Step 1: Customer Placed an Order
//                                   _buildProgressStep(
//                                     'Placed an order',
//                                     isCompleted: false,
//                                     color: const Color(0xFF34C759),
//                                   ),
//                                   // Dotted Line
//                                   _buildDottedLine(),
//                                   // Step 2: You need to accept
//                                   _buildProgressStep(
//                                     'Vendor to accept',
//                                     isCompleted: false,
//                                     color: const Color(0xFFAFAFAF),
//                                     showInnerDot: true,
//                                   ),
//                                   _buildDottedLine(),
//                                   _buildProgressStep(
//                                     'Design and Proposal from Vendor',
//                                     isCompleted: false,
//                                     color: const Color(0xFFAFAFAF),
//                                     showInnerDot: false,
//                                   ),
//
//                                   _buildDottedLine(),
//                                   // Step 4: Design Finalized
//                                   _buildProgressStep(
//                                     'Material Procurement',
//                                     isCompleted: false,
//                                     color: const Color(0xFFAFAFAF),
//                                     showInnerDot: false,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Add note to receive ideas from Vendor',
//                         style: TextStyle(
//                           color: const Color(0xFF0C141C),
//                           fontSize: 12,
//                           fontFamily: 'Figtree-Medium',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 12),
//
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ElevatedButton(
//                             onPressed: _isLoading
//                                 ? null
//                                 : _showPaymentOptionsBottomSheet,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _isLoading
//                                   ? Colors.grey.shade300
//                                   : const Color(0xFF1A202C),
//                               foregroundColor: _isLoading
//                                   ? Colors.grey.shade600
//                                   : Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 10,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: BorderSide(
//                                   width: 1,
//                                   color: _isLoading
//                                       ? Colors.transparent
//                                       : const Color(0xFF1A202C),
//                                 ),
//                               ),
//                               elevation: 0,
//                               minimumSize: const Size(double.infinity, 48),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.green,
//                                 ),
//                               ),
//                             )
//                                 : const Text(
//                               'Choose Payment Option',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'Figtree-Medium',
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 6),
//                           RichText(
//                             text: TextSpan(
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontFamily: 'Figtree-Regular',
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.4,
//                                 color: Color(0xFF475467),
//                               ),
//                               children: [
//                                 const TextSpan(text: 'Customer '),
//                                 WidgetSpan(
//                                   alignment: PlaceholderAlignment.baseline,
//                                   baseline: TextBaseline.alphabetic,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => WebViewScreen(
//                                             title: 'Customer Terms & Conditions',
//                                             url: 'https://app.vayil.in/customer-tc-for-initial-payment',
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: const Text(
//                                       'Terms & Conditions',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontFamily: 'Figtree-Medium',
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xFF1D60FF),
//                                         height: 1.4,
//                                         decoration: TextDecoration.underline,
//                                         decorationColor: Color(0xFF1D60FF),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const TextSpan(text: ' for Initial Payment '),
//                                 // const TextSpan(
//                                 //   text: 'Vayil',
//                                 //   style: TextStyle(
//                                 //     color: Color(0xFFE8943A),
//                                 //     fontSize: 14,
//                                 //     fontFamily: 'Figtree-Medium',
//                                 //     fontWeight: FontWeight.w700,
//                                 //     height: 1.4,
//                                 //   ),
//                                 // ),
//                                 const TextSpan(text: '.'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// Widget _buildRadioButton(bool isSelected) {
//   return Container(
//     width: 16,
//     height: 16,
//     decoration: ShapeDecoration(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           width: 1,
//           color: isSelected ? const Color(0xFF1B517E) : const Color(0xFFC2C8CC),
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
//     child: isSelected
//         ? Center(
//       child: Container(
//         width: 6,
//         height: 6,
//         decoration: const ShapeDecoration(
//           color: Color(0xFF1B517E),
//           shape: OvalBorder(),
//         ),
//       ),
//     )
//         : null,
//   );
// }
//
// Widget _buildProgressStep(
//     String text, {
//       required bool isCompleted,
//       required Color color,
//       bool showInnerDot = true,
//     }) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Container(
//         width: 16,
//         height: 16,
//         decoration: ShapeDecoration(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             side: BorderSide(width: 1, color: color),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: showInnerDot
//             ? Center(
//           child: Container(
//             width: 6,
//             height: 6,
//             decoration: ShapeDecoration(
//               color: color,
//               shape: const OvalBorder(),
//             ),
//           ),
//         )
//             : null,
//       ),
//       const SizedBox(width: 8),
//       Expanded(
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: Color(0xFF49545C),
//             fontSize: 14,
//             fontFamily: 'Lato-Regular',
//             fontWeight: FontWeight.w500,
//             height: 1.43,
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildDottedLine() {
//   return Padding(
//     padding: const EdgeInsets.only(left: 7.5, top: 4, bottom: 4),
//     child: CustomPaint(size: const Size(1, 18), painter: DottedLineNextStep()),
//   );
// }
//
// void _viewFileInWebView(String fileUrl, String fileName) {
//   Get.to(() => FileViewerScreen(fileUrl: fileUrl, fileName: fileName));
// }
//
// class DottedLineNextStep extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFCEDBE8)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     const dashHeight = 3.0;
//     const dashSpace = 3.0;
//     double startY = 0;
//
//     while (startY < size.height) {
//       canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
//       startY += dashHeight + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
//
// // Custom Painter for Dotted Line
// class DottedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFCEDBE8)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     const dashWidth = 5.0;
//     const dashSpace = 3.0;
//     double startX = 0;
//
//     while (startX < size.width) {
//       canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//       startX += dashWidth + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class FileViewerScreen extends StatefulWidget {
//   final String fileUrl;
//   final String fileName;
//
//   const FileViewerScreen({
//     Key? key,
//     required this.fileUrl,
//     required this.fileName,
//   }) : super(key: key);
//
//   @override
//   State<FileViewerScreen> createState() => _FileViewerScreenState();
// }
//
// class _FileViewerScreenState extends State<FileViewerScreen> {
//   late final WebViewController _controller;
//   bool isLoading = true;
//   String? errorMessage;
//   bool isImage = false;
//   bool isPdf = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkFileType();
//     _initializeWebView();
//   }
//
//   void _checkFileType() {
//     String lowerFileName = widget.fileName.toLowerCase();
//     String lowerUrl = widget.fileUrl.toLowerCase();
//
//     // Check if it's an image
//     isImage =
//         lowerFileName.endsWith('.jpg') ||
//             lowerFileName.endsWith('.jpeg') ||
//             lowerFileName.endsWith('.png') ||
//             lowerFileName.endsWith('.gif') ||
//             lowerFileName.endsWith('.webp') ||
//             lowerFileName.endsWith('.bmp') ||
//             lowerFileName.endsWith('.svg') ||
//             lowerUrl.contains('.jpg') ||
//             lowerUrl.contains('.jpeg') ||
//             lowerUrl.contains('.png') ||
//             lowerUrl.contains('.gif') ||
//             lowerUrl.contains('.webp') ||
//             lowerUrl.contains('.bmp') ||
//             lowerUrl.contains('.svg');
//
//     // Check if it's a PDF
//     isPdf = lowerFileName.endsWith('.pdf') || lowerUrl.contains('.pdf');
//   }
//
//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               isLoading = true;
//               errorMessage = null;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               isLoading = false;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             setState(() {
//               isLoading = false;
//               errorMessage = 'Failed to load file: ${error.description}';
//             });
//           },
//         ),
//       );
//
//     String finalUrl;
//
//     if (isImage) {
//       // For images, create HTML to display the image directly
//       finalUrl = Uri.dataFromString(
//         '''
//         <!DOCTYPE html>
//         <html>
//         <head>
//           <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
//           <style>
//             body {
//               margin: 0;
//               padding: 0;
//               display: flex;
//               justify-content: center;
//               align-items: center;
//               min-height: 100vh;
//               background-color: #f7fafc;
//             }
//             img {
//               max-width: 100%;
//               height: auto;
//               display: block;
//             }
//             .container {
//               padding: 16px;
//               width: 100%;
//               box-sizing: border-box;
//             }
//           </style>
//         </head>
//         <body>
//           <div class="container">
//             <img src="${widget.fileUrl}" alt="${widget.fileName}" />
//           </div>
//         </body>
//         </html>
//         ''',
//         mimeType: 'text/html',
//         encoding: Encoding.getByName('utf-8'),
//       ).toString();
//     } else if (isPdf) {
//       // For PDFs, use multiple fallback options
//       // Try Google Docs Viewer first
//       finalUrl =
//       'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.fileUrl)}&embedded=true';
//
//       // Alternative: Use Mozilla PDF.js viewer
//       // finalUrl = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(widget.fileUrl)}';
//     } else {
//       // For Excel, CSV, Word, and other documents
//       // Google Docs Viewer supports: .doc, .docx, .xls, .xlsx, .ppt, .pptx, .pdf, .pages, .ai, .psd, .tiff, .dxf, .svg, .eps, .ps, .ttf, .xps, .zip, .rar
//       finalUrl =
//       'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.fileUrl)}&embedded=true';
//     }
//
//     _controller.loadRequest(Uri.parse(finalUrl));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF183954)),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           widget.fileName,
//           style: const TextStyle(
//             color: Color(0xFF183954),
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         actions: [
//           // Add a download/open in browser option
//           IconButton(
//             icon: const Icon(Icons.open_in_browser, color: Color(0xFF183954)),
//             onPressed: () async {
//               if (await canLaunchUrl(Uri.parse(widget.fileUrl))) {
//                 await launchUrl(
//                   Uri.parse(widget.fileUrl),
//                   mode: LaunchMode.externalApplication,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           if (errorMessage != null)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: Colors.red,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       errorMessage!,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Color(0xFF183954),
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               errorMessage = null;
//                               _initializeWebView();
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE8943A),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: const Text(
//                             'Retry',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         ElevatedButton(
//                           onPressed: () async {
//                             if (await canLaunchUrl(Uri.parse(widget.fileUrl))) {
//                               await launchUrl(
//                                 Uri.parse(widget.fileUrl),
//                                 mode: LaunchMode.externalApplication,
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF183954),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: const Text(
//                             'Open in Browser',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             WebViewWidget(controller: _controller),
//           if (isLoading)
//             const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8943A)),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


////////////////////////////////////////////////////////////////////////////////


// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../App Configuration/app_config.dart';
// import '../../Controllers/Services_Controller.dart';
// import '../../Routes/app_routes.dart';
// import '../../common/App Bar.dart';
// import '../../common/Orange Button.dart';
//
// class ProjectDetailsScreen extends StatefulWidget {
//   const ProjectDetailsScreen({super.key});
//
//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }
//
// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   var serviceController = Get.put(ServiceController());
//   double sliderValue = 20.0;
//   List<MaterialItem> materials = [];
//   bool selectAll = false;
//   List<dynamic> paymentHistory = [];
//
//   bool get isDesignFinalized {
//     if (serviceController.onGoingProjectDetailsData.value.steps == null) {
//       return false;
//     }
//
//     // Check if there are at least 4 steps
//     if (serviceController.onGoingProjectDetailsData.value.steps!.length < 4) {
//       return false;
//     }
//
//     // Check if the "Design Finalized" step (4th step, index 3) is accepted (status = "1")
//     var designStep =
//     serviceController.onGoingProjectDetailsData.value.steps![3];
//     return designStep.stepStatus == "1";
//   }
//
//   bool get areAllMilestonesCompleted {
//     if (serviceController.onGoingProjectDetailsData.value.data == null ||
//         serviceController.onGoingProjectDetailsData.value.data!.isEmpty) {
//       return false;
//     }
//
//     return serviceController.onGoingProjectDetailsData.value.data!.every(
//           (milestone) => milestone.status == 10,
//     );
//   }
//
//   bool get hasReview {
//     final review = serviceController.onGoingProjectDetailsData.value.review;
//     return review != null && review.isNotEmpty;
//   }
//
//   // Calculate milestone completion percentage
//   double get milestoneCompletionPercentage {
//     if (serviceController.onGoingProjectDetailsData.value.data == null ||
//         serviceController.onGoingProjectDetailsData.value.data!.isEmpty) {
//       return 0.0;
//     }
//
//     int totalMilestones =
//         serviceController.onGoingProjectDetailsData.value.data!.length;
//     int completedMilestones = serviceController
//         .onGoingProjectDetailsData
//         .value
//         .data!
//         .where((milestone) => milestone.status == 10)
//         .length;
//
//     return (completedMilestones / totalMilestones) * 100;
//   }
//
//   // Get indicator color based on completion percentage
//   Color get indicatorColor {
//     double percentage = milestoneCompletionPercentage;
//     if (percentage >= 80) {
//       return const Color(0xFF24C934); // Green for 80% and above
//     } else {
//       return const Color(0xFFE8943A); // Orange for below 80%
//     }
//   }
//
//   List<MilestoneItem> _getMilestones() {
//     if (serviceController.onGoingProjectDetailsData.value.data == null ||
//         serviceController.onGoingProjectDetailsData.value.data!.isEmpty) {
//       return [];
//     }
//
//     return serviceController.onGoingProjectDetailsData.value.data!.map((
//         milestone,
//         ) {
//       // Determine status color based on status value
//       Color statusColor;
//       String statusText;
//
//       if (milestone.status == 1) {
//         statusColor = const Color(0xFFC92424);
//         statusText = 'Pending';
//       } else if (milestone.status == 4) {
//         statusColor = const Color(0xFFE8943A);
//         statusText = 'In Progress';
//       } else if (milestone.status == 5) {
//         statusColor = const Color(0xFF24C934);
//         statusText = 'Paid';
//       } else if (milestone.status == 6) {
//         statusColor = const Color(0xFFE8943A);
//         statusText = 'Partial Completion';
//       } else if (milestone.status == 7) {
//         statusColor = const Color(0xFFCEDBE8);
//         statusText = 'Verify';
//       } else if (milestone.status == 8) {
//         statusColor = const Color(0xFFC92424);
//         statusText = 'Need Payment';
//       } else if (milestone.status == 9) {
//         statusColor = const Color(0xFFCEDBE8);
//         statusText = 'On going';
//       } else if (milestone.status == 10) {
//         statusColor = const Color(0xFF24C934);
//         statusText = 'Completed';
//       } else if (milestone.status == 12) {
//         statusColor = const Color(0xFFCEDBE8);
//         statusText = 'Need Verify';
//       } else if (milestone.status == 13) {
//         statusColor = const Color(0xFF24C934);
//         statusText = 'Verified';
//       } else {
//         statusColor = const Color(0xffCFDBE8);
//         statusText = 'PENDING';
//       }
//
//       // Parse update_photo - it's a JSON string like "[\"url1\",\"url2\"]"
//       String? parsedImageUrls;
//       if (milestone.updatePhoto != null &&
//           milestone.updatePhoto.toString().isNotEmpty) {
//         String photoString = milestone.updatePhoto.toString();
//
//         try {
//           // The photoString is already "[\"url1\",\"url2\"]"
//           // We need to decode the escaped quotes
//           String cleaned = photoString.replaceAll(r'\"', '"');
//
//           // Now try to parse it as JSON
//           var decoded = jsonDecode(cleaned);
//
//           if (decoded is List && decoded.isNotEmpty) {
//             // Re-encode it as a proper JSON string for the widget to parse
//             parsedImageUrls = jsonEncode(decoded);
//           }
//         } catch (e) {
//           print('Error parsing update_photo: $e');
//           print('Photo string: $photoString');
//         }
//       }
//
//       // Get comments
//       String? comments = milestone.updateComments?.toString();
//       if (comments != null && comments.isEmpty) {
//         comments = null;
//       }
//
//       return MilestoneItem(
//         title: milestone.title ?? '',
//         days: milestone.completionDays ?? '',
//         status: statusText,
//         statusColor: statusColor,
//         imageUrl: parsedImageUrls,
//         amount: milestone.balanceCost,
//         description: comments,
//         comments: comments,
//         dotColor: const Color(0xffE9EBED),
//         isExpanded: false,
//         planId: milestone.id.toString(),
//       );
//     }).toList();
//   }
//
//   // var list = [
//   //   "Placed an order",
//   //   "Vendor to accept",
//   //   "Design and Proposal from Vendor",
//   //   "Design Finalized",
//   // ];
//   var list = [
//     "Enquiry Submitted",
//     "Site Survey",
//     "Proposal Approved & Advance Paid",
//     "Core Implementation",
//   ];
//
//   Future<void> _handleRefresh() async {
//     // Refresh categories
//     await serviceController.getOnGoingProjectDetails("getPlan", {
//       "order_id": Get.arguments,
//     });
//     _initializeMaterials();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     serviceController
//         .getOnGoingProjectDetails("getPlan", {"order_id": Get.arguments})
//         .then((_) {
//       _initializeMaterials();
//     });
//   }
//
//   void _initializeMaterials() {
//     materials.clear();
//     if (serviceController.onGoingProjectDetailsData.value.ordermaterials !=
//         null) {
//       materials.addAll(
//         serviceController.onGoingProjectDetailsData.value.ordermaterials!.map((
//             material,
//             ) {
//           // Determine if material is fully paid
//           // You need to check your API response for the actual field name
//           // Common field names: is_paid, payment_status, balance_cost == 0, etc.
//           bool isFullyPaid = false;
//
//           // Option 1: Check if balance_cost is 0
//           if (material.balanceCost != null) {
//             double balanceCost =
//                 double.tryParse(material.balanceCost.toString()) ?? 0.0;
//             isFullyPaid = balanceCost == 0.0;
//           }
//
//           // Option 2: Or check if there's a specific field like 'is_paid' or 'payment_status'
//           // Uncomment and adjust based on your API response:
//           // if (material.isPaid != null) {
//           //   isFullyPaid = material.isPaid == true || material.isPaid == "1";
//           // }
//
//           // Option 3: Or check payment_status field
//           // if (material.paymentStatus != null) {
//           //   isFullyPaid = material.paymentStatus == "paid" || material.paymentStatus == "5";
//           // }
//
//           return MaterialItem(
//             name: material.title ?? '',
//             quantity: material.qty ?? '',
//             unit: material.unitType ?? '',
//             cost: material.balanceCost ?? '',
//             isChecked: false,
//             originalData: material,
//             qty: material.qty,
//             unitType: material.unitType,
//             unitCost: material.unitCost,
//             totalCost: material.totalCost,
//             isFullyPaid: isFullyPaid, // Add this
//           );
//         }).toList(),
//       );
//     }
//   }
//
//   void _toggleSelectAll(bool? value) {
//     setState(() {
//       selectAll = value ?? false;
//       for (var item in materials) {
//         item.isChecked = selectAll;
//       }
//     });
//   }
//
//   void _toggleMaterial(int index, bool? value) {
//     setState(() {
//       materials[index].isChecked = value ?? false;
//       selectAll = materials.every((item) => item.isChecked);
//     });
//   }
//
//   List<MaterialItem> _getSelectedMaterials() {
//     return materials.where((item) => item.isChecked).toList();
//   }
//
//   double _calculateSelectedTotal() {
//     double total = 0.0;
//     for (var item in materials) {
//       if (item.isChecked) {
//         String cleanCost = item.cost.replaceAll(RegExp(r'[₹,\s]'), '');
//         total += double.tryParse(cleanCost) ?? 0.0;
//       }
//     }
//     return total;
//   }
//
//   List<dynamic> _getSelectedMaterialsJson() {
//     return materials
//         .where((item) => item.isChecked)
//         .map((item) => item.originalData)
//         .toList();
//   }
//
//   // Update the _makePayment method in ProjectDetailsScreen:
//
//   _makePayment(BuildContext context) async {
//     List<MaterialItem> selectedMaterials = _getSelectedMaterials();
//     if (selectedMaterials.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select at least one material to make payment'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     double totalAmount = _calculateSelectedTotal();
//     List<dynamic> selectedMaterialsData = _getSelectedMaterialsJson();
//     int orderId =
//         selectedMaterials.first.originalData?.orderId ??
//             materials.first?.originalData?.orderId ??
//             0;
//
//     // Navigate to PaymentPlanMaterial page with data and wait for result
//     final result = await Get.toNamed(
//       AppRoutes.paymentPlanMaterial,
//       arguments: {
//         'selected_materials': selectedMaterials,
//         'selected_materials_data': selectedMaterialsData,
//         'balance_cost': totalAmount, // ADD THIS LINE - it was missing!
//         'order_id': orderId,
//         'service_name':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .serviceTitle ??
//             'Service',
//         'vendor_name':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .companyName ??
//             'Vendor',
//         'minimum_fee':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .minimumFee ??
//             "25.00",
//       },
//     );
//
//     // If payment was successful, refresh the data
//     if (result == true) {
//       await _handleRefresh();
//     }
//   }
//
//   // Also update _makeIndividualPayment to use async/await:
//   void _makeIndividualPayment(BuildContext context, int index) async {
//     setState(() {
//       for (var material in materials) {
//         material.isChecked = false;
//       }
//       materials[index].isChecked = true;
//     });
//     await _makePayment(context);
//   }
//
//   // Update _makeMilestonePayment similarly:
//   // void _makeMilestonePayment(BuildContext context, dynamic milestone) async {
//   //   double milestoneAmount =
//   //       double.tryParse(
//   //         milestone.amount?.toString().replaceAll(RegExp(r'[₹,\s]'), '') ?? '0',
//   //       ) ??
//   //       0.0;
//   //
//   //   final result = await Get.toNamed(
//   //     AppRoutes.paymentPlanMaterial,
//   //     arguments: {
//   //       'payment_type': 'milestone',
//   //       'milestone_data': milestone,
//   //       'total_amount': milestoneAmount,
//   //       'order_id': milestone.orderId ?? Get.arguments,
//   //       'service_name':
//   //           serviceController
//   //               .onGoingProjectDetailsData
//   //               .value
//   //               .ordersMain!
//   //               .first
//   //               .serviceTitle ??
//   //           'Service',
//   //       'vendor_name':
//   //           serviceController
//   //               .onGoingProjectDetailsData
//   //               .value
//   //               .ordersMain!
//   //               .first
//   //               .companyName ??
//   //           'Vendor',
//   //       'milestone_title': milestone.title ?? 'Milestone Payment',
//   //     },
//   //   );
//   //
//   //   // If payment was successful, refresh the data
//   //   if (result == true) {
//   //     await _handleRefresh();
//   //   }
//   // }
//   void _makeMilestonePayment(BuildContext context, dynamic milestone) async {
//     // Use balance_cost instead of amount for the payment
//     double milestoneAmount =
//         double.tryParse(
//           milestone.balanceCost?.toString().replaceAll(RegExp(r'[₹,\s]'), '') ??
//               '0',
//         ) ??
//             0.0;
//
//     final result = await Get.toNamed(
//       AppRoutes.paymentPlanMaterial,
//       arguments: {
//         'payment_type': 'milestone',
//         'milestone_data': milestone,
//         'balance_cost': milestoneAmount,
//         // CHANGED: Use balance_cost instead of total_amount
//         'order_id': milestone.orderId ?? Get.arguments,
//         'service_name':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .serviceTitle ??
//             'Service',
//         'vendor_name':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .companyName ??
//             'Vendor',
//         'milestone_title': milestone.title ?? 'Milestone Payment',
//         'minimum_fee':
//         serviceController
//             .onGoingProjectDetailsData
//             .value
//             .ordersMain!
//             .first
//             .minimumFee ??
//             "25.00",
//       },
//     );
//
//     // If payment was successful, refresh the data
//     if (result == true) {
//       await _handleRefresh();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: const CustomAppBar(title: 'Your Project'),
//         body: Obx(() {
//           if (serviceController.onGoingProjectDetailsResponseStatus.value) {
//             return Scaffold(
//               body: const Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (serviceController.onGoingProjectDetailsData.value.success !=
//               true) {
//             return const Scaffold(
//               body: Center(child: Text('No Service available')),
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: _handleRefresh,
//             color: AppConfig.primaryColor,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           // Project Summary Card
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 11,
//                               vertical: 8,
//                             ),
//                             decoration: ShapeDecoration(
//                               color: const Color(0xFFF7F9FC),
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   width: 1,
//                                   color: const Color(0xFFCEDBE8),
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   serviceController
//                                       .onGoingProjectDetailsData
//                                       .value
//                                       .ordersMain!
//                                       .first
//                                       .serviceTitle
//                                       .toString(),
//                                   style: TextStyle(
//                                     color: Color(0xFF183954),
//                                     fontSize: 18,
//                                     fontFamily: 'Figtree-Medium',
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 3,
//                                     vertical: 1,
//                                   ),
//                                   decoration: ShapeDecoration(
//                                     color: const Color(0xFF24C934),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(50),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     areAllMilestonesCompleted == false
//                                         ? 'IN PROGRESS'
//                                         : "COMPLETED",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 8,
//                                       fontFamily: 'Figtree-Bold',
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   width: double.infinity,
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFCEDBE8),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width:
//                                         (MediaQuery.of(context).size.width -
//                                             62) *
//                                             (milestoneCompletionPercentage /
//                                                 100),
//                                         height: 8,
//                                         decoration: BoxDecoration(
//                                           color: indicatorColor,
//                                           // Dynamic color
//                                           borderRadius: BorderRadius.circular(
//                                             4,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//
//                           // Order Progress Card
//                           Container(
//                             width: double.infinity,
//                             decoration: ShapeDecoration(
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               shadows: const [
//                                 BoxShadow(
//                                   color: Color(0xFFEDF2F6),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 4),
//                                   spreadRadius: 0,
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Header
//                                   const Text(
//                                     'Order Progress',
//                                     style: TextStyle(
//                                       color: Color(0xFF183954),
//                                       fontSize: 18,
//                                       fontFamily: 'Figtree-Bold',
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     serviceController
//                                         .onGoingProjectDetailsData
//                                         .value
//                                         .ordersMain!
//                                         .first
//                                         .companyName
//                                         .toString(),
//                                     style: TextStyle(
//                                       color: Color(0x99183954),
//                                       fontSize: 12,
//                                       fontFamily: 'Figtree-Regular',
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 26),
//
//                                   // Step 1: Customer Placed an Order
//                                   for (
//                                   var i = 0;
//                                   i <
//                                       serviceController
//                                           .onGoingProjectDetailsData
//                                           .value
//                                           .steps!
//                                           .length;
//                                   i++
//                                   )
//                                     Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         _buildProgressStep(
//                                           list[i],
//                                           isCompleted: true,
//                                           color:
//                                           serviceController
//                                               .onGoingProjectDetailsData
//                                               .value
//                                               .steps![i]
//                                               .stepStatus ==
//                                               "1"
//                                               ? const Color(0xFF038153)
//                                               : const Color(0xFFAFAFAF),
//                                         ),
//                                         if (serviceController
//                                             .onGoingProjectDetailsData
//                                             .value
//                                             .steps!
//                                             .length -
//                                             1 !=
//                                             i)
//                                           _buildDottedLine(),
//                                         if (serviceController
//                                             .onGoingProjectDetailsData
//                                             .value
//                                             .steps!
//                                             .length -
//                                             1 ==
//                                             i &&
//                                             serviceController
//                                                 .onGoingProjectDetailsData
//                                                 .value
//                                                 .steps![i]
//                                                 .stepStatus ==
//                                                 "0" &&
//                                             list[i] ==
//                                                 "Core Implementation") ...[
//                                           const SizedBox(height: 16),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                               left: 27.5,
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: SizedBox(
//                                                     height: 40,
//                                                     child: OutlinedButton(
//                                                       onPressed: () async {
//                                                         print('Accepted');
//
//                                                         // First call the API and wait for it to complete
//                                                         await serviceController
//                                                             .getDesignFinalized(
//                                                           "finalStep",
//                                                           {
//                                                             "order_id":
//                                                             serviceController
//                                                                 .onGoingProjectDetailsData
//                                                                 .value
//                                                                 .steps!
//                                                                 .first
//                                                                 .orderId,
//                                                             "step_status":
//                                                             "2",
//                                                             // 0 is pending, 1 is accept, 2 is reject
//                                                           },
//                                                         );
//
//                                                         // Then refresh after API call is complete
//                                                         await _handleRefresh();
//
//                                                         print('Completed');
//                                                       },
//                                                       style: OutlinedButton.styleFrom(
//                                                         foregroundColor:
//                                                         const Color(
//                                                           0xFF1A202C,
//                                                         ),
//                                                         side: const BorderSide(
//                                                           color: Color(
//                                                             0xFF1A202C,
//                                                           ),
//                                                           width: 1,
//                                                         ),
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius:
//                                                           BorderRadius.circular(
//                                                             8,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       child: const Text(
//                                                         'Reject',
//                                                         style: TextStyle(
//                                                           fontSize: 14,
//                                                           fontFamily:
//                                                           'Figtree-Medium',
//                                                           fontWeight:
//                                                           FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 12),
//                                                 Expanded(
//                                                   child: SizedBox(
//                                                     height: 40,
//                                                     child: ElevatedButton(
//                                                       onPressed: () async {
//                                                         print('Accepted');
//
//                                                         // First call the API and wait for it to complete
//                                                         await serviceController
//                                                             .getDesignFinalized(
//                                                           "finalStep",
//                                                           {
//                                                             "order_id":
//                                                             serviceController
//                                                                 .onGoingProjectDetailsData
//                                                                 .value
//                                                                 .steps!
//                                                                 .first
//                                                                 .orderId,
//                                                             "step_status":
//                                                             "1",
//                                                             // 0 is pending, 1 is accept, 2 is reject
//                                                           },
//                                                         );
//
//                                                         // Then refresh after API call is complete
//                                                         await _handleRefresh();
//
//                                                         print('Completed');
//                                                       },
//                                                       style: ElevatedButton.styleFrom(
//                                                         backgroundColor:
//                                                         const Color(
//                                                           0xFF1A202C,
//                                                         ),
//                                                         foregroundColor:
//                                                         Colors.white,
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius:
//                                                           BorderRadius.circular(
//                                                             8,
//                                                           ),
//                                                         ),
//                                                         elevation: 0,
//                                                       ),
//                                                       child: const Text(
//                                                         'Accept',
//                                                         style: TextStyle(
//                                                           fontSize: 14,
//                                                           fontFamily:
//                                                           'Figtree-Medium',
//                                                           fontWeight:
//                                                           FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//
//                           // Milestones Card
//                           // ExpandableMilestoneWidget(
//                           //   milestones: _getMilestones(),
//                           //   onReplan: () {
//                           //     Get.toNamed(AppRoutes.ratingPage,arguments: serviceController.onGoingProjectDetailsData.value.ordersMain);
//                           //
//                           //   },
//                           // ),
//                           ExpandableMilestoneWidget(
//                             milestones: _getMilestones(),
//                             onReplan: () {
//                               Get.toNamed(
//                                 AppRoutes.ratingPage,
//                                 arguments: serviceController
//                                     .onGoingProjectDetailsData
//                                     .value
//                                     .ordersMain,
//                               );
//                             },
//                             onPayMilestone: (milestone) {
//                               // Find the original milestone data from controller
//                               var originalMilestone = serviceController
//                                   .onGoingProjectDetailsData
//                                   .value
//                                   .data
//                                   ?.firstWhere(
//                                     (m) => m.title == milestone.title,
//                               );
//                               if (originalMilestone != null) {
//                                 _makeMilestonePayment(
//                                   context,
//                                   originalMilestone,
//                                 );
//                               }
//                             },
//                             onRefresh: _handleRefresh, // ADD THIS LINE
//                           ),
//
//                           const SizedBox(height: 24),
//                           // MATERIALS SECTION (NEW)
//                           if (materials.isNotEmpty) ...[
//                             _buildMaterialsSection(),
//                             const SizedBox(height: 24),
//                           ],
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               Get.toNamed(AppRoutes.home);
//                               // Your action here
//                             },
//                             icon: const Icon(
//                               Icons.add_circle_outline,
//                               color: Colors.white,
//                             ),
//                             label: const Text(
//                               'Add More Services',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontFamily: 'Figtree-Medium',
//                                 fontWeight: FontWeight.w500,
//                                 height: 1.50,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF1A202C),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 10,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: const BorderSide(
//                                   width: 1,
//                                   color: Color(0xFF1A202C),
//                                 ),
//                               ),
//                               elevation: 1,
//                               shadowColor: const Color(0x0C101828),
//                             ),
//                           ),
//
//                           const SizedBox(height: 80),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Bottom Fixed Button
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFFEDF2F7),
//                         blurRadius: 24,
//                         offset: const Offset(0, -6),
//                       ),
//                     ],
//                   ),
//                   child: VayilOrangeButton(
//                     title: (areAllMilestonesCompleted && !hasReview)
//                         ? "Rate This Service"
//                         : "View Project Activity",
//                     onTap: () {
//                       if (areAllMilestonesCompleted && !hasReview) {
//                         // Navigate to rating page only if not yet reviewed
//                         Get.toNamed(
//                           AppRoutes.ratingPage,
//                           arguments: serviceController
//                               .onGoingProjectDetailsData
//                               .value
//                               .ordersMain,
//                         );
//                       } else {
//                         // Show payment activity bottom sheet
//                         showPaymentsBottomSheet(
//                           context,
//                           serviceController
//                               .onGoingProjectDetailsData
//                               .value
//                               .data!
//                               .first
//                               .orderId,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildMaterialsSection() {
//     // Separate materials into paid and unpaid
//     List<MaterialItem> paidItems = materials
//         .where((item) => item.isFullyPaid)
//         .toList();
//     List<MaterialItem> unpaidItems = materials
//         .where((item) => !item.isFullyPaid)
//         .toList();
//
//     int selectedCount = unpaidItems.where((item) => item.isChecked).length;
//     double selectedTotal = _calculateSelectedTotal();
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         shadows: const [
//           BoxShadow(
//             color: Color(0xFFEDF2F6),
//             blurRadius: 4,
//             offset: Offset(0, 4),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Materials',
//             style: TextStyle(
//               color: Color(0xFF183954),
//               fontSize: 20,
//               fontFamily: 'Figtree-Medium',
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Below are the list of materials procured and not procured',
//             style: TextStyle(
//               color: Color(0xFF0C141C),
//               fontSize: 12,
//               fontFamily: 'Figtree-Regular',
//               fontWeight: FontWeight.w400,
//               height: 1.32,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Show lock message if design is not finalized
//           if (!isDesignFinalized) ...[
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF9E6),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFFFE5B4), width: 1),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.lock_outline, color: Color(0xFFE8943A), size: 20),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Please accept the design to enable material payments',
//                       style: TextStyle(
//                         color: Color(0xFF0C141C),
//                         fontSize: 13,
//                         fontFamily: 'Figtree-Medium',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           // Selected items summary
//           if (selectedCount > 0 && isDesignFinalized)
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE8F5E9),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFF329537), width: 1),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '$selectedCount item(s) selected',
//                       style: const TextStyle(
//                         color: Color(0xFF329537),
//                         fontSize: 14,
//                         fontFamily: 'Manrope-regular',
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     '₹${selectedTotal.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       color: Color(0xFF329537),
//                       fontSize: 16,
//                       fontFamily: 'Manrope-regular',
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           // PAID SECTION
//           if (paidItems.isNotEmpty) ...[
//             const Padding(
//               padding: EdgeInsets.only(bottom: 12),
//               child: Text(
//                 'Paid',
//                 style: TextStyle(
//                   color: const Color(0xFF0C141C),
//                   fontSize: 12,
//                   fontFamily: "Manrope-Bold",
//                   fontWeight: FontWeight.w600,
//                   height: 1.75,
//                 ),
//               ),
//             ),
//             ...paidItems.asMap().entries.map((entry) {
//               int originalIndex = materials.indexOf(entry.value);
//               return _buildMaterialRow(originalIndex, entry.value);
//             }),
//             const SizedBox(height: 16),
//           ],
//
//           // NEED TO PAY SECTION
//           if (unpaidItems.isNotEmpty) ...[
//             const Padding(
//               padding: EdgeInsets.only(bottom: 12),
//               child: Text(
//                 'Need to Pay',
//                 style: TextStyle(
//                   color: const Color(0xFF0C141C),
//                   fontSize: 12,
//                   fontFamily: "Manrope-Bold",
//                   fontWeight: FontWeight.w600,
//                   height: 1.75,
//                 ),
//               ),
//             ),
//             ...unpaidItems.asMap().entries.map((entry) {
//               int originalIndex = materials.indexOf(entry.value);
//               return _buildMaterialRow(originalIndex, entry.value);
//             }),
//           ],
//
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: isDesignFinalized ? () => _makePayment(context) : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isDesignFinalized
//                   ? Colors.white
//                   : const Color(0xFFF0F0F0),
//               foregroundColor: isDesignFinalized
//                   ? const Color(0xFF329537)
//                   : const Color(0xFFB0B0B0),
//               padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 side: BorderSide(
//                   width: 1,
//                   color: isDesignFinalized
//                       ? const Color(0xFF5EAE91)
//                       : const Color(0xFFE0E0E0),
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (!isDesignFinalized) ...[
//                   const Icon(Icons.lock_outline, size: 16),
//                   const SizedBox(width: 8),
//                 ],
//                 Text(
//                   isDesignFinalized
//                       ? (selectedCount > 0
//                       ? 'Continue to Payment (₹${selectedTotal.toStringAsFixed(2)})'
//                       : 'Continue to Payment')
//                       : 'Design approval required',
//                   style: TextStyle(
//                     color: isDesignFinalized
//                         ? const Color(0xFF329537)
//                         : const Color(0xFFB0B0B0),
//                     fontSize: 14,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w500,
//                     height: 1.43,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMaterialRow(int index, MaterialItem item) {
//     // Check if cost is 0.00 OR design is not finalized to disable the row
//     bool isDisabled = _parseCost(item.cost) == 0.00 || !isDesignFinalized;
//
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 12),
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         shadows: const [
//           BoxShadow(
//             color: Color(0xFFEDF2F6),
//             blurRadius: 4,
//             offset: Offset(0, 1),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: isDisabled
//                 ? null
//                 : () => _toggleMaterial(index, !item.isChecked),
//             child: Container(
//               width: 16,
//               height: 16,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(
//                   color: isDisabled
//                       ? const Color(0xFFE0E0E0)
//                       : const Color(0xFFC2C8CC),
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: item.isChecked && !isDisabled
//                   ? const Icon(Icons.check, size: 12, color: Color(0xFF329537))
//                   : null,
//             ),
//           ),
//           const SizedBox(width: 5),
//           // Left side - Material details
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name ?? '',
//                       style: TextStyle(
//                         color: const Color(0xFF0C141C),
//                         fontSize: 11,
//                         fontFamily: "Manrope-Bold",
//                         fontWeight: FontWeight.w600,
//                         height: 1.75,
//                       ),
//                     ),
//                     Text(
//                       'Qty: ${item.qty ?? '0'}',
//                       style: TextStyle(
//                         color: const Color(0xFF4C7299),
//                         fontSize: 12,
//                         fontFamily: "Manrope-Regular",
//                         fontWeight: FontWeight.w400,
//                         height: 1.75,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//
//                   children: [
//                     Text(
//                       'Unit Type: ${item.unitType ?? 'N/A'}',
//                       style: TextStyle(
//                         color: const Color(0xFF4C7299),
//                         fontSize: 11,
//                         fontFamily: "Manrope-Regular",
//                         fontWeight: FontWeight.w400,
//                         height: 1.75,
//                       ),
//                     ),
//                     Text(
//                       'Cost/Unit: ₹${double.parse(item.unitCost.toString()).round()}',
//                       style: TextStyle(
//                         color: const Color(0xFF4C7299),
//                         fontSize: 11,
//                         fontFamily: "Manrope-Regular",
//                         fontWeight: FontWeight.w400,
//                         height: 1.75,
//                       ),
//                     ),
//                     isDisabled
//                         ? const Text(
//                       'Fully Paid',
//                       style: TextStyle(
//                         color: Color(0xFF4C7299),
//                         fontSize: 12,
//                         fontFamily: 'Manrope-Medium',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                         : Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'Total Cost: ',
//                             style: TextStyle(
//                               color: const Color(0xFF0C141C),
//                               fontSize: 11,
//                               fontFamily: "Manrope-Regular",
//                               fontWeight: FontWeight.w400,
//                               height: 1.75,
//                             ),
//                           ),
//                           TextSpan(
//                             text: double.parse(
//                               item.totalCost.toString(),
//                             ).round().toString(),
//                             style: TextStyle(
//                               color: const Color(0xFF0C141C),
//                               fontSize: 11,
//                               fontFamily: 'Manrope-Regular',
//                               fontWeight: FontWeight.w700,
//                               height: 1.75,
//                             ),
//                           ),
//                         ],
//                       ),
//                       textAlign: TextAlign.right,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 5),
//
//           // Right side - Cost and Pay button
//           SizedBox(width: 10),
//           GestureDetector(
//             onTap: isDisabled
//                 ? null
//                 : () => _makeIndividualPayment(context, index),
//             child: Text(
//               'Pay',
//               style: TextStyle(
//                 color: isDisabled
//                     ? const Color(0xFFB0B0B0)
//                     : const Color(0xFF329537),
//                 fontSize: 12,
//                 fontFamily: 'Manrope-regular',
//                 fontWeight: FontWeight.w600,
//                 height: 1.9,
//                 decoration: TextDecoration.underline,
//                 decorationColor: Color(0xFF329537),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to parse cost string to double
//   double _parseCost(String cost) {
//     // Remove currency symbol and any other non-numeric characters except decimal point
//     String cleanCost = cost.replaceAll(RegExp(r'[^\d.]'), '');
//     return double.tryParse(cleanCost) ?? 0.0;
//   }
//
//   Widget _buildProgressStep(
//       String text, {
//         required bool isCompleted,
//         required Color color,
//       }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         HugeIcon(
//           icon: HugeIcons.strokeRoundedCheckmarkCircle04,
//           size: 16.0,
//           color: color,
//           strokeWidth: 2,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF49545C),
//               fontSize: 14,
//               fontFamily: 'Lato-Regular',
//               fontWeight: FontWeight.w500,
//               height: 1.43,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDottedLine() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 7.5, top: 4, bottom: 4),
//       child: CustomPaint(size: const Size(1, 18), painter: DottedLinePainter()),
//     );
//   }
// }
//
// class DottedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFCEDBE8)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     const dashHeight = 4.0;
//     const dashSpace = 4.0;
//     double startY = 0;
//
//     while (startY < size.height) {
//       canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
//       startY += dashHeight + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
//
// void showPaymentsBottomSheet(BuildContext context, var orderId) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => DraggableScrollableSheet(
//       initialChildSize: 0.75,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) => ViewPaymentsBottomSheet(
//         scrollController: scrollController,
//         orderId: orderId,
//       ),
//     ),
//   );
// }
//
// class MaterialItem {
//   final String name;
//   final String quantity;
//   final String unit;
//   String? unitType;
//   String? qty;
//   dynamic? unitCost;
//   dynamic? totalCost;
//   final String cost;
//   bool isChecked;
//   final dynamic originalData;
//   bool isFullyPaid; // Add this property
//
//   MaterialItem({
//     required this.name,
//     required this.quantity,
//     required this.unit,
//     required this.qty,
//     required this.unitType,
//     required this.totalCost,
//     required this.unitCost,
//     required this.cost,
//     this.isChecked = false,
//     this.originalData,
//     this.isFullyPaid = false,
//   });
// }
//
// class ActivityItem {
//   final String name;
//   final String price;
//   final Color color;
//
//   ActivityItem(this.name, this.price, this.color);
// }
//
// class ViewPaymentsBottomSheet extends StatefulWidget {
//   final ScrollController scrollController;
//   final dynamic orderId;
//
//   const ViewPaymentsBottomSheet({
//     super.key,
//     required this.scrollController,
//     required this.orderId,
//   });
//
//   @override
//   State<ViewPaymentsBottomSheet> createState() =>
//       _ViewPaymentsBottomSheetState();
// }
//
// class _ViewPaymentsBottomSheetState extends State<ViewPaymentsBottomSheet> {
//   var serviceController = Get.put(ServiceController());
//
//   bool selectAll = false;
//   List<dynamic> materialPaymentHistory = [];
//   List<dynamic> servicePaymentHistory = [];
//
//   // Dynamic payment data
//   double totalAmount = 0.0;
//   double totalPaidAmount = 0.0;
//   double sliderValue = 0.0;
//   double totalMaterialAmount = 0.0;
//   double totalPlanAmount = 0.0;
//
//   // Expand/Collapse states
//   bool isActivity1Expanded = true;
//   bool isActivity2Expanded = true;
//
//   bool isNeedPay1Expanded = true;
//   bool isNeedPay2Expanded = true;
//   String invoiceUrl = AppConfig.baseUrl;
//
//   // ─── FEE CALCULATION HELPERS ────────────────────────────────
//
//   /// Parse AppConfig fee strings safely
//   double _parseFee(String value) => double.tryParse(value) ?? 0.0;
//
//   /// GST = sGST + cGST + iGST (as % e.g. "9" means 9%)
//   double get _gstPercent =>
//       _parseFee(AppConfig.sGST) + _parseFee(AppConfig.cGST);
//
//   /// Compute fees for a given base amount
//   Map<String, double> _computeFees(double baseAmount) {
//     final convenience =
//         baseAmount * double.parse(AppConfig.convenienceFee) / 100;
//     final platform = baseAmount * double.parse(AppConfig.platformFee) / 100;
//     final gst = ((baseAmount + convenience + platform) * _gstPercent) / 100;
//     final total =
//         baseAmount + convenience.round() + platform.round() + gst.round();
//     return {
//       'convenience': convenience,
//       'platform': platform,
//       'gst': gst,
//       'total': total,
//     };
//   }
//
//   // ─── GRAND TOTAL HELPERS ────────────────────────────────────
//
//   /// Sum of balance_cost for all pending materials
//   double _totalMaterialBalance() {
//     final materials = serviceController.needToPayData.value.materials ?? [];
//     return materials.fold(0.0, (sum, m) {
//       return sum + (double.tryParse(m.balanceCost ?? '0') ?? 0.0);
//     });
//   }
//
//   /// Sum of balance_cost for all pending plan items
//   double _totalPlanBalance() {
//     final plans = serviceController.needToPayData.value.plan ?? [];
//     return plans.fold(0.0, (sum, p) {
//       return sum + (double.tryParse(p.balanceCost ?? '0') ?? 0.0);
//     });
//   }
//
//   /// Total material cost (before any payments) from planoverall
//   double _totalMaterialOverall() {
//     final overall =
//         serviceController.needToPayData.value.materialsoverall ?? [];
//     if (overall.isEmpty) return 0.0;
//     return double.tryParse(overall[0].totalCostAmount ?? '0') ?? 0.0;
//   }
//
//   /// Total plan cost (before any payments) from planoverall
//   double _totalPlanOverall() {
//     final overall = serviceController.needToPayData.value.planoverall ?? [];
//     if (overall.isEmpty) return 0.0;
//     return double.tryParse(overall[0].totalAmount ?? '0') ?? 0.0;
//   }
//
//   /// Overall remaining (materials + plans, with fees applied)
//   double _grandTotalRemaining() {
//     final matBase = _totalMaterialBalance();
//     final planBase = _totalPlanBalance();
//     final matFees = _computeFees(matBase);
//     final planFees = _computeFees(planBase);
//     return (matFees['total'] ?? 0) + (planFees['total'] ?? 0);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchPaymentSummary();
//   }
//
//   void _fetchPaymentSummary() {
//     serviceController
//         .getPaymentSummary("getPaymentDetails", {"order_id": widget.orderId})
//         .then((_) {
//       setState(() {
//         if (serviceController.paymentSummaryData != null &&
//             serviceController.paymentSummaryData.value.success == true) {
//           // Get material and service payment arrays
//           materialPaymentHistory =
//               serviceController.paymentSummaryData.value.materialPayment ??
//                   [];
//           servicePaymentHistory =
//               serviceController.paymentSummaryData.value.servicePayment ??
//                   [];
//
//           // Get dynamic amounts from API
//           totalAmount =
//               double.tryParse(
//                 serviceController.paymentSummaryData.value.totalAmount
//                     ?.toString() ??
//                     '0',
//               ) ??
//                   0.0;
//
//           totalPaidAmount =
//               double.tryParse(
//                 serviceController.paymentSummaryData.value.totalPaidAmount
//                     ?.toString() ??
//                     '0',
//               ) ??
//                   0.0;
//
//           totalMaterialAmount =
//               double.tryParse(
//                 serviceController
//                     .paymentSummaryData
//                     .value
//                     .totalMaterialAmount
//                     ?.toString() ??
//                     '0',
//               ) ??
//                   0.0;
//
//           totalPlanAmount =
//               double.tryParse(
//                 serviceController.paymentSummaryData.value.totalPlanAmount
//                     ?.toString() ??
//                     '0',
//               ) ??
//                   0.0;
//           // Add after totalPlanAmount assignment
//           invoiceUrl =
//               serviceController.paymentSummaryData.value.invoiceUrl
//                   ?.toString() ??
//                   '';
//           // Calculate slider percentage (0-100)
//           if (totalAmount > 0) {
//             sliderValue = (totalPaidAmount / totalAmount) * 100;
//           }
//         }
//       });
//     });
//
//     serviceController
//         .getNeedToPay("NeedPaymentSummary", {"order_id": widget.orderId})
//         .then((_) {
//       setState(() {});
//     });
//   }
//
//   // Parse payment_data to get materials
//   List<dynamic> _parsePaymentData(String? paymentData) {
//     if (paymentData == null || paymentData.isEmpty) return [];
//
//     try {
//       // Remove the extra quotes and parse
//       String cleaned = paymentData.replaceAll(r'\"', '"');
//       if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
//         cleaned = cleaned.substring(1, cleaned.length - 1);
//       }
//       return jsonDecode(cleaned) as List<dynamic>;
//     } catch (e) {
//       print('Error parsing payment data: $e');
//       return [];
//     }
//   }
//
//   Color getTrackColor(double value) {
//     if (value > 80) {
//       return const Color(0xFF4CAF50); // Green
//     }
//     return const Color(0xFFE8943A); // Orange
//   }
//
//   // Build consolidated activity logs - Activity 1: Materials, Activity 2: Others
//   List<Widget> _buildConsolidatedActivityLogs() {
//     List<Widget> logs = [];
//
//     // Activity 1: ALL Materials in ONE log
//     if (materialPaymentHistory.isNotEmpty) {
//       // Get total paid from the first successful material payment
//       double materialPaid = 0.0;
//
//       for (var payment in materialPaymentHistory) {
//         if (payment.paymentStatus == 'success') {
//           materialPaid =
//               double.tryParse(payment.totalPaidAmount?.toString() ?? '0') ??
//                   0.0;
//           break; // Take only the first successful payment's total_paid_amount
//         }
//       }
//
//       logs.add(
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: _buildCombinedMaterialActivityLog(
//             'Activity 1 Logs',
//             "Material procurement Summary",
//             materialPaymentHistory
//                 .where((p) => p.paymentStatus == 'success')
//                 .toList(),
//             materialPaid,
//             totalMaterialAmount,
//             isActivity1Expanded,
//                 () {
//               setState(() {
//                 isActivity1Expanded = !isActivity1Expanded;
//               });
//             },
//           ),
//         ),
//       );
//     }
//
//     // Activity 2: ALL Service payments (place_order + plan) in ONE log
//     if (servicePaymentHistory.isNotEmpty) {
//       // Get total paid from the first successful service payment
//       double servicePaid = 0.0;
//
//       for (var payment in servicePaymentHistory) {
//         if (payment.paymentStatus == 'success') {
//           servicePaid =
//               double.tryParse(payment.totalPaidAmount?.toString() ?? '0') ??
//                   0.0;
//           break; // Take only the first successful payment's total_paid_amount
//         }
//       }
//
//       logs.add(
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: _buildCombinedServicePaymentsLog(
//             'Activity 2 Logs',
//             "Work Cost Summary",
//             servicePaymentHistory
//                 .where((p) => p.paymentStatus == 'success')
//                 .toList(),
//             servicePaid,
//             totalPlanAmount,
//             isActivity2Expanded,
//                 () {
//               setState(() {
//                 isActivity2Expanded = !isActivity2Expanded;
//               });
//             },
//           ),
//         ),
//       );
//     }
//
//     return logs;
//   }
//
//   // Build combined material activity log with multiple payment sections
//   Widget _buildCombinedMaterialActivityLog(
//       String title,
//       String type,
//       List<dynamic> materialPayments,
//       double totalPaid,
//       double totalBase,
//       bool isExpanded,
//       VoidCallback onToggle,
//       ) {
//     // Generate color for each material across all payments
//     List<Color> colors = [
//       const Color(0xFFE8943A),
//       const Color(0xFF329537),
//       const Color(0xFF1B527E),
//       const Color(0xFFE53935),
//       const Color(0xFF8E24AA),
//     ];
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(10),
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with expand/collapse button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Color(0xFF183954),
//                   fontSize: 14,
//                   fontFamily: 'Figtree-Medium',
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onToggle,
//                 child: Icon(
//                   isExpanded
//                       ? Icons.keyboard_arrow_up
//                       : Icons.keyboard_arrow_down,
//                   color: const Color(0xFF183954),
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             type,
//             style: const TextStyle(
//               color: Color(0xFF98A1B2),
//               fontSize: 10,
//               fontFamily: 'Figtree',
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You have paid ₹${totalPaid.toInt()} of ₹${totalBase.toInt()}',
//             style: const TextStyle(
//               color: Color(0xFF0C141C),
//               fontSize: 14,
//               fontFamily: 'Manrope-regular',
//               fontWeight: FontWeight.w400,
//               height: 1.50,
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Progress bar for material payments
//           SliderTheme(
//             data: SliderThemeData(
//               trackHeight: 8,
//               thumbShape: const RoundSliderThumbShape(
//                 enabledThumbRadius: 0,
//                 disabledThumbRadius: 0,
//               ),
//               overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
//               activeTrackColor: getTrackColor(
//                 totalBase > 0 ? (totalPaid / totalBase) * 100 : 0,
//               ),
//               disabledActiveTrackColor: getTrackColor(
//                 totalBase > 0 ? (totalPaid / totalBase) * 100 : 0,
//               ),
//               inactiveTrackColor: const Color(0xFFCEDBE8),
//               disabledInactiveTrackColor: const Color(0xFFCEDBE8),
//               trackShape: const RoundedRectSliderTrackShape(),
//             ),
//             child: Slider(
//               value: (totalBase > 0 ? ((totalPaid / totalBase) * 100) : 0.0)
//                   .clamp(0.0, 100.0),
//               min: 0,
//               max: 100,
//               onChanged: null,
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Collapsible content
//           if (isExpanded)
//           // Iterate through each material payment and show as separate sections
//             ...materialPayments.asMap().entries.map((entry) {
//               int paymentIndex = entry.key;
//               var payment = entry.value;
//
//               String paymentDate = _formatPaymentDate(payment.paymentDate);
//               List<dynamic> materials = _parsePaymentData(payment.paymentData);
//
//               // Calculate color start index based on previous materials
//               int colorStartIndex = 0;
//               for (int i = 0; i < paymentIndex; i++) {
//                 List<dynamic> prevMaterials = _parsePaymentData(
//                   materialPayments[i].paymentData,
//                 );
//                 colorStartIndex += prevMaterials.length;
//               }
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Show payment date at the top of each payment section
//                   if (paymentIndex > 0) const SizedBox(height: 16),
//
//                   Text(
//                     paymentDate,
//                     style: const TextStyle(
//                       color: Color(0xFF183954),
//                       fontSize: 10,
//                       fontFamily: 'Manrope-regular',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Material Items for this payment
//                   ...materials.asMap().entries.map((materialEntry) {
//                     int materialIndex = materialEntry.key;
//                     var material = materialEntry.value;
//                     Color itemColor =
//                     colors[(colorStartIndex + materialIndex) %
//                         colors.length];
//                     String materialTitle = material['title'] ?? '';
//                     String qty = material['qty'] ?? '';
//                     String unitType = material['unit_type'] ?? '';
//                     String totalCost = material['total_cost'] ?? '0';
//
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 12,
//                             height: 12,
//                             decoration: ShapeDecoration(
//                               color: itemColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               '$qty x $materialTitle',
//                               style: const TextStyle(
//                                 color: Color(0xFF0C141C),
//                                 fontSize: 12,
//                                 fontFamily: 'Manrope-regular',
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.75,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '₹${(double.tryParse(totalCost) ?? 0).toInt()}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Color(0xFF0C141C),
//                               fontSize: 14,
//                               fontFamily: 'Manrope-regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.50,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//
//                   // Divider
//                   Row(
//                     children: List.generate(
//                       150 ~/ 3,
//                           (index) => Expanded(
//                         child: Container(
//                           color: index % 1.5 == 0
//                               ? const Color(0xFFCEDBE8)
//                               : Colors.transparent,
//                           height: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Fees
//                   if (payment.convenienceFeeCost != "0.00")
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Convenience Fee',
//                               style: TextStyle(
//                                 color: Color(0xFF49545C),
//                                 fontSize: 10,
//                                 fontFamily: 'Lato-Regular',
//                                 fontWeight: FontWeight.w500,
//                                 height: 2,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '₹${(double.tryParse(payment.convenienceFeeCost?.toString() ?? '0') ?? 0).toInt()}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Color(0xFF183954),
//                               fontSize: 14,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.43,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (payment.platformCost != "0.00")
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Platform Fee',
//                               style: TextStyle(
//                                 color: Color(0xFF49545C),
//                                 fontSize: 10,
//                                 fontFamily: 'Lato-Regular',
//                                 fontWeight: FontWeight.w500,
//                                 height: 2,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '₹${(double.tryParse(payment.platformCost?.toString() ?? '0') ?? 0).toInt()}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Color(0xFF183954),
//                               fontSize: 14,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.43,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'GST 18% of all the line item',
//                             style: TextStyle(
//                               color: Color(0xFF49545C),
//                               fontSize: 10,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w500,
//                               height: 2,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '₹${(double.tryParse(payment.taxCost?.toString() ?? '0') ?? 0).toInt()}',
//                           textAlign: TextAlign.right,
//                           style: const TextStyle(
//                             color: Color(0xFF183954),
//                             fontSize: 14,
//                             fontFamily: 'Lato-Regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.43,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Total
//                   Row(
//                     children: [
//                       const Expanded(
//                         child: Text(
//                           'TOTAL',
//                           style: TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 12,
//                             fontFamily: 'Manrope-regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.75,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '₹${(double.tryParse(payment.paymentAmount?.toString() ?? '0') ?? 0).toInt()}',
//                         style: const TextStyle(
//                           color: Color(0xFF0C141C),
//                           fontSize: 14,
//                           fontFamily: 'Manrope-regular',
//                           fontWeight: FontWeight.w700,
//                           height: 1.50,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Order placed date (shown at bottom)
//                   Text(
//                     paymentDate,
//                     style: const TextStyle(
//                       color: Color(0xFF696F76),
//                       fontSize: 8,
//                       fontFamily: 'Manrope-regular',
//                       fontWeight: FontWeight.w600,
//                       height: 2.63,
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//                   // Download Invoice
//                   Center(
//                     child: GestureDetector(
//                       onTap: () async {
//                         final url = invoiceUrl.isNotEmpty
//                             ? '$invoiceUrl${payment.orderId}/${payment.id}'
//                             : '';
//                         if (url.isEmpty) {
//                           debugPrint('Invoice URL not available');
//                           return;
//                         }
//                         final uri = Uri.parse(url);
//                         if (await canLaunchUrl(uri)) {
//                           await launchUrl(
//                             uri,
//                             mode: LaunchMode.externalApplication,
//                           );
//                         } else {
//                           debugPrint('Could not launch invoice URL: $url');
//                         }
//                       },
//
//                       child: const Text(
//                         'Download Invoice',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Color(0xFF696F76),
//                           fontSize: 8,
//                           fontFamily: 'Manrope-regular',
//                           fontWeight: FontWeight.w700,
//                           decoration: TextDecoration.underline,
//                           height: 2.63,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               );
//             }),
//         ],
//       ),
//     );
//   } // Build combined material activity log with multiple payment sections
//
//   Widget needPaymentActivityLog() {
//     return Obx(() {
//       final model = serviceController.needToPayData.value;
//
//       // Nothing to show if API hasn't responded yet or lists are empty
//       if ((model.plan == null || model.plan!.isEmpty) &&
//           (model.materials == null || model.materials!.isEmpty)) {
//         return const SizedBox.shrink();
//       }
//
//       final materials = model.materials ?? [];
//       final plans = model.plan ?? [];
//
//       final grandRemaining = _grandTotalRemaining();
//
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: ShapeDecoration(
//           color: const Color(0xFFF7F9FC),
//           shape: RoundedRectangleBorder(
//             side: const BorderSide(width: 1, color: Color(0xFFCEDBE8)),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Grand total header ──────────────────────────────
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: ShapeDecoration(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Need to pay',
//                     style: TextStyle(
//                       color: Color(0xFF183954),
//                       fontSize: 18,
//                       fontFamily: 'Figtree-Medium',
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text.rich(
//                     TextSpan(
//                       children: [
//                         const TextSpan(
//                           text: 'You need to pay remaining of ',
//                           style: TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 14,
//                             fontFamily: 'Manrope-Regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.50,
//                           ),
//                         ),
//                         TextSpan(
//                           text: '₹${grandRemaining.toInt()}',
//                           style: const TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 14,
//                             fontFamily: 'Manrope-Medium',
//                             fontWeight: FontWeight.w700,
//                             height: 1.50,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // ── Activity 1 – Materials ──────────────────────────
//             if (materials.isNotEmpty)
//               _buildNeedToPayActivityCard(
//                 activityTitle: 'Activity 1 Logs',
//                 paidAmount: _computeFees(_totalMaterialOverall() - _totalMaterialBalance(),)['total'] ?? 0.0,
//                 totalAmount: _computeFees(_totalMaterialOverall())['total'] ?? 0.0,
//                 remainingBase: _totalMaterialBalance(),
//                 isExpanded: isNeedPay1Expanded,
//                 // ADD
//                 onToggle: () => setState(() {
//                   // ADD
//                   isNeedPay1Expanded = !isNeedPay1Expanded; // ADD
//                 }),
//                 itemRows: materials.map((m) {
//                   final base = double.tryParse(m.balanceCost ?? '0') ?? 0.0;
//                   final fees = _computeFees(base);
//
//                   return _NeedPayItem(
//                     color: const Color(0xFFE8943A),
//                     label: '${m.qty ?? ''} x ${m.title ?? ''}',
//                     baseAmount: base,
//                     fees: fees,
//                   );
//                 }).toList(),
//               ),
//
//             const SizedBox(height: 12),
//
//             // ── Activity 2 – Plans / Service charges ────────────
//             if (plans.isNotEmpty)
//               _buildNeedToPayActivityCard(
//                 activityTitle: 'Activity 2 Logs',
//                 paidAmount: _computeFees(_totalPlanOverall() - _totalPlanBalance(),)['total'] ?? 0.0,
//                 totalAmount: _computeFees(_totalPlanOverall())['total'] ?? 0.0,
//                 remainingBase: _totalPlanBalance(),
//                 isExpanded: isNeedPay2Expanded,
//                 // ADD
//                 onToggle: () => setState(() {
//                   // ADD
//                   isNeedPay2Expanded = !isNeedPay2Expanded; // ADD
//                 }),
//                 itemRows: plans.map((p) {
//                   final base = double.tryParse(p.balanceCost ?? '0') ?? 0.0;
//                   final fees = _computeFees(base);
//                   return _NeedPayItem(
//                     color: const Color(0xFF329537),
//                     label: p.title ?? 'Service Charge',
//                     baseAmount: base,
//                     fees: fees,
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       );
//     });
//   }
//
//   // ─── ACTIVITY CARD ──────────────────────────────────────────
//
//   Widget _buildNeedToPayActivityCard({
//     required String activityTitle,
//     required double paidAmount,
//     required double totalAmount,
//     required double remainingBase,
//     required List<_NeedPayItem> itemRows,
//     required bool isExpanded, // ADD THIS
//     required VoidCallback onToggle, // ADD THIS
//   }) {
//     final fees = _computeFees(remainingBase);
//     final remainingTotal = fees['total'] ?? 0.0;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(10),
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title row — ADD toggle button here
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 activityTitle,
//                 style: const TextStyle(
//                   color: Color(0xFF183954),
//                   fontSize: 14,
//                   fontFamily: 'Figtree-Medium',
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               GestureDetector(
//                 // ADD
//                 onTap: onToggle, // ADD
//                 child: Icon(
//                   // ADD
//                   isExpanded // ADD
//                       ? Icons
//                       .keyboard_arrow_up // ADD
//                       : Icons.keyboard_arrow_down, // ADD
//                   color: const Color(0xFF183954), // ADD
//                   size: 24, // ADD
//                 ), // ADD
//               ), // ADD
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // Paid / remaining summary
//           Text(
//             'You have paid ₹${paidAmount.toInt()} of ₹${totalAmount.toInt()}',
//             style: const TextStyle(
//               color: Color(0xFF98A1B2),
//               fontSize: 10,
//               fontFamily: 'Figtree-Regular',
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'You need to pay remaining of ₹${remainingTotal.toInt()}',
//             style: const TextStyle(
//               color: Color(0xFF0C141C),
//               fontSize: 14,
//               fontFamily: 'Manrope-Regular',
//               fontWeight: FontWeight.w400,
//               height: 1.50,
//             ),
//           ),
//
//           // Collapsible content — WRAP item rows with this condition
//           if (isExpanded) ...[
//             // ADD
//             const SizedBox(height: 16),
//             ...itemRows.asMap().entries.map((entry) {
//               final i = entry.key;
//               final item = entry.value;
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (i > 0) ...[
//                     const Divider(color: Color(0xFFCEDBE8)),
//                     const SizedBox(height: 8),
//                   ],
//                   _buildNeedPayItemSection(item),
//                 ],
//               );
//             }),
//           ], // ADD
//         ],
//       ),
//     );
//   }
//
//   // ─── SINGLE ITEM SECTION ────────────────────────────────────
//
//   Widget _buildNeedPayItemSection(_NeedPayItem item) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Item label + base amount
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: ShapeDecoration(
//                     color: item.color,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   item.label,
//                   style: const TextStyle(
//                     color: Color(0xFF0C141C),
//                     fontSize: 12,
//                     fontFamily: 'Manrope-Regular',
//                     fontWeight: FontWeight.w400,
//                     height: 1.75,
//                   ),
//                 ),
//               ],
//             ),
//             Text(
//               '₹${item.baseAmount.toInt()}',
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 color: Color(0xFF0C141C),
//                 fontSize: 14,
//                 fontFamily: 'Manrope-Regular',
//                 fontWeight: FontWeight.w400,
//                 height: 1.50,
//               ),
//             ),
//           ],
//         ),
//
//         const SizedBox(height: 12),
//
//         // Dashed divider
//         Row(
//           children: List.generate(
//             150 ~/ 3,
//                 (index) => Expanded(
//               child: Container(
//                 color: index % 1.5 == 0
//                     ? const Color(0xFFCEDBE8)
//                     : Colors.transparent,
//                 height: 1,
//               ),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12),
//
//         // Convenience fee (only if non-zero)
//         if ((item.fees['convenience'] ?? 0) > 0)
//           _feeRow(
//             'Convenience fee',
//             '₹${(item.fees['convenience']!.round() ?? 0).toInt()}',
//           ),
//
//         // Platform fee (only if non-zero)
//         if ((item.fees['platform'] ?? 0) > 0)
//           _feeRow(
//             'Platform fee',
//             '₹${(item.fees['platform']!.round() ?? 0).toInt()}',
//           ),
//
//         // GST – always show, label reflects actual %
//         _feeRow(
//           'GST ${_gstPercent.toInt()}% of all the line item',
//           '₹${(item.fees['gst']!.round() ?? 0).toInt()}',
//         ),
//
//         const SizedBox(height: 8),
//
//         // Total
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'TOTAL',
//               style: TextStyle(
//                 color: Color(0xFF0C141C),
//                 fontSize: 12,
//                 fontFamily: 'Manrope-Regular',
//                 fontWeight: FontWeight.w400,
//                 height: 1.75,
//               ),
//             ),
//             Text(
//               '₹${(item.fees['total']!.round() ?? 0).toInt()}',
//               style: const TextStyle(
//                 color: Color(0xFF0C141C),
//                 fontSize: 14,
//                 fontFamily: 'Manrope-Medium',
//                 fontWeight: FontWeight.w700,
//                 height: 1.50,
//               ),
//             ),
//           ],
//         ),
//
//         const SizedBox(height: 8),
//       ],
//     );
//   }
//
//   // ─── FEE ROW ────────────────────────────────────────────────
//
//   Widget _feeRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF49545C),
//               fontSize: 10,
//               fontFamily: 'Lato-Regular',
//               fontWeight: FontWeight.w500,
//               height: 2,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Color(0xFF183954),
//               fontSize: 14,
//               fontFamily: 'Lato-Regular',
//               fontWeight: FontWeight.w400,
//               height: 1.43,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build combined service payments log (place_order + plan)
//   Widget _buildCombinedServicePaymentsLog(
//       String title,
//       String type,
//       List<dynamic> servicePayments,
//       double totalPaid,
//       double totalBase,
//       bool isExpanded,
//       VoidCallback onToggle,
//       ) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(10),
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with expand/collapse button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Color(0xFF183954),
//                   fontSize: 14,
//                   fontFamily: 'Figtree-Medium',
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onToggle,
//                 child: Icon(
//                   isExpanded
//                       ? Icons.keyboard_arrow_up
//                       : Icons.keyboard_arrow_down,
//                   color: const Color(0xFF183954),
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             type,
//             style: const TextStyle(
//               color: Color(0xFF98A1B2),
//               fontSize: 10,
//               fontFamily: 'Figtree',
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You have paid ₹${totalPaid.toInt()} of ₹${totalBase.toInt()}',
//             style: const TextStyle(
//               color: Color(0xFF0C141C),
//               fontSize: 14,
//               fontFamily: 'Manrope-regular',
//               fontWeight: FontWeight.w400,
//               height: 1.50,
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Progress bar for service payments
//           SliderTheme(
//             data: SliderThemeData(
//               trackHeight: 8,
//               thumbShape: const RoundSliderThumbShape(
//                 enabledThumbRadius: 0,
//                 disabledThumbRadius: 0,
//               ),
//               overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
//               activeTrackColor: getTrackColor(
//                 totalBase > 0 ? (totalPaid / totalBase) * 100 : 0,
//               ),
//               disabledActiveTrackColor: getTrackColor(
//                 totalBase > 0 ? (totalPaid / totalBase) * 100 : 0,
//               ),
//               inactiveTrackColor: const Color(0xFFCEDBE8),
//               disabledInactiveTrackColor: const Color(0xFFCEDBE8),
//               trackShape: const RoundedRectSliderTrackShape(),
//             ),
//             child: Slider(
//               value: (totalBase > 0 ? ((totalPaid / totalBase) * 100) : 0.0)
//                   .clamp(0.0, 100.0),
//               min: 0,
//               max: 100,
//               onChanged: null,
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Collapsible content
//           if (isExpanded)
//           // Iterate through each service payment
//             ...servicePayments.asMap().entries.map((entry) {
//               int paymentIndex = entry.key;
//               var payment = entry.value;
//
//               String paymentDate = _formatPaymentDate(payment.paymentDate);
//               List<dynamic> paymentDataList = _parsePaymentData(
//                 payment.paymentData,
//               );
//
//               // Get title from payment_data array if available, otherwise use notes
//               String displayTitle = '';
//               if (paymentDataList.isNotEmpty && paymentDataList[0] is Map) {
//                 displayTitle =
//                     paymentDataList[0]['title'] ?? payment.notes ?? '';
//               } else {
//                 displayTitle = payment.notes ?? '';
//               }
//
//               double baseAmount =
//                   double.tryParse(payment.baseAmount?.toString() ?? '0') ?? 0.0;
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Show payment date at the top of each payment section
//                   if (paymentIndex > 0) const SizedBox(height: 16),
//
//                   Text(
//                     paymentDate,
//                     style: const TextStyle(
//                       color: Color(0xFF183954),
//                       fontSize: 10,
//                       fontFamily: 'Manrope-regular',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Payment Note/Description (using title from payment_data)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 12,
//                           height: 12,
//                           decoration: ShapeDecoration(
//                             color: _getColorForPaymentType(payment.paymentType),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             displayTitle,
//                             style: const TextStyle(
//                               color: Color(0xFF0C141C),
//                               fontSize: 12,
//                               fontFamily: 'Manrope-regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.75,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '₹${baseAmount.toInt()}',
//                           textAlign: TextAlign.right,
//                           style: const TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 14,
//                             fontFamily: 'Manrope-regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.50,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Divider
//                   Row(
//                     children: List.generate(
//                       150 ~/ 3,
//                           (index) => Expanded(
//                         child: Container(
//                           color: index % 1.5 == 0
//                               ? const Color(0xFFCEDBE8)
//                               : Colors.transparent,
//                           height: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Fees
//                   if (payment.convenienceFeeCost != "0.00")
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Convenience Fee',
//                               style: TextStyle(
//                                 color: Color(0xFF49545C),
//                                 fontSize: 10,
//                                 fontFamily: 'Lato-Regular',
//                                 fontWeight: FontWeight.w500,
//                                 height: 2,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '₹${(double.tryParse(payment.convenienceFeeCost?.toString() ?? '0') ?? 0).toInt()}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Color(0xFF183954),
//                               fontSize: 14,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.43,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (payment.platformCost != "0.00")
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 5),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Platform Fee',
//                               style: TextStyle(
//                                 color: Color(0xFF49545C),
//                                 fontSize: 10,
//                                 fontFamily: 'Lato-Regular',
//                                 fontWeight: FontWeight.w500,
//                                 height: 2,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '₹${(double.tryParse(payment.platformCost?.toString() ?? '0') ?? 0).toInt()}',
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Color(0xFF183954),
//                               fontSize: 14,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w400,
//                               height: 1.43,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'GST 18% of all the line item',
//                             style: TextStyle(
//                               color: Color(0xFF49545C),
//                               fontSize: 10,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w500,
//                               height: 2,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '₹${(double.tryParse(payment.taxCost?.toString() ?? '0') ?? 0).toInt()}',
//                           textAlign: TextAlign.right,
//                           style: const TextStyle(
//                             color: Color(0xFF183954),
//                             fontSize: 14,
//                             fontFamily: 'Lato-Regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.43,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Total
//                   Row(
//                     children: [
//                       const Expanded(
//                         child: Text(
//                           'TOTAL',
//                           style: TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 12,
//                             fontFamily: 'Manrope-regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.75,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '₹${(double.tryParse(payment.paymentAmount?.toString() ?? '0') ?? 0).toInt()}',
//                         style: const TextStyle(
//                           color: Color(0xFF0C141C),
//                           fontSize: 14,
//                           fontFamily: 'Manrope-regular',
//                           fontWeight: FontWeight.w700,
//                           height: 1.50,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Order placed date
//                   Text(
//                     paymentDate,
//                     style: const TextStyle(
//                       color: Color(0xFF696F76),
//                       fontSize: 8,
//                       fontFamily: 'Manrope-regular',
//                       fontWeight: FontWeight.w600,
//                       height: 2.63,
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//                   // Download Invoice
//                   Center(
//                     child: GestureDetector(
//                       onTap: () async {
//                         final url = invoiceUrl.isNotEmpty
//                             ? '$invoiceUrl${payment.orderId}/${payment.id}'
//                             : '';
//                         if (url.isEmpty) {
//                           debugPrint('Invoice URL not available');
//                           return;
//                         }
//                         final uri = Uri.parse(url);
//                         if (await canLaunchUrl(uri)) {
//                           await launchUrl(
//                             uri,
//                             mode: LaunchMode.externalApplication,
//                           );
//                         } else {
//                           debugPrint('Could not launch invoice URL: $url');
//                         }
//                       },
//                       child: const Text(
//                         'Download Invoice',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Color(0xFF696F76),
//                           fontSize: 8,
//                           fontFamily: 'Manrope-regular',
//                           fontWeight: FontWeight.w700,
//                           decoration: TextDecoration.underline,
//                           height: 2.63,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               );
//             }),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//         ),
//         shadows: [
//           BoxShadow(
//             color: Color(0x664C7299),
//             blurRadius: 54,
//             offset: Offset(0, -6),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         controller: widget.scrollController,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Column(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 24),
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE0E0E0),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Dynamic Payment Summary Section
//               if (materialPaymentHistory.isNotEmpty ||
//                   servicePaymentHistory.isNotEmpty)
//                 Column(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(height: 24),
//                         const Text(
//                           'View Payments',
//                           style: TextStyle(
//                             color: Color(0xFF183954),
//                             fontSize: 20,
//                             fontFamily: 'Figtree-Medium',
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const Text(
//                           'Below are the list of materials which is needed',
//                           style: TextStyle(
//                             color: Color(0xFF0C141C),
//                             fontSize: 12,
//                             fontFamily: 'Figtree-Regular',
//                             fontWeight: FontWeight.w400,
//                             height: 1.32,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         // Payment Summary Card
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(12),
//                           decoration: ShapeDecoration(
//                             color: const Color(0xFFF7F9FC),
//                             shape: RoundedRectangleBorder(
//                               side: const BorderSide(
//                                 width: 1,
//                                 color: Color(0xFFCEDBE8),
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: ShapeDecoration(
//                                   color: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Payment Summary',
//                                       style: TextStyle(
//                                         color: Color(0xFF183954),
//                                         fontSize: 18,
//                                         fontFamily: 'Figtree-Medium',
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//
//                                     const Text(
//                                       'Over all summary Inc. of Tax & fee | Inc. of Material Procurement',
//                                       style: TextStyle(
//                                         color: Color(0xFF98A1B2),
//                                         fontSize: 10,
//                                         fontFamily: 'Figtree-Regular',
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     Text.rich(
//                                       TextSpan(
//                                         children: [
//                                           const TextSpan(
//                                             text: 'You have paid ',
//                                             style: TextStyle(
//                                               color: Color(0xFF0C141C),
//                                               fontSize: 14,
//                                               fontFamily: 'Manrope-regular',
//                                               fontWeight: FontWeight.w400,
//                                               height: 1.50,
//                                             ),
//                                           ),
//                                           TextSpan(
//                                             text:
//                                             '₹${totalPaidAmount.toInt()} ',
//                                             style: const TextStyle(
//                                               color: Color(0xFF0C141C),
//                                               fontSize: 14,
//                                               fontFamily: 'Manrope-medium',
//                                               fontWeight: FontWeight.w700,
//                                               height: 1.50,
//                                             ),
//                                           ),
//                                           const TextSpan(
//                                             text: 'of ',
//                                             style: TextStyle(
//                                               color: Color(0xFF0C141C),
//                                               fontSize: 14,
//                                               fontFamily: 'Manrope-medium',
//                                               fontWeight: FontWeight.w400,
//                                               height: 1.50,
//                                             ),
//                                           ),
//                                           TextSpan(
//                                             text: '₹${totalAmount.toInt()}',
//                                             style: const TextStyle(
//                                               color: Color(0xFF0C141C),
//                                               fontSize: 14,
//                                               fontFamily: 'Manrope-medium',
//                                               fontWeight: FontWeight.w700,
//                                               height: 1.50,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     // Progress Bar - Dynamic Value
//                                     SliderTheme(
//                                       data: SliderThemeData(
//                                         trackHeight: 8,
//                                         thumbShape: const RoundSliderThumbShape(
//                                           enabledThumbRadius: 0,
//                                           disabledThumbRadius: 0,
//                                         ),
//                                         overlayShape:
//                                         const RoundSliderOverlayShape(
//                                           overlayRadius: 0,
//                                         ),
//                                         activeTrackColor: getTrackColor(
//                                           sliderValue,
//                                         ),
//                                         disabledActiveTrackColor: getTrackColor(
//                                           sliderValue,
//                                         ),
//                                         inactiveTrackColor: const Color(
//                                           0xFFCEDBE8,
//                                         ),
//                                         disabledInactiveTrackColor: const Color(
//                                           0xFFCEDBE8,
//                                         ),
//                                         trackShape:
//                                         const RoundedRectSliderTrackShape(),
//                                       ),
//                                       child: Slider(
//                                         value: sliderValue.clamp(0.0, 100.0),
//                                         min: 0,
//                                         max: 100,
//                                         onChanged: null,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                   ],
//                                 ),
//                               ),
//
//                               const SizedBox(height: 12),
//
//                               // Consolidated Activity Logs
//                               ..._buildConsolidatedActivityLogs(),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 44),
//
//                         needPaymentActivityLog(),
//                       ],
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatPaymentDate(dynamic dateValue) {
//     if (dateValue == null) return 'Date unavailable';
//
//     try {
//       DateTime date;
//       String dateString = dateValue.toString();
//
//       if (dateString.isEmpty) return 'Date unavailable';
//
//       dateString = dateString.replaceAll('"', '').trim();
//
//       if (dateString.contains('T')) {
//         date = DateTime.parse(dateString).toLocal();
//       } else if (dateString.contains('-')) {
//         date = DateTime.parse(dateString);
//       } else {
//         int? timestamp = int.tryParse(dateString);
//         if (timestamp != null) {
//           date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
//         } else {
//           return 'Date unavailable';
//         }
//       }
//
//       int hour = date.hour;
//       int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//       String period = hour >= 12 ? 'PM' : 'AM';
//
//       return '${date.day} ${_getMonthName(date.month)} ${date.year}, $displayHour:${date.minute.toString().padLeft(2, '0')}$period';
//     } catch (e) {
//       print('Error formatting date: $e');
//       return 'Date unavailable';
//     }
//   }
//
//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }
//
//   Color _getColorForPaymentType(String? paymentType) {
//     switch (paymentType) {
//       case 'place_order':
//         return const Color(0xFFE8943A); // Orange
//       case 'plan':
//         return const Color(0xFF329537); // Green
//       case 'material':
//         return const Color(0xFF1B527E); // Blue
//       default:
//         return const Color(0xFFE53935); // Red
//     }
//   }
// }
//
// class MilestoneItem {
//   final String title;
//   final String days;
//   final String status;
//   final String planId;
//   final Color statusColor;
//   final Color dotColor;
//   final String? imageUrl;
//   final String? amount;
//   final String? description;
//   late String? comments;
//   bool isExpanded;
//
//   MilestoneItem({
//     required this.title,
//     required this.days,
//     required this.status,
//     required this.statusColor,
//     required this.dotColor,
//     required this.planId,
//     this.imageUrl,
//     this.amount,
//     this.description,
//     this.comments,
//     this.isExpanded = false,
//   });
// }
//
// class ExpandableMilestoneWidget extends StatefulWidget {
//   final List<MilestoneItem> milestones;
//   final VoidCallback? onReplan;
//   final Function(MilestoneItem)? onPayMilestone;
//   final Future<void> Function()? onRefresh; // CHANGED: Now returns Future<void>
//
//   const ExpandableMilestoneWidget({
//     super.key,
//     required this.milestones,
//     this.onReplan,
//     this.onPayMilestone,
//     this.onRefresh,
//   });
//
//   @override
//   State<ExpandableMilestoneWidget> createState() =>
//       _ExpandableMilestoneWidgetState();
// }
//
// class _ExpandableMilestoneWidgetState extends State<ExpandableMilestoneWidget> {
//   Map<int, bool> milestoneExpandedStates = {};
//   bool isMilestoneVerifying = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Opacity(
//       opacity: 0.90,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(10),
//         decoration: ShapeDecoration(
//           color: const Color(0xFFEFF3F6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Container
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: ShapeDecoration(
//                 color: const Color(0xFFF7FAFC),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         "NEXT STEP: ",
//                         style: TextStyle(
//                           color: Color(0xFF329537),
//                           fontSize: 10,
//                           fontFamily: 'Figtree-Medium',
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         "Milestones",
//                         style: TextStyle(
//                           color: Color(0xFF183954),
//                           fontSize: 18,
//                           fontFamily: 'Figtree-Medium',
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // InkWell(
//                   //   onTap: widget.onReplan,
//                   //   child: Row(
//                   //     mainAxisSize: MainAxisSize.min,
//                   //     children: const [
//                   //       Text(
//                   //         'Replan',
//                   //         style: TextStyle(
//                   //           color: Color(0xFF183954),
//                   //           fontSize: 16,
//                   //           fontFamily: 'Figtree-Regular',
//                   //           fontWeight: FontWeight.w600,
//                   //           height: 1.50,
//                   //         ),
//                   //       ),
//                   //       SizedBox(width: 8),
//                   //       HugeIcon(
//                   //         icon: HugeIcons.strokeRoundedPencilEdit02,
//                   //         size: 20.0,
//                   //         color: AppConfig.primaryColor,
//                   //         strokeWidth: 1.5,
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Milestones List
//             ...widget.milestones.asMap().entries.map((entry) {
//               final index = entry.key;
//               final milestone = entry.value;
//               final isLast = index == widget.milestones.length - 1;
//
//               return _buildExpandableMilestone(milestone, isLast: isLast);
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExpandableMilestone(
//       MilestoneItem milestone, {
//         required bool isLast,
//       }) {
//     // Check if this milestone has expandable content
//     final bool hasExpandableContent = _hasExpandableContent(milestone);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: hasExpandableContent
//               ? () {
//             setState(() {
//               milestone.isExpanded = !milestone.isExpanded;
//             });
//           }
//               : null,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Left side: Icon and line
//               Column(
//                 children: [
//                   Container(
//                     width: 16,
//                     height: 16,
//                     decoration: ShapeDecoration(
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(
//                           width: 1,
//                           color: milestone.status == "Completed"
//                               ? const Color(0xFF24CA35)
//                               : const Color(0xFFE9EBED),
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: milestone.status == "Completed"
//                         ? const Icon(
//                       Icons.check,
//                       size: 12,
//                       color: Color(0xFF24CA35),
//                     )
//                         : Center(
//                       child: Container(
//                         width: 6,
//                         height: 6,
//                         decoration: ShapeDecoration(
//                           color: milestone.dotColor,
//                           shape: const OvalBorder(),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (!isLast)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 0, bottom: 0),
//                       child: CustomPaint(
//                         size: Size(
//                           0,
//                           milestone.isExpanded && isLast ? 500 : 30,
//                         ),
//                         painter: DottedLinePainter(),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(width: 8),
//
//               // Right side: Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             milestone.title,
//                             style: TextStyle(
//                               color: const Color(0xFF49545C),
//                               fontSize: 14,
//                               fontFamily: 'Lato-Regular',
//                               fontWeight: FontWeight.w500,
//                               decoration: hasExpandableContent
//                                   ? TextDecoration.underline
//                                   : TextDecoration.none,
//                               height: 1.43,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           "${milestone.days} ${"days"}",
//                           style: const TextStyle(
//                             color: Color(0xFF49545C),
//                             fontSize: 13,
//                             fontFamily: 'Lato-Regular',
//                             fontWeight: FontWeight.w500,
//                             height: 1.43,
//                           ),
//                         ),
//                         const SizedBox(width: 15),
//                         _buildStatusBadge(
//                           milestone.status,
//                           milestone.statusColor,
//                         ),
//                         if (milestone.status == 'Need Payment' &&
//                             (milestone.amount != "0.00" &&
//                                 milestone.amount != "" &&
//                                 milestone.amount != null)) ...[
//                           const SizedBox(width: 8),
//                           GestureDetector(
//                             onTap: () {
//                               print(milestone.amount);
//                               if (widget.onPayMilestone != null) {
//                                 widget.onPayMilestone!(milestone);
//                               }
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF329537),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: const Text(
//                                 'Pay Now',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontFamily: 'Figtree-Medium',
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//
//                     // Expanded content
//                     if (milestone.isExpanded &&
//                         (isLast || hasExpandableContent)) ...[
//                       const SizedBox(height: 16),
//
//                       // Parse and display updates (images + comments grouped together)
//                       Builder(
//                         builder: (context) {
//                           List<MilestoneUpdate> updates = _parseUpdates(
//                             milestone,
//                           );
//
//                           if (updates.isEmpty) {
//                             return const SizedBox.shrink();
//                           }
//
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Updates',
//                                 style: TextStyle(
//                                   color: Color(0xFF183954),
//                                   fontSize: 16,
//                                   fontFamily: 'Figtree-Medium',
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//
//                               // Display each update
//                               ...updates.asMap().entries.map((entry) {
//                                 final updateIndex = entry.key;
//                                 final update = entry.value;
//                                 return _buildUpdateCard(
//                                   update,
//                                   updateIndex + 1,
//                                 );
//                               }).toList(),
//                             ],
//                           );
//                         },
//                       ),
//
//                       // Accept/Reject buttons for Verify status
//                       // if (milestone.status == 'Need Verify') ...[
//                       if (milestone.isExpanded &&
//                           isLast &&
//                           milestone.status == 'Need Verify') ...[
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: SizedBox(
//                                 height: 40,
//                                 child: ElevatedButton(
//                                   onPressed: isMilestoneVerifying
//                                       ? null
//                                       : () {
//                                     _verifyMilestone(milestone.planId);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFF1A202C),
//                                     foregroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: isMilestoneVerifying
//                                       ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                       : const Text(
//                                     'Verify',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontFamily: 'Figtree-Medium',
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Parse updates from milestone data
//   List<MilestoneUpdate> _parseUpdates(MilestoneItem milestone) {
//     List<MilestoneUpdate> updates = [];
//
//     // Parse image URLs
//     List<List<String>> imageSets = [];
//     if (milestone.imageUrl != null && milestone.imageUrl!.isNotEmpty) {
//       try {
//         var decoded = jsonDecode(milestone.imageUrl!);
//         if (decoded is List) {
//           for (var item in decoded) {
//             if (item is List) {
//               // It's already a list of URLs
//               imageSets.add(item.map((e) => e.toString()).toList());
//             } else if (item is String) {
//               // Single URL
//               imageSets.add([item]);
//             }
//           }
//         }
//       } catch (e) {
//         print('Error parsing image URLs: $e');
//         // Try parsing as single URL or comma-separated
//         String imageString = milestone.imageUrl!;
//         if (imageString.startsWith('http')) {
//           imageSets.add([imageString]);
//         }
//       }
//     }
//
//     // Parse comments
//     List<String> comments = [];
//     if (milestone.comments != null && milestone.comments!.isNotEmpty) {
//       try {
//         var decoded = jsonDecode(milestone.comments!);
//         if (decoded is List) {
//           comments = decoded.map((e) => e.toString()).toList();
//         } else if (decoded is String) {
//           comments = [decoded];
//         }
//       } catch (e) {
//         print('Error parsing comments: $e');
//         // Treat as single comment
//         comments = [milestone.comments!];
//       }
//     }
//
//     // Create update objects by pairing images and comments
//     int maxLength = max(imageSets.length, comments.length);
//
//     for (int i = 0; i < maxLength; i++) {
//       updates.add(
//         MilestoneUpdate(
//           images: i < imageSets.length ? imageSets[i] : [],
//           comment: i < comments.length ? comments[i] : '',
//         ),
//       );
//     }
//
//     return updates;
//   }
//
//   // Build individual update card
//   Widget _buildUpdateCard(MilestoneUpdate update, int updateNumber) {
//     bool hasImages = update.images.isNotEmpty;
//     bool hasComment = update.comment.isNotEmpty;
//
//     if (!hasImages && !hasComment) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFCEDBE8), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Update number header
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1B527E).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   'Update #$updateNumber',
//                   style: const TextStyle(
//                     color: Color(0xFF1B527E),
//                     fontSize: 12,
//                     fontFamily: 'Figtree-Medium',
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // Images
//           if (hasImages) ...[
//             const SizedBox(height: 12),
//             Text(
//               '${update.images.length} Photo${update.images.length > 1 ? 's' : ''}',
//               style: const TextStyle(
//                 color: Color(0xFF183954),
//                 fontSize: 13,
//                 fontFamily: 'Figtree-Medium',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: update.images.map((url) {
//                 return GestureDetector(
//                   onTap: () {
//                     // Optional: Show full-screen image viewer
//                     _showImageViewer(context, url);
//                   },
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFCEDBE8),
//                         width: 1,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         url,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             color: const Color(0xFFF7F9FC),
//                             child: const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.image_not_supported,
//                                     color: Color(0xFFCEDBE8),
//                                     size: 30,
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Failed',
//                                     style: TextStyle(
//                                       fontSize: 9,
//                                       color: Color(0xFF49545C),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Container(
//                             color: const Color(0xFFF7F9FC),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 value:
//                                 loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                                     : null,
//                                 color: const Color(0xFF1B527E),
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//
//           // Comment
//           if (hasComment) ...[
//             const SizedBox(height: 12),
//             const Text(
//               'Comment',
//               style: TextStyle(
//                 color: Color(0xFF183954),
//                 fontSize: 13,
//                 fontFamily: 'Figtree-Medium',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF7F9FC),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 update.comment,
//                 style: const TextStyle(
//                   color: Color(0xFF49545C),
//                   fontSize: 12,
//                   fontFamily: 'Lato-Regular',
//                   fontWeight: FontWeight.w400,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // Show full-screen image viewer
//   void _showImageViewer(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: Stack(
//           children: [
//             Center(
//               child: InteractiveViewer(
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Center(
//                       child: Icon(
//                         Icons.error_outline,
//                         color: Colors.white,
//                         size: 50,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 10,
//               right: 10,
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper method to check if milestone has expandable content
//   bool _hasExpandableContent(MilestoneItem milestone) {
//     bool hasImages =
//         milestone.imageUrl != null && milestone.imageUrl!.isNotEmpty;
//     bool hasComments =
//         milestone.comments != null && milestone.comments!.isNotEmpty;
//     return hasImages || hasComments;
//   }
//
//   Future<void> _verifyMilestone(String planId) async {
//     var serviceController = Get.put(ServiceController());
//     if (isMilestoneVerifying) return;
//
//     setState(() {
//       isMilestoneVerifying = true;
//     });
//
//     try {
//       await serviceController.getVerifyMilestone("CustomerupdatePlan", {
//         "plan_id": planId,
//         "status": "13",
//       });
//
//       if (serviceController.verifyDesignsData.value['success'] == true) {
//         setState(() {
//           isMilestoneVerifying = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 SizedBox(width: 12),
//                 Text(
//                   'Milestone verified successfully!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'Figtree-Medium',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: const Color(0xFF038153),
//             duration: const Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//
//         if (widget.onRefresh != null) {
//           await widget.onRefresh!();
//         }
//       } else {
//         setState(() {
//           isMilestoneVerifying = false;
//         });
//
//         Get.snackbar(
//           'Verification Failed',
//           serviceController.verifyDesignsData.value['message'] ??
//               'Failed to verify milestone. Please try again.',
//           backgroundColor: Colors.red.shade100,
//           colorText: Colors.red.shade900,
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       debugPrint("Error in _verifyMilestone: $e");
//       setState(() {
//         isMilestoneVerifying = false;
//       });
//
//       Get.snackbar(
//         'Error',
//         'Something went wrong. Please try again.',
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
//
//   Widget _buildStatusBadge(String text, Color statusColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
//       decoration: ShapeDecoration(
//         color: statusColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//       ),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         textHeightBehavior: const TextHeightBehavior(
//           applyHeightToFirstAscent: false,
//           applyHeightToLastDescent: false,
//         ),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 8,
//           fontFamily: 'Figtree-Regular',
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
// }
//
// // Model class for individual updates
// class MilestoneUpdate {
//   final List<String> images;
//   final String comment;
//
//   MilestoneUpdate({required this.images, required this.comment});
// }
//
// class _NeedPayItem {
//   final Color color;
//   final String label;
//   final double baseAmount;
//   final Map<String, double> fees; // convenience, platform, gst, total
//
//   const _NeedPayItem({
//     required this.color,
//     required this.label,
//     required this.baseAmount,
//     required this.fees,
//   });
// }
