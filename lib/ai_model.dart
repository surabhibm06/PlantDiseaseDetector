import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AIModel {
  Interpreter? _interpreter;

  // These are the 15 classes used by the model.
  // The order strictly matches the alphabetical class folder order of the PlantVillage dataset
  final List<String> labels = [
    'Pepper Bell Bacterial Spot',
    'Pepper Bell Healthy',
    'Potato Early Blight',
    'Potato Late Blight',
    'Potato Healthy',
    'Tomato Bacterial Spot',
    'Tomato Early Blight',
    'Tomato Late Blight',
    'Tomato Leaf Mold',
    'Tomato Septoria Leaf Spot',
    'Tomato Spider Mites',
    'Tomato Target Spot',
    'Tomato Yellow Leaf Curl Virus',
    'Tomato Mosaic Virus',
    'Tomato Healthy',
  ];

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_disease_model.tflite',
      );
    } catch (e) {
      _interpreter = null;
      throw Exception('Failed to load TFLite model: $e');
    }
  }

  Future<Map<String, dynamic>> predict(
    String imagePath, {
    Uint8List? imageBytes,
  }) async {
    if (_interpreter == null) {
      await loadModel();
    }
    if (_interpreter == null) {
      throw Exception('TFLite interpreter is not initialized.');
    }

    final Uint8List bytes = imageBytes ?? await File(imagePath).readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Could not read or decode the plant image');
    }

    // Orient image upright based on EXIF camera metadata
    image = img.bakeOrientation(image);

    // Center-crop square and resize to 128 x 128 RGB to preserve natural leaf aspect ratio
    final resizedImage = img.copyResizeCropSquare(
      image,
      size: 128,
      interpolation: img.Interpolation.linear,
    );

    // Convert image to model input and normalize pixels to 0-1
    final input = List.generate(
      1,
      (_) => List.generate(
        128,
        (y) => List.generate(128, (x) {
          final pixel = resizedImage.getPixel(x, y);

          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    // Model has 15 output classes
    final output = List.generate(1, (_) => List<double>.filled(15, 0.0));

    // Run AI prediction
    _interpreter!.run(input, output);

    final rawOutputs = List<double>.from(output[0]);

    // Apply Softmax only if outputs are raw unnormalized logits
    double sum = 0.0;
    bool needsSoftmax = false;
    for (final val in rawOutputs) {
      if (val < -0.01 || val > 1.01) needsSoftmax = true;
      sum += val;
    }
    if ((sum - 1.0).abs() > 0.10) needsSoftmax = true;

    List<double> probabilities;
    if (needsSoftmax) {
      final double maxVal = rawOutputs.reduce(math.max);
      double expSum = 0.0;
      final expVals = <double>[];
      for (final val in rawOutputs) {
        final e = math.exp(val - maxVal);
        expVals.add(e);
        expSum += e;
      }
      probabilities = expVals
          .map((e) => expSum > 0 ? e / expSum : 0.0)
          .toList();
    } else {
      probabilities = rawOutputs;
    }

    int bestIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[bestIndex]) {
        bestIndex = i;
      }
    }

    final confidence = (probabilities[bestIndex] * 100.0).clamp(0.0, 100.0);

    final sortedIndices = List<int>.generate(probabilities.length, (i) => i)
      ..sort((a, b) => probabilities[b].compareTo(probabilities[a]));

    final topPredictions = sortedIndices
        .take(3)
        .map(
          (i) => {
            'disease': labels[i],
            'confidence': (probabilities[i] * 100.0).clamp(0.0, 100.0),
            'index': i,
          },
        )
        .toList();

    // 1. Cautious Image-Quality & Vegetation Analysis
    // Checks if the cropped image contains plant foliage and checks lesion characteristics
    int greenPixelCount = 0;
    int necroticPixelCount = 0;
    int leafPixelCount = 0;
    const int totalPixels = 128 * 128;

    for (int y = 0; y < 128; y++) {
      for (int x = 0; x < 128; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // Neutral gray background check: background paper/surface has r ≈ g ≈ b
        final maxDiff = math.max(
          (r - g).abs(),
          math.max((g - b).abs(), (r - b).abs()),
        );
        final isNeutralBg = maxDiff < 0.06;

        // General foliage signature (chlorophyll green, clearly chromatic)
        final isGreen =
            !isNeutralBg && (g > 0.15) && (g > b * 1.05) && (g >= r * 0.72);

        // Dark necrotic / decayed tissue signature (true rot/blight lesions: warm brown/yellowish decay)
        final isNecrotic =
            !isNeutralBg &&
            (r > 0.12) &&
            (r > g * 1.08) &&
            (r > b * 1.15) &&
            (g < 0.55);

        final isLeaf = isGreen || isNecrotic;
        if (isLeaf) leafPixelCount++;
        if (isGreen) greenPixelCount++;
        if (isNecrotic) necroticPixelCount++;
      }
    }

    final double leafRatio = leafPixelCount / totalPixels;
    final double necroticToGreenRatio = greenPixelCount > 0
        ? necroticPixelCount / greenPixelCount
        : 0.0;

    // 2. Statistical Confidence & Ambiguity Margin
    final double topProb = probabilities[sortedIndices[0]];
    final double secondProb = sortedIndices.length > 1
        ? probabilities[sortedIndices[1]]
        : 0.0;
    final double margin = topProb - secondProb;

    // 3. Cautious Uncertainty & Reliability Check
    bool isUncertain = false;
    String rejectionReason = '';

    final String candidateName = labels[bestIndex];
    final bool isNecroticCandidate =
        candidateName.contains('Blight') || candidateName.contains('Spot');

    if (leafRatio < 0.08) {
      // Image quality check: Insufficient recognizable plant foliage
      isUncertain = true;
      rejectionReason =
          'The image does not contain recognizable plant foliage.';
    } else if (isNecroticCandidate &&
        greenPixelCount >= 600 &&
        necroticToGreenRatio < 0.03) {
      // The leaf is predominantly healthy green foliage without necrotic/decay lesions (<3% of green area),
      // safeguarding against false positives caused by shadows, leaf edges, or lighting artifacts across any framing.
      isUncertain = true;
      rejectionReason = 'The leaf appears predominantly green without clear disease lesions. Please ensure adequate lighting and avoid shadows on the foliage for a reliable diagnosis.';
    } else if (topProb < 0.55) {
      // Low confidence across all categories
      isUncertain = true;
      rejectionReason =
          'Low AI model confidence across all disease categories.';
    } else if (margin < 0.15 && topProb < 0.75) {
      // Ambiguous prediction
      isUncertain = true;
      rejectionReason = 'Ambiguous symptoms: overlapping probability between multiple conditions.';
    }

    final String resultDisease = isUncertain
        ? 'Unable to identify reliably'
        : labels[bestIndex];

    return {
      'disease': resultDisease,
      'confidence': isUncertain
          ? (topProb * 100.0).clamp(0.0, 100.0)
          : confidence,
      'index': bestIndex,
      'isUncertain': isUncertain,
      'rejectionReason': rejectionReason,
      'topCandidate': labels[bestIndex],
      'topPredictions': topPredictions,
    };
  }

  void closeModel() {
    try {
      _interpreter?.close();
    } catch (_) {}
    _interpreter = null;
  }
}
