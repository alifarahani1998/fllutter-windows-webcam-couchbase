import 'dart:io';

class CustomerInfoModel {
  String? firstName;
  String? lastName;
  String? nationalCode;
  File? imageUri;

  CustomerInfoModel({this.firstName, this.lastName, this.nationalCode, this.imageUri});

  CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    nationalCode = json['national_code'];
    imageUri = json['image_uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['national_code'] = this.nationalCode;
    data['image_uri'] = this.imageUri;
    return data;
  }
}
