


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxschool/bloc/flashcard/factory/cubit/FlashcardBookmarkedCubit.dart';
import 'package:foxschool/bloc/flashcard/factory/state/FlashcardBookmarkedState.dart';
import 'package:foxschool/common/FoxschoolLocalization.dart';
import 'package:foxschool/view/widget/RobotoNormalText.dart';

import '../../../../bloc/flashcard/factory/FlashcardFactoryController.dart';
import '../../../../common/CommonUtils.dart';
import '../../../../di/Dependencies.dart';
import '../../../../values/AppColors.dart';

class FlashcardResultSubScreen extends StatelessWidget {
  final FlashcardFactoryController factoryController;
  FlashcardResultSubScreen({
    super.key, 
    required this.factoryController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/image/flashcard_result_bg_effect.png',
              width: CommonUtils.getInstance(context).getWidth(1598),
              height: CommonUtils.getInstance(context).getHeight(976),
              fit: BoxFit.cover),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image/flashcard_result_title.png',
                width: CommonUtils.getInstance(context).getWidth(726),
                height: CommonUtils.getInstance(context).getHeight(164),
                fit: BoxFit.contain),
              SizedBox(
                height: CommonUtils.getInstance(context).getHeight(36),
              ),
              Image.asset('assets/image/flashcard_result_image.png',
                width: CommonUtils.getInstance(context).getWidth(510),
                height: CommonUtils.getInstance(context).getHeight(478),
                fit: BoxFit.contain),
              SizedBox(
                height: CommonUtils.getInstance(context).getHeight(84),
              ),
              BlocBuilder<FlashcardBookmarkedCubit, FlashcardBookmarkedState>(builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        factoryController.onClickReplay();
                      },
                      child: Container(
                        width: CommonUtils.getInstance(context).getWidth(476),
                        height: CommonUtils.getInstance(context).getHeight(158),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/image/btn_flashcard_start_bg.png'),
                              fit: BoxFit.contain
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/image/flashcard_result_icon_replay.png',
                              width: CommonUtils.getInstance(context).getWidth(49),
                              height: CommonUtils.getInstance(context).getHeight(56),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                              width: CommonUtils.getInstance(context).getWidth(10),
                            ),
                            RobotoNormalText(
                                text: getIt<FoxschoolLocalization>().data['text_study_flashcard_replay'],
                                fontSize: CommonUtils.getInstance(context).getWidth(36),
                                color: AppColors.color_ffffff)
                          ],
                        ),
                      ),
                    ),

                    state.isBookmarked ? GestureDetector(
                      onTap: (){
                        factoryController.onClickBookmarkedPlay();
                      },
                      child: Container(
                        width: CommonUtils.getInstance(context).getWidth(476),
                        height: CommonUtils.getInstance(context).getHeight(158),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/image/btn_flashcard_start_bg02.png'),
                              fit: BoxFit.contain
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/image/flashcard_result_icon_bookmark.png',
                              width: CommonUtils.getInstance(context).getWidth(49),
                              height: CommonUtils.getInstance(context).getHeight(56),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                              width: CommonUtils.getInstance(context).getWidth(10),
                            ),
                            RobotoNormalText(
                                text: getIt<FoxschoolLocalization>().data['text_study_flashcard_bookmark'],
                                fontSize: CommonUtils.getInstance(context).getWidth(36),
                                color: AppColors.color_ffffff)
                          ],
                        ),
                      ),
                    ) : Container(),
                  ],
                );
              })
            ],
          )
        ],
      ),
    );
  }
}