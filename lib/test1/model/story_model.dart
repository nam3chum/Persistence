class Story {
  final String id;
  final String name;
  final String originName;
  final String content;
  final String author;
  final List<String> genreId;
  final String imgUrl;
  final String status;
  final DateTime updatedAt;
  final int numberOfChapter;
  final int? deleted;

  Story({
    this.deleted,
    required this.id,
    required this.name,
    required this.originName,
    required this.content,
    required this.author,
    required this.genreId,
    required this.imgUrl,
    required this.status,
    required this.updatedAt,
    required this.numberOfChapter,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json["id"].toString(),
    name: json['name'] != null ? json["name"] : '',
    originName: json["originName"] ?? '',
    content: json["content"] ?? '',
    author: json["author"],
    genreId:
        (() {
          final genre = json["genreId"] ?? json["genreId"];
          if (genre is List) {
            return genre.map((e) => e.toString()).toList();
          } else if (genre is String) {
            return genre.split(',').map((e) => e.trim()).toList();
          }
          return <String>[];
        })(),
    imgUrl: json["imgUrl"],
    status: json["status"],
    updatedAt: DateTime.tryParse(json["updateAt"] ?? '') ?? DateTime.now(),
    numberOfChapter: (int.parse(json["numberOfChapter"].toString())),
    deleted: json['deleted'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "originName": originName,
    "content": content,
    "author": author,
    "genreId": genreId.join(','),
    "imgUrl": imgUrl,
    "status": status,
    "updateAt": updatedAt.toIso8601String(),
    "numberOfChapter": numberOfChapter.toInt(),
    "deleted": deleted ?? 0,
  };
}
