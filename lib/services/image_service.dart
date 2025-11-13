class ImageService {
  static const List<String> _defaultBookImages = [
    'https://picsum.photos/400/600?random=1',
    'https://picsum.photos/400/600?random=2',
    'https://picsum.photos/400/600?random=3',
    'https://picsum.photos/400/600?random=4',
    'https://picsum.photos/400/600?random=5',
    'https://picsum.photos/400/600?random=6',
    'https://picsum.photos/400/600?random=7',
    'https://picsum.photos/400/600?random=8',
    'https://picsum.photos/400/600?random=9',
    'https://picsum.photos/400/600?random=10',
  ];

  static String getRandomBookImage() => _defaultBookImages[
      DateTime.now().millisecond % _defaultBookImages.length];

  static bool isValidImageUrl(String url) =>
      Uri.tryParse(url) != null &&
      (url.startsWith('http://') || url.startsWith('https://'));

  static String sanitizeImageUrl(String url) {
    if (url.isEmpty || !isValidImageUrl(url)) {
      return getRandomBookImage();
    }
    return url;
  }
}
