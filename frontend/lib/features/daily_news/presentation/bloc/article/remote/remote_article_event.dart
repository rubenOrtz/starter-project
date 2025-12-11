import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class DeleteArticle extends RemoteArticlesEvent {
  final ArticleEntity article;

  const DeleteArticle(this.article);

  List<Object> get props => [article];
}