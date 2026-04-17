class LegalSection {
  final int index;
  final String heading;
  final List<String> paragraphs;
  final List<String>? bullets;
  final bool initiallyExpanded;

  const LegalSection({
    required this.index,
    required this.heading,
    required this.paragraphs,
    this.bullets,
    this.initiallyExpanded = false,
  });
}