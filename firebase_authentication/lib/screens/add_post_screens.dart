import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// import 'package:firebase_auth/firebase_auth.dart'
class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  String? _base64Image;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double? _latitude;
  double? _longitude;
  String? _aiCategory;
  String? _aiDescription;
  bool _isGenerating = false;
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _aiCategory = null;
          _aiDescription = null;
          _descriptionController.clear();
        });
        await _compressAndEncodeImage();
        // await _generateDescriptionWithAI();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _generateDescriptonWithAI() async {
    if (_image == null) return;
    setState(() => _isGenerating = true);
    try {
      final model = await GenerativeModel(
        model: 'gemini-1-.5-pro',
        apikey: 'your_api_key_here',
        apiUrl: 'https://generativelanguage.googleapis.com/v1beta/models'
      );

      final imageBytes = await _image!.readAsBytes();
      final content = context.multi([
        dataPart('image/jpeg', imageBytes)
        TextPart(
          'Berdasarkan foto ini, identifikasi satu kategori utama kerusakan fasilitas umum'
            'dari daftar berikut: Jalan Rusak, Marka Pudar, Lampu Mati, Trotoar Rusak,'
            'Rambu Rusak, Jembatan Rusak, Sampah Menumpuk, Saluran Tersumbat, Sungai Tercemar,'
            'Sampah Sungai, Pohon Tumbang, Taman Rusak, Fasilitas Rusak, Pipa Bocor,'
            'Vandalisme, Banjir, dan Lainnya.'
            'Pilih kategori yang paling dominan atau paling mendesak untuk dilaporkan.'
            'Buat deskripsi singkat untuk laporan perbaikan, dan tambahkan permohonan perbaikan.'
            'Fokus pada kerusakan yang terlihat dan hindari spekulasi. \n\n'
            'Format output yang diinginkan:\n'
            'Kategori: (satu kategori yang dipilih]\n'
            'Deskripsi: (deskripsi singkat)',
        ),
      if (compressedImage == null) return;
      setState(() {
        _base64Image = base64Encode(compressedImage);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to compress image:$e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Post')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Add a brief description...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: Text('Post')),
          ],
        ),
      ),
    );
  }
}