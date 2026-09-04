class VendorDetailsModel {
  bool? success;
  List<Data>? data;
  List<Category>? category;
  List<Service>? service;
  List<Review>? review;

  VendorDetailsModel(
      {this.success, this.data, this.category, this.service, this.review});

  VendorDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['service'] != null) {
      service = <Service>[];
      json['service'].forEach((v) {
        service!.add(Service.fromJson(v));
      });
    }
    if (json['review'] != null) {
      review = <Review>[];
      json['review'].forEach((v) {
        review!.add(Review.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (service != null) {
      data['service'] = service!.map((v) => v.toJson()).toList();
    }
    if (review != null) {
      data['review'] = review!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? phCode;
  String? phone;
  String? email;
  String? companyName;
  String? fullName;
  String? state;
  String? city;
  String? pincode;
  String? address;
  String? profilePhoto;
  String? serviceTag;
  String? serviceCategory;
  String? subService;
  int? yearsOfExperience;
  String? shortBio;
  String? languages;
  String? areaOfService;
  String? workingHoursFrom;
  String? workingHoursTo;
  int? willingToTravel;
  String? toolsAvailable;
  String? rating;

  Data(
      {this.id,
        this.name,
        this.phCode,
        this.phone,
        this.email,
        this.companyName,
        this.fullName,
        this.state,
        this.city,
        this.pincode,
        this.address,
        this.profilePhoto,
        this.serviceTag,
        this.serviceCategory,
        this.subService,
        this.yearsOfExperience,
        this.shortBio,
        this.languages,
        this.areaOfService,
        this.workingHoursFrom,
        this.workingHoursTo,
        this.willingToTravel,
        this.toolsAvailable,
        this.rating});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phCode = json['ph_code'];
    phone = json['phone'];
    email = json['email'];
    companyName = json['company_name'];
    fullName = json['full_name'];
    state = json['state'];
    city = json['city'];
    pincode = json['pincode'];
    address = json['address'];
    profilePhoto = json['profile_photo'];
    serviceTag = json['service_tag'];
    serviceCategory = json['service_category'];
    subService = json['sub_service'];
    yearsOfExperience = json['years_of_experience'];
    shortBio = json['short_bio'];
    languages = json['languages'];
    areaOfService = json['area_of_service'];
    workingHoursFrom = json['working_hours_from'];
    workingHoursTo = json['working_hours_to'];
    willingToTravel = json['willing_to_travel'];
    toolsAvailable = json['tools_available'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['ph_code'] = phCode;
    data['phone'] = phone;
    data['email'] = email;
    data['company_name'] = companyName;
    data['full_name'] = fullName;
    data['state'] = state;
    data['city'] = city;
    data['pincode'] = pincode;
    data['address'] = address;
    data['profile_photo'] = profilePhoto;
    data['service_tag'] = serviceTag;
    data['service_category'] = serviceCategory;
    data['sub_service'] = subService;
    data['years_of_experience'] = yearsOfExperience;
    data['short_bio'] = shortBio;
    data['languages'] = languages;
    data['area_of_service'] = areaOfService;
    data['working_hours_from'] = workingHoursFrom;
    data['working_hours_to'] = workingHoursTo;
    data['willing_to_travel'] = willingToTravel;
    data['tools_available'] = toolsAvailable;
    data['rating'] = rating;
    return data;
  }
}

class Category {
  int? categoryId;
  String? categoryName;
  String? iconUrl;
  int? serviceCount;

  Category(
      {this.categoryId, this.categoryName, this.iconUrl, this.serviceCount});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    iconUrl = json['icon_url'];
    serviceCount = json['service_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['icon_url'] = iconUrl;
    data['service_count'] = serviceCount;
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
  dynamic? showReview;
  String? createdAt;
  String? updatedAt;
  String? companyName;
  int? bookingCount;
  String? rating;
  String? bookingText;
  String? categoryName;

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
        this.bookingCount,
        this.rating,
        this.bookingText,
        this.categoryName});

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

class Review {
  int? id;
  int? customerId;
  int? vendorId;
  int? serviceId;
  int? rating;
  String? reviewDescription;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? customerName;

  Review(
      {this.id,
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
