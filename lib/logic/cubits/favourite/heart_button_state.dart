import 'package:equatable/equatable.dart';

final class HeartButtonState extends Equatable {
  const HeartButtonState({
    this.scale = 1.0,
    this.showDialog = false,
  });

  final double scale;
  final bool showDialog;

  HeartButtonState copyWith({
    double? scale,
    bool? showDialog,
  }) =>
      HeartButtonState(
        scale: scale ?? this.scale,
        showDialog: showDialog ?? this.showDialog,
      );

  @override
  List<Object> get props => [scale, showDialog];
}