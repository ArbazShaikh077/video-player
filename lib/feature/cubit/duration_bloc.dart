import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player_application/core/dependency_injection.dart';
import 'package:video_player_application/domain/video_handler.dart';

class DurationBloc extends Cubit<TimeHandler?> {
  DurationBloc() : super(null);


  void updateTheDuration(TimeHandler duration) {
    emit(duration);
  }

  void clearDuration() {
    emit(null);
  }

  void seekTo(double time) {
    getIt<VideoHandler>().seekTo(time);
  }
}
