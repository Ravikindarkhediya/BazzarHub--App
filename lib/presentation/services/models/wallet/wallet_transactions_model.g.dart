// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transactions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransactionsModel _$WalletTransactionsModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionsModel(
  id: json['_id'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  title: json['title'] as String? ?? '',
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  transactionId: json['transactionId'] as String? ?? '',
  status: json['status'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
  v: (json['__v'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WalletTransactionsModelToJson(
  WalletTransactionsModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'coins': instance.coins,
  'transactionId': instance.transactionId,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.v,
};
