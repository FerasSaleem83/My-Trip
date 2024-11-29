import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    Key? key,
    required this.onPickImages,
  }) : super(key: key);

  final void Function(List<File> pickedImages) onPickImages;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  final List<File> _pickedImages = [];

  void _pickImageGallery() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
    );
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImages.add(File(pickedImage.path));
    });
    widget.onPickImages(_pickedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 120.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.5,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {});
                },
                scrollDirection: Axis.horizontal,
              ),
              items: _pickedImages.map((image) {
                return CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundImage: FileImage(image),
                );
              }).toList(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImageGallery,
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
              label: Text(
                'galarey'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
