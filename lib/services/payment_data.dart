class PaymentData {
  final double amount;
  final String name;
  final String description;
  final String? orderId;
  final String prefillContact;
  final String prefillEmail;
  final Map<String, dynamic>? notes;

  PaymentData({
    required this.amount,
    this.name = 'Vayil',
    required this.description,
    this.orderId,
    this.prefillContact = '',
    this.prefillEmail = '',
    this.notes,
  });

  // Factory constructor for your bucket list payment
  factory PaymentData.bucketList({
    required double total,
    required String serviceName,
    required String vendorName,
    String? pricePerSqft,
  }) {
    return PaymentData(
      amount: total,
      description: serviceName,
      notes: {
        'service': serviceName,
        'vendor': vendorName,
        if (pricePerSqft != null) 'price_per_sqft': pricePerSqft,
      },
    );
  }

  // Factory constructor for other payments
  factory PaymentData.service({
    required double amount,
    required String serviceName,
    Map<String, dynamic>? additionalNotes,
  }) {
    return PaymentData(
      amount: amount,
      description: serviceName,
      notes: additionalNotes,
    );
  }
}