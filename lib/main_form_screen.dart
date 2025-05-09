import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/classifier.dart';
import 'package:camera/camera.dart';
import 'dart:io'; // Required for File

// You will need to add the image_picker package to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   image_picker: ^1.0.0 // Use the latest version

// You will also need to add the camera package for full camera functionality:
// dependencies:
//   flutter:
//     sdk: flutter
//   camera: ^0.10.0 // Use the latest version

// Assuming you have added the Pacifico font to your project
// and declared it in pubspec.yaml.

class MainFormScreen extends StatefulWidget {
  final dynamic classifier; // Or the correct type of your classifier

  const MainFormScreen({super.key, required this.classifier});

  @override
  _MainFormScreenState createState() => _MainFormScreenState();
}

class _MainFormScreenState extends State<MainFormScreen> {
  File? _imageFile;
  bool _showImageActions = false;
  bool _isUploading = false;
  // Camera related variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _startCamera();
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<void> _startCamera() async {
    if (_cameras.isEmpty) return;

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error starting camera: $e');
    }
  }

  void _closeCamera() {
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    setState(() {
      _isCameraInitialized = false;
    });
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    _closeCamera();
    _startCamera();
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _imageFile = File(photo.path);
        _showImageActions = true;
      });
      _closeCamera();
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _showImageActions = true;
      });
      // if it was camera, it will close the camera
      if (source == ImageSource.camera) {
        _closeCamera();
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _imageFile = null;
      _showImageActions = false;
    });
  }

  void _uploadImage() {
    setState(() {
      _isUploading = true;
    });

    // Simulate upload process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
      });
      // Navigate to the grading results screen
      // Replace '/gradingResults' with your actual route
      Navigator.pushReplacementNamed(
        context,
        '/gradingResults',
        arguments: {
          'grade': 'A+', // Replace with actual grade
          'quality': 'Excellent Quality', // Replace with actual quality
          'details': {
            'color': 'Deep Red (#98)', // Replace with actual details
            'size': 'Large (72mm)',
            'shape': 'Regular',
            'defects': 'None',
            'firmness': 'Excellent'
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the target width is 375px as per the HTML
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth > 375 ? 375 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // border-b is handled by AppBar shadow/elevation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black), // Using built-in icons
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'logo', // Replace with your actual logo text or image
          style: TextStyle(
            fontFamily: 'Pacifico', // Use the font family name
            fontSize: 20.0,
            color: Color(0xFF4CAF50), // primary color
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // Placeholder for right side
        ],
      ),
      body: Center(
        child: SizedBox(
          width: containerWidth,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Image Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500, // font-medium
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Please select or take a photo to continue',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image Preview Area
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors
                                .grey[300]!, // Approximate border-gray-200
                            width: 2.0,
                            style: BorderStyle
                                .solid, // Changed from BorderStyle.dashed to solid
                          ),
                        ),
                        clipBehavior: Clip.antiAlias, // overflow-hidden
                        child: _imageFile != null
                            ? Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                // Placeholder content
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.1), // primary/10
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons
                                            .add_photo_alternate_outlined, // Approximate ri-image-add-line
                                        size: 32.0,
                                        color:
                                            Color(0xFF4CAF50), // primary color
                                      ),
                                    ),
                                    const SizedBox(height: 12.0), // mb-3 approx
                                    Text(
                                      'Drag and drop or click to upload', // This text is less relevant for mobile
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4.0), // mt-1 approx
                                    Text(
                                      'Supported formats: JPG, PNG',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24.0), // mb-6 approx

                    // Choose File and Take Photo Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50)
                                  .withOpacity(0.1), // primary/10
                              foregroundColor:
                                  const Color(0xFF4CAF50), // text-primary
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // rounded-button
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file,
                                    size:
                                        20.0), // Approximate ri-folder-upload-line
                                SizedBox(width: 8.0), // mr-2 approx
                                Text(
                                  'Choose File',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0), // gap-4 approx
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _startCamera();
                              _pickImage(ImageSource.camera);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4CAF50), // primary color
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // rounded-button
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    size: 20.0), // Approximate ri-camera-line
                                SizedBox(width: 8.0), // mr-2 approx
                                Text(
                                  'Take Photo',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Image Actions (Retake and Upload)
                    if (_showImageActions)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 24.0), // mt-6 approx
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _retakePhoto,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFF4CAF50), // text-primary
                                  side: const BorderSide(
                                      color: Color(
                                          0xFF4CAF50)), // border border-primary
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // rounded-button
                                  ),
                                ),
                                child: const Text(
                                  'Retake',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0), // space-x-4 approx
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _uploadImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF4CAF50), // primary color
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // rounded-button
                                  ),
                                ),
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Camera Modal (Placeholder)
              // Camera logic needs to be implemented
              // TODO: Implement this using the camera package or a dedicated camera screen
              // if (_showCameraModal)
              //   Container(
              //     color: Colors.black,
              //     child: Center(child: Text('Camera View Here', style: TextStyle(color: Colors.white))),
              //   ),

              // Uploading Modal
              if (_isUploading)
                Container(
                  color: Colors.black54, // bg-black/50
                  child: Center(
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 4.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50)), // border-primary
                            ),
                          ),
                          SizedBox(height: 16.0), // mb-4 approx
                          Text(
                            'Uploading image...',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
