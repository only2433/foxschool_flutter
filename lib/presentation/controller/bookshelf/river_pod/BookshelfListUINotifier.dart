
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foxschool/data/model/contents/contents_base/ContentsBaseResult.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data/BookshelfListUIState.dart';

part 'BookshelfListUINotifier.g.dart';


@riverpod
class BookshelfListUINotifier extends _$BookshelfListUINotifier {
  @override
  BookshelfListUIState build() {
    return BookshelfListUIState(
        isContentsLoading: false,
        itemList: [],
        selectItemCount: 0,
        isEnableBottomSelectView: false);
  }

  void enableContentsLoading(bool isEnable)
  {
    state = state.copyWith(
        isContentsLoading: isEnable
    );
  }

  void notifyBookshelfItemList(List<ContentsBaseResult> list)
  {
    state = state.copyWith(
        itemList: list
    );
  }

  void setSelectItemCount(int count)
  {
    state = state.copyWith(
        selectItemCount: count
    );
  }

  void enableBottomSelectView(bool isEnable)
  {
    state = state.copyWith(
        isEnableBottomSelectView: isEnable
    );
  }

}