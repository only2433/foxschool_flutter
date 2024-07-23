
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxschool/bloc/flashcard/factory/state/FlashcardStudyCurrentIndexState.dart';

class FlashcardStudyCurrentIndexCubit extends Cubit<FlashcardStudyCurrentIndexState>
{
  FlashcardStudyCurrentIndexCubit() : super(FlashcardStudyCurrentIndexState(currentIndex: 0, maxCount: 0));

  void setIndex(int index, int maxCount)
  {
    emit(FlashcardStudyCurrentIndexState(currentIndex: index, maxCount: maxCount));
  }

}