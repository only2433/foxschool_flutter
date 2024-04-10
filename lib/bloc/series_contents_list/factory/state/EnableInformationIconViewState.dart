

import 'package:equatable/equatable.dart';
import 'package:foxschool/bloc/base/BlocState.dart';

class EnableInformationIconViewState extends Equatable
{
  final bool isEnable;
  EnableInformationIconViewState({
    required this.isEnable
  });

  @override
  List<Object> get props => [isEnable];
}