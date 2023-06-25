import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_application/dependency_injection.dart';
import 'package:video_player_application/video_handler.dart';

class VideoBloc extends Cubit<VideoPlayerController?> {
  VideoBloc() : super(null);

  /// Initialize list of controller and duration starts the first video
  void initializeVideoControllers(List<PlatformFile> files) async {
    final VideoHandler videoHandler = getIt<VideoHandler>();
    await videoHandler.initializeControllerList(files);
    await videoHandler.initializeDurationList(files);

    videoHandler.initializePlayer();
  }

/// Used to change the video by updating the video controller
  void play(VideoPlayerController controller) {
    emit(controller);
  }

/// Clear all the list after dispose of the screen
  void clearControllerList() async {
    await getIt<VideoHandler>().clearControllerList();
    emit(null);
  }
}
