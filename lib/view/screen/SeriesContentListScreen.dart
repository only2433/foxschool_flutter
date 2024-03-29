import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:foxschool/bloc/series_contents_list/factory/SeriesContentsListFactoryController.dart';
import 'package:foxschool/bloc/series_contents_list/factory/cubit/SeriesItemListCubit.dart';
import 'package:foxschool/bloc/series_contents_list/factory/state/SeriesItemListState.dart';
import 'package:foxschool/common/CommonUtils.dart';
import 'package:foxschool/view/widget/RobotoBoldText.dart';

import '../../common/Common.dart';
import '../../data/main/series/base/SeriesBaseResult.dart';
import '../../values/AppColors.dart';
import '../widget/ContentsListItemView.dart';

class SeriesContentListScreen extends StatefulWidget {

  final SeriesBaseResult seriesBaseResult;

  const SeriesContentListScreen({
    super.key,
    required this.seriesBaseResult});

  @override
  State<SeriesContentListScreen> createState() => _SeriesContentListScreenState();
}

class _SeriesContentListScreenState extends State<SeriesContentListScreen> with TickerProviderStateMixin  {

  late SeriesContentsListFactoryController _factoryController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _factoryController = SeriesContentsListFactoryController(
        context: context, currentSeriesBaseResult: widget.seriesBaseResult);
    _factoryController.init();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );


  }

  @override
  Widget build(BuildContext context) {

    Color statusBarColor = CommonUtils.getInstance(context).colorFromHex(widget.seriesBaseResult.colors!.statusBar);
    Color topBarColor = CommonUtils.getInstance(context).colorFromHex(widget.seriesBaseResult.colors!.title); 
    return Scaffold(
      backgroundColor: AppColors.color_edeef2,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: statusBarColor,
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: AppColors.color_edeef2,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: topBarColor,
                  toolbarHeight: CommonUtils.getInstance(context).getHeight(150),
                  expandedHeight: CommonUtils.getInstance(context).getHeight(607),
                  centerTitle: true,
                  title: RobotoBoldText(
                    text: widget.seriesBaseResult.name,
                    fontSize: CommonUtils.getInstance(context).getWidth(50),
                    color: AppColors.color_ffffff,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,

                    background: Hero(
                      tag: widget.seriesBaseResult.id,
                      child: Image.network(
                        widget.seriesBaseResult.thumbnailUrl,
                        height: CommonUtils.getInstance(context).getHeight(607),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  pinned: true,
                  floating: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                BlocBuilder<SeriesItemListCubit, SeriesDataBaseState>(
                  builder: (context, state) {
                    Logger.d("state : ${state.toString()}");
                    if (state is SeriesItemListState) {
                      _animationController.forward();
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                            return FadeTransition(
                              opacity: _animationController.drive(
                                Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).chain(
                                  CurveTween(
                                    curve: Interval(
                                      index * 0.1,
                                      1.0,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: index == 0 ?
                                    EdgeInsets.only(
                                      top: CommonUtils.getInstance(context).getHeight(40),
                                      bottom: CommonUtils.getInstance(context).getHeight(20),
                                      left: CommonUtils.getInstance(context).getWidth(25),
                                      right: CommonUtils.getInstance(context).getWidth(25)
                                    )
                                : EdgeInsets.only(
                                    bottom: CommonUtils.getInstance(context).getHeight(20),
                                    left: CommonUtils.getInstance(context).getWidth(25),
                                    right: CommonUtils.getInstance(context).getWidth(25)
                                ),
                                child: ContentsListItemView(
                                  thumbnailUrl: state.itemList[index].thumbnailUrl,
                                  index: state.itemList[index].index,
                                  indexColor: topBarColor,
                                  title: state.itemList[index].getSubName(),
                                  onThumbnailPressed: () {},
                                ),
                              ),
                            );
                          },
                          childCount: state.itemList.length,
                        ),
                      );
                    } else {
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.color_47e1ad,),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _factoryController.dispose();
    super.dispose();
  }
}
