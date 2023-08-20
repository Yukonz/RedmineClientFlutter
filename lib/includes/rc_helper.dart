class RcHelper {
  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: true,
    );

    return htmlText.replaceAll(exp, '');
  }

  static String formatDate(String dateStr) {
    String newStr = dateStr.replaceAll('T', ' ');
    newStr = newStr.substring(0, newStr.length - 4);

    return newStr;
  }
}