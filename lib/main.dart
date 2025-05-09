import 'package:flutter/material.dart';
import 'package:tobacco_grading_app/welcome_screen.dart';
import 'package:tobacco_grading_app/main_form_screen.dart';
import 'package:tobacco_grading_app/grading_results_screen.dart';
import 'package:tobacco_grading_app/services/classifier.dart'; // Import the classifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the classifier when the app starts
  final classifier = await TobaccoClassifier.load(
    'assets/models/tobacco_model_v1.joblib',
  );
  runApp(MyApp(classifier: classifier));
}

class MyApp extends StatelessWidget {
  final TobaccoClassifier classifier; // Hold the classifier instance

  const MyApp({super.key, required this.classifier});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafGrader',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      // Use onGenerateRoute to pass arguments like the classifier
      onGenerateRoute: (settings) {
        // Handle arguments for the grading results screen
        if (settings.name == '/gradingResults') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => GradingResultsScreen(
              gradingData: args,
            ),
          );
        }

        // Pass the classifier to the main form screen
        if (settings.name == '/mainForm') {
           // You can optionally pass other arguments here if needed
          return MaterialPageRoute(
            builder: (context) =>  MainFormScreen(
               classifier: classifier,
            ),
          );
        }

        // Default route for the welcome screen
        if (settings.name == '/') {
           return MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          );
        }

        // Fallback for unknown routes
         return MaterialPageRoute(
            builder: (context) => const WelcomeScreen(), // Or an error screen
          );
      },
      // onUnknownRoute is not needed when using onGenerateRoute for all paths
    );
  }
}

// Note:
// You will need to modify your MainFormScreen widget to accept the TobaccoClassifier instance.
// Example:
// class MainFormScreen extends StatelessWidget {
//   final TobaccoClassifier classifier;
//   const MainFormScreen({Key? key, required this.classifier}) : super(key: key);
//   ...
// }
// Inside MainFormScreen, you can then use the classifier instance to perform grading.
// You would integrate the CameraWidget and call classifier.classifyImage from there.
