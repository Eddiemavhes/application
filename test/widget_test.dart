// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:myapp/services/classifier.dart'; // Import the classifier
import 'package:myapp/welcome_screen.dart'; // Import the WelcomeScreen

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Initialize Flutter bindings for test environment if needed (e.g. for asset loading)
    TestWidgetsFlutterBinding.ensureInitialized();

    // Load the classifier.
    // Note: For more complex tests, you might want to mock the classifier
    // or ensure that 'assets/models/tobacco_model.tflite' is available in the test environment.
    // For this basic smoke test, we'll attempt to load the real one.
    // Ensure assets are available for tests by configuring pubspec.yaml or using a test asset bundle.
    // We also need to make sure that the assets used by the classifier are declared in pubspec.yaml
    // and actually exist at the specified paths.
    TobaccoClassifier classifier;
    try {
      classifier = await TobaccoClassifier.load();
    } catch (e) {
      // Fallback or error handling if classifier loading fails in test.
      // For a robust test, consider mocking or providing a dummy classifier.
      print('Error loading classifier in test: $e. Using a dummy classifier.');
      // As a simple fallback, we're rethrowing to indicate test setup issues.
      // In a real scenario, you might use a mock/fake classifier here.
      rethrow;
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(classifier: classifier));

    // Verify that the WelcomeScreen is present.
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // You can also verify specific elements on the WelcomeScreen, for example:
    expect(find.text('LeafGrader'), findsOneWidget); // Assuming 'LeafGrader' is part of WelcomeScreen
    expect(find.text('Get Started'), findsOneWidget); // Assuming 'Get Started' button is present
  });
}
