import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirebaseService _firebaseService;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._appDatabase,
    this._firebaseService,
  );

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    List<ArticleModel> apiArticles = [];
    List<ArticleModel> firebaseArticles = [];
    DioException? lastError;

    // Parallel computing them.
    await Future.wait([
      _newsApiService
          .getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      )
          .then((httpResponse) {
        if (httpResponse.response.statusCode == HttpStatus.ok) {
          apiArticles = httpResponse.data;
        }
      }).catchError((e) {
        if (e is DioException) lastError = e;
      }),
      _firebaseService.getArticles().then((articles) {
        firebaseArticles = articles;
      }).catchError((e) {
        if (e is DioException) lastError = e;
      }),
    ]);

    if (apiArticles.isEmpty && firebaseArticles.isEmpty) {
      return DataFailed(lastError ??
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: "Ambas fuentes fallaron",
            type: DioExceptionType.unknown,
          ));
    }

    final allArticles = [...firebaseArticles, ...apiArticles];

    return DataSuccess(allArticles);
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<DataState<String>> uploadImage(File imageFile) async {
    try {
      final imageUrl = await _firebaseService.uploadImage(imageFile);
      return DataSuccess(imageUrl);
    } catch (e) {
      return DataFailed(DioException(
        error: e.toString(),
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<DataState<void>> createArticle(ArticleEntity article) async {
    try {
      await _firebaseService.createArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioException(
        error: e.toString(),
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
      ));
    }
  }
}