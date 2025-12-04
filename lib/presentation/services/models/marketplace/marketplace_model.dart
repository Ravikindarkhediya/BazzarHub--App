import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';
import '../categorie/categorie_model.dart';
import '../Common/location_model.dart';
import 'marketplace_contact_info_model.dart';

part 'marketplace_model.g.dart';

@JsonSerializable()
class MarketplaceModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'title', defaultValue: '')
  final String title;

  @JsonKey(name: 'description', defaultValue: '')
  final String description;

  @JsonKey(name: 'price', defaultValue: 0)
  final double price;

  @JsonKey(name: 'category')
  final CategoryModel? category;

  @JsonKey(name: 'images', defaultValue: [])
  final List<String> images;

  @JsonKey(name: 'condition', defaultValue: '')
  final String condition;

  @JsonKey(name: 'type', defaultValue: '')
  final String type;

  @JsonKey(name: 'views', defaultValue: 0)
  final int views;

  @JsonKey(name: 'favoritesCount', defaultValue: 0)
   int favoritesCount;

  @JsonKey(name: 'favorites', defaultValue: 0)
  int favorites;

  @JsonKey(name: 'isFavorite',  defaultValue: false)
  bool isFavorite;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'location')
  final LocationModel? location;

  @JsonKey(name: 'contactInfo')
  final MarketplaceContactInfoModel? contactInfo;

  @JsonKey(name: 'createdBy')
  final UserModel? createdBy;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  @JsonKey(name: '__v', defaultValue: 0)
  final int version;

  @JsonKey(name: 'relatedListings')
  final List<MarketplaceModel>? list;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isFromYourPost;

  MarketplaceModel({
    this.id = '',
    this.title = '',
    this.description = '',
    this.price = 0,
    this.category,
    this.images = const [],
    this.condition = '',
    this.type = '',
    this.views = 0,
    this.favoritesCount = 0,
    this.favorites = 0,
    this.isFavorite = false,
    this.isActive = false,
    this.location,
    this.contactInfo,
    this.createdBy,
    this.createdAt = '',
    this.updatedAt = '',
    this.version = 0,
    this.list,
    this.isFromYourPost = false,
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceModelToJson(this);
}
