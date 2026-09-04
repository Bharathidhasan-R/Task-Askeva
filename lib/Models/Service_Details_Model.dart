class ServiceDetailsModel {
  bool? success;
  String? message;
  Data? data;

  ServiceDetailsModel({this.success, this.message, this.data});

  ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Service? service;
  List<CustomerReviews>? customerReviews;
  List<SimilarVendors>? similarVendors;
  List<CartData>? cartData;
  List<Portfolioservices>? portfolioservices;

  Data({this.service, this.customerReviews, this.similarVendors,this.cartData,this.portfolioservices});

  Data.fromJson(Map<String, dynamic> json) {
    service =
    json['service'] != null ? Service.fromJson(json['service']) : null;
    if (json['customer_reviews'] != null) {
      customerReviews = <CustomerReviews>[];
      json['customer_reviews'].forEach((v) {
        customerReviews!.add(CustomerReviews.fromJson(v));
      });
    }
    if (json['similar_vendors'] != null) {
      similarVendors = <SimilarVendors>[];
      json['similar_vendors'].forEach((v) {
        similarVendors!.add(SimilarVendors.fromJson(v));
      });
    }
    if (json['cart_data'] != null) {
      cartData = <CartData>[];
      json['cart_data'].forEach((v) {
        cartData!.add(new CartData.fromJson(v));
      });
    }
    if (json['Portfolioservices'] != null) {
      portfolioservices = <Portfolioservices>[];
      json['Portfolioservices'].forEach((v) {
        portfolioservices!.add(new Portfolioservices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (customerReviews != null) {
      data['customer_reviews'] =
          customerReviews!.map((v) => v.toJson()).toList();
    }
    if (similarVendors != null) {
      data['similar_vendors'] =
          similarVendors!.map((v) => v.toJson()).toList();
    }
    if (cartData != null) {
      data['cart_data'] = cartData!.map((v) => v.toJson()).toList();
    }
    if (portfolioservices != null) {
      data['Portfolioservices'] =
          portfolioservices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
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
  String? vendorName;
  String? categoryName;
  int? bookingCount;
  String? rating;
  String? bookingText;

  Service(
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
        this.vendorName,
        this.categoryName,
        this.bookingCount,
        this.rating,
        this.bookingText});

  Service.fromJson(Map<String, dynamic> json) {
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
    vendorName = json['vendor_name'];
    categoryName = json['category_name'];
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
    data['vendor_name'] = vendorName;
    data['category_name'] = categoryName;
    data['booking_count'] = bookingCount;
    data['rating'] = rating;
    data['booking_text'] = bookingText;
    return data;
  }
}

class CustomerReviews {
  int? id;
  int? customerId;
  int? vendorId;
  int? serviceId;
  int? rating;
  String? reviewDescription;
  int? status;
  String? createdAt;
  String? customerName;

  CustomerReviews(
      {this.id,
        this.customerId,
        this.vendorId,
        this.serviceId,
        this.rating,
        this.reviewDescription,
        this.status,
        this.createdAt,
        this.customerName});

  CustomerReviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    serviceId = json['service_id'];
    rating = json['rating'];
    reviewDescription = json['review_description'];
    status = json['status'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['service_id'] = serviceId;
    data['rating'] = rating;
    data['review_description'] = reviewDescription;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    return data;
  }
}

class SimilarVendors {
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
  String? vendorName;
  String? profilePhoto;
  String? shortBio;
  String? categoryName;
  String? rating;

  SimilarVendors(
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
        this.vendorName,
        this.profilePhoto,
        this.shortBio,
        this.categoryName,
        this.rating});

  SimilarVendors.fromJson(Map<String, dynamic> json) {
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
    vendorName = json['vendor_name'];
    profilePhoto = json['profile_photo'];
    shortBio = json['short_bio'];
    categoryName = json['category_name'];
    rating = json['rating'];
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
    data['vendor_name'] = vendorName;
    data['profile_photo'] = profilePhoto;
    data['short_bio'] = shortBio;
    data['category_name'] = categoryName;
    data['rating'] = rating;
    return data;
  }

}

class CartData {
  int? id;
  int? customerId;
  int? vendorId;
  int? serviceId;
  int? status;
  String? createdAt;
  String? deviceId;

  CartData(
      {this.id,
        this.customerId,
        this.vendorId,
        this.serviceId,
        this.status,
        this.createdAt,
        this.deviceId});

  CartData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    serviceId = json['service_id'];
    status = json['status'];
    createdAt = json['created_at'];
    deviceId = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['service_id'] = serviceId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['device_id'] = deviceId;
    return data;
  }}
class Portfolioservices {
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
  dynamic showReview;
  String? createdAt;
  String? updatedAt;
  String? companyName;
  int? bookingCount;
  String? rating;
  String? bookingText;
  String? categoryName;

  Portfolioservices(
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
        this.bookingText,
        this.categoryName});

  Portfolioservices.fromJson(Map<String, dynamic> json) {
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
    categoryName = json['category_name'];
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
    data['category_name'] = categoryName;
    return data;
  }
}