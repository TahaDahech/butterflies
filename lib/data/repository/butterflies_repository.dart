import 'dart:io';
import 'package:butterflies/data/model/butterfly.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class ButterfliesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to upload an image file to Firebase Storage and get the URL
  Future<String?> _uploadFile(File file, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Add a new butterfly to Firestore
  Future<void> addButterfly(
      Butterfly butterfly, File imageFile, File pdfFile) async {
    try {
      // Upload image and PDF to Firebase Storage
      String? imageUrl = await _uploadFile(
          imageFile, 'butterflies/images/${basename(imageFile.path)}');
      String? pdfUrl = await _uploadFile(
          pdfFile, 'butterflies/pdfs/${basename(pdfFile.path)}');

      if (imageUrl != null && pdfUrl != null) {
        DocumentReference docRef = _firestore.collection('butterflies').doc();
        butterfly.id = docRef.id;
        butterfly.imageUrl = imageUrl;
        butterfly.pdfUrl = pdfUrl;

        await docRef.set(butterfly.toFirestore());
        print('Butterfly added to Firestore');
      } else {
        print('Failed to upload image or PDF');
      }
    } catch (e) {
      print('Error adding butterfly: $e');
    }
  }

  // Retrieve all butterflies from Firestore
  Future<List<Butterfly>> getButterflies() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('butterflies').get();
      return querySnapshot.docs
          .map((doc) =>
              Butterfly.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching butterflies: $e');
      return [];
    }
  }

  // Retrieve a single butterfly by ID
  Future<Butterfly?> getButterflyById(String id) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('butterflies').doc(id).get();
      if (docSnapshot.exists) {
        return Butterfly.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching butterfly: $e');
      return null;
    }
  }

  // Update an existing butterfly in Firestore
  Future<void> updateButterfly(Butterfly butterfly) async {
    try {
      await _firestore
          .collection('butterflies')
          .doc(butterfly.id)
          .update(butterfly.toFirestore());
      print('Butterfly updated successfully');
    } catch (e) {
      print('Error updating butterfly: $e');
    }
  }

  // Delete a butterfly from Firestore and its files from Firebase Storage
  Future<void> deleteButterfly(
      String id, String imageUrl, String pdfUrl) async {
    try {
      await _firestore.collection('butterflies').doc(id).delete();

      // Delete image and PDF from Firebase Storage
      await _storage.refFromURL(imageUrl).delete();
      await _storage.refFromURL(pdfUrl).delete();

      print('Butterfly deleted successfully');
    } catch (e) {
      print('Error deleting butterfly: $e');
    }
  }
}
