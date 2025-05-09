import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// A widget that provides functionality to capture images using the device's camera.
class CameraWidget extends StatefulWidget {
  // Callback function to handle the captured image file path.
  final Function(String) onImageCaptured;

  // Constructor for the CameraWidget.
  const CameraWidget({super.key, required this.onImageCaptured});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

// State class for the CameraWidget.
class _CameraWidgetState extends State<CameraWidget> {
  // ImagePicker instance to handle image capturing.
  final _picker = ImagePicker();

  // Asynchronous function to capture an image from the camera.
  Future<void> _captureImage() async {
    // Use the ImagePicker to pick an image from the camera source.
    final image = await _picker.pickImage(source: ImageSource.camera);
    // If an image is captured successfully,
    if (image != null) {
      // call the onImageCaptured callback with the image's file path.
      widget.onImageCaptured(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build method to create the UI for the widget.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically.
      children: [
        // IconButton to trigger the image capture.
        IconButton(
          icon: const Icon(Icons.camera_alt, size: 72), // Camera icon with a size of 72.
          onPressed: _captureImage, // Call _captureImage when the button is pressed.
        ),
        const SizedBox(height: 8), // Added a small vertical gap between the icon and the text.
        const Text('Capture Leaf Image', style: TextStyle(fontSize: 18)), // Text label for the button.
      ],
    );
  }
}
