import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:foxschool/api/remote_intro/FoxSchoolRepository.dart';
import 'package:foxschool/bloc/intro/IntroBloc.dart';
import 'package:foxschool/bloc/login/LoginBloc.dart';
import 'package:foxschool/bloc/observer/FoxschoolBlocObserver.dart';
import 'package:foxschool/common/CommonUtils.dart';
import 'package:foxschool/route/RouteHelper.dart';
import 'package:foxschool/view/screen/IntroScreen.dart';
import 'package:foxschool/view/screen/LoginScreen.dart';
import 'package:foxschool/view/screen/webview/FoxschoolIntroduceScreen.dart';
import 'package:foxschool/di/Dependencies.dart' as Dependencies;
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import '../../common/Preference.dart' as Preference;

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => getIt<IntroBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<LoginBloc>(),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteHelper.getGenerateRoute,
          initialRoute: RouteHelper.getIntro(),
        )
    );
  }
}

