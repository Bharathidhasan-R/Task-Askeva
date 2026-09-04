class CartDetailsModel {
  bool? success;
  List<Data>? data;

  CartDetailsModel({this.success, this.data});

  CartDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? cartId;
  int? vendorId;
  int? serviceId;
  String? companyName;
  int? id;
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
  String? minimumFee;

  Data(
      {this.cartId,
        this.vendorId,
        this.serviceId,
        this.companyName,
        this.id,
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
        this.minimumFee});

  Data.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    vendorId = json['vendor_id'];
    serviceId = json['service_id'];
    companyName = json['company_name'];
    id = json['id'];
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
    minimumFee = json['minimum_fee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['vendor_id'] = vendorId;
    data['service_id'] = serviceId;
    data['company_name'] = companyName;
    data['id'] = id;
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
    data['minimum_fee'] = minimumFee;
    return data;
  }
}
