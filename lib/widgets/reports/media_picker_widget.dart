import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class MediaPickerWidget extends StatelessWidget {
  final List<File> selectedImages;
  final File? selectedVideo;
  final Function(File) onImageSelected;
  final Function(File) onVideoSelected;
  final Function(int) onImageRemoved;
  final Function() onVideoRemoved;

  const MediaPickerWidget({
    super.key,
    required this.selectedImages,
    required this.selectedVideo,
    required this.onImageSelected,
    required this.onVideoSelected,
    required this.onImageRemoved,
    required this.onVideoRemoved,
  });

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web platform
          onImageSelected(File(image.path));
        } else {
          // For mobile platforms
          onImageSelected(File(image.path));
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photos (${selectedImages.length}/5)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (selectedImages.length < 5)
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_photo_alternate, size: 32),
                ),
              ),
            const SizedBox(width: 8),
            if (selectedImages.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            kIsWeb
                                ? Image.network(
                                    selectedImages[index].path,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    selectedImages[index],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.white,
                                onPressed: () => onImageRemoved(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
