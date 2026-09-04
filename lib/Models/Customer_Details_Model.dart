class CustomerDetailsModel {
  bool? success;
  String? message;
  List<Data>? data;

  CustomerDetailsModel({this.success, this.message, this.data});

  CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phCode;
  String? phone;
  String? status;
  String? createdAt;
  String? state;
  String? city;
  String? pincode;
  String? address;
  String? profilePhoto;
  String? lastOtpSentAt;

  Data(
      {this.id,
        this.name,
        this.email,
        this.phCode,
        this.phone,
        this.status,
        this.createdAt,
        this.state,
        this.city,
        this.pincode,
        this.address,
        this.profilePhoto,
        this.lastOtpSentAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phCode = json['ph_code'];
    phone = json['phone'];
    status = json['status'];
    createdAt = json['created_at'];
    state = json['state'];
    city = json['city'];
    pincode = json['pincode'];
    address = json['address'];
    profilePhoto = json['profile_photo'];
    lastOtpSentAt = json['last_otp_sent_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['ph_code'] = phCode;
    data['phone'] = phone;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['state'] = state;
    data['city'] = city;
    data['pincode'] = pincode;
    data['address'] = address;
    data['profile_photo'] = profilePhoto;
    data['last_otp_sent_at'] = lastOtpSentAt;
    return data;
  }
}
