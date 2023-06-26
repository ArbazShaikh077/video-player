import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_application/core/dependency_injection.dart';
import 'package:video_player_application/feature/cubit/duration_bloc.dart';
import 'package:video_player_application/core/utils/slider_shape.dart';
import 'package:video_player_application/feature/cubit/video_bloc.dart';
import 'package:video_player_application/domain/video_handler.dart';

class VideoPlayers extends StatefulWidget {
  const VideoPlayers({super.key, required this.platformFile});
  final List<PlatformFile> platformFile;

  @override
  State<VideoPlayers> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayers> {
  VideoBloc videoBloc = getIt.get<VideoBloc>();
  DurationBloc durationBloc = getIt.get<DurationBloc>();

  @override
  void initState() {
    videoBloc.initializeVideoControllers(widget.platformFile);

    super.initState();
  }

  @override
  void dispose() {
    videoBloc.clearControllerList();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: videoBloc),
        BlocProvider.value(value: durationBloc),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: BlocBuilder<VideoBloc, VideoPlayerController?>(
                builder: (_, state) {
              if (state != null) {
                return AspectRatio(
                  aspectRatio: state.value.aspectRatio,
                  child: VideoPlayer(state),
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          BlocBuilder<DurationBloc, TimeHandler?>(builder: (_, state) {
            print(state);
            if (state != null) {
              int endValue = (state.endTime / 1000).round();
              int currentTime = (state.currentTime / 1000).round();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("00:${currentTime.toString().padLeft(2, '0')}"),
                        const Spacer(),
                        Text("00:${endValue.toString().padLeft(2, '0')}")
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        // here
                        trackShape: CustomTrackShape(),
                      ),
                      child: Slider(
                        value: currentTime.toDouble(),
                        onChanged: (value) {
                          durationBloc.seekTo(value);
                        },
                        min: 0.0,
                        max: endValue.toDouble(),
                      ),
                    )
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          }),
        ],
      ),
    ));
  }
}
