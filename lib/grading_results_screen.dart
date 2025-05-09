import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

// Assuming you have added the Pacifico font to your project
// and declared it in pubspec.yaml.
// You will also need built-in Flutter icons or a custom icon font for the icons.

class GradingResultsScreen extends StatefulWidget {
  // This screen will likely receive the results data
  // from the previous screen (MainFormScreen)
  final Map<String, dynamic> gradingData;

  const GradingResultsScreen({
    super.key,
    // Accept grading data as a parameter
    required this.gradingData,
  });

  @override
  _GradingResultsScreenState createState() => _GradingResultsScreenState();
}

class _GradingResultsScreenState extends State<GradingResultsScreen> {
  // Mock data structure based on the HTML script
  // Replace this with actual data passed to the widget
  late Map<String, dynamic> _results;

  @override
  void initState() {
    super.initState();
    // Validate and initialize the results
    if (widget.gradingData.isEmpty) {
      _results = {
        'grade': 'N/A',
        'quality': 'No data available',
        'details': {
          'color': 'N/A',
          'size': 'N/A',
          'shape': 'N/A',
          'defects': 'N/A',
          'firmness': 'N/A'
        }
      };
    } else {
      _results = widget.gradingData;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Approximate position
      ),
    );
  }

  Future<void> _saveResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().toIso8601String();
      final resultKey = 'grading_result_$timestamp';

      // Save the result with timestamp
      await prefs.setString(resultKey, jsonEncode(_results));

      // Save the timestamp to a list of saved results
      final savedResults = prefs.getStringList('saved_results') ?? [];
      savedResults.add(resultKey);
      await prefs.setStringList('saved_results', savedResults);

      _showToast('Result saved successfully');
    } catch (e) {
      _showToast('Error saving result: $e');
    }
  }

  Future<void> _shareResult() async {
    try {
      // Format the results into a readable string
      final String shareText = '''
LeafGrader Analysis Results
------------------------
Grade: ${_results['grade'] ?? 'N/A'}
Quality: ${_results['quality'] ?? 'N/A'}

Detailed Analysis:
${_formatDetails(_results['details'])}
''';

      await Share.share(shareText);
    } catch (e) {
      _showToast('Error sharing result: $e');
    }
  }

  String _formatDetails(Map<String, dynamic>? details) {
    if (details == null) return 'No details available';

    return details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the target width is 375px as per the HTML
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth > 375 ? 375 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.grey[100], // bg-gray-50 approx
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0, // border-b border-gray-100 shadow-sm approx
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.grey), // ri-arrow-left-s-line text-xl text-gray-700
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'Grading Results',
          style: TextStyle(
            fontSize: 18.0, // text-lg
            fontWeight: FontWeight.w500, // font-medium
            color: Colors.black, // text-gray-900
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // Placeholder for right side
        ],
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          color: Colors.white, // bg-white for the content area
          child: SingleChildScrollView(
            // Allows scrolling if content overflows
            padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0)
                .copyWith(
                    top: 20.0 +
                        kToolbarHeight), // pt-20 + pb-20 approx, considering AppBar height
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // stretch items to full width
              children: [
                // Grade Display
                Container(
                  padding: const EdgeInsets.all(32.0), // p-8
                  margin: const EdgeInsets.only(bottom: 24.0), // mb-6
                  decoration: BoxDecoration(
                    color: Colors.green[50], // bg-green-50
                    borderRadius: BorderRadius.circular(8.0), // rounded-lg
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.05), // shadow-sm approx
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _results['grade'] ??
                            '-', // Display grade, default to '-' if null
                        style: TextStyle(
                          fontSize: 80.0, // text-[80px]
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600], // text-green-600
                        ),
                      ),
                      const SizedBox(height: 8.0), // mt-2 approx
                      Text(
                        _results['quality'] ??
                            'N/A', // Display quality, default to 'N/A' if null
                        style: TextStyle(
                          color: Colors.green[600], // text-green-600
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Detailed Analysis
                Container(
                  padding: const EdgeInsets.all(16.0), // p-4
                  margin: const EdgeInsets.only(bottom: 24.0), // mb-6
                  decoration: BoxDecoration(
                    color: Colors.white, // bg-white
                    borderRadius: BorderRadius.circular(8.0), // rounded-lg
                    border: Border.all(
                        color:
                            Colors.grey[300]!), // border border-gray-200 approx
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.05), // shadow-sm approx
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0), // mb-4
                        child: Text(
                          'Detailed Analysis',
                          style: TextStyle(
                            fontSize: 18.0, // text-lg
                            fontWeight: FontWeight.w500, // font-medium
                            color: Colors.black, // text-gray-900
                          ),
                        ),
                      ),
                      // Analysis details list
                      if (_results['details']
                          is Map) // Check if details is a map
                        ...(_results['details'] as Map).entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0), // space-y-4 / 2 approx
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key, // Detail name (e.g., Color, Size)
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors
                                        .grey[700], // text-gray-600 approx
                                  ),
                                ),
                                Text(
                                  entry.value.toString(), // Detail value
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black, // text-gray-900 approx
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        const Text('Analysis details not available'),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF4F46E5), // primary color (indigo-600 from the third HTML)
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0), // py-3
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // !rounded-button
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_alt,
                                size: 20.0), // ri-save-line approx
                            SizedBox(width: 8.0), // mr-2
                            Text(
                              'Save Result',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0), // gap-4
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _shareResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF10B981), // secondary color (emerald-500 from the third HTML)
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0), // py-3
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // !rounded-button
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share,
                                size: 20.0), // ri-share-line approx
                            SizedBox(width: 8.0), // mr-2
                            Text(
                              'Share',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // The toast is handled by ScaffoldMessenger, not a fixed position widget in modern Flutter
    );
  }
}
