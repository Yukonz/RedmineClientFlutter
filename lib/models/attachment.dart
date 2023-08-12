class Attachment {
  final int id;
  final int authorId;
  final int fileSize;

  final String fileName;
  final String contentType;
  final String description;
  final String contentUrl;
  final String hrefUrl;
  final String thumbnailUrl;
  final String authorName;
  final String dateCreated;

  const Attachment({
    required this.id,
    required this.authorId,
    required this.fileSize,
    required this.fileName,
    required this.contentType,
    required this.description,
    required this.contentUrl,
    required this.hrefUrl,
    required this.thumbnailUrl,
    required this.authorName,
    required this.dateCreated,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id:           json['id']             ?? 0,
      authorId:     json['author']['id']   ?? 0,
      fileSize:     json['filesize']       ?? '',
      fileName:     json['filename']       ?? '',
      contentType:  json['content_type']   ?? '',
      description:  json['description']    ?? '',
      contentUrl:   json['content_url']    ?? '',
      hrefUrl:      json['href_url']       ?? '',
      thumbnailUrl: json['thumbnail_url']  ?? '',
      authorName:   json['author']['name'] ?? '',
      dateCreated:  json['created_on']     ?? '',
    );
  }
}