import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' show exp, sqrt, pow;

class TobaccoClassifier {
  late final Interpreter _interpreter;
  late final List<String> _classes;
  final int _targetSize = 224;

  TobaccoClassifier._internal(this._interpreter, this._classes);

  static Future<TobaccoClassifier> load() async {
    try {
      // Load the TFLite model
      final interpreter = await Interpreter.fromAsset(
        'assets/models/tobacco_model.tflite',
      );

      // Define classes based on your training data
      final classes = [
        'L1',
        'L2',
        'L3',
        'L4',
        'L5',
        'LG',
        'LK',
        'LLV',
        'LND',
        'LOV',
      ];

      return TobaccoClassifier._internal(interpreter, classes);
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    try {
      // Use isolates for heavy computation
      final result = await compute(_isolateClassify, {
        'imagePath': imagePath,
        'targetSize': _targetSize,
        'modelPath': 'assets/models/tobacco_model.tflite',
      });

      return result;
    } catch (e) {
      print('Error classifying image: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _isolateClassify(
    Map<String, dynamic> params,
  ) async {
    try {
      final String imagePath = params['imagePath'];
      final int targetSize = params['targetSize'];
      final String modelPath = params['modelPath'];

      // Load interpreter in isolate
      final interpreter = await Interpreter.fromAsset(modelPath);

      // Load and preprocess image
      final image = img.decodeImage(File(imagePath).readAsBytesSync());
      if (image == null) throw Exception('Failed to load image');

      // Apply preprocessing pipeline
      final processedImage = _preprocessImage(image, targetSize);

      // Prepare input tensor
      final inputShape = interpreter.getInputTensor(0).shape;
      final inputBuffer = Float32List(inputShape.reduce((a, b) => a * b));

      // Convert image to input tensor
      _imageToInputBuffer(processedImage, inputBuffer);

      // Prepare output tensor
      final outputShape = interpreter.getOutputTensor(0).shape;
      final outputBuffer = Float32List(outputShape.reduce((a, b) => a * b));

      // Run inference
      interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

      // Get prediction
      final prediction = _getPrediction(outputBuffer);
      final probabilities = _getProbabilities(outputBuffer);

      // Clean up
      interpreter.close();

      return {
        'grade': prediction,
        'probabilities': probabilities,
        'details': _getGradeDetails(prediction),
      };
    } catch (e) {
      print('Error in isolate: $e');
      rethrow;
    }
  }

  static img.Image _preprocessImage(img.Image image, int targetSize) {
    // Resize
    var resized = img.copyResize(image, width: targetSize, height: targetSize);

    // Convert to grayscale for CLAHE
    var gray = img.grayscale(resized);

    // Apply CLAHE
    var clahe = _applyCLAHE(gray);

    // Convert back to RGB
    var enhanced = img.Image(width: clahe.width, height: clahe.height);
    for (var y = 0; y < clahe.height; y++) {
      for (var x = 0; x < clahe.width; x++) {
        var pixel = clahe.getPixel(x, y);
        enhanced.setPixelRgb(x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      }
    }

    // Apply bilateral filter
    enhanced = _applyBilateralFilter(enhanced);

    return enhanced;
  }

  static void _imageToInputBuffer(img.Image image, Float32List buffer) {
    var bufferIndex = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        var r = pixel.r;
        var g = pixel.g;
        var b = pixel.b;

        buffer[bufferIndex++] = r / 255.0;
        buffer[bufferIndex++] = g / 255.0;
        buffer[bufferIndex++] = b / 255.0;
      }
    }
  }

  static String _getPrediction(Float32List outputBuffer) {
    var maxIndex = 0;
    var maxValue = outputBuffer[0];

    for (var i = 1; i < outputBuffer.length; i++) {
      if (outputBuffer[i] > maxValue) {
        maxValue = outputBuffer[i];
        maxIndex = i;
      }
    }

    final classes = [
      'L1',
      'L2',
      'L3',
      'L4',
      'L5',
      'LG',
      'LK',
      'LLV',
      'LND',
      'LOV',
    ];

    return classes[maxIndex];
  }

  static List<double> _getProbabilities(Float32List outputBuffer) {
    return outputBuffer.toList();
  }

  static Map<String, String> _getGradeDetails(String grade) {
    final details = {
      'L1': {
        'color': 'Deep Red (#98)',
        'size': 'Large (72mm)',
        'shape': 'Regular',
        'defects': 'None',
        'firmness': 'Excellent',
      },
      'L2': {
        'color': 'Red (#85)',
        'size': 'Medium (65mm)',
        'shape': 'Regular',
        'defects': 'Minor',
        'firmness': 'Good',
      },
    };

    return details[grade] ??
        {
          'color': 'N/A',
          'size': 'N/A',
          'shape': 'N/A',
          'defects': 'N/A',
          'firmness': 'N/A',
        };
  }

  static img.Image _applyCLAHE(img.Image image) {
    if (image.numChannels != 1) {
      image = img.grayscale(image);
    }

    final pixels = image.getBytes(order: img.ChannelOrder.red);
    final histogram = List<int>.filled(256, 0);
    for (var p in pixels) {
      histogram[p]++;
    }

    final cumulative = List<int>.filled(256, 0);
    cumulative[0] = histogram[0];
    for (var i = 1; i < 256; i++) {
      cumulative[i] = cumulative[i - 1] + histogram[i];
    }

    final normalized = List<int>.filled(256, 0);
    final totalPixels = pixels.length;
    if (totalPixels == 0) return image;

    for (var i = 0; i < 256; i++) {
      normalized[i] = (cumulative[i] * 255 / totalPixels).round().clamp(0, 255);
    }

    final newPixels = Uint8List(totalPixels);
    for (var i = 0; i < totalPixels; i++) {
      newPixels[i] = normalized[pixels[i]];
    }

    return img.Image.fromBytes(width: image.width, height: image.height, bytes: newPixels.buffer, numChannels: 1);
  }

  static img.Image _applyBilateralFilter(img.Image image) {
    const sigmaSpace = 5.0;
    const sigmaColor = 30.0;
    const radius = 5;

    var result = img.Image.from(image);

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        var centerPixel = image.getPixel(x, y);
        var sumR = 0.0, sumG = 0.0, sumB = 0.0;
        var weightSum = 0.0;

        for (var ky = -radius; ky <= radius; ky++) {
          for (var kx = -radius; kx <= radius; kx++) {
            var nx = x + kx;
            var ny = y + ky;

            if (nx >= 0 && nx < image.width && ny >= 0 && ny < image.height) {
              var neighborPixel = image.getPixel(nx, ny);

              var dSquare = kx * kx + ky * ky;
              var cDistance = _colorDistance(centerPixel, neighborPixel);

              var spaceWeight = exp(-dSquare / (2 * sigmaSpace * sigmaSpace));
              var colorWeight = exp(-cDistance / (2 * sigmaColor * sigmaColor));
              var weight = spaceWeight * colorWeight;

              weightSum += weight;
              sumR += neighborPixel.r * weight;
              sumG += neighborPixel.g * weight;
              sumB += neighborPixel.b * weight;
            }
          }
        }

        if (weightSum == 0) { 
           result.setPixelRgb(x,y, centerPixel.r.toInt(), centerPixel.g.toInt(), centerPixel.b.toInt());
        } else {
            var r = (sumR / weightSum).round().clamp(0, 255);
            var g = (sumG / weightSum).round().clamp(0, 255);
            var b = (sumB / weightSum).round().clamp(0, 255);
            result.setPixelRgb(x, y, r, g, b);
        }
      }
    }
    return result;
  }

  static double _colorDistance(img.Pixel pixel1, img.Pixel pixel2) {
    var r1 = pixel1.r;
    var g1 = pixel1.g;
    var b1 = pixel1.b;

    var r2 = pixel2.r;
    var g2 = pixel2.g;
    var b2 = pixel2.b;

    return sqrt(
      pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2),
    ).toDouble();
  }
}
