
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:foxschool/bloc/base/BlocController.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginAutoCheckCubit.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginFindSchoolListCubit.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginSchoolNameCubit.dart';
import 'package:foxschool/bloc/login/factory/state/AutoLoginCheckState.dart';

import '../../../common/Common.dart';
import '../../../common/CommonUtils.dart';
import '../../../data/school_data/SchoolData.dart';
import '../../base/BlocState.dart';
import '../api/LoginBloc.dart';
import '../api/event/GetSchoolDataEvent.dart';
import 'package:foxschool/view/dialog/LoadingDialog.dart' as LoadingDialog;
import 'package:foxschool/common/Preference.dart' as Preference;

import '../api/event/LoginEvent.dart';
import '../api/state/LoginLoadedState.dart';
import '../api/state/SchoolDataLoadedState.dart';

class LoginFactoryController extends BlocController {

  late StreamSubscription _subscription;
  late List<SchoolData> _schoolDataList;
  List<SchoolData> _currentSearchSchoolList = [];
  String _schoolName = "";
  bool _isAutoLoginCheck = false;
  final BuildContext context;

  LoginFactoryController({
    required this.context
  });


  @override
  void init() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      context.read<LoginBloc>().add(GetSchoolDataEvent());
    });
    _settingSubscriptions();
  }

  void _settingSubscriptions() {
    var blocState;
    _subscription = context
        .read<LoginBloc>()
        .stream
        .listen((state) {
      switch (state.runtimeType) {
        case LoadingState:
          {
            LoadingDialog.show(context);
            break;
          }
        case SchoolDataLoadedState:
          {
            blocState = state as SchoolDataLoadedState;
            Logger.d("LoadedState : ${blocState.data.toString()}");
            LoadingDialog.dismiss(context);
            _schoolDataList = blocState.data;
            break;
          }
        case LoginLoadedState:
          {
            blocState = state as LoginLoadedState;
            Logger.d("LoadedState : ${blocState.data.toString()}");
            LoadingDialog.dismiss(context);
            Navigator.of(context).pop(true);
            break;
          }
        case ErrorState:
          {
            var errorState = state as ErrorState;
            LoadingDialog.dismiss(context);
            CommonUtils.getInstance(context).showErrorMessage(errorState.message);
            break;
          }
      }
    });
  }

  void _settingCurrentSearchSchoolList() {
    _currentSearchSchoolList = [];
    for (int i = 0; i < _schoolDataList.length; i++) {
      if (_schoolDataList[i].name.contains(_schoolName)) {
        _currentSearchSchoolList.add(_schoolDataList[i]);
      }
    }
  }

  String getSchoolID(String selectSchoolName) {
    String result = "";
    for (var data in _schoolDataList) {
      if (data.name == selectSchoolName) {
        result = data.id;
        break;
      }
    }
    return result;
  }

  void onClickLogin(String userID, String password, String schoolCode) {
    context.read<LoginBloc>().add(
        LoginEvent(
            loginID: userID,
            password: password,
            schoolCode: schoolCode)
    );
  }

  void onInitSchoolData()
  {
    _schoolName = "";
    _currentSearchSchoolList = [];
  }

  void onInitFindSchoolList()
  {
    _currentSearchSchoolList = [];
    context.read<LoginFindSchoolListCubit>().setSchoolList(_currentSearchSchoolList);
  }

  void onSetSchoolName(String value)
  {
    _schoolName = value;
    context.read<LoginSchoolNameCubit>().setSchoolName(_schoolName);
  }

  void onSetFindSchoolList(List<SchoolData> list)
  {
    _currentSearchSchoolList = list;
    context.read<LoginFindSchoolListCubit>().setSchoolList(_currentSearchSchoolList);
  }

  void onChangeSchoolData(String value)
  {
    _schoolName = value;
    _settingCurrentSearchSchoolList();
    context.read<LoginSchoolNameCubit>().setSchoolName(_schoolName);
    context.read<LoginFindSchoolListCubit>().setSchoolList(_currentSearchSchoolList);
  }

  void onCheckAutoLogin()
  {
    _isAutoLoginCheck = !_isAutoLoginCheck;
    Preference.setBoolean(Common.PARAMS_IS_AUTO_LOGIN_DATA, _isAutoLoginCheck);
    context.read<LoginAutoCheckCubit>().setAutoLogin(_isAutoLoginCheck);
  }



  @override
  void dispose() {
    _subscription.cancel();
  }

  @override
  void onBackPressed()
  {
    Navigator.of(context).pop(false);
  }
}