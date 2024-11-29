import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class PhotosPage extends StatefulWidget {
  final String placeId;

  const PhotosPage({super.key, required this.placeId});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Set<String> likedImages = {};

  Future<List<Map<String, dynamic>>> _fetchImages() async {
    QuerySnapshot snapshot = await _firestore
        .collection('app_mytrip')
        .doc('QXmlP0NZfyfeJrKUICjq')
        .collection('places')
        .doc(widget.placeId)
        .collection('images')
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _likeImage(String imageId, int currentLikes) {
    final imageRef = _firestore
        .collection('app_mytrip')
        .doc('QXmlP0NZfyfeJrKUICjq')
        .collection('places')
        .doc(widget.placeId)
        .collection('images')
        .doc(imageId);

    if (likedImages.contains(imageId)) {
      int updatedLikes = currentLikes - 1;
      imageRef.update({'likes': updatedLikes}).then((_) {
        setState(() {
          likedImages.remove(imageId);
        });
      });
    } else {
      int updatedLikes = currentLikes + 1;
      imageRef.update({'likes': updatedLikes}).then((_) {
        setState(() {
          likedImages.add(imageId);
        });
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        _storage.ref().child('places/${widget.placeId}/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String imageUrl = await _uploadImage(imageFile);

      _firestore
          .collection('app_mytrip')
          .doc('QXmlP0NZfyfeJrKUICjq')
          .collection('places')
          .doc(widget.placeId)
          .collection('images')
          .add({
        'url': imageUrl,
        'likes': 0,
        'id': DateTime.now().toString(),
      }).then((_) {
        setState(() {
          _fetchImages(); // قم باسترداد الصور مجددًا
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('best_photo'.tr()),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('done'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(
        title: 'best_photo_contest'.tr(),
      ),
      body: BackgroundMyTrip(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('something_went_wrong'.tr()));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('there_are_no_pictures'.tr()));
              }

              final images = snapshot.data!;

              return ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  final String imageUrl = image['url'];

                  return Column(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: _pickAndUploadImage,
        child: Image.asset(
          'assets/image/camera.png',
          width: 70,
          height: 70,
        ),
      ),
    );
  }
}
