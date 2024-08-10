String makeWebSocketAddress(String url) {
  if (url.contains("https")) {
    return url.replaceFirst("https", "wss");
  } else if (url.contains("http")) {
    return url.replaceFirst("http", "ws");
  }
  return url; // return the original URL if neither https nor http is found
}

String makeHTTPSAddress(String url) {
  url = url.trim(); // Remove any leading or trailing whitespace

  // Parse the URL
  Uri uri;
  try {
    uri = Uri.parse(url);
  } catch (e) {
    print("Error parsing URL: $e");
    return url; // Return original URL if parsing fails
  }

  // If the scheme is missing, assume http
  if (!uri.hasScheme) {
    uri = Uri.parse('http://${uri.toString()}');
  }

  // Convert ws to http and wss to https if necessary
  String scheme = uri.scheme;
  if (scheme == 'ws') {
    scheme = 'http';
  } else if (scheme == 'wss') {
    scheme = 'https';
  }

  // Rebuild the URL with the correct scheme
  return uri.replace(scheme: scheme).toString();
}
