import "package:flutter/material.dart";

class MyFlappy extends StatelessWidget {
  const MyFlappy({Key? key, required this.face, required this.size}) : super(key: key);
  final String face;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Image.asset(
        face,
        height: MediaQuery.of(context).size.width * 0.25 ,
        width: MediaQuery.of(context).size.width * 0.25,
        // "lib/assets/flappy_face.png",
        // height: 48,
        // width: 48,
      ),
    );
  }
}
