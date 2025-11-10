import 'package:json_annotation/json_annotation.dart';

part 'marketplace_contact_info_model.g.dart';

@JsonSerializable()
class MarketplaceContactInfoModel {
  @JsonKey(name: 'phone', defaultValue: [])
  final List<String> phone;

  @JsonKey(name: 'email', defaultValue: [])
  final List<String> email;

  const MarketplaceContactInfoModel({
    this.phone = const [],
    this.email = const [],
  });

  factory MarketplaceContactInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceContactInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceContactInfoModelToJson(this);
}
