class EnquireDetailsModel {
  bool? success;
  List<Data>? data;

  EnquireDetailsModel({this.success, this.data});

  EnquireDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? minimumFee;
  List<Quotations>? quotations;

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
        this.minimumFee,
        this.quotations});

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
    minimumFee = json['minimum_fee'];
    if (json['quotations'] != null) {
      quotations = <Quotations>[];
      json['quotations'].forEach((v) {
        quotations!.add(Quotations.fromJson(v));
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
    data['minimum_fee'] = this.minimumFee;
    if (quotations != null) {
      data['quotations'] = quotations!.map((v) => v.toJson()).toList();
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
  String? serviceTime;
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
        this.serviceTime,
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
    serviceTime = json['service_time'];
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
    data['service_time'] = serviceTime;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['status_name'] = statusName;
    data['company_name'] = companyName;
    return data;
  }
}
