class CityListModel {
  bool? success;
  List<City>? city;

  CityListModel({this.success, this.city});

  CityListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['city'] != null) {
      city = <City>[];
      json['city'].forEach((v) {
        city!.add(City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (city != null) {
      data['city'] = city!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  int? cityId;
  String? cityName;
  String? cityState;

  City({this.cityId, this.cityName, this.cityState});

  City.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    cityName = json['city_name'];
    cityState = json['city_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city_id'] = cityId;
    data['city_name'] = cityName;
    data['city_state'] = cityState;
    return data;
  }
}
