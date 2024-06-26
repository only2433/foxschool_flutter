

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:foxschool/bloc/base/BlocController.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainMyBooksTypeCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainSongCategoryListCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainStorySelectTypeListCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainUserInformationCubit.dart';
import 'package:foxschool/common/CommonUtils.dart';
import 'package:foxschool/common/FoxschoolLocalization.dart';
import 'package:foxschool/common/MainObserver.dart';
import 'package:foxschool/common/Preference.dart' as Preference;
import 'package:foxschool/common/PageNavigator.dart' as Page;
import 'package:foxschool/enum/ManagementMyBooksStatus.dart';
import 'package:foxschool/enum/MyBooksType.dart';
import 'package:foxschool/view/screen/IntroScreen.dart';
import 'package:foxschool/view/screen/ManagementMyBooksScreen.dart';
import 'package:foxschool/view/screen/MyBookshelfScreen.dart';
import 'package:foxschool/view/screen/SearchScreen.dart';
import 'package:foxschool/view/screen/SeriesContentListScreen.dart';
import 'package:foxschool/view/screen/StoryCategoryListScreen.dart';

import '../../common/Common.dart';
import '../../data/login/LoginInformationResult.dart';
import '../../data/main/MainInformationResult.dart';
import '../../data/main/my_book/MyBookshelfResult.dart';
import '../../data/main/my_vocabulary/MyVocabularyResult.dart';
import '../../data/main/series/SeriesInformationResult.dart';
import '../../data/vocabulary/information/VocabularyInformationData.dart';
import '../../di/Dependencies.dart';
import '../../enum/StorySeriesType.dart';
import 'package:page_transition/page_transition.dart';
import '../../view/dialog/FoxSchoolDialog.dart' as FoxSchoolDialog;
import '../../enum/VocabularyType.dart';
import '../../view/screen/VocabularyScreen.dart';

class MainFactoryController extends BlocController
{
  final int TYPE_LEVELS = 0;
  final int TYPE_CATEGORIES = 1;

  late List<SeriesInformationResult> _storyLevelItemList;
  late List<SeriesInformationResult> _storyCategoriesList;
  late List<SeriesInformationResult> _songCategoriesList;
  late List<MyBookshelfResult> _bookshelfList;
  late List<MyVocabularyResult> _vocabularyList;
  StorySeriesType _currentStorySeriesType = StorySeriesType.LEVEL;
  late MainInformationResult _mainData;
  late LoginInformationResult _userData;
  String _schoolName = "";
  String _userName = "";
  String _userClass = "";

  final BuildContext context;
  MainFactoryController({
    required this.context
  });

  @override
  void init() {
    _initData();
  }

  void _initData() async
  {
    await _loadMainData();
    _storyLevelItemList = _mainData.mainStoryInformation!.levelsList;
    _storyCategoriesList = _mainData.mainStoryInformation!.categoriesList;
    _songCategoriesList = _mainData.mainSongInformation;
    _bookshelfList = _mainData.bookshelfList;
    _vocabularyList =_mainData.vocabularyList;

    Logger.d("_vocabularyList data : ${_vocabularyList.toString()}");
    _settingStoryPageData(StorySeriesType.LEVEL);
    _settingSongPageData();
    _settingMyBooksData(MyBooksType.BOOKSHELF);
  }

  Future<void> _loadMainData() async
  {
    await _loadUserInformation();
    await _loadMainInformation();
  }

  Future<void> _loadUserInformation() async
  {
    Object? userObject = await Preference.getObject(Common.PARAMS_USER_API_INFORMATION);
    if (userObject != null) {
      _userData = LoginInformationResult.fromJson(userObject as Map<String, dynamic>);
      context.read<MainUserInformationCubit>().setUserInformation(
          _userData.userData!.name,
          _userData.schoolData!.className,
          _userData.schoolData!.name
      );
    }
  }

  Future<void> _loadMainInformation() async
  {
    Object? mainObject = await Preference.getObject(Common.PARAMS_FILE_MAIN_INFO);
    _mainData = MainInformationResult.fromJson(mainObject as Map<String, dynamic>);
  }

  void _checkUpdateMainData() async
  {
    if(MainObserver().isUpdate())
    {
      Logger.d(" 메인 데이터 업데이트 ");
      await _loadMainInformation();
      _bookshelfList = _mainData.bookshelfList;
      _vocabularyList =_mainData.vocabularyList;
      MainObserver().clear();
    }
  }

  void _settingStoryPageData(StorySeriesType type)
  {
    _currentStorySeriesType = type;
    if(type == StorySeriesType.LEVEL)
    {
      context.read<MainStorySelectTypeListCubit>().setSelectTypeList(StorySeriesType.LEVEL, _storyLevelItemList);
    }
    else
    {
      context.read<MainStorySelectTypeListCubit>().setSelectTypeList(StorySeriesType.CATEGORY, _storyCategoriesList);
    }
  }

