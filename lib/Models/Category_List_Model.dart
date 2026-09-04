class CategoryListModel {
  bool? success;
  List<Categories>? categories;

  CategoryListModel({this.success, this.categories});

  CategoryListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
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
  String? name;
  String? slug;
  String? iconUrl;
  int? isActive;
  String? createdAt;

  Categories(
      {this.id,
        this.name,
        this.slug,
        this.iconUrl,
        this.isActive,
        this.createdAt});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    iconUrl = json['icon_url'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['icon_url'] = iconUrl;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    return data;
  }
}
