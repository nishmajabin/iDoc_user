class ThinkingBubbleState {
  final List<double> offsets; // one offset per dot

  const ThinkingBubbleState({required this.offsets});

  factory ThinkingBubbleState.initial() =>
      const ThinkingBubbleState(offsets: [0.0, 0.0, 0.0]);

  ThinkingBubbleState copyWith({List<double>? offsets}) =>
      ThinkingBubbleState(offsets: offsets ?? this.offsets);
}
