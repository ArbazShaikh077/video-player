import 'package:get_it/get_it.dart';
import 'package:video_player_application/feature/cubit/duration_bloc.dart';
import 'package:video_player_application/feature/cubit/video_bloc.dart';
import 'package:video_player_application/domain/video_handler.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  /// Bloc for handling the video event
  getIt.registerLazySingleton<VideoBloc>(() => VideoBloc());

  /// Bloc for handling the duration event
  getIt.registerLazySingleton<DurationBloc>(() => DurationBloc());

  /// Bloc for handling video processing
  getIt.registerLazySingleton<VideoHandler>(() => VideoHandler());
}
