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
    print('👉 1. INICIANDO SUBIDA (Versión putData)...');

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('media/articles/$fileName.jpg');

      // CAMBIO CLAVE: Leemos los bytes primero
      Uint8List fileBytes = await imageFile.readAsBytes();
      print('👉 2. BYTES LEÍDOS: ${fileBytes.length}');

      // Usamos putData en lugar de putFile
      UploadTask uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      uploadTask.snapshotEvents.listen((event) {
        print('👉 PROGRESO: ${event.bytesTransferred} / ${event.totalBytes}');
      });

      TaskSnapshot snapshot = await uploadTask;
      print('👉 3. SUBIDA COMPLETADA. PIDIENDO URL...');

      String url = await snapshot.ref.getDownloadURL();
      print('👉 4. URL OBTENIDA: $url');
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
}
