import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class AddArticleEvent extends Equatable {
  const AddArticleEvent();

  @override
  List<Object> get props => [];
}

class UploadImage extends AddArticleEvent {
  final File imageFile;

  const UploadImage(this.imageFile);
}

class CreateArticle extends AddArticleEvent {
  final ArticleEntity article;

  const CreateArticle(this.article);
}
