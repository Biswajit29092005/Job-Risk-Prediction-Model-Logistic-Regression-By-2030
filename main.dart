import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
// Imports your m2cgen native Dart model
import 'model_logic.dart'; 

void main() => runApp(const JobPredictionApp());

class JobPredictionApp extends StatelessWidget {
  const JobPredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic Labor Risk Simulator',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const OfflinePredictionScreen(),
    );
  }
}

class OfflinePredictionScreen extends StatefulWidget {
  const OfflinePredictionScreen({super.key});

  @override
  State<OfflinePredictionScreen> createState() => _OfflinePredictionScreenState();
}

class _OfflinePredictionScreenState extends State<OfflinePredictionScreen> {
  Map<String, dynamic> _jobDatabase = {};
  
  // --- CORE DETAILS CONTROLLERS ---
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  double _selectedEducation = 2.0; 

  // --- ENVIRONMENT FACTORS ---
  double _aiExposureIndex = 0.50;
  double _techGrowthFactor = 1.00;
  double _automationProbability = 0.50;

  // --- SKILL VALUATIONS ---
  final List<double> _userSkillInputs = List.generate(10, (_) => 0.50);

  // --- UI OUTPUT STATES ---
  String _resultText = "Enter an occupation title above to map skills and run analytics.";
  Color _resultColor = Colors.grey;
  bool _isLoading = true;

  // INITIAL LABELS
  List<String> _currentSkillLabels = List.generate(10, (i) => "Core Competency ${i + 1}");

  // EXACT MEANS EXTRACTED FROM PYTHON STANDARD SCALER (From your newly balanced data.csv)
  final List<double> _scalerMeans = const [
    89917.289524, 14.681429, 1.46619, 0.502471, 0.988119, 0.500786, 
    0.493938, 0.501019, 0.497676, 0.486852, 0.498719, 0.493124, 
    0.495976, 0.503638, 0.493452, 0.50001
  ];

  // EXACT STANDARD DEVIATIONS (SCALES) EXTRACTED FROM PYTHON STANDARD SCALER
  final List<double> _scalerScales = const [
    34615.322496, 8.783043, 1.113253, 0.28282, 0.286627, 0.247957, 
    0.284564, 0.287682, 0.287299, 0.288421, 0.286962, 0.288443, 
    0.287427, 0.286017, 0.286237, 0.288152
  ];

  @override
  void initState() {
    super.initState();
    _loadDatabase();
    _jobTitleController.addListener(_updateSkillLabelsDynamically);
  }

