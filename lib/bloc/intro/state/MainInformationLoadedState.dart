
import 'package:foxschool/bloc/base/BlocState.dart';
import 'package:foxschool/data/main/main_story_infomation/MainInformationResult.dart';

class MainInformationLoadedState extends BlocState
{
  final MainInformationResult data;
  const MainInformationLoadedState({
    required this.data
  });

  @override
  List<Object> get props => [data];
}