import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UploadImageUseCase implements UseCase<DataState<String>, File> {
  final ArticleRepository _articleRepository;

  UploadImageUseCase(this._articleRepository);

  @override
  Future<DataState<String>> call({File? params}) {
    return _articleRepository.uploadImage(params!);
  }
}
