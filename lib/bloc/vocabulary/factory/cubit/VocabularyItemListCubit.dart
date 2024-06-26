

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxschool/bloc/vocabulary/factory/state/VocabularyItemListState.dart';
import 'package:foxschool/bloc/vocabulary/factory/state/base/VocabularyListBaseState.dart';

import '../../../../data/vocabulary/VocabularyDataResult.dart';


class VocabularyItemListCubit extends Cubit<VocabularyListBaseState>
{
  VocabularyItemListCubit() : super(InitVocabularyListState());

  void showLoading()
  {
    emit(LoadingVocabularyListState());
  }

  void setVocabularyItemList(List<VocabularyDataResult> list)
  {
    emit(VocabularyItemListState(data: list));
  }

}