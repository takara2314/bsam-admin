enum PositionSource {
  gps('gps'),
  manual('manual');

  const PositionSource(this.value);

  final String value;

  static PositionSource? fromJsonValue(Object? rawValue) {
    if (rawValue is! String) {
      return null;
    }

    for (final source in PositionSource.values) {
      if (source.value == rawValue) {
        return source;
      }
    }

    return null;
  }
}
