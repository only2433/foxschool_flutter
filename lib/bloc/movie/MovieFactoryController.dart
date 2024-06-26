
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foxschool/bloc/base/BlocController.dart';

import 'package:foxschool/bloc/movie/api/MovieContentsBloc.dart';
import 'package:foxschool/bloc/movie/api/event/MovieContentsEvent.dart';
import 'package:foxschool/bloc/movie/api/state/MovieContentsLoadedState.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MovieCaptionTextCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayCompleteCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayListCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayTimeCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayTitleCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayerMenuCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MoviePlayerSettingCubit.dart';
import 'package:foxschool/bloc/movie/factory/cubit/MovieSeekProgressCubit.dart';
import 'package:foxschool/common/CommonUtils.dart';
import 'package:foxschool/data/movie/MovieItemResult.dart';
import 'package:foxschool/view/screen/IntroScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:foxschool/common/PageNavigator.dart' as Page;
import 'package:foxschool/common/Preference.dart' as Preference;
import '../../common/Common.dart';
import '../../data/contents/contents_base/ContentsBaseResult.dart';
import '../../view/widget/BottomContentLayoutWidget.dart';
import '../base/BlocState.dart';

class MovieFactoryController extends BlocController {
  VideoPlayerController? _controller;
  StreamSubscription? _subscription;
  int _currentPlayIndex = 0;
  int _currentCaptionIndex = 0;
  MovieItemResult? _currentItemResult;
  Timer? _progressTimer;
  bool _isMenuVisible = false;
  bool _isCaptionEnable = false;
  bool _isFullScreen = false;


  final BuildContext context;
  final List<ContentsBaseResult> playList;

  MovieFactoryController({
    required this.context,
    required this.playList
  });

  @override
  void init() async
  {
    Logger.d("");
    _settingSubscription();
    _readyToPlay();
  }


  void _initVideoController() async
  {
    await Future.delayed(Duration(milliseconds: Common.DURATION_LONG), () {
      _controller = VideoPlayerController.networkUrl(Uri.parse(
          '${_currentItemResult!.movieMP4Url}'));
    },);


    _controller!.initialize().then((value) async {
      _controller!.addListener(_initVideoListener);
      context.read<MoviePlayerSettingCubit>().setController(_controller!);

      await Future.delayed(Duration(milliseconds: Common.DURATION_NORMAL), () {
        _controller!.play();
        _settingPreparedView();
        _enableTimer(isEnable: true);
      },);
    });
  }

  void _initVideoListener() {
    if (_controller?.value.isPlaying == false && _controller?.value.position == _controller?.value.duration)
    {
      _enableTimer(isEnable: false);
      if (_currentPlayIndex == playList.length - 1)
      {
        Logger.d("플레이가 종료 되었습니다.");
        context.read<MovieSeekProgressCubit>().setInvisible();
        context.read<MoviePlayCompleteCubit>().showPlayCompleteView(true);
      }
      else {
        _currentPlayIndex++;
        _readyToPlay();
      }
    }
  }

  void _settingSubscription() {
    var blocState;
    _subscription = BlocProvider.of<MovieContentsBloc>(context).stream.listen((state) async {
      Logger.d("state.runtimeType : ${state.runtimeType}");
      switch (state.runtimeType) {
        case MovieContentsLoadedState:
          blocState = state as MovieContentsLoadedState;
          _currentItemResult = blocState.data;
          _initVideoController();
          break;
        case LoadingState:
          break;
        case ErrorState:
          Logger.d("context : ${context}");
          blocState = state as ErrorState;
          Fluttertoast.showToast(msg: blocState.message);
          await Preference.setBoolean(Common.PARAMS_IS_AUTO_LOGIN_DATA, false);
          await Preference.setString(Common.PARAMS_ACCESS_TOKEN, "");
          Navigator.pushAndRemoveUntil(
            context,
            Page.getLogoutTransition(context),
                (route) => false,
          );
          break;
      }
    });
  }


