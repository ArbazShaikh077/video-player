
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_application/dependency_injection.dart';
import 'package:video_player_application/duration_bloc.dart';
import 'package:video_player_application/video_bloc.dart';

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
         const SizedBox(height: 10,),
          BlocBuilder<DurationBloc, double?>(builder: (_, state) {
            if (state != null) {
              return Text((state / 1000).toString(),style: const TextStyle(color: Colors.black),);
            }
            return const CircularProgressIndicator();
          }),
        ],
      ),
    ));
  }
}
