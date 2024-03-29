import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxschool/bloc/main/factory/cubit/MainSongCategoryListCubit.dart';
import 'package:foxschool/view/widget/ThumbnailView.dart';

import '../../../../bloc/main/factory/MainFactoryController.dart';
import '../../../../bloc/main/factory/state/SongCategoryListState.dart';
import '../../../../common/CommonUtils.dart';
import '../../../../values/AppColors.dart';
import '../../../widget/RobotoBoldText.dart';

class MainSongSubScreen extends StatelessWidget {

  final MainFactoryController factoryController;
  const MainSongSubScreen({
    super.key,
    required this.factoryController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: AppColors.color_f5f5f5,
      child: Column(
        children: [
          SizedBox(
            height: CommonUtils.getInstance(context).getHeight(40),
          ),
          Expanded(
              child: BlocBuilder<MainSongCategoryListCubit, SongCategoryListState>(builder: (context, state)
              {
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: CommonUtils.getInstance(context).getHeight(10),
                      crossAxisSpacing: CommonUtils.getInstance(context).getHeight(10),
                      mainAxisExtent: CommonUtils.getInstance(context).getHeight(374),
                    ),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: CommonUtils.getInstance(context).getWidth(20)),
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      return ThumbnailView(
                        id: state.list[index].id,
                        imageUrl: state.list[index].thumbnailUrl,
                        title: '${state.list[index].contentsCount} 편',
                      );
                    },);
                },
              ))
        ],
      ),
    );
  }
}
