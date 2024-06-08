String makeWebSocketAddress(String url) {
  if (url.contains("https")) {
    return url.replaceFirst("https", "ws");
  } else if (url.contains("http")) {
    return url.replaceFirst("http", "ws");
  }
  return url; // return the original URL if neither https nor http is found
}
