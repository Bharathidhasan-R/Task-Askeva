class EnquireListAndOngoingListModel {
  bool? success;
  List<Data>? data;

  EnquireListAndOngoingListModel({this.success, this.data});

  EnquireListAndOngoingListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? enquiryId;
  int? customerId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? message;
  String? files;
  int? status;
  String? createdAt;
  int? serviceId;
  int? vendorId;
  String? statusName;
  String? companyName;
  String? serviceTitle;
  String? price;
  String? unitName;
  String? pricingType;
  String? description;
  String? serviceImage;
  List<Quotations>? quotations;
  List<Orders>? orders;

  Data(
      {this.enquiryId,
        this.customerId,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.message,
        this.files,
        this.status,
        this.createdAt,
        this.serviceId,
        this.vendorId,
        this.statusName,
        this.companyName,
        this.serviceTitle,
        this.price,
        this.unitName,
        this.pricingType,
        this.description,
        this.serviceImage,
        this.quotations,
        this.orders});

  Data.fromJson(Map<String, dynamic> json) {
    enquiryId = json['enquiry_id'];
    customerId = json['customer_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    message = json['message'];
    files = json['files'];
    status = json['status'];
    createdAt = json['created_at'];
    serviceId = json['service_id'];
    vendorId = json['vendor_id'];
    statusName = json['status_name'];
    companyName = json['company_name'];
    serviceTitle = json['service_title'];
    price = json['price'];
    unitName = json['unit_name'];
    pricingType = json['pricing_type'];
    description = json['description'];
    serviceImage = json['service_image'];
    if (json['quotations'] != null) {
      quotations = <Quotations>[];
      json['quotations'].forEach((v) {
        quotations!.add(Quotations.fromJson(v));
      });
    }
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['enquiry_id'] = enquiryId;
    data['customer_id'] = customerId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['message'] = message;
    data['files'] = files;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['service_id'] = serviceId;
    data['vendor_id'] = vendorId;
    data['status_name'] = statusName;
    data['company_name'] = companyName;
    data['service_title'] = serviceTitle;
    data['price'] = price;
    data['unit_name'] = unitName;
    data['pricing_type'] = pricingType;
    data['description'] = description;
    data['service_image'] = serviceImage;
    if (quotations != null) {
      data['quotations'] = quotations!.map((v) => v.toJson()).toList();
    }
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Quotations {
  int? id;
  int? enquiryId;
  int? customerId;
  String? message;
  String? files;
  String? amount;
  int? status;
  String? createdAt;
  String? statusName;
  String? companyName;

  Quotations(
      {this.id,
        this.enquiryId,
        this.customerId,
        this.message,
        this.files,
        this.amount,
        this.status,
        this.createdAt,
        this.statusName,
        this.companyName});

  Quotations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enquiryId = json['enquiry_id'];
    customerId = json['customer_id'];
    message = json['message'];
    files = json['files'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
    statusName = json['status_name'];
    companyName = json['company_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['enquiry_id'] = enquiryId;
    data['customer_id'] = customerId;
    data['message'] = message;
    data['files'] = files;
    data['amount'] = amount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['status_name'] = statusName;
    data['company_name'] = companyName;
    return data;
  }
}

class Orders {
  int? id;
  int? enquiryId;
  String? paymentStatus;
  List<Ordersteps>? ordersteps;

  Orders({this.id, this.enquiryId, this.paymentStatus,this.ordersteps});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enquiryId = json['enquiry_id'];
    paymentStatus = json['payment_status'];
    if (json['ordersteps'] != null) {
      ordersteps = <Ordersteps>[];
      json['ordersteps'].forEach((v) {
        ordersteps!.add(Ordersteps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['enquiry_id'] = enquiryId;
    data['payment_status'] = paymentStatus;
    if (ordersteps != null) {
      data['ordersteps'] = ordersteps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Ordersteps {
  int? id;
  int? orderId;
  int? step;
  String? stepStatus;
  String? performedBy;
  int? performedById;
  String? remarks;
  String? createdAt;
  String? updatedAt;

  Ordersteps(
      {this.id,
        this.orderId,
        this.step,
        this.stepStatus,
        this.performedBy,
        this.performedById,
        this.remarks,
        this.createdAt,
        this.updatedAt});

  Ordersteps.fromJson(Map<String, dynamic> json) {
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