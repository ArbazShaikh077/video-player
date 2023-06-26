import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_application/core/dependency_injection.dart';
import 'package:video_player_application/feature/cubit/duration_bloc.dart';
import 'package:video_player_application/feature/cubit/video_bloc.dart';

class VideoHandler {
  /// Contains list of controller and duration as combine object
  List<ControllerWithDuration> listOfController = [];

  /// Bloc for updating the video part of the screen
  VideoBloc videoBloc = getIt.get<VideoBloc>();

  /// Bloc for updating the duration part of the screen
  DurationBloc durationBloc = getIt.get<DurationBloc>();

  /// contains currently active index of VideoController
  int currentlyActiveControllerIndex = 0;

  /// Timer for changing the video controller and change the current video with next video
  Timer? videoTimeHandler;

  /// Holds current time of the video in millisecond
  double currentPosition = 0;

  /// Only contains list of video controller
  List<VideoPlayerController> controllerList = [];

  /// Only contains list of duration
  List<double> listOfDuration = [];

  double currentTimer = 0;

  /// Used to initialize all video controller
  /// And start the first video
  void initializePlayer() {
    for (int i = 0; i < controllerList.length; i++) {
      listOfController.add(ControllerWithDuration(
          controller: controllerList[i], duration: listOfDuration[i]));
    }
    playVideo();
  }

  /// Used for setting list of controller
  Future<void> initializeControllerList(List<PlatformFile> files) async {
    await Future.forEach(files, (element) async {
      VideoPlayerController controller =
          VideoPlayerController.file(File(element.path!));
      await controller.initialize();
      controllerList.add(controller);
    });
  }

  /// Used for setting list of duration
  Future<void> initializeDurationList(List<PlatformFile> files) async {
    FlutterVideoInfo videoInfo = FlutterVideoInfo();

    await Future.forEach(files, (element) async {
      VideoData? videoInfoData = await videoInfo.getVideoInfo(element.path!);
      double? duration = videoInfoData?.duration;
      listOfDuration.add(duration ?? 0);
    });
  }

  /// Method used for cleanup
  Future<void> clearControllerList() async {
    await Future.forEach(listOfController, (element) async {
      await element.controller.dispose();
    });

    currentPosition = 0.0;
    currentTimer = 0.0;
    durationBloc.clearDuration();

    /// Mark the first video controller as active for next time
    currentlyActiveControllerIndex = 0;
    listOfController.clear();
    controllerList.clear();
    listOfDuration.clear();
    videoTimeHandler?.cancel();
  }

  void playVideo() async {
    /// Initially start the play for the first video controller
    await listOfController[currentlyActiveControllerIndex].controller.play();

    double totalDuration = 0.0;
    for (var element in listOfController) {
      totalDuration = totalDuration + element.duration;
    }

    /// Check if only one video select then there is no need to play next video
    if (listOfController.length > 1) {
      /// Check every millisecond that the current video completes its duration or not
      /// If it's complete the duration then mark the next video controller as active and play the next video

      videoTimeHandler =
          Timer.periodic(const Duration(milliseconds: 1), (timer) async {
        currentPosition = currentPosition + 1;
        currentTimer = currentTimer + 1;
        durationBloc.updateTheDuration(TimeHandler(
          initialTime: 0.0,
          endTime: totalDuration,
          currentTime: currentTimer,
        ));

        if (listOfController.length > 1 &&
            listOfController[currentlyActiveControllerIndex].duration ==
                currentPosition) {
          if (currentlyActiveControllerIndex != (listOfController.length - 1)) {
            currentlyActiveControllerIndex = currentlyActiveControllerIndex + 1;
            await listOfController[currentlyActiveControllerIndex]
                .controller
                .play();

            /// Again initialize as 0 to play next video complete because currentPosition must holds value according to video not the sum of the video duration
            currentPosition = 0;
            videoBloc.play(
                listOfController[currentlyActiveControllerIndex].controller);
          } else {
            videoTimeHandler?.cancel();
            currentlyActiveControllerIndex = 0;
            return;
          }
        }
      });
    }
    listOfController[currentlyActiveControllerIndex].controller.addListener(() async{ 
      int time = (await listOfController[currentlyActiveControllerIndex].controller.position)?.inMilliseconds ?? 0;
      durationBloc.updateTheDuration(TimeHandler(initialTime: 0.0, endTime: totalDuration, currentTime: time.toDouble()));
    });

    videoBloc.play(listOfController[currentlyActiveControllerIndex].controller);
  }

  void seekTo(double seconds)async{

    /// Handle the seek controller for single videos
    if(listOfController.length < 2){
      await listOfController[currentlyActiveControllerIndex].controller.seekTo(Duration(seconds:seconds.toInt()));
    }
    else{
      // Todo : Handle multiple videos seek controller
    }
  }
}

class ControllerWithDuration {
  final VideoPlayerController controller;
  final double duration;

  ControllerWithDuration({required this.controller, required this.duration});
}

class TimeHandler {
  final double initialTime;
  final double endTime;
  final double currentTime;

  TimeHandler(
      {required this.initialTime,
      required this.endTime,
      required this.currentTime});
}
