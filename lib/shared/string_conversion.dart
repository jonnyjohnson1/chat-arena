String makeWebSocketAddress(String url) {
  if (url.contains("https")) {
    return url.replaceFirst("https", "wss");
  } else if (url.contains("http")) {
    return url.replaceFirst("http", "ws");
  }
  return url; // return the original URL if neither https nor http is found
}

String makeHTTPSAddress(String url) {
  if (url.contains("wss")) {
    return url.replaceFirst("wss", "https");
  } else if (url.contains("ws")) {
    return url.replaceFirst("ws", "http");
  }
  return url; // return the original URL if neither https nor http is found
}
