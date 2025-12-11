import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class AddArticleState extends Equatable {
  final String? imageUrl;
  final DioException? error;

  const AddArticleState({this.imageUrl, this.error});

  @override
  List<Object?> get props => [imageUrl, error];
}

class AddArticleInitial extends AddArticleState {
  const AddArticleInitial();
}

class AddArticleLoading extends AddArticleState {
  const AddArticleLoading();
}

class AddArticleImageUploaded extends AddArticleState {
  const AddArticleImageUploaded(String imageUrl) : super(imageUrl: imageUrl);
}

class AddArticleSuccess extends AddArticleState {
  const AddArticleSuccess();
}

class AddArticleError extends AddArticleState {
  const AddArticleError(DioException error) : super(error: error);
}
