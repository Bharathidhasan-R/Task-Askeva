class NotificationListModel {
  bool? success;
  List<Data>? data;

  NotificationListModel({this.success, this.data});

  NotificationListModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? title;
  String? description;
  int? customerId;
  int? vendorId;
  int? serviceId;
  String? senderRole;
  String? receiverRole;
  int? readStatus;
  String? createdAt;

  Data(
      {this.id,
        this.title,
        this.description,
        this.customerId,
        this.vendorId,
        this.serviceId,
        this.senderRole,
        this.receiverRole,
        this.readStatus,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    serviceId = json['service_id'];
    senderRole = json['sender_role'];
    receiverRole = json['receiver_role'];
    readStatus = json['read_status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['service_id'] = serviceId;
    data['sender_role'] = senderRole;
    data['receiver_role'] = receiverRole;
    data['read_status'] = readStatus;
    data['created_at'] = createdAt;
    return data;
  }
}
