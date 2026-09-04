class CustomerPaymentSummaryModel {
  bool? success;
  String? totalAmount;
  String? totalPaidAmount;
  String? totalMaterialAmount;
  String? totalPlanAmount;
  List<ServicePayment>? servicePayment;
  List<MaterialPayment>? materialPayment;
  String? invoiceUrl;

  CustomerPaymentSummaryModel(
      {this.success,
        this.totalAmount,
        this.totalPaidAmount,
        this.totalMaterialAmount,
        this.totalPlanAmount,
        this.servicePayment,
        this.materialPayment,
        this.invoiceUrl});

  CustomerPaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalAmount = json['TotalAmount'];
    totalPaidAmount = json['TotalPaidAmount'];
    totalMaterialAmount = json['TotalMaterialAmount'];
    totalPlanAmount = json['TotalPlanAmount'];
    if (json['servicePayment'] != null) {
      servicePayment = <ServicePayment>[];
      json['servicePayment'].forEach((v) {
        servicePayment!.add(new ServicePayment.fromJson(v));
      });
    }
    if (json['materialPayment'] != null) {
      materialPayment = <MaterialPayment>[];
      json['materialPayment'].forEach((v) {
        materialPayment!.add(new MaterialPayment.fromJson(v));
      });
    }
    invoiceUrl = json['invoice_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['TotalAmount'] = totalAmount;
    data['TotalPaidAmount'] = totalPaidAmount;
    data['TotalMaterialAmount'] = totalMaterialAmount;
    data['TotalPlanAmount'] = totalPlanAmount;
    if (servicePayment != null) {
      data['servicePayment'] =
          servicePayment!.map((v) => v.toJson()).toList();
    }
    if (materialPayment != null) {
      data['materialPayment'] =
          materialPayment!.map((v) => v.toJson()).toList();
    }
    data['invoice_url'] = invoiceUrl;
    return data;
  }
}

class ServicePayment {
  int? id;
  int? orderId;
  int? customerId;
  String? notes;
  String? currency;
  String? paymentId;
  String? paymentJson;
  String? paymentStatus;
  String? convenienceFeeCost;
  String? baseAmount;
  String? paymentAmount;
  String? paymentDate;
  String? createdAt;
  Null? updatedAt;
  String? paymentData;
  String? paymentType;
  String? platformCost;
  String? taxCost;
  String? totalPaidAmount;

  ServicePayment(
      {this.id,
        this.orderId,
        this.customerId,
        this.notes,
        this.currency,
        this.paymentId,
        this.paymentJson,
        this.paymentStatus,
        this.convenienceFeeCost,
        this.baseAmount,
        this.paymentAmount,
        this.paymentDate,
        this.createdAt,
        this.updatedAt,
        this.paymentData,
        this.paymentType,
        this.platformCost,
        this.taxCost,
        this.totalPaidAmount});

  ServicePayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    notes = json['notes'];
    currency = json['currency'];
    paymentId = json['payment_id'];
    paymentJson = json['payment_json'];
    paymentStatus = json['payment_status'];
    convenienceFeeCost = json['convenience_fee_cost'];
    baseAmount = json['base_amount'];
    paymentAmount = json['payment_amount'];
    paymentDate = json['payment_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    paymentData = json['payment_data'];
    paymentType = json['payment_type'];
    platformCost = json['platform_cost'];
    taxCost = json['tax_cost'];
    totalPaidAmount = json['total_paid_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['notes'] = notes;
    data['currency'] = currency;
    data['payment_id'] = paymentId;
    data['payment_json'] = paymentJson;
    data['payment_status'] = paymentStatus;
    data['convenience_fee_cost'] = convenienceFeeCost;
    data['base_amount'] = baseAmount;
    data['payment_amount'] = paymentAmount;
    data['payment_date'] = paymentDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['payment_data'] = paymentData;
    data['payment_type'] = paymentType;
    data['platform_cost'] = platformCost;
    data['tax_cost'] = taxCost;
    data['total_paid_amount'] = totalPaidAmount;
    return data;
  }
}
class MaterialPayment {
  int? id;
  int? orderId;
  int? customerId;
  String? notes;
  String? currency;
  String? paymentId;
  String? paymentJson;
  String? paymentStatus;
  String? convenienceFeeCost;
  String? baseAmount;
  String? paymentAmount;
  String? paymentDate;
  String? createdAt;
  Null? updatedAt;
  String? paymentData;
  String? paymentType;
  String? platformCost;
  String? taxCost;
  String? totalPaidAmount;

  MaterialPayment(
      {this.id,
        this.orderId,
        this.customerId,
        this.notes,
        this.currency,
        this.paymentId,
        this.paymentJson,
        this.paymentStatus,
        this.convenienceFeeCost,
        this.baseAmount,
        this.paymentAmount,
        this.paymentDate,
        this.createdAt,
        this.updatedAt,
        this.paymentData,
        this.paymentType,
        this.platformCost,
        this.taxCost,
        this.totalPaidAmount});

  MaterialPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    notes = json['notes'];
    currency = json['currency'];
    paymentId = json['payment_id'];
    paymentJson = json['payment_json'];
    paymentStatus = json['payment_status'];
    convenienceFeeCost = json['convenience_fee_cost'];
    baseAmount = json['base_amount'];
    paymentAmount = json['payment_amount'];
    paymentDate = json['payment_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    paymentData = json['payment_data'];
    paymentType = json['payment_type'];
    platformCost = json['platform_cost'];
    taxCost = json['tax_cost'];
    totalPaidAmount = json['total_paid_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['notes'] = notes;
    data['currency'] = currency;
    data['payment_id'] = paymentId;
    data['payment_json'] = paymentJson;
    data['payment_status'] = paymentStatus;
    data['convenience_fee_cost'] = convenienceFeeCost;
    data['base_amount'] = baseAmount;
    data['payment_amount'] = paymentAmount;
    data['payment_date'] = paymentDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['payment_data'] = paymentData;
    data['payment_type'] = paymentType;
    data['platform_cost'] = platformCost;
    data['tax_cost'] = taxCost;
    data['total_paid_amount'] = totalPaidAmount;
    return data;
  }
}
