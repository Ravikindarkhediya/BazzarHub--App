import 'package:json_annotation/json_annotation.dart';

part 'wallet_transactions_model.g.dart';

@JsonSerializable()
class WalletTransactionsModel {
  @JsonKey(name: '_id',defaultValue: '')
  final String id;

  @JsonKey(name: 'userId',defaultValue: '')
  final String userId;

  @JsonKey(name: 'title', defaultValue: '')
  final String title;

  @JsonKey(name: 'coins', defaultValue: 0)
  final int coins;

  @JsonKey(name: 'transactionId', defaultValue: '')
  final String transactionId;

  @JsonKey(name: 'status', defaultValue: '')
  final String status;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  @JsonKey(name: '__v', defaultValue: 0)
  final int v;

  WalletTransactionsModel({
    this.id = '',
    this.userId= '',
    this.title= '',
    this.coins= 0,
    this.transactionId= '',
    this.status= '',
    this.createdAt= '',
    this.updatedAt= '',
    this.v= 0,
  });

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionsModelToJson(this);
}
