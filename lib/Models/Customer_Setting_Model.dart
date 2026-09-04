class CustomerSettingModel {
  bool? success;
  List<Categories>? categories;

  CustomerSettingModel({this.success, this.categories});

  CustomerSettingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  int? id;
  String? siteName;
  String? siteLogo;
  String? convenienceFeePercentage;
  String? platformFee;
  String? payoutFee;
  String? paymentName;
  String? paymentKey;
  String? paymentSecret;
  String? taxOption;
  String? smtpHost;
  int? smtpPort;
  String? smtpUsername;
  String? smtpPassword;
  String? smtpEncryption;
  String? smtpFromEmail;
  String? smtpFromName;
  String? createdAt;
  String? updatedAt;

  Categories(
      {this.id,
        this.siteName,
        this.siteLogo,
        this.convenienceFeePercentage,
        this.platformFee,
        this.payoutFee,
        this.paymentName,
        this.paymentKey,
        this.paymentSecret,
        this.taxOption,
        this.smtpHost,
        this.smtpPort,
        this.smtpUsername,
        this.smtpPassword,
        this.smtpEncryption,
        this.smtpFromEmail,
        this.smtpFromName,
        this.createdAt,
        this.updatedAt});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteName = json['site_name'];
    siteLogo = json['site_logo'];
    convenienceFeePercentage = json['convenience_fee_percentage'];
    platformFee = json['platform_fee'];
    payoutFee = json['payout_fee'];
    paymentName = json['payment_name'];
    paymentKey = json['payment_key'];
    paymentSecret = json['payment_secret'];
    taxOption = json['tax_option'];
    smtpHost = json['smtp_host'];
    smtpPort = json['smtp_port'];
    smtpUsername = json['smtp_username'];
    smtpPassword = json['smtp_password'];
    smtpEncryption = json['smtp_encryption'];
    smtpFromEmail = json['smtp_from_email'];
    smtpFromName = json['smtp_from_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['site_name'] = siteName;
    data['site_logo'] = siteLogo;
    data['convenience_fee_percentage'] = convenienceFeePercentage;
    data['platform_fee'] = platformFee;
    data['payout_fee'] = payoutFee;
    data['payment_name'] = paymentName;
    data['payment_key'] = paymentKey;
    data['payment_secret'] = paymentSecret;
    data['tax_option'] = taxOption;
    data['smtp_host'] = smtpHost;
    data['smtp_port'] = smtpPort;
    data['smtp_username'] = smtpUsername;
    data['smtp_password'] = smtpPassword;
    data['smtp_encryption'] = smtpEncryption;
    data['smtp_from_email'] = smtpFromEmail;
    data['smtp_from_name'] = smtpFromName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
