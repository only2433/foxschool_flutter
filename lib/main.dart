import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardBookmarkedCubit.dart';
import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardConstituteWidgetCubit.dart';
import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardHelpPageCubit.dart';
import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardOptionSelectCubit.dart';
import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardStudyCurrentIndexCubit.dart';
import 'package:foxschool/presentation/bloc/flashcard/factory/cubit/FlashcardStudyListUpdateCubit.dart';
import 'package:foxschool/presentation/bloc/movie/api/MovieContentsBloc.dart';
import 'package:foxschool/presentation/bloc/movie/factory/cubit/MovieCaptionTextCubit.dart';
import 'package:foxschool/presentation/bloc/movie/factory/cubit/MoviePlayCompleteCubit.dart';
import 'package:foxschool/presentation/bloc/movie/factory/cubit/MoviePlayTitleCubit.dart';
import 'package:foxschool/presentation/bloc/movie/factory/cubit/MoviePlayerMenuCubit.dart';
import 'package:foxschool/presentation/bloc/movie/factory/cubit/MovieSeekProgressCubit.dart';
import 'package:foxschool/presentation/bloc/vocabulary/api/VocabularyBloc.dart';
import 'package:foxschool/presentation/bloc/vocabulary/factory/cubit/VocabularyBottomControllerCubit.dart';
import 'package:foxschool/presentation/bloc/vocabulary/factory/cubit/VocabularyItemListCubit.dart';
import 'package:foxschool/presentation/bloc/vocabulary/factory/cubit/VocabularyPlayingCubit.dart';
import 'package:foxschool/presentation/bloc/vocabulary/factory/cubit/VocabularyStudyTypeCubit.dart';
import 'package:foxschool/common/CommonHttpOverrides.dart';
import 'package:foxschool/presentation/view/screen/IntroScreen.dart';
import 'package:foxschool/di/Dependencies.dart' as Dependencies;
import 'package:foxschool/common/Preference.dart' as Preference;
import 'presentation/bloc/base/observer/FoxschoolBlocObserver.dart';
import 'presentation/bloc/flashcard/api/FlashcardBloc.dart';
import 'presentation/bloc/flashcard/factory/cubit/FlashcardBookmarkOptionSelectCubit.dart';
import 'presentation/bloc/movie/factory/cubit/MoviePlayListCubit.dart';
import 'presentation/bloc/movie/factory/cubit/MoviePlayTimeCubit.dart';
import 'presentation/bloc/movie/factory/cubit/MoviePlayerSettingCubit.dart';
import 'common/Common.dart';
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
      const ProviderScope(
          child: MyApp())
  );
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return  MultiBlocProvider(providers: [


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
    BlocProvider(create: (context) => MovieCaptionTextCubit()),
    BlocProvider(create: (context) => MoviePlayTimeCubit()),

    /**
    * Vocabulary
    */
    BlocProvider(
    create: (context) => getIt<VocabularyBloc>()),
    BlocProvider(create: (context) => VocabularyItemListCubit()),
    BlocProvider(create: (context) => VocabularyPlayingCubit()),
    BlocProvider(create: (context) => VocabularyBottomControllerCubit()),
    BlocProvider(create: (context) => VocabularyStudyTypeCubit()),


    BlocProvider(create: (context) => getIt<FlashcardBloc>()),
    BlocProvider(create: (context) => FlashcardConstituteWidgetCubit()),
    BlocProvider(create: (context) => FlashcardHelpPageCubit()),
    BlocProvider(create: (context) => FlashcardOptionSelectCubit()),
    BlocProvider(create: (context) => FlashcardBookmarkOptionSelectCubit()),
    BlocProvider(create: (context) => FlashcardBookmarkedCubit()),
    BlocProvider(create: (context) => FlashcardStudyCurrentIndexCubit()),
    BlocProvider(create: (context) => FlashcardStudyListUpdateCubit()),
    ], child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    )
    );

    /*return MultiBlocProvider(
        providers: [

          *//**
           *  Intro
           *//*
          BlocProvider(
            create: (context) => getIt<IntroBloc>(),
          ),
          BlocProvider(
            create: (context) => IntroScreenTypeCubit(),
          ),
          BlocProvider(
            create: (context) => IntroProgressPercentCubit(),
          ),

          *//**
           *  Login
           *//*
          BlocProvider(
            create: (context) => getIt<LoginBloc>(),
          ),
          BlocProvider(create: (context) => LoginAutoCheckCubit()),
          BlocProvider(create: (context) => LoginFindSchoolListCubit()),
          BlocProvider(create: (context) => LoginSchoolNameCubit()),

          *//**
           *  Main
           *//*
          BlocProvider(create: (context) => MainUserInformationCubit()),
          BlocProvider(create: (context) => MainStorySelectTypeListCubit()),
          BlocProvider(create: (context) => MainSongCategoryListCubit()),
          BlocProvider(create: (context) => MainMyBooksTypeCubit()),

          *//**
           *  SeriesContentsScreen
           *//*
          BlocProvider(
            create: (context) => getIt<SeriesContentsBloc>(),
          ),
          BlocProvider(create: (context) => SeriesEnableInformationViewCubit()),
          BlocProvider(create: (context) => SeriesDataViewCubit()),
          BlocProvider(create: (context) => SeriesLastWatchItemCubit()),
          BlocProvider(create: (context) => SeriesTitleColorCubit()),

          *//**
           * StoryCategoryListScreen
           *//*
          BlocProvider(
              create: (context) => getIt<CategoryContentsDataBloc>()
          ),
          BlocProvider(create: (context) => CategoryItemListCubit()),
          BlocProvider(create: (context) => CategoryTitleColorCubit()),
          *//**
           * Search
           *//*
          BlocProvider(
              create: (context) => getIt<SearchContentsBloc>()
          ),
          BlocProvider(create: (context) => SearchItemListCubit()),
          BlocProvider(create: (context) => SearchTypeCubit()),

          *//**
           * Movie
           *//*
          BlocProvider(
              create: (context) => getIt<MovieContentsBloc>()
          ),
          BlocProvider(create: (context) => MoviePlayerSettingCubit()),
          BlocProvider(create: (context) => MoviePlayListCubit()),
          BlocProvider(create: (context) => MoviePlayTitleCubit()),
          BlocProvider(create: (context) => MoviePlayCompleteCubit()),
          BlocProvider(create: (context) => MovieSeekProgressCubit()),
          BlocProvider(create: (context) => MoviePlayerMenuCubit()),
          BlocProvider(create: (context) => MovieCaptionTextCubit()),
          BlocProvider(create: (context) => MoviePlayTimeCubit()),

          *//**
           * QUIZ
           *//*
          BlocProvider(
              create: (context) => getIt<QuizInformationBloc>()),
          BlocProvider(create: (context) => QuizReadyDataCubit()),
          BlocProvider(create: (context) => QuizEnableTaskboxCubit()),
          BlocProvider(create: (context) => QuizConstituteWidgetCubit()),
          BlocProvider(create: (context) => QuizRemainTimeCubit()),
          BlocProvider(create: (context) => QuizCorrectCountCubit()),

          *//**
           * Vocabulary
           *//*
          BlocProvider(
              create: (context) => getIt<VocabularyBloc>()),
          BlocProvider(create: (context) => VocabularyItemListCubit()),
          BlocProvider(create: (context) => VocabularyPlayingCubit()),
          BlocProvider(create: (context) => VocabularyBottomControllerCubit()),
          BlocProvider(create: (context) => VocabularyStudyTypeCubit()),

          *//**
           * Management MyBooks
           *//*
          BlocProvider(
              create: (context) => getIt<ManagementMyBooksBloc>()),
          BlocProvider(create: (context) => MyBooksUpdateNameCubit()),
          BlocProvider(create: (context) => MyBooksUpdateColorCubit()),

          *//**
           * MyBookshelf
           *//*
          BlocProvider(create: (context) => getIt<MyBookshelfBloc>()),
          BlocProvider(create: (context) => ContentsEnableBottomViewCubit()),
          BlocProvider(create: (context) => ContentsItemListCubit()),
          BlocProvider(create: (context) => ContentsSelectItemCountCubit()),

          *//**
           * MyBookshelf
           *//*
          BlocProvider(create: (context) => getIt<MyBookshelfBloc>()),

          BlocProvider(create: (context) => getIt<FlashcardBloc>()),
          BlocProvider(create: (context) => FlashcardConstituteWidgetCubit()),
          BlocProvider(create: (context) => FlashcardHelpPageCubit()),
          BlocProvider(create: (context) => FlashcardOptionSelectCubit()),
          BlocProvider(create: (context) => FlashcardBookmarkOptionSelectCubit()),
          BlocProvider(create: (context) => FlashcardBookmarkedCubit()),
          BlocProvider(create: (context) => FlashcardStudyCurrentIndexCubit()),
          BlocProvider(create: (context) => FlashcardStudyListUpdateCubit()),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: IntroScreen(),
        )
    );*/
  }
}

