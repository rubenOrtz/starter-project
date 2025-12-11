import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    String? id,
    String ? author,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
    String? category,
  }): super(
    id: id,
    author: author,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
          category: category,
        );

  factory ArticleModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return ArticleModel(
      id: snapshot.id,
      author: data['authorName'] ?? "",
      // 'authorName' -> 'author'
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      url: data['url'] ?? "",
      urlToImage: data['thumbnailURL'] ?? kDefaultImage,
      // 'thumbnailURL' -> 'urlToImage'
      publishedAt: data['publishedAt'] ?? "",
      content: data['content'] ?? "",
      category: data['category'] ?? "",
    );
  }

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] ?? map['url'] ?? "",
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
        id: entity.id,
        author: entity.author,
        title: entity.title,
        description: entity.description,
        url: entity.url,
        urlToImage: entity.urlToImage,
        publishedAt: entity.publishedAt,
        content: entity.content,
        category: entity.category);
  }

  Map<String, dynamic> toDocumentJson() {
    return {
      'authorName': author ?? "Unknown",
      'title': title,
      'description': description,
      'url': url,
      'thumbnailURL': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'category': category,
    };
  }
}