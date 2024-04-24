import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:foxschool/api/remote_intro/FoxSchoolRepository.dart';
import 'package:foxschool/bloc/category_contents_list/api/CategoryContentsDataBloc.dart';
import 'package:foxschool/bloc/category_contents_list/factory/cubit/CategoryItemListCubit.dart';
import 'package:foxschool/bloc/intro/api/IntroBloc.dart';
import 'package:foxschool/bloc/intro/factory/cubit/IntroProgressPercentCubit.dart';
import 'package:foxschool/bloc/intro/factory/cubit/IntroScreenTypeCubit.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginAutoCheckCubit.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginFindSchoolListCubit.dart';
import 'package:foxschool/bloc/login/factory/cubit/LoginSchoolNameCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainMyBooksTypeCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainSongCategoryListCubit.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainStorySelectTypeListCubit.dart';
import 'package:foxschool/bloc/movie/api/MovieContentsBloc.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MovieCaptionTextCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayCompleteCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayTitleCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayerMenuCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MovieSeekProgressCubit.dart';
import 'package:foxschool/bloc/observer/FoxschoolBlocObserver.dart';
import 'package:foxschool/bloc/search/api/SearchContentsBloc.dart';
import 'package:foxschool/bloc/search/factory/cubit/SearchItemListCubit.dart';
import 'package:foxschool/bloc/search/factory/cubit/SearchTypeCubit.dart';
import 'package:foxschool/bloc/series_contents_list/api/SeriesContentsListBloc.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/EnableBottomSelectViewCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/EnableInformationIconViewCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/EnableSeriesDataViewCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/LastWatchSeriesItemCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/SelectItemCountCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/SeriesItemListCubit.dart';
import 'package:foxschool/common/CommonHttpOverrides.dart';
import 'package:foxschool/common/CommonUtils.dart';
import 'package:foxschool/values/AppColors.dart';
import 'package:foxschool/view/screen/IntroScreen.dart';
import 'package:foxschool/view/screen/LoginScreen.dart';
import 'package:foxschool/view/screen/SearchScreen.dart';
import 'package:foxschool/view/screen/webview/FoxschoolIntroduceScreen.dart';
import 'package:foxschool/di/Dependencies.dart' as Dependencies;
import 'package:foxschool/view/widget/RobotoBoldText.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import '../../common/Preference.dart' as Preference;

import 'bloc/login/api/LoginBloc.dart';
import 'bloc/movie/factory/cubit/MoviePlayListCubit.dart';
import 'bloc/movie/factory/cubit/MoviePlayerSettingCubit.dart';
import 'common/Common.dart';
import 'data/base/BaseResponse.dart';
import 'di/Dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
  Preference.setString(Common.PARAMS_FIREBASE_PUSH_TOKEN, fcmToken);
  Logger.d("fcmToken : ${fcmToken}");

  //DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
 // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;


  const _androidIdPlugin = AndroidId();
  final String androidId = await _androidIdPlugin.getId() ?? "";
  await Preference.setString(Common.PARAMS_SECURE_ANDROID_ID, androidId);
  Logger.d("secureID : ${androidId}");

  Bloc.observer = FoxschoolBlocObserver();
  await Dependencies.init();
  HttpOverrides.global = CommonHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [

          /**
           *  Intro
           */
          BlocProvider(
            create: (context) => getIt<IntroBloc>(),
          ),
          BlocProvider(
            create: (context) => IntroScreenTypeCubit(),
          ),
          BlocProvider(
            create: (context) => IntroProgressPercentCubit(),
          ),

          /**
           *  Login
           */
          BlocProvider(
            create: (context) => getIt<LoginBloc>(),
          ),
          BlocProvider(create: (context) => LoginAutoCheckCubit()),
          BlocProvider(create: (context) => LoginFindSchoolListCubit()),
          BlocProvider(create: (context) => LoginSchoolNameCubit()),

          /**
           *  Main
           */
          BlocProvider(create: (context) => MainStorySelectTypeListCubit()),
          BlocProvider(create: (context) => MainSongCategoryListCubit()),
          BlocProvider(create: (context) => MainMyBooksTypeCubit()),

          /**
           *  SeriesContentsScreen
           */
          BlocProvider(
            create: (context) => getIt<SeriesContentsBloc>(),
          ),
          BlocProvider(create: (context) => EnableInformationIconViewCubit()),
          BlocProvider(create: (context) => EnableSeriesDataViewCubit()),
          BlocProvider(create: (context) => EnableBottomSelectViewCubit()),
          BlocProvider(create: (context) => LastWatchSeriesItemCubit()),
          BlocProvider(create: (context) => SeriesItemListCubit()),
          BlocProvider(create: (context) => SelectItemCountCubit()),

          /**
           * StoryCategoryListScreen
           */
          BlocProvider(
              create: (context) => getIt<CategoryContentsDataBloc>()
          ),
          BlocProvider(create: (context) => CategoryItemListCubit()),

          /**
           * Search
           */
          BlocProvider(
              create: (context) => getIt<SearchContentsBloc>()
          ),
          BlocProvider(create: (context) => SearchItemListCubit()),
          BlocProvider(create: (context) => SearchTypeCubit()),

          /**
           * Movie
           */
          BlocProvider(
              create: (context) => getIt<MovieContentsBloc>()
          ),
          BlocProvider(create: (context) => MoviePlayerSettingCubit()),
          BlocProvider(create: (context) => MoviePlayListCubit()),
          BlocProvider(create: (context) => MoviePlayTitleCubit()),
          BlocProvider(create: (context) => MoviePlayCompleteCubit()),
          BlocProvider(create: (context) => MovieSeekProgressCubit()),
          BlocProvider(create: (context) => MoviePlayerMenuCubit()),
          BlocProvider(create: (context) => MovieCaptionTextCubit())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: IntroScreen(),
        )
    );
  }
}