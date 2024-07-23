
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class QuizConstituteWidgetState extends Equatable
{
  final List<Widget> list;
  const QuizConstituteWidgetState({
    required this.list
  });

  @override
  List<Object> get props => [list];
}