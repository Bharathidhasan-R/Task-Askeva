class FileUploadModel {
  bool? success;
  String? message;
  UploadedUrls? uploadedUrls;

  FileUploadModel({this.success, this.message, this.uploadedUrls});

  FileUploadModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    uploadedUrls = json['uploadedUrls'] != null
        ? new UploadedUrls.fromJson(json['uploadedUrls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (uploadedUrls != null) {
      data['uploadedUrls'] = uploadedUrls!.toJson();
    }
    return data;
  }
}

class UploadedUrls {
  List<String>? uploadFiles;

  UploadedUrls({this.uploadFiles});

  UploadedUrls.fromJson(Map<String, dynamic> json) {
    uploadFiles = json['upload_files'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['upload_files'] = uploadFiles;
    return data;
  }
}
