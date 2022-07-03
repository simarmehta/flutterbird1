import 'package:flappy_bird/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MyBarrier extends StatelessWidget {
  final double heightRatio;
  final double widthRatio;
  final int skyFlexRatio;
  final int groundFlexRatio;

  const MyBarrier(
      {Key? key,
      required this.heightRatio,
      required this.widthRatio,
      required this.skyFlexRatio,
      required this.groundFlexRatio})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width *
          heightRatio *
          skyFlexRatio /
          (skyFlexRatio + groundFlexRatio),
      width: MediaQuery.of(context).size.width * widthRatio,
      decoration: BoxDecoration(
          color: AppColors.green,
          border: Border.all(width: 10, color: AppColors.darkGreen),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}
