import 'package:flutter/material.dart';
import 'package:foxschool/view/widget/RobotoBoldText.dart';

import '../../common/CommonUtils.dart';
import '../../enum/TopTitleButtonType.dart';
import '../../values/AppColors.dart';

class TopTitleView extends StatelessWidget {
  final String title;
  final TopTitleButtonType type;
  final VoidCallback onPressed;
  const TopTitleView({super.key,
    required this.title,
    required this.type,
    required this.onPressed});

  @override
  Widget build(BuildContext context)
  {
    if(type == TopTitleButtonType.BACK)
      {
        return _BackButtonWidget(context);
      }
    else
      {
        return _CloseButtonWidget(context);
      }
  }

  Widget _BackButtonWidget(BuildContext context)
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: CommonUtils.getInstance(context).getHeight(145),
      color: AppColors.color_23cc8a,
      child: Stack(
        children: [
          Positioned(
            top: CommonUtils.getInstance(context).getWidth(45),
            left: CommonUtils.getInstance(context).getWidth(40),
            child: GestureDetector(
                onTap: onPressed,
                child: Icon(Icons.arrow_back, color: Colors.white,
                  size: CommonUtils.getInstance(context).getWidth(80),
                )
            ),
          ),
          Center(
            child: RobotoBoldText(
              text: title,
              fontSize: CommonUtils.getInstance(context).getWidth(50),
            ),
          ),

        ],
      ),
    );
  }

  Widget _CloseButtonWidget(BuildContext context)
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: CommonUtils.getInstance(context).getHeight(145),
      color: AppColors.color_23cc8a,
      child: Stack(
        children: [
          Center(
            child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: CommonUtils.getInstance(context).getWidth(50),
                  fontFamily: 'Roboto'
              ),),
          ),
          Positioned(
            top: CommonUtils.getInstance(context).getWidth(35),
            right: CommonUtils.getInstance(context).getWidth(40),
            child: GestureDetector(
                onTap: onPressed,
                child: Icon(Icons.close, color: Colors.white,
                size: CommonUtils.getInstance(context).getWidth(80),)
            ),
          ),
        ],
      ),
    );
  }
}