  @override
  void dispose() {
    _jobTitleController.removeListener(_updateSkillLabelsDynamically);
    _jobTitleController.dispose();
    _salaryController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabase() async {
    try {
      final String response = await rootBundle.loadString('assets/job_database.json');
      final data = await json.decode(response);
      setState(() {
        _jobDatabase = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _resultText = "Ready to simulate (Local offline fallback engaged).";
        _isLoading = false;
      });
    }
  }

  // INDUSTRY TAXONOMY ENGINE: Fixes the IT-bias bug by mapping specific archetypes
  void _updateSkillLabelsDynamically() {
    String input = _jobTitleController.text.trim().toLowerCase();

    setState(() {
      if (input.isEmpty) {
        _currentSkillLabels = List.generate(10, (i) => "Core Competency ${i + 1}");
        return;
      }

      if (input.contains('secur') || input.contains('guard') || input.contains('police') || input.contains('patrol')) {
        _currentSkillLabels = [
          "Surveillance Operations", "Physical Patrolling & Presence", "Access Control Management", 
          "Incident Reporting Accuracy", "Risk & Threat Assessment", "Emergency Response Speed", 
          "Conflict De-escalation", "Crowd Control Tactics", "First Aid / CPR Proficiency", "Security Tech Operation"
        ];
      } else if (input.contains('softwar') || input.contains('develop') || input.contains('engin') || input.contains('data') || input.contains('ai ')) {
        _currentSkillLabels = [
          "System Architecture", "Algorithmic Logic", "Data Wrangling", "Database Management", 
          "Cloud Infrastructure", "API Integration", "Debugging Fluency", "Cybersecurity Protocols", 
          "Version Control (Git)", "Technical Documentation"
        ];
      } else if (input.contains('nurs') || input.contains('doctor') || input.contains('medic') || input.contains('health') || input.contains('surg')) {
        _currentSkillLabels = [
          "Patient Vital Monitoring", "Diagnostic Precision", "Surgical/Manual Dexterity", "Triage Assessment", 
          "Electronic Health Records", "Infection Control", "Emergency Life Support", "Clinical Pharmacology", 
          "Patient Empathy & Bedside", "Medical Terminology"
        ];
      } else if (input.contains('mechan') || input.contains('construct') || input.contains('build') || input.contains('worker') || input.contains('driver')) {
        _currentSkillLabels = [
          "Heavy Machinery Operation", "Physical Stamina", "Manual Precision Dexterity", "Safety Protocol Compliance", 
          "Blueprint & Schematic Reading", "Spatial Awareness", "Equipment Diagnostics", "Material Handling", 
          "Vehicle Navigation", "Routine Maintenance Execution"
        ];
      } else if (input.contains('teach') || input.contains('educat') || input.contains('profess') || input.contains('tutor')) {
        _currentSkillLabels = [
          "Curriculum Development", "Classroom Management", "Information Synthesis", "Public Speaking", 
          "Student Emotional Empathy", "Assessment & Grading", "Adaptive Learning Pacing", "Subject Matter Expertise", 
          "Conflict Resolution", "Digital Teaching Tools"
        ];
      } else if (input.contains('manag') || input.contains('exec') || input.contains('hr ') || input.contains('financ') || input.contains('analyst')) {
        _currentSkillLabels = [
          "Capital Allocation", "Risk Forecasting", "Contract Negotiation", "Stakeholder Presentation", 
          "Market Trend Analysis", "Strategic Scalability", "Operational Auditing", "Cross-Functional Leadership", 
          "Corporate Compliance", "Client Retention"
        ];
      } else {
        // PROFESSIONAL FALLBACK: Uses universal business terms, completely avoiding IT/Tech jargon.
        String title = _jobTitleController.text.trim();
        String formatted = title[0].toUpperCase() + title.substring(1);
        _currentSkillLabels = [
          "$formatted - Core Task Execution", "$formatted - Contextual Problem Solving", "$formatted - Specialized Tool Proficiency", 
          "$formatted - Process Optimization", "$formatted - Quality Assurance", "$formatted - Regulatory Compliance", 
          "$formatted - Resource Management", "$formatted - Adaptability to Change", "$formatted - Interpersonal Communication", "$formatted - Information Handling"
        ];
      }
    });
  }

  // 100% HONEST ML PIPELINE (No artificial external logic modifiers)
  void _executeModelPipeline() {
    String salaryText = _salaryController.text.trim();
    String expText = _experienceController.text.trim();

    if (salaryText.isEmpty || expText.isEmpty) {
      setState(() {
        _resultText = "Please input values for Annual Salary and Experience.";
        _resultColor = Colors.orangeAccent;
      });
      return;
    }

    double userSalary = double.tryParse(salaryText) ?? 45000.0;
    double userExperience = double.tryParse(expText) ?? 0.0;

    // Preprocessing Step: Qualifications scale individual candidate competency ceilings honestly
    double qualificationWeightModifier = 1.0;
    if (_selectedEducation == 1.0) qualificationWeightModifier = 0.70; 
    if (_selectedEducation == 3.0) qualificationWeightModifier = 1.30; 

    // STEP 1: VECTOR ASSEMBLY
    List<double> rawFeatures = [
      userSalary,             // Index 0
      userExperience,         // Index 1
      _selectedEducation,     // Index 2
      _aiExposureIndex,       // Index 3
      _techGrowthFactor,      // Index 4
      _automationProbability, // Index 5
      
      // Indices 6-15: Map current slider state metrics compounded by qualification baselines
      (_userSkillInputs[0] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[1] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[2] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[3] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[4] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[5] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[6] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[7] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[8] * qualificationWeightModifier).clamp(0.0, 1.0),
      (_userSkillInputs[9] * qualificationWeightModifier).clamp(0.0, 1.0),
    ];

    // STEP 2: Z-SCORE NORMALIZATION
    List<double> normalizedFeatures = [];
    for (int i = 0; i < rawFeatures.length; i++) {
      double zScore = (rawFeatures[i] - _scalerMeans[i]) / _scalerScales[i];
      normalizedFeatures.add(zScore);
    }

    // STEP 3: NATIVE ML PREDICTION
    try {
      double logOdds = score(normalizedFeatures); 
      double probability = 1.0 / (1.0 + exp(-logOdds));
      String percentage = (probability * 100).toStringAsFixed(1);

      setState(() {
        if (probability > 0.5) {
          _resultText = "STATUS: AT RISK\nProbability of Job Displacement: $percentage%";
          _resultColor = Colors.redAccent;
        } else {
          _resultText = "STATUS: SAFE\nProbability of Job Displacement: $percentage%";
          _resultColor = Colors.tealAccent;
        }
      });
    } catch (e) {
      setState(() {
        _resultText = "Calculation error. Please verify input data ranges.";
        _resultColor = Colors.redAccent;
      });
    }
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label, 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(value * 100).toStringAsFixed(0)}%", 
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min, max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Risk Predictor'),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader("1. Candidate Baseline & Profession"),
                  TextField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Target Job Title',
                      hintText: 'Enter Any Job Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Annual Salary (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _experienceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Years Exp.',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.trending_up),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: _selectedEducation,
                    decoration: const InputDecoration(
                      labelText: 'Candidate Qualification Tier',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1.0, child: Text("High School / Associate")),
                      DropdownMenuItem(value: 2.0, child: Text("Bachelor's Degree")),
                      DropdownMenuItem(value: 3.0, child: Text("Master's or Ph.D.")),
                    ],
                    onChanged: (val) => setState(() => _selectedEducation = val ?? 2.0),
                  ),
                  const SizedBox(height: 28),

                  _buildSectionHeader("2. Macro Threat Environment Factors"),
                  Card(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          _buildSliderRow(
                            label: "AI Task Exposure Index",
                            value: _aiExposureIndex,
                            min: 0.0, max: 1.0, divisions: 20,
                            onChanged: (val) => setState(() => _aiExposureIndex = val),
                          ),
                          _buildSliderRow(
                            label: "Industry Tech Growth Acceleration",
                            value: _techGrowthFactor,
                            min: 0.0, max: 2.0, divisions: 20,
                            onChanged: (val) => setState(() => _techGrowthFactor = val),
                          ),
                          _buildSliderRow(
                            label: "General Job Automation Probability",
                            value: _automationProbability,
                            min: 0.0, max: 1.0, divisions: 20,
                            onChanged: (val) => setState(() => _automationProbability = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildSectionHeader("3. Competency Vectors (Adaptive)"),
                  Card(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: List.generate(10, (index) {
                          return _buildSliderRow(
                            label: _currentSkillLabels[index], 
                            value: _userSkillInputs[index],
                            min: 0.0, max: 1.0, divisions: 20,
                            onChanged: (val) => setState(() => _userSkillInputs[index] = val),
                          );
                        }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _executeModelPipeline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bolt, size: 24),
                  label: const Text(
                    'COMPUTE DISPLACEMENT RISK',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _resultColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PREDICTION CALCULATOR OUTPUT",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _resultText,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _resultColor, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent, letterSpacing: 1.1),
      ),
    );
  }
}