

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_cubit.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_body.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_view_cache.dart';


class UserVideoCallScreen extends StatelessWidget {
  const UserVideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final cache = VideoViewCache(
      repo: context.read<UserCallBloc>().repository,
    );

    cache.localView; // triggers lazy build if engine is ready

    return BlocProvider<VideoCallCubit>(
      create: (_) => VideoCallCubit(),
      child: VideoCallBody(cache: cache),
    );
  }
}
