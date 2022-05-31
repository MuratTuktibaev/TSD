// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<DTOReturnData> dtoReturnDataFromJson(String str) => List<DTOReturnData>.from(json.decode(str).map((x) => DTOReturnData.fromJson(x as Map<String, dynamic>)) as Iterable);

class DTOReturnData {
  DTOReturnData({
    required this.id,
    required this.refundId,
    required this.name,
    required this.image,
    required this.barcode,
    required this.status,
    required this.totalCount,
    required this.scanCount,
    required this.producer,
    required this.series,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? refundId;
  final String? name;
  final String? image;
  final String? barcode;
  final int? status;
  int? totalCount;
  final int? scanCount;
  final String? producer;
  String? series;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DTOReturnData.fromJson(Map<String, dynamic> json) => DTOReturnData(
    id: json["id"] == null ? null : json["id"] as int,
    refundId: json["refund_id"] == null ? null : json["refund_id"] as int,
    name: json["name"] == null ? null : json["name"] as String,
    image: json["image"] == null ? null : json["image"] as String,
    barcode: json["barcode"] == null ? null : json["barcode"] as String,
    status: json["status"] == null ? null : json["status"] as int,
    totalCount: json["total_count"] == null ? null : json["total_count"] as int,
    scanCount: json["scan_count"] == null ? null : json["scan_count"] as int,
    producer: json["producer"] == null ? null : json["producer"] as String,
    series: json["series"] == null ? null : json["series"] as String,
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"] as String),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"] as String),
  );
}
