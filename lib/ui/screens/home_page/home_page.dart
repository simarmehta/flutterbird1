import 'dart:async';
import "dart:math";
import 'package:audioplayers/audioplayers.dart';
import 'package:flappy_bird/ui/screens/home_page/components/barriers.dart';
import 'package:flappy_bird/ui/screens/home_page/components/bird.dart';
import 'package:flappy_bird/ui/screens/home_page/components/constants.dart';
import 'package:flappy_bird/ui/theme/app_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // assets
  AudioPlayer audioPlayer = AudioPlayer();
  String changingFace = "lib/assets/images/download2.png";
  String firstSlogan = "";
  String secondSlogan = "";
  double birdSize = 0.15;

  //score related variables
  int score = 0;
  int bestScore = 0;
  String bestFaceImagePath = "lib/assets/images/question.png";
  String bestScoreSoundPath = "";

  // our bird or flappyFace and its motion related variables
  double birdYaxis = 0;
  double time = 0;
  double timeStep = 0.04;
  double height = 0;
  double initialHeight = 0; // late double initialHeight = birdYaxis;
  double velocity = 2.8;
  double acceleration = -4.9;
  double collisionTolerance = 0.98; // which means 2% is the tolerance

  //flex related variables
  int skyFlexRatio = 4;
  int groundFlexRatio = 1;

  // barriers
  // (-1, -1) means top left, (1, 1) means bottom right, (0, 0) is the center
  double barrierX1 = 1; // out of 2 total
  double barrierX2 = 2.7;
  double barrierYRatioBottom = -1.1;
  double barrierYRatioSky = 1.1;

  double barrierX1WidthRatio = 0.25; // 1 means the entire width of the sky area
  double barrierX1HeightRatio = 0.4; // 1 means the half of the sky area height

  double barrierX2WidthRatio = 0.3; // 1 means the entire width of the sky area
  double barrierX2HeightRatio = 0.6; // 1 means the half of the sky area height

  // game conditions
  bool gameHasStarted = false;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    getBestScoreAttributes();
  }

  void changeGameText() {
    setState(() {
      gameEnded = false;
    });
  }

  void endGame() {
    gameEnded = true;
    setState(() {
      gameEnded = true;
    });
    saveBestScoreAttributes();
  }

  void resetGame() {
    setState(() {
      birdYaxis = 0;
      time = 0;
      height = 0;
      initialHeight = birdYaxis;
      gameHasStarted = false;
      // changingFace = "lib/assets/flappy_face.png";
      score = 0;
      // int bestScore = 0;
      barrierX1 = 1;
      barrierX2 = 2.7;
    });
  }

  Future<void> saveBestScoreAttributes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("best score:$score > $bestScore");
    if (score >= bestScore) {
      await prefs.setInt("bestScoreInt", score);
      await prefs.setString("bestScoreImagePath", changingFace);
      await prefs.setString("bestScoreSoundPath", "");
    }
  }

  Future<void> getBestScoreAttributes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int? bestScoreIntTaken = prefs.getInt("bestScoreInt");
    final String? bestScoreImagePathTaken =
        prefs.getString("bestScoreImagePath");
    final String? bestScoreSoundPathTaken =
        prefs.getString("bestScoreSoundPath");
    debugPrint(bestScoreImagePathTaken);
    if (bestScoreIntTaken == null) {
      setState(() {
        bestScore = 0;
      });
    } else {
      setState(() {
        bestScore = bestScoreIntTaken;
      });
    }
    if (bestScoreImagePathTaken == null) {
      setState(() {
        bestFaceImagePath = "lib/assets/images/question.png";
      });
    } else {
      setState(() {
        bestFaceImagePath = bestScoreImagePathTaken;
      });
    }
    if (bestScoreSoundPathTaken == null) {
      setState(() {
        bestScoreSoundPath = "fillSound";
      });
    } else {
      setState(() {
        bestScoreSoundPath = bestScoreSoundPathTaken;
      });
    }
  }

  void playLocal() async {
    int takenAudio = await audioPlayer.play(bestScoreSoundPath, isLocal: true);
  }

  void changeFace() {
    final faces = [
      "lib/assets/images/download2.png",
      "lib/assets/images/download1.png",


    ];
    final randomSeed = Random();
    faces.remove(changingFace);
    var faceElement = faces[randomSeed.nextInt(faces.length)];
    // debugPrint(faceElement);

    setState(() {
      changingFace = faceElement;
    });
  }

  void changeSlogan() {
    var takenSloganList = faceSlogans[changingFace]!;
    print(changingFace);
    print(takenSloganList);
    setState(() {
      firstSlogan = takenSloganList[0];
      secondSlogan = takenSloganList[1];
    });
  }

  void jump() {
    changeFace();
    changeSlogan();
    setState(() {
      time = 0;
      score += 1;
      initialHeight = birdYaxis;
    });
  }

  bool faceDead() {
    if (birdYaxis < -1.3 || birdYaxis > 1.3) {
      debugPrint("sky or ground is passed");
      return true;
    }
    if (-1 * barrierX1HeightRatio > birdYaxis + birdSize * collisionTolerance &&
        birdYaxis < 0 &&
        (barrierX1 - barrierX1WidthRatio / 4 < birdSize / 2 && barrierX1 > 0)) {
      debugPrint("barrier1 sky");
      return true; // done
    }

    if (barrierX1HeightRatio < birdYaxis - birdSize * collisionTolerance &&
        birdYaxis > 0 &&
        (barrierX1 - barrierX1WidthRatio / 4 < birdSize / 2 && barrierX1 > 0)) {
      debugPrint("barrier1 ground");
      return true;
    }

    if (-1 * barrierX2HeightRatio > birdYaxis + birdSize * collisionTolerance &&
        birdYaxis < 0 &&
        (barrierX2 - barrierX2WidthRatio / 4 < birdSize / 2 && barrierX2 > 0)) {
      debugPrint("barrier2 sky");
      return true; // done
    }

    if (barrierX2HeightRatio < birdYaxis + birdSize * collisionTolerance * 2 &&
        birdYaxis > 0 &&
        (barrierX2 - barrierX2WidthRatio / 2 < birdSize / 2 && barrierX2 > 0)) {
      debugPrint("barrier1 ground");
      return true;
    }
    return false;
  }

  void startGame() {
    setState(() {
      gameHasStarted = true;
    });
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      time += timeStep;
      height = acceleration * time * time + velocity * time;
      setState(() {
        birdYaxis = initialHeight - height;
        debugPrint(birdYaxis.toString());
      });
      setState(() {
        if (barrierX1 < -1.9) {
          barrierX1 += 4.0;
        } else {
          barrierX1 -= 0.05;
        }
      });
      setState(() {
        if (barrierX2 < -2.2) {
          barrierX2 += 4.5;
        } else {
          barrierX2 -= 0.05;
        }
      });

      if (faceDead()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void onTapFunction() {
    // debugPrint("game started: " + gameHasStarted.toString());
    if (gameEnded) {
      // print(1);
      debugPrint("game is ended");
      getBestScoreAttributes();
      changeGameText();
      resetGame();
    } else if (gameHasStarted) {
      // print(2);
      gameHasStarted = gameHasStarted ? true : false;
      debugPrint("game continues");
      jump();
    } else {
      // print(3);
      getBestScoreAttributes();
      debugPrint("game is started");
      startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTapFunction,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                  flex: skyFlexRatio,
                  child: Stack(children: [
                    AnimatedContainer(
                      alignment: Alignment(0, birdYaxis),
                      duration: const Duration(milliseconds: 0),
                      color: AppColors.blue,
                      child: MyFlappy(
                        face: changingFace,
                        size: birdSize,
                      ),
                    ),
                    AnimatedContainer(
                        alignment: Alignment(barrierX1, barrierYRatioBottom),
                        duration: const Duration(milliseconds: 0),
                        child: MyBarrier(
                          widthRatio: barrierX1WidthRatio,
                          heightRatio: barrierX1HeightRatio,
                          skyFlexRatio: skyFlexRatio,
                          groundFlexRatio: groundFlexRatio,
                        )),
                    AnimatedContainer(
                        alignment: Alignment(barrierX1, barrierYRatioSky),
                        duration: const Duration(milliseconds: 0),
                        child: MyBarrier(
                          widthRatio: barrierX1WidthRatio,
                          heightRatio: barrierX1HeightRatio,
                          skyFlexRatio: skyFlexRatio,
                          groundFlexRatio: groundFlexRatio,
                        )),
                    AnimatedContainer(
                        alignment: Alignment(barrierX2, barrierYRatioBottom),
                        duration: const Duration(milliseconds: 0),
                        child: MyBarrier(
                          widthRatio: barrierX2WidthRatio,
                          heightRatio: barrierX2HeightRatio,
                          skyFlexRatio: skyFlexRatio,
                          groundFlexRatio: groundFlexRatio,
                        )),
                    AnimatedContainer(
                        alignment: Alignment(barrierX2, barrierYRatioSky),
                        duration: const Duration(milliseconds: 0),
                        child: MyBarrier(
                          widthRatio: barrierX2WidthRatio,
                          heightRatio: barrierX2HeightRatio,
                          skyFlexRatio: skyFlexRatio,
                          groundFlexRatio: groundFlexRatio,
                        )),
                    Container(
                      alignment: const Alignment(0, -0.3),
                      child: !gameHasStarted && !gameEnded
                          ? const Text(
                              "B I R D",
                              style: TextStyle(
                                  fontSize: 30, color: AppColors.white),
                            )
                          : null,
                    ),
                    Container(
                      alignment: const Alignment(0, -0.3),
                      child: gameEnded
                          ? Text(
                              firstSlogan,
                              style: const TextStyle(
                                  fontSize: 20, color: AppColors.white),
                            )
                          : null,
                    ),
                    Container(
                      alignment: const Alignment(0, -0.1),
                      child: gameEnded
                          ? Text(
                              secondSlogan,
                              style: const TextStyle(
                                  fontSize: 20, color: AppColors.white),
                            )
                          : null,
                    ),
                  ])),
              Container(
                height: 15,
                color: AppColors.green,
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.brown,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "S C O R E",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "$score",
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 35),
                            )
                          ],
                        ),
                        // NeumorphicButton(
                        //   onPressed: onTapFunction,
                        //   style: NeumorphicStyle(
                        //       shape: NeumorphicShape.concave,
                        //       boxShape: NeumorphicBoxShape.roundRect(
                        //           BorderRadius.circular(100)),
                        //       depth: 0,
                        //       lightSource: LightSource.topRight,
                        //       color: Colors.transparent),
                        //   child: MyFlappy(
                        //     face: bestFaceImagePath,
                        //     size: birdSize,
                        //   ),
                        // ),
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     const Text(
                        //       "En İyi",
                        //       style: TextStyle(
                        //           color: AppColors.white, fontSize: 20),
                        //     ),
                        //     const SizedBox(
                        //       height: 15,
                        //     ),
                        //     Text(
                        //       "$bestScore",
                        //       style: const TextStyle(
                        //           color: AppColors.white, fontSize: 35),
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }
}
