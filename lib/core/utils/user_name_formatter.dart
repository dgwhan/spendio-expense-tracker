class UserNameFormatter {
  static String extractName(
    String email,
  ) {
    final prefix = email.split('@').first;

    if (prefix.isEmpty) {
      return 'User';
    }

    return prefix[0].toUpperCase() + prefix.substring(1);
  }
}
