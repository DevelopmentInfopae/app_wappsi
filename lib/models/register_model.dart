import 'dart:convert';

RegisterModel registerModelFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  RegisterModel({
    required this.status,
    this.id = '',
    required this.date,
    this.userId = '',
    this.cashInHand = '',
    this.movementsIn = '',
    this.totalRetention = '',
    this.totalReturnRetention = '',
    this.totalRcRetention = '',
    required this.registrationDate,
  });

  String status;
  String id;
  DateTime date;
  String userId;
  String cashInHand;
  String movementsIn;
  String totalRetention;
  String totalReturnRetention;
  String totalRcRetention;
  DateTime registrationDate;

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        status: json['status'] ?? '',
        id: json['id'],
        date: DateTime.parse(json['date']),
        userId: json['user_id'],
        cashInHand: json['cash_in_hand'],
        movementsIn: json['movements_in'],
        totalRetention: json['total_retention'],
        totalReturnRetention: json['total_return_retention'],
        totalRcRetention: json['total_rc_retention'],
        registrationDate: DateTime.parse(json['registration_date']),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'id': id,
        'date': date.toIso8601String(),
        'user_id': userId,
        'cash_in_hand': cashInHand,
        'movements_in': movementsIn,
        'total_retention': totalRetention,
        'total_return_retention': totalReturnRetention,
        'total_rc_retention': totalRcRetention,
        'registration_date': registrationDate.toIso8601String(),
      };
  get registerStatus => status;
}
