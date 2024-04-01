

import 'package:foxschool/data/story_category_contents/theme_data/ThemeData.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../main/series/SeriesInformationResult.dart';

part 'StoryCategoryContentsResult.freezed.dart';
part 'StoryCategoryContentsResult.g.dart';

@freezed
class StoryCategoryContentsResult with _$StoryCategoryContentsResult
{
  factory StoryCategoryContentsResult({

    @JsonKey(name:'theme_info')
    ThemeData? themeInfo,

    @JsonKey(name:'children')
    @Default([])
    List<SeriesInformationResult> itemList
  }) = _StoryCategoryContentsResult;

  factory StoryCategoryContentsResult.fromJson(Map<String, dynamic> data) => _$StoryCategoryContentsResultFromJson(data);
}