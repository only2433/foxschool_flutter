


import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import '../../../../data/contents/contents_base/ContentsBaseResult.dart';
import '../../../base/ContentsListBaseState.dart';

class ContentsItemListState extends ContentsListBaseState
{
  final String seriesColor;
  final bool isFullName;
  final List<ContentsBaseResult> itemList;
  ContentsItemListState({
    this.seriesColor = "",
    this.isFullName = false,
    required this.itemList
  });

  /**
   * 리스트 아이템 각 개별마다 업데이트를 해주기 위해서, 매번 업데이트
   */
  @override
  List<Object> get props {
    return [seriesColor, isFullName];
  }


}

