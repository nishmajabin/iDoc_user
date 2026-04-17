import 'package:flutter_bloc/flutter_bloc.dart';

class InputBarCubit extends Cubit<bool> {
  InputBarCubit() : super(false); // false = no text

  void onTextChanged(String text) {
    final hasText = text.trim().isNotEmpty;
    if (hasText != state) emit(hasText);
  }
}