  void _readyToPlay() async
  {
    Logger.d("_currentPlayIndex : $_currentPlayIndex");
    _currentCaptionIndex = 0;
    _controller?.removeListener(_initVideoListener);
    _setMenuVisible(false);
    context.read<MovieCaptionTextCubit>().setText("");
    context.read<MovieSeekProgressCubit>().setPercent(0);
    context.read<MoviePlayCompleteCubit>().showPlayCompleteView(false);
    context.read<MoviePlayerSettingCubit>().showLoading();
    _setCurrentPlayItem(_currentPlayIndex);
    await Future.delayed(Duration(milliseconds: Common.DURATION_LONG), () {
      BlocProvider.of<MovieContentsBloc>(context).add(
          MovieContentsEvent(data: playList[_currentPlayIndex].id)
      );
    },);
  }

  void _setCurrentPlayItem(int index) {
    for (int i = 0; i < playList.length; i++) {
      if (i == index) {
        playList[i] = playList[i].setSelected(true);
        context.read<MoviePlayTitleCubit>().setTitle(playList[i].getContentsName());
      }
      else {
        playList[i] = playList[i].setSelected(false);
      }
    }
    context.read<MoviePlayListCubit>().setMoviePlayList(playList);
  }

  void _enableTimer({required bool isEnable})
  {
    if(isEnable)
    {
      _progressTimer = Timer.periodic(Duration(milliseconds: Common.DURATION_SHORTEST), (timer) {
        _updateUI();
      });
    }
    else
    {
      _progressTimer?.cancel();
      _progressTimer = null;
    }
  }

  void _updateUI()
  {
    double percent = (_controller!.value.position.inSeconds/_controller!.value.duration.inSeconds) * 100;
    context.read<MovieSeekProgressCubit>().setPercent(percent);

    var tempData = _controller!.value;
    Duration currentDuration = tempData.position;
    Duration remainDuration = tempData.duration;
    context.read<MoviePlayTimeCubit>().setPlayTime(
        CommonUtils.getInstance(context).getFormatDuration(currentDuration),
        CommonUtils.getInstance(context).getFormatDuration(remainDuration)
    );

    if(_isTimeForCaption())
      {
        context.read<MovieCaptionTextCubit>().setText(_currentItemResult!.captionList[_currentCaptionIndex].text);
        _currentCaptionIndex++;
      }
  }

  bool isMoviePlaying()
  {
    if(_controller!.value.isPlaying)
      {
        return true;
      }
    return false;
  }

  void _changePlayerButton(bool isMoviePlaying)
  {
    context.read<MoviePlayerMenuCubit>().changePlayButton(isMoviePlaying: isMoviePlaying);
  }

  void _setMenuVisible(bool isVisible)
  {
    _isMenuVisible = isVisible;
    context.read<MoviePlayerMenuCubit>().enableMenu(isEnable: _isMenuVisible);
  }

  void _setOrientation(bool isFullScreen) async
  {
    _isFullScreen = isFullScreen;
    if(_isFullScreen)
      {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      }
    else
      {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }

    _setMenuVisible(false);
    await Future.delayed(Duration(milliseconds: Common.DURATION_SHORT), () {
      _settingPreparedView();
    },);
  }

  void _settingPreparedView()
  {
    context.read<MoviePlayerMenuCubit>().changePlayButton(isMoviePlaying: isMoviePlaying());
    context.read<MoviePlayerMenuCubit>().enableCaptionButton(isEnable: _isCaptionEnable);
    context.read<MoviePlayTimeCubit>().setPlayTime(
        "--:--",
        "--:--"
    );
    _checkPrevNextButton();
  }

  void _checkPrevNextButton()
  {
    if(playList.length == 1)
    {
      context.read<MoviePlayerMenuCubit>().enablePrevButton(isEnable: false);
      context.read<MoviePlayerMenuCubit>().enableNextButton(isEnable: false);
    }
    else
    {
      if(_currentPlayIndex == 0)
      {
        context.read<MoviePlayerMenuCubit>().enablePrevButton(isEnable: false);
        context.read<MoviePlayerMenuCubit>().enableNextButton(isEnable: true);
      }
      else if(_currentPlayIndex == playList.length - 1)
      {
        context.read<MoviePlayerMenuCubit>().enablePrevButton(isEnable: true);
        context.read<MoviePlayerMenuCubit>().enableNextButton(isEnable: false);
      }
      else
      {
        context.read<MoviePlayerMenuCubit>().enablePrevButton(isEnable: true);
        context.read<MoviePlayerMenuCubit>().enableNextButton(isEnable: true);
      }
    }
  }

  bool _isTimeForCaption()
  {
    try
    {
      if(_currentCaptionIndex >= _currentItemResult!.captionList.length
          || _currentCaptionIndex == -1
          || _currentItemResult!.captionList.length <= 0)
      {
        return false;
      }
      int visibleTime = _currentItemResult!.captionList[_currentCaptionIndex].startTime;

      if(visibleTime <= _controller!.value.position.inMilliseconds)
      {
        return true;
      }
    }
    catch(e)
    {
      return false;
    }
    return false;
  }

  int _getCurrentCaptionIndex(int currentTime)
  {
    int startTime = 0;
    int endTime = 0;

    if(_currentItemResult!.captionList.isEmpty)
      {
        return -1;
      }
    startTime = _currentItemResult!.captionList[0].startTime;

    Logger.d("startTime : $startTime, position : ${currentTime}");
    if(startTime > currentTime)
      {
        return 0;
      }
    for(int i = 0 ; i < _currentItemResult!.captionList.length; i++)
      {
        startTime = _currentItemResult!.captionList[i].startTime;
        endTime = _currentItemResult!.captionList[i].endTime;
        if(startTime <= currentTime
            && endTime >= currentTime)
          {
            return i;
          }
      }
    for(int i = 0 ; i < _currentItemResult!.captionList.length; i++)
      {
        startTime = _currentItemResult!.captionList[i].startTime;
        if(startTime >= currentTime)
          {
            return i;
          }
      }
    return -1;
  }


  @override
  void dispose() {
    _setOrientation(false);
    _enableTimer(isEnable: false);
    _subscription?.cancel();
    _subscription = null;
    _controller?.removeListener(_initVideoListener);
    _controller?.dispose();
    Logger.d("_subscription cancel");
  }

  @override
  void onBackPressed() async {

    Logger.d("MediaQuery.of(context).orientation :  ${MediaQuery.of(context).orientation}");
    if(MediaQuery.of(context).orientation == Orientation.landscape)
      {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await Future.delayed(Duration(milliseconds: Common.DURATION_NORMAL),() {
          Navigator.of(context).pop();
        },);
      }
    else
      {
        Navigator.of(context).pop();
      }
  }

  void onClickPlayItem(int index) {
    Logger.d("index : $index");
    _currentPlayIndex = index;
    _controller?.pause();
    _enableTimer(isEnable: false);
    _readyToPlay();
  }

  void onClickReplay() {
    Logger.d("");
    _readyToPlay();
  }

  void onStartSeekProgress()
  {
    Logger.d("");
    _enableTimer(isEnable: false);
    context.read<MovieCaptionTextCubit>().setText("");
  }

  void onChangeSeekProgress(double value)
  {
    Logger.d("value : $value");
    context.read<MovieSeekProgressCubit>().setPercent(value);
  }

  void onEndSeekProgress(double value)
  {
    Logger.d("value : $value");
    double totalTime = _controller!.value.duration.inMilliseconds.toDouble();
    double seekTime = totalTime * (value / 100);
    _enableTimer(isEnable: true);
    _controller?.seekTo(Duration(milliseconds: seekTime.toInt()));
    _currentCaptionIndex = _getCurrentCaptionIndex(seekTime.toInt());
    Logger.d("_currentCaptionIndex : $_currentCaptionIndex");
  }

  void onClickMenu()
  {
    _setMenuVisible(!_isMenuVisible);
  }

  void onClickCaptionButton()
  {
    _isCaptionEnable = !_isCaptionEnable;
    context.read<MoviePlayerMenuCubit>().enableCaptionButton(isEnable: _isCaptionEnable);
  }

  void onClickPlayButton()
  {
    if(_controller!.value.isPlaying)
      {
        _controller!.pause();
        _changePlayerButton(false);
      }
    else
      {
        _controller!.play();
        _changePlayerButton(true);
      }
  }

  void onClickPrevButton()
  {
    _currentPlayIndex = _currentPlayIndex > 0 ? _currentPlayIndex - 1 : 0;
    _controller?.pause();
    _enableTimer(isEnable: false);
    _readyToPlay();
  }

  void onClickNextButton()
  {
    _currentPlayIndex = _currentPlayIndex < playList.length - 1 ? _currentPlayIndex + 1 : playList.length - 1;
    _controller?.pause();
    _enableTimer(isEnable: false);
    _readyToPlay();
  }

  void onClickZoomButton()
  {
    _setOrientation(!_isFullScreen);
  }
}