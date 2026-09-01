import 'geography_type.dart';

/// كائن طلب البحث الجغرافي.
class GeographySearchRequest {
  final String searchKeyword;
  final GeographyType type;

  const GeographySearchRequest({
    required this.searchKeyword,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'search_keyword': searchKeyword,
      'type': type.apiKey,
    };
  }
}
