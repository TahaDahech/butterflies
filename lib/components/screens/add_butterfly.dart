import 'dart:typed_data';
import 'package:butterflies/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddButterflyScreen extends StatefulWidget {
  const AddButterflyScreen({super.key});

  @override
  _AddButterflyScreenState createState() => _AddButterflyScreenState();
}

class _AddButterflyScreenState extends State<AddButterflyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _classificationController =
      TextEditingController();
  final TextEditingController _geolocationController = TextEditingController();

  Uint8List? _imageData;
  Uint8List? _pdfData;
  String? _imageFileName;
  String? _pdfFileName;
  String? _imageUrl;
  String? _pdfUrl;
  bool _isAdding = false; // Track whether adding operation is in progress

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageData = result.files.single.bytes;
        _imageFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pdfData = result.files.single.bytes;
        _pdfFileName = result.files.single.name;
      });
    }
  }

  Future<String> _uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putData(fileBytes);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> _addButterfly() async {
    if (_formKey.currentState!.validate() && !_isAdding) {
      setState(() {
        _isAdding = true; // Set loading indicator to true
      });

      try {
        if (_imageData != null && _imageFileName != null) {
          String imagePath =
              'butterfly_images/${DateTime.now().toIso8601String()}_$_imageFileName';
          _imageUrl = await _uploadFile(_imageData!, imagePath);
        }

        if (_pdfData != null && _pdfFileName != null) {
          String pdfPath =
              'butterfly_pdfs/${DateTime.now().toIso8601String()}_$_pdfFileName';
          _pdfUrl = await _uploadFile(_pdfData!, pdfPath);
        }

        await FirebaseFirestore.instance.collection('butterflies').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'caption': _captionController.text,
          'classification': _classificationController.text,
          'geolocation': _geolocationController.text,
          'imageUrl': _imageUrl,
          'pdfUrl': _pdfUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Butterfly added successfully!'),
        ));

        Navigator.pop(context);
      } catch (e) {
        print('Error adding butterfly: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add butterfly. Please try again.'),
        ));
      } finally {
        setState(() {
          _isAdding = false; // Set loading indicator back to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF333333),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mask.png'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
            ),
            const SizedBox(width: 8),
            const Text(
              'Add New Butterfly',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Oswald',
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double sidePadding =
              constraints.maxWidth >= 600 ? constraints.maxWidth * 0.15 : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextFormField(_nameController, 'Name'),
                          _buildTextFormField(
                              _descriptionController, 'Description',
                              maxLines: 3),
                          _buildTextFormField(_captionController, 'Caption'),
                          _buildTextFormField(
                              _classificationController, 'Classification'),
                          _buildTextFormField(
                              _geolocationController, 'Geolocation'),
                          const SizedBox(height: 20),
                          _buttonAddImage(),
                          const SizedBox(height: 20),
                          _buttonAddPdf(),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _addButterfly,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: _isAdding
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'Add Butterfly',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Oswald',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Color(0xFF333333),
            fontFamily: 'Oswald',
            fontSize: 18,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF333333),
              width: 2.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFCCCCCC),
              width: 1.0,
            ),
          ),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buttonAddImage() {
    return Column(
      children: [
        _imageData == null
            ? ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Row(
                  children: [
                    Spacer(),
                    Icon(Icons.image, color: Colors.white),
                    SizedBox(width: 20),
                    Text(
                      'Select Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Oswald',
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              )
            : Image.memory(
                _imageData!,
                height: MediaQuery.of(context).size.height /
                    3, // Image height is 1/3 of screen height
              ),
      ],
    );
  }

  Widget _buttonAddPdf() {
    return Column(
      children: [
        _pdfData == null
            ? ElevatedButton(
                onPressed: _pickPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Row(
                  children: [
                    Spacer(),
                    Icon(Icons.picture_as_pdf, color: Colors.white),
                    SizedBox(width: 20),
                    Text(
                      'Select PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Oswald',
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              )
            : Text(
                'PDF Selected: ${_pdfFileName ?? "Unknown PDF"}',
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 16,
                ),
              ),
      ],
    );
  }
}
