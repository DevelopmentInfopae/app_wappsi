// To parse this JSON data, do
//
//     final groups = groupsFromJson(jsonString);

import 'dart:convert';

Groups groupsFromJson(String str) => Groups.fromJson(json.decode(str));

String groupsToJson(Groups data) => json.encode(data.toJson());

class Groups {
  Groups({
    required this.id,
    required this.idCloud,
    required this.name,
    required this.description,
    this.relationedCompanies,
    this.groupNameRelationed,
    this.lastUpdate,
  });

  String id;
  String idCloud;
  String name;
  String description;
  String? relationedCompanies;
  String? groupNameRelationed;
  String? lastUpdate;

  factory Groups.fromJson(Map<String, dynamic> json) => Groups(
        id: json['id'].toString(),
        idCloud: json['id_cloud'].toString(),
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        relationedCompanies: json['relationed_companies'].toString(),
        groupNameRelationed: json['group_name_relationed'],
        lastUpdate: json['last_update'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_cloud': idCloud,
        'name': name,
        'description': description,
        'relationed_companies': relationedCompanies,
        'group_name_relationed': groupNameRelationed,
        'last_update': lastUpdate,
      };

  @override
  String toString() => name;
}
