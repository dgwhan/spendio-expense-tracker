extension StringSecurity on String {
  String get obscure {
    const String bullet = '\u2022';
    return bullet * length;
  }
}
