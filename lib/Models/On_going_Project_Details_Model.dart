class OngoingProjectDetailsModel {
  bool? success;
  String? message;
  List<Steps>? steps;
  List<Ordermaterials>? ordermaterials;
  List<OrdersMain>? ordersMain;
  List<Data>? data;  List<Review>? review;

  OngoingProjectDetailsModel(
      {this.success,
        this.message,
        this.steps,
        this.ordermaterials,
        this.ordersMain,
        this.data,this.review});

  OngoingProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(new Steps.fromJson(v));
      });
    }
    if (json['ordermaterials'] != null) {
      ordermaterials = <Ordermaterials>[];
      json['ordermaterials'].forEach((v) {
        ordermaterials!.add(new Ordermaterials.fromJson(v));
      });
    }
    if (json['ordersMain'] != null) {
      ordersMain = <OrdersMain>[];
      json['ordersMain'].forEach((v) {
        ordersMain!.add(new OrdersMain.fromJson(v));
      });
    }
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    if (json['review'] != null) {
      review = <Review>[];
      json['review'].forEach((v) {
        review!.add(new Review.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    if (ordermaterials != null) {
      data['ordermaterials'] =
          ordermaterials!.map((v) => v.toJson()).toList();
    }
    if (ordersMain != null) {
      data['ordersMain'] = ordersMain!.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (review != null) {
      data['review'] = review!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Steps {
  int? id;
  int? orderId;
  int? step;
  String? stepStatus;
  String? performedBy;
  int? performedById;
  String? remarks;
  String? createdAt;
  String? updatedAt;

  Steps(
      {this.id,
        this.orderId,
        this.step,
        this.stepStatus,
        this.performedBy,
        this.performedById,
        this.remarks,
        this.createdAt,
        this.updatedAt});

  Steps.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    step = json['step'];
    stepStatus = json['step_status'];
    performedBy = json['performed_by'];
    performedById = json['performed_by_id'];
    remarks = json['remarks'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['step'] = step;
    data['step_status'] = stepStatus;
    data['performed_by'] = performedBy;
    data['performed_by_id'] = performedById;
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Ordermaterials {
  int? id;
  int? orderId;
  String? planId;
  String? title;
  String? unitType;
  String? qty;
  String? unitCost;
  String? totalCost;
  String? balanceCost;
  String? paymentStatus;
  String? status;
  String? createdAt;
  String? updatedAt;

  Ordermaterials(
      {this.id,
        this.orderId,
        this.planId,
        this.title,
        this.unitType,
        this.qty,
        this.unitCost,
        this.totalCost,
        this.balanceCost,
        this.paymentStatus,
        this.status,
        this.createdAt,
        this.updatedAt});

  Ordermaterials.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    planId = json['plan_id'];
    title = json['title'];
    unitType = json['unit_type'];
    qty = json['qty'];
    unitCost = json['unit_cost'];
    totalCost = json['total_cost'];
    balanceCost = json['balance_cost'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['plan_id'] = planId;
    data['title'] = title;
    data['unit_type'] = unitType;
    data['qty'] = qty;
    data['unit_cost'] = unitCost;
    data['total_cost'] = totalCost;
    data['balance_cost'] = balanceCost;
    data['payment_status'] = paymentStatus;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OrdersMain {
  int? id;
  int? serviceId;
  int? vendorId;
  int? customerId;
  String? companyName;
  String? serviceTitle;
  String? price;
  String? unitName;
  String? pricingType;
  String? description;
  String? serviceImage;
  String? minimumFee;

  OrdersMain(
      {this.id,
        this.serviceId,
        this.vendorId,
        this.customerId,
        this.companyName,
        this.serviceTitle,
        this.price,
        this.unitName,
        this.pricingType,
        this.description,
        this.serviceImage,
        this.minimumFee});

  OrdersMain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    companyName = json['company_name'];
    serviceTitle = json['service_title'];
    price = json['price'];
    unitName = json['unit_name'];
    pricingType = json['pricing_type'];
    description = json['description'];
    serviceImage = json['service_image'];
    minimumFee = json['minimum_fee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['vendor_id'] = vendorId;
    data['customer_id'] = customerId;
    data['company_name'] = companyName;
    data['service_title'] = serviceTitle;
    data['price'] = price;
    data['unit_name'] = unitName;
    data['pricing_type'] = pricingType;
    data['description'] = description;
    data['service_image'] = serviceImage;
    data['minimum_fee'] = minimumFee;
    return data;
  }
}

class Data {
  int? id;
  int? orderId;
  String? title;
  String? amount;
  String? completionDays;
  String? balanceCost;
  String? updatedAt;
  String? updatePhoto;
  String? updateComments;
  int? status;
  String? createdAt;

  Data(
      {this.id,
        this.orderId,
        this.title,
        this.amount,
        this.completionDays,
        this.balanceCost,
        this.updatedAt,
        this.updatePhoto,
        this.updateComments,
        this.status,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    title = json['title'];
    amount = json['amount'];
    completionDays = json['completion_days'];
    balanceCost = json['balance_cost'];
    updatedAt = json['updated_at'];
    updatePhoto = json['update_photo'];
    updateComments = json['update_comments'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['title'] = title;
    data['amount'] = amount;
    data['completion_days'] = completionDays;
    data['balance_cost'] = balanceCost;
    data['updated_at'] = updatedAt;
    data['update_photo'] = updatePhoto;
    data['update_comments'] = updateComments;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}


class Review {
  int? id;
  int? orderId;
  int? customerId;
  int? vendorId;
  int? serviceId;
  int? rating;
  String? reviewDescription;
  int? status;
  String? createdAt;
  Null? updatedAt;
  String? customerName;

  Review(
      {this.id,
        this.orderId,
        this.customerId,
        this.vendorId,
        this.serviceId,
        this.rating,
        this.reviewDescription,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.customerName});

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    serviceId = json['service_id'];
    rating = json['rating'];
    reviewDescription = json['review_description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customerName = json['customer_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['service_id'] = serviceId;
    data['rating'] = rating;
    data['review_description'] = reviewDescription;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['customer_name'] = customerName;
    return data;
  }
}