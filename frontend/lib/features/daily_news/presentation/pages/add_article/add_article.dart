import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/add_article/add_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/add_article/add_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/add_article/add_article_state.dart';

import '../../../../../injection_container.dart';

class AddArticle extends HookWidget {
  const AddArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final contentController = useTextEditingController();

    final localImage = useState<File?>(null);

    return BlocProvider(
      create: (_) => sl<AddArticleBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocListener<AddArticleBloc, AddArticleState>(
          listener: (context, state) {
            if (state is AddArticleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Article published successfully! 🚀')),
              );
              Navigator.pop(context);
            }
            if (state is AddArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error?.message ?? "Unknown"}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: _buildBody(titleController, contentController, localImage),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'New Article',
        style: TextStyle(color: Colors.black),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevron_back, color: Colors.black),
      ),
    );
  }

  Widget _buildBody(
    TextEditingController titleController,
    TextEditingController contentController,
    ValueNotifier<File?> localImage,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(titleController),
          const SizedBox(height: 20),
          _buildImagePicker(localImage),
          const SizedBox(height: 20),
          _buildContentField(contentController),
          const SizedBox(height: 30),
          _buildPublishButton(titleController, contentController, localImage),
        ],
      ),
    );
  }

  Widget _buildTitleField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        hintText: 'Title goes here...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
      ),
    );
  }

  Widget _buildContentField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null,
      // Infinite lines
      keyboardType: TextInputType.multiline,
      maxLength: 2000,
      // Maximun Character Amount
      style: const TextStyle(fontSize: 16, height: 1.5),
      decoration: const InputDecoration(
        hintText: 'Write your story here... (Markdown supported)',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildImagePicker(ValueNotifier<File?> localImage) {
    return BlocBuilder<AddArticleBloc, AddArticleState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);

            if (image != null) {
              localImage.value = File(image.path);
              context
                  .read<AddArticleBloc>()
                  .add(UploadImage(localImage.value!));
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: localImage.value != null
                  ? DecorationImage(
                      image: FileImage(localImage.value!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: localImage.value == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Ionicons.image_outline,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Add Cover Image",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : state is AddArticleLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child:
                              Icon(Icons.edit, size: 15, color: Colors.black),
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildPublishButton(
    TextEditingController title,
    TextEditingController content,
    ValueNotifier<File?> image,
  ) {
    return BlocBuilder<AddArticleBloc, AddArticleState>(
      builder: (context, state) {
        bool isLoading = state is AddArticleLoading;

        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (title.text.isEmpty || content.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in title and content')),
                      );
                      return;
                    }
                    String? finalImageUrl = state.imageUrl;

                    context.read<AddArticleBloc>().add(
                          CreateArticle(
                            ArticleEntity(
                              author: "Journalist",
                              title: title.text,
                              description: content.text,
                              content: content.text,
                              urlToImage: finalImageUrl,
                              publishedAt: DateTime.now().toIso8601String(),
                              category: "General",
                            ),
                          ),
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text(
                    'Publish Article',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
          ),
        );
      },
    );
  }
}
