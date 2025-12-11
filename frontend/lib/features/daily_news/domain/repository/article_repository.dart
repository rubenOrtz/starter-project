import 'dart:io'; // Necesario para File

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Database methods
  Future < List < ArticleEntity >> getSavedArticles();
  Future < void > saveArticle(ArticleEntity article);
  Future < void > removeArticle(ArticleEntity article);

  Future<DataState<String>> uploadImage(File imageFile);

  Future<DataState<void>> createArticle(ArticleEntity article);
}