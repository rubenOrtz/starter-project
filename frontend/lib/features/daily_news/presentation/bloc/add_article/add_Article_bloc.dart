import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';

import 'add_article_event.dart';
import 'add_article_state.dart';

class AddArticleBloc extends Bloc<AddArticleEvent, AddArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  AddArticleBloc(
    this._createArticleUseCase,
    this._uploadImageUseCase,
  ) : super(const AddArticleInitial()) {
    on<UploadImage>(_onUploadImage);
    on<CreateArticle>(_onCreateArticle);
  }

  void _onUploadImage(UploadImage event, Emitter<AddArticleState> emit) async {
    emit(const AddArticleLoading());

    final result = await _uploadImageUseCase(params: event.imageFile);

    if (result is DataSuccess && result.data != null) {
      emit(AddArticleImageUploaded(result.data!));
    } else if (result is DataFailed) {
      emit(AddArticleError(result.error!));
    }
  }

  void _onCreateArticle(
      CreateArticle event, Emitter<AddArticleState> emit) async {
    emit(const AddArticleLoading());

    final result = await _createArticleUseCase(params: event.article);

    if (result is DataSuccess) {
      emit(const AddArticleSuccess());
    } else if (result is DataFailed) {
      emit(AddArticleError(result.error!));
    }
  }
}
