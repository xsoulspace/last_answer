part of extensions;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required final String message,
    final Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showErrorSnackBar({required final String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
