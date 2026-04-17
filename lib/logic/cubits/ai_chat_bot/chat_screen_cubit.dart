import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenCubit extends Cubit<int> {
  // State is a simple counter — each increment signals "scroll to bottom"
  ChatScreenCubit() : super(0);

  void scrollToBottom() => emit(state + 1);
}