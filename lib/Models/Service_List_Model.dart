class ServiceListModel {
  bool? success;
  String? message;
  List<Data>? data;

  ServiceListModel({this.success, this.message, this.data});

  ServiceListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? vendorId;
  String? serviceTitle;
  String? serviceCategory;
  String? serviceSubcategory;
  String? description;
  String? pricingType;
  String? unitName;
  String? price;
  String? serviceImage;
  String? certificateUrl;
  int? isActive;
  int? showReview;
  String? createdAt;
  String? updatedAt;
  String? companyName;
  int? bookingCount;
  String? rating;
  String? bookingText;

  Data(
      {this.id,
        this.vendorId,
        this.serviceTitle,
        this.serviceCategory,
        this.serviceSubcategory,
        this.description,
        this.pricingType,
        this.unitName,
        this.price,
        this.serviceImage,
        this.certificateUrl,
        this.isActive,
        this.showReview,
        this.createdAt,
        this.updatedAt,
        this.companyName,
        this.bookingCount,
        this.rating,
        this.bookingText});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    serviceTitle = json['service_title'];
    serviceCategory = json['service_category'];
    serviceSubcategory = json['service_subcategory'];
    description = json['description'];
    pricingType = json['pricing_type'];
    unitName = json['unit_name'];
    price = json['price'];
    serviceImage = json['service_image'];
    certificateUrl = json['certificate_url'];
    isActive = json['is_active'];
    showReview = json['show_review'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    companyName = json['company_name'];
    bookingCount = json['booking_count'];
    rating = json['rating'];
    bookingText = json['booking_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['service_title'] = serviceTitle;
    data['service_category'] = serviceCategory;
    data['service_subcategory'] = serviceSubcategory;
    data['description'] = description;
    data['pricing_type'] = pricingType;
    data['unit_name'] = unitName;
    data['price'] = price;
    data['service_image'] = serviceImage;
    data['certificate_url'] = certificateUrl;
    data['is_active'] = isActive;
    data['show_review'] = showReview;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['company_name'] = companyName;
    data['booking_count'] = bookingCount;
    data['rating'] = rating;
    data['booking_text'] = bookingText;
    return data;
  }
}
