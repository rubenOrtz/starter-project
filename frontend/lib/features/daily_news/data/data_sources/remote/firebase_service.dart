import 'dart:io';
import 'dart:typed_data'; // Importar esto

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/article.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService(this._firestore, this._storage);

  CollectionReference get _articlesCollection =>
      _firestore.collection('articles');

  Future<void> createArticle(ArticleModel article) async {
    DocumentReference docRef = _articlesCollection.doc();
    Map<String, dynamic> articleData = article.toDocumentJson();
    articleData['id'] = docRef.id;
    await docRef.set(articleData);
  }

  Future<String> uploadImage(File imageFile) async {

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('media/articles/$fileName.jpg');

      Uint8List fileBytes = await imageFile.readAsBytes();

      UploadTask uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('❌ ERROR EN UPLOAD: $e');
      throw e;
    }
  }

  Future<List<ArticleModel>> getArticles() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ArticleModel.fromFirebase(doc)).toList();
  }

  Future<void> deleteArticle(String? articleId) async {
    if (articleId != null && articleId.isNotEmpty) {
      await _articlesCollection.doc(articleId).delete();
    }
  }
}
