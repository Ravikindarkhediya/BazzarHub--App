import 'package:json_annotation/json_annotation.dart';
import '../../../modules/home/model/category_model.dart';
import '../Common/pagination_model.dart';

part 'category_list_response_model.g.dart';

@JsonSerializable()
class CategoryListResponseModel {

  @JsonKey(name: 'categories')
  final List<CategoryModel> categories;

  @JsonKey(name: 'pagination')
  final PaginationModel pagination;

  const CategoryListResponseModel({
    this.categories = const [],
    this.pagination = const PaginationModel(),
  });

  factory CategoryListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryListResponseModelToJson(this);
}
