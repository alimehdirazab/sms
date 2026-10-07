class MockDelay {
  static Future<void> simulate({int milliseconds = 1500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}
