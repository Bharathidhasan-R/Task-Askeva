class NeedToPayModel {
  bool? success;
  List<Plan>? plan;
  List<Planoverall>? planoverall;
  List<Materials>? materials;
  List<Materialsoverall>? materialsoverall;

  NeedToPayModel({this.success, this.plan, this.planoverall,this.materials,this.materialsoverall});

  NeedToPayModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['plan'] != null) {
      plan = <Plan>[];
      json['plan'].forEach((v) {
        plan!.add(Plan.fromJson(v));
      });
    }
    if (json['planoverall'] != null) {
      planoverall = <Planoverall>[];
      json['planoverall'].forEach((v) {
        planoverall!.add(new Planoverall.fromJson(v));
      });
    }
    if (json['materials'] != null) {
      materials = <Materials>[];
      json['materials'].forEach((v) {
        materials!.add(Materials.fromJson(v));
      });
    }
    if (json['materialsoverall'] != null) {
      materialsoverall = <Materialsoverall>[];
      json['materialsoverall'].forEach((v) {
        materialsoverall!.add(new Materialsoverall.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (plan != null) {
      data['plan'] = plan!.map((v) => v.toJson()).toList();
    }
    if (planoverall != null) {
      data['planoverall'] = planoverall!.map((v) => v.toJson()).toList();
    }
    if (materials != null) {
      data['materials'] = materials!.map((v) => v.toJson()).toList();
    }
    if (materialsoverall != null) {
      data['materialsoverall'] =
          materialsoverall!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plan {
  int? id;
  int? orderId;
  String? title;
  String? completionDays;
  int? amountPercentage;
  String? amount;
  String? balanceCost;
  String? updatedAt;
  String? updatePhoto;
  String? updateComments;
  int? status;
  String? createdAt;

  Plan(
      {this.id,
        this.orderId,
        this.title,
        this.completionDays,
        this.amountPercentage,
        this.amount,
        this.balanceCost,
        this.updatedAt,
        this.updatePhoto,
        this.updateComments,
        this.status,
        this.createdAt});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    title = json['title'];
    completionDays = json['completion_days'];
    amountPercentage = json['amount_percentage'];
    amount = json['amount'];
    balanceCost = json['balance_cost'];
    updatedAt = json['updated_at'];
    updatePhoto = json['update_photo'];
    updateComments = json['update_comments'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['title'] = title;
    data['completion_days'] = completionDays;
    data['amount_percentage'] = amountPercentage;
    data['amount'] = amount;
    data['balance_cost'] = balanceCost;
    data['updated_at'] = updatedAt;
    data['update_photo'] = updatePhoto;
    data['update_comments'] = updateComments;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}

class Materials {
  int? id;
  int? orderId;
  String? planId;
  String? title;
  String? unitType;
  String? qty;
  String? unitCost;
  String? totalCost;
  String? balanceCost;
  String? mTax;
  String? mTaxCost;
  String? mPlatformCost;
  String? mConvenienceCost;
  String? mFinalAmount;
  String? paymentStatus;
  String? status;
  String? createdAt;
  String? updatedAt;

  Materials(
      {this.id,
        this.orderId,
        this.planId,
        this.title,
        this.unitType,
        this.qty,
        this.unitCost,
        this.totalCost,
        this.balanceCost,
        this.mTax,
        this.mTaxCost,
        this.mPlatformCost,
        this.mConvenienceCost,
        this.mFinalAmount,
        this.paymentStatus,
        this.status,
        this.createdAt,
        this.updatedAt});

  Materials.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    planId = json['plan_id'];
    title = json['title'];
    unitType = json['unit_type'];
    qty = json['qty'];
    unitCost = json['unit_cost'];
    totalCost = json['total_cost'];
    balanceCost = json['balance_cost'];
    mTax = json['m_tax'];
    mTaxCost = json['m_tax_cost'];
    mPlatformCost = json['m_platform_cost'];
    mConvenienceCost = json['m_convenience_cost'];
    mFinalAmount = json['m_final_amount'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['plan_id'] = planId;
    data['title'] = title;
    data['unit_type'] = unitType;
    data['qty'] = qty;
    data['unit_cost'] = unitCost;
    data['total_cost'] = totalCost;
    data['balance_cost'] = balanceCost;
    data['m_tax'] = mTax;
    data['m_tax_cost'] = mTaxCost;
    data['m_platform_cost'] = mPlatformCost;
    data['m_convenience_cost'] = mConvenienceCost;
    data['m_final_amount'] = mFinalAmount;
    data['payment_status'] = paymentStatus;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Planoverall {
  String? totalAmount;
  String? totalBalanceCost;

  Planoverall({this.totalAmount, this.totalBalanceCost});

  Planoverall.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'];
    totalBalanceCost = json['total_balance_cost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_amount'] = totalAmount;
    data['total_balance_cost'] = totalBalanceCost;
    return data;
  }
}

class Materialsoverall {
  String? totalCostAmount;
  String? totalBalanceCost;

  Materialsoverall({this.totalCostAmount, this.totalBalanceCost});

  Materialsoverall.fromJson(Map<String, dynamic> json) {
    totalCostAmount = json['total_cost_amount'];
    totalBalanceCost = json['total_balance_cost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_cost_amount'] = totalCostAmount;
    data['total_balance_cost'] = totalBalanceCost;
    return data;
  }
}