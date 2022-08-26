enum SampleRate {
  normal,
  ui,
  game,
  fastest,
}
extension SampleRateExtension on SampleRate {
  int toHz() {
    switch (this) {
      case SampleRate.normal:
        return 15;
      case SampleRate.ui:
        return 30;
      case SampleRate.game:
        return 60;
      case SampleRate.fastest:
        return 120;
      default:
        return 15;
    }
  }
}