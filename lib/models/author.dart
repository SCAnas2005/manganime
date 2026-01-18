class Author {
  final int id;
  final String name;
  final String? url;

  Author({required this.id, required this.name, this.url});

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "url": url};
  }

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json["id"] as int,
      name: json["name"] as String,
      url: json["url"] as String?,
    );
  }

  factory Author.fromJikan(Map<String, dynamic> json) {
    return Author(
      id: json["mal_id"] as int,
      name: json["name"] as String,
      url: json["url"] as String?,
    );
  }
}
