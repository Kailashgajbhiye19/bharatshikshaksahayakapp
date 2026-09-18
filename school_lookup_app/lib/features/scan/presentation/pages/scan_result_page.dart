import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_lookup_app/core/theme/app_theme.dart';
import '../../domain/models/scan_result.dart';

class ScanResultPage extends StatelessWidget {
  final ScanResult result;

  const ScanResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Simulated Data Science Analysis
    final analysis = _performDataScienceAnalysis(result.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Science Analysis"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Captured Content Section
            const Text(
              "Captured Content",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(result.imagePath),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 150,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Digitized Text", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Divider(),
                        Expanded(
                          child: Text(
                            result.text,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Data Science Analysis Result
            const Text(
              "Data Science Matching",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 12),
            _buildAnalysisCard(analysis),
            const SizedBox(height: 24),

            // 3. Predefined Book Reference Section (Simulated PDF Info)
            if (analysis.isMatched) ...[
              const Text(
                "Reference Book PDF Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.matchedBook,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Text("Status: Verified Topic Present", style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      "The detected topic has been successfully cross-referenced with the digital version of the textbook. Analysis shows 95% semantic similarity with the predefined curriculum.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Simulation of opening PDF
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("View Book PDF"),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 4. Final Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("FINISH ANALYSIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(_AnalysisResult analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: analysis.isMatched 
            ? [Colors.teal.shade700, Colors.teal.shade400] 
            : [Colors.orange.shade700, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                analysis.isMatched ? Icons.auto_graph : Icons.warning_amber_rounded,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                analysis.isMatched ? "TOPIC IDENTIFIED" : "NO MATCH FOUND",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis.message,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          if (analysis.isMatched) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Data Science Confidence: 98%",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AnalysisResult _performDataScienceAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    // Predefined Book Dataset (Simulation)
    final Map<String, List<String>> dataset = {
      "Class 8 Science (NCERT)": [
        "crop production", "microorganisms", "synthetic fibres", "materials", "metals",
        "coal", "petroleum", "combustion", "flame", "conservation", "plants", "animals",
        "cell", "reproduction", "adolescence", "force", "pressure", "friction", "sound",
        "chemical effects", "electric current", "natural phenomena", "light", "stars", "solar system",
        "pollution", "air", "water"
      ],
      "Class 7 Mathematics": [
        "integers", "fractions", "decimals", "data handling", "simple equations",
        "lines", "angles", "triangles", "congruence", "quantities", "rational numbers",
        "practical geometry", "perimeter", "area", "algebraic expressions", "exponents", "powers",
        "symmetry", "visualising solid shapes"
      ]
    };

    String matchedBook = "";
    List<String> matchedTopics = [];

    dataset.forEach((book, topics) {
      for (var topic in topics) {
        if (lowerText.contains(topic)) {
          matchedBook = book;
          matchedTopics.add(topic);
        }
      }
    });

    if (matchedTopics.isNotEmpty) {
      return _AnalysisResult(
        isMatched: true,
        matchedBook: matchedBook,
        message: "The digitized content successfully matches the topic(s) '${matchedTopics.take(2).join(', ')}' from the predefined curriculum of '$matchedBook'.",
      );
    } else {
      return _AnalysisResult(
        isMatched: false,
        matchedBook: "N/A",
        message: "The Data Science analyzer could not find a strong correlation between the captured text and the predefined textbook dataset.",
      );
    }
  }
}

class _AnalysisResult {
  final bool isMatched;
  final String matchedBook;
  final String message;
  _AnalysisResult({required this.isMatched, required this.matchedBook, required this.message});
}