  void _settingSongPageData()
  {
    context.read<MainSongCategoryListCubit>().setSongCategoryList(_songCategoriesList);
  }

  void _settingMyBooksData(MyBooksType type)
  {
    context.read<MainMyBooksTypeCubit>()
        .setMyBooksTypeData(
        type,
        _bookshelfList,
        _vocabularyList
    );
  }



  @override
  void onBackPressed() {
    Logger.d("");
    FoxSchoolDialog.showSelectDialog(
        context: context,
        message: getIt<FoxschoolLocalization>().data['message_check_end_app'],
        buttonText: getIt<FoxschoolLocalization>().data['text_confirm'],
        onSelected: () {
          SystemNavigator.pop(animated: true);
        },);
  }

  void onClickStorySelectType(StorySeriesType type)
  {
    Logger.d("type : ${type}");
    _settingStoryPageData(type);
  }

  void onClickMyBooksType(MyBooksType type)
  {
    _settingMyBooksData(type);
  }

  void onClickStorySeriesItem(SeriesInformationResult data, Widget widget)
  {
    if(_currentStorySeriesType == StorySeriesType.LEVEL) {
       Navigator.push(
        context,
          Page.getSeriesDetailListTransition(context, SeriesContentScreen(seriesBaseResult: data))
      ).then((value) {
        Logger.d(" ----- onResume");
        _checkUpdateMainData();
       });
    }
    else
    {
        Navigator.push(
          context,
          Page.getSeriesDetailListTransition(context, StoryCategoryListScreen(seriesBaseResult: data))
      ).then((value) {
          Logger.d(" ----- onResume");
          _checkUpdateMainData();
        });
    }
  }

  void onClickSongSeriesItem(SeriesInformationResult data, Widget widget)
  {
    Navigator.push(
        context,
        Page.getSeriesDetailListTransition(context, SeriesContentScreen(seriesBaseResult: data))
    );
  }

  void onClickMyBookshelf(int index)
  {
    Logger.d("index : $index");
    Navigator.push(context,
        Page.getDefaultTransition(context,
            MyBookshelfScreen(
                id: _mainData.bookshelfList[index].id,
                title: _mainData.bookshelfList[index].name)
        )
    ).then((value){
      Logger.d(" ----- onResume");
      _checkUpdateMainData();
    });
  }

  void onClickMyVocabulary(int index)
  {
    Logger.d("index : $index");
    VocabularyInformationData vocabularyInformationData = VocabularyInformationData(
        id: _mainData.vocabularyList[index].id,
        type: VocabularyType.VOCABULARY_SHELF,
        title: _mainData.vocabularyList[index].name);
    Navigator.push(
        context,
        Page.getDefaultTransition(context,
            VocabularyScreen(
                data: vocabularyInformationData)
        )
    ).then((value){
      Logger.d(" ----- onResume");
      _checkUpdateMainData();
    });
  }

  void onClickSearch()
  {
    Navigator.push(
        context,
        Page.getDefaultTransition(context,  const SearchScreen())
    );
  }

  void onClickLogout() async
  {
    await Preference.setBoolean(Common.PARAMS_IS_AUTO_LOGIN_DATA, false);
    await Preference.setObject(Common.PARAMS_USER_API_INFORMATION, null);
    Navigator.pushAndRemoveUntil(
        context,
        Page.getLogoutTransition(context),
       (route) => false,
    );
  }

  void onClickCreateMyBooks(ManagementMyBooksStatus status)
  {
    Logger.d("status : $status");
    Navigator.push(context,
        Page.getDefaultTransition(context,
            ManagementMyBooksScreen(status: status))
    ).then((value){
      Logger.d(" ----- onResume");
      _checkUpdateMainData();
    });
  }

  void onClickModifyMyBooks(ManagementMyBooksStatus status, int index)
  {
    ManagementMyBooksScreen screen;

    if(status == ManagementMyBooksStatus.BOOKSHELF_MODIFY)
      {
        screen = ManagementMyBooksScreen(
            status: status,
            id: _mainData.bookshelfList[index].id,
            name: _mainData.bookshelfList[index].name,
            type: CommonUtils.getInstance(context).getMyBooksType(_mainData.bookshelfList[index].color));
      }
    else
      {
        screen = ManagementMyBooksScreen(
            status: status,
            id: _mainData.vocabularyList[index].id,
            name: _mainData.vocabularyList[index].name,
            type: CommonUtils.getInstance(context).getMyBooksType(_mainData.vocabularyList[index].color));
      }

    Navigator.push(context,
        Page.getDefaultTransition(context,
            screen)
    ).then((value){
      Logger.d(" ----- onResume");
      _checkUpdateMainData();
    });
  }
}