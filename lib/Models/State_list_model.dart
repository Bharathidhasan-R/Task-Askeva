class StateListModel {
  bool? success;
  List<StatesList>? statesList;

  StateListModel({this.success, this.statesList});

  StateListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['states_list'] != null) {
      statesList = <StatesList>[];
      json['states_list'].forEach((v) {
        statesList!.add(StatesList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (statesList != null) {
      data['states_list'] = statesList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatesList {
  int? id;
  String? name;
  int? countryId;
  String? countryCode;
  String? fipsCode;
  String? iso2;
  String? type;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;
  int? flag;
  String? wikiDataId;
  int? status;
  String? createdOn;

  StatesList(
      {this.id,
        this.name,
        this.countryId,
        this.countryCode,
        this.fipsCode,
        this.iso2,
        this.type,
        this.latitude,
        this.longitude,
        this.createdAt,
        this.updatedAt,
        this.flag,
        this.wikiDataId,
        this.status,
        this.createdOn,});

  StatesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryId = json['country_id'];
    countryCode = json['country_code'];
    fipsCode = json['fips_code'];
    iso2 = json['iso2'];
    type = json['type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    flag = json['flag'];
    wikiDataId = json['wikiDataId'];
    status = json['status'];
    createdOn = json['created_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country_id'] = countryId;
    data['country_code'] = countryCode;
    data['fips_code'] = fipsCode;
    data['iso2'] = iso2;
    data['type'] = type;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['flag'] = flag;
    data['wikiDataId'] = wikiDataId;
    data['status'] = status;
    data['created_on'] = createdOn;
    return data;
  }
}
