import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../domain/entities/article.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {
  
  final GetArticleUseCase _getArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase, this._deleteArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on <GetArticles> (onGetArticles);
    on<DeleteArticle>(onDeleteArticle);
  }


  void onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(
        RemoteArticlesDone(dataState.data!)
      );
    }
    
    if (dataState is DataFailed) {
      emit(
        RemoteArticlesError(dataState.error!)
      );
    }
  }

  void onDeleteArticle(
      DeleteArticle event, Emitter<RemoteArticlesState> emit) async {
    if (state.articles != null) {
      final updatedList = List<ArticleEntity>.from(state.articles!);
      updatedList.remove(event.article);
      emit(RemoteArticlesDone(updatedList));
    }

    await _deleteArticleUseCase(params: event.article);

    add(const GetArticles());
  }
}