import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_model.dart';

// ================= SCAN RECORD MODEL & HISTORY STORE =================

class ScanRecord {
  final String id;
  final String disease;
  final double confidence;
  final String? imagePath;
  final Uint8List? imageBytes;
  final DateTime timestamp;

  ScanRecord({
    required this.id,
    required this.disease,
    required this.confidence,
    this.imagePath,
    this.imageBytes,
    required this.timestamp,
  });
}

class ScanHistoryStore {
  static final ValueNotifier<List<ScanRecord>> scansNotifier =
      ValueNotifier<List<ScanRecord>>([]);

  static List<ScanRecord> get scans => scansNotifier.value;

  static void addScan(ScanRecord record) {
    scansNotifier.value = [record, ...scansNotifier.value];
  }

  static bool isSaved(String? path, String disease, double confidence) {
    return scansNotifier.value.any(
      (s) => s.disease == disease && s.confidence == confidence && s.imagePath == path,
    );
  }

  static void clearHistory() {
    scansNotifier.value = [];
  }
}

void main() {
  runApp(const PlantDiseaseApp());
}

class PlantDiseaseApp extends StatelessWidget {
  const PlantDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.local_florist,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'AI Plant Disease Detector',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Detect plant diseases using AI',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= REGISTER PAGE =================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully! Please log in.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Return to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add,
                size: 70,
                color: Colors.green,
              ),

              const SizedBox(height: 15),

              const Text(
                'Join AI Plant Disease Detector',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Return to LoginPage
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Plant Disease Detector'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome
            const Text(
              'Welcome, Plant User 🌱',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Detect plant diseases quickly using AI.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // Scan Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Column(
                children: [

                  const Icon(
                    Icons.local_florist,
                    size: 65,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Scan Your Plant',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Take a photo or choose a plant image '
                    'to detect possible diseases.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        'Start Plant Scan',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // History and Profile
            Row(
              children: [

                Expanded(
                  child: _quickButton(
                    context,
                    Icons.history,
                    'History',
                    const HistoryPage(),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _quickButton(
                    context,
                    Icons.person,
                    'Profile',
                    const ProfilePage(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // How it works
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _step(
              Icons.camera_alt,
              '1. Capture',
              'Take a clear photo of your plant.',
            ),

            _step(
              Icons.psychology,
              '2. AI Detection',
              'AI analyzes the plant image.',
            ),

            _step(
              Icons.medical_information,
              '3. Get Result',
              'View the disease and treatment information.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: const BorderSide(color: Colors.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(
              icon,
              color: Colors.green,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SCAN PAGE =================

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  Future<void> pickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: source,
      );

      if (image == null) return;

      if (context.mounted) {
        // Show loading dialog while processing AI model
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Analyzing plant image with AI...'),
                ),
              ],
            ),
          ),
        );
      }

      try {
        final imageBytes = await image.readAsBytes();
        if (imageBytes.isEmpty) {
          throw Exception('Selected image is empty or unreadable.');
        }

        final aiModel = AIModel();

        try {
          final result = await aiModel.predict(image.path, imageBytes: imageBytes);

          if (!context.mounted) return;
          Navigator.pop(context); // Close loading dialog

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                imagePath: image.path,
                imageBytes: imageBytes,
                disease: result['disease'],
                confidence: (result['confidence'] as num).toDouble(),
                rejectionReason: result['rejectionReason'] as String?,
                topCandidate: result['topCandidate'] as String?,
              ),
            ),
          );
        } finally {
          aiModel.closeModel();
        }
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI detection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plant'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_florist,
              size: 100,
              color: Colors.green,
            ),

            const SizedBox(height: 25),

            const Text(
              'Scan or Upload a plant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  pickImage(
                    context,
                    ImageSource.camera,
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Plant Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  pickImage(context, ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose plant image'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= RESULT PAGE =================

class ResultPage extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final String disease;
  final double confidence;
  final String? rejectionReason;
  final String? topCandidate;

  const ResultPage({
    super.key,
    this.imagePath,
    this.imageBytes,
    required this.disease,
    required this.confidence,
    this.rejectionReason,
    this.topCandidate,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = ScanHistoryStore.isSaved(widget.imagePath, widget.disease, widget.confidence);
  }

  String getTreatment() {
    final d = widget.disease;
    if (d.contains('Unable to identify') || d.contains('Uncertain') || d.contains('Unsupported')) {
      if (widget.rejectionReason != null && widget.rejectionReason!.isNotEmpty) {
        return '${widget.rejectionReason!}\n\nTry a clear, well-lit photo with the plant or affected leaf in focus. This model was trained on selected leaf-disease categories, so results for other plant types or whole-plant photos may be unreliable.';
      }
      return 'The AI model could not identify a clear disease pattern. You can upload different plant photos, but this model works best with clear images of leaves from its trained categories. Results for other plants or whole-plant photos may be unreliable.';
    } else if (d.contains('Pepper Bell Bacterial Spot') || d.contains('Tomato Bacterial Spot') || d.contains('Bacterial')) {
      return 'Preliminary Screening: Confirm symptoms (small dark spots with yellow halos) before applying treatment. If confirmed:\n\n• Remove infected leaves immediately.\n• Apply a copper-based fungicide or bactericide.\n• Avoid overhead watering and handle plants when foliage is completely dry.';
    } else if (d.contains('Potato Early Blight') || d.contains('Tomato Early Blight') || d.contains('Early Blight')) {
      return 'Preliminary Screening: Confirm symptoms (dark concentric ring spots on lower foliage) before pruning. If confirmed:\n\n• Prune infected lower foliage.\n• Apply bio-fungicide or copper spray weekly during moist conditions.\n• Ensure proper plant nutrition to help foliage recover.';
    } else if (d.contains('Potato Late Blight') || d.contains('Tomato Late Blight') || d.contains('Late Blight')) {
      return 'Preliminary Screening: Confirm symptoms (large water-soaked dark lesions or white fungal mold) before destroying foliage. If confirmed:\n\n• Immediately remove and destroy infected plant foliage.\n• Apply protective copper fungicide on remaining foliage and keep the plant area dry and ventilated.';
    } else if (d.contains('Tomato Leaf Mold') || d.contains('Leaf Mold')) {
      return 'Preliminary Screening: Confirm symptoms (pale green/yellow leaf spots with olive mold underneath) before treating. If confirmed:\n\n• Improve greenhouse/garden ventilation and spacing.\n• Prune lower infected leaves and apply a copper-based fungicide.';
    } else if (d.contains('Tomato Septoria Leaf Spot') || d.contains('Septoria')) {
      return 'Preliminary Screening: Confirm symptoms (small circular spots with dark margins and grey centers) before treating. If confirmed:\n\n• Remove diseased leaves as soon as spots appear.\n• Apply organic copper fungicide and avoid wetting leaves when watering.';
    } else if (d.contains('Spider Mites')) {
      return 'Preliminary Screening: Inspect leaf undersides for fine webbing or tiny moving mites before treatment. If confirmed:\n\n• Spray leaf undersides thoroughly with insecticidal soap, neem oil, or miticide.\n• Keep foliage well-hydrated to reduce mite infestation.';
    } else if (d.contains('Target Spot')) {
      return 'Preliminary Screening: Confirm symptoms (brown circular lesions with concentric rings) before treating. If confirmed:\n\n• Remove symptomatic leaves and apply chlorothalonil or copper fungicide according to product instructions.';
    } else if (d.contains('Mosaic Virus')) {
      return 'Preliminary Screening: Confirm symptoms (mottled light/dark green patterns or leaf distortion) before discarding plants. If confirmed:\n\n• Remove and destroy infected plants promptly as viruses cannot be cured.\n• Control insect vectors and wash hands before handling healthy plants.';
    } else if (d.contains('Yellow Leaf Curl')) {
      return 'Preliminary Screening: Confirm symptoms (severe upward leaf curling with yellow margins) before discarding plants. If confirmed:\n\n• Pull up severely infected plants to stop disease spread.\n• Treat surrounding plants with neem oil or insecticidal soap to manage whiteflies.';
    } else if (d.contains('Healthy')) {
      return 'No treatment required! Your plant appears healthy. Continue normal watering, sunlight, and nutrient routine.';
    } else {
      return 'Preliminary Screening: Confirm symptoms with an agricultural expert. If confirmed, remove affected leaves and apply recommended treatment for the specific condition.';
    }
  }

  String getPrevention() {
    final d = widget.disease;
    if (d.contains('Unable to identify') || d.contains('Uncertain') || d.contains('Unsupported')) {
      return 'Use a clear image with the plant or affected leaf in focus and good natural light. The closest AI match is only a suggestion, not a confirmed diagnosis. Verify visible symptoms before taking any treatment action.';
    } else if (d.contains('Healthy')) {
      return 'Maintain consistent watering, provide 6+ hours of full sun daily, ensure good soil drainage, and inspect regularly for early pest signs.';
    } else if (d.contains('Bacterial')) {
      return 'Use certified disease-free seeds, practice crop rotation, sanitize garden tools after pruning, and use drip irrigation to keep foliage dry.';
    } else if (d.contains('Blight')) {
      return 'Mulch base of plants to prevent soil-borne spores from splashing onto leaves, stake stems off ground, and practice annual crop rotation.';
    } else if (d.contains('Virus')) {
      return 'Plant virus-resistant crop varieties, control whiteflies/aphids with netting or traps, and thoroughly sanitize tools between uses.';
    } else if (d.contains('Mites')) {
      return 'Keep surrounding weeds under control, avoid dry dusty conditions, and encourage beneficial predatory insects in your garden.';
    } else {
      return 'Maintain proper watering, optimal sunlight, and good air circulation around foliage. Remove fallen plant debris and keep the garden clean.';
    }
  }

  void _saveScan() {
    if (_isSaved) return;

    final newRecord = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      disease: widget.disease,
      confidence: widget.confidence,
      imagePath: widget.imagePath,
      imageBytes: widget.imageBytes,
      timestamp: DateTime.now(),
    );

    ScanHistoryStore.addScan(newRecord);

    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan saved to Scan History!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = widget.disease.toLowerCase().contains('healthy');
    final isUncertain = widget.disease.toLowerCase().contains('unable') ||
        widget.disease.toLowerCase().contains('uncertain') ||
        widget.disease.toLowerCase().contains('unsupported');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: widget.imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      widget.imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : widget.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: kIsWeb
                            ? Image.network(
                                widget.imagePath!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(widget.imagePath!),
                                fit: BoxFit.cover,
                              ),
                      )
                    : const Icon(
                        Icons.local_florist,
                        size: 80,
                        color: Colors.green,
                      ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUncertain ? Colors.amber.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isUncertain ? Colors.amber.shade300 : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isUncertain ? Colors.amber.shade800 : Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prototype limitation: This model has 15 leaf-disease categories for tomato, potato and bell pepper. Results for other plant types, whole-plant photos, or outdoor conditions may be unreliable.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUncertain ? Colors.amber.shade900 : Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                isUncertain
                    ? Icons.help_outline
                    : (isHealthy ? Icons.check_circle : Icons.warning),
                color: isUncertain
                    ? Colors.amber.shade700
                    : (isHealthy ? Colors.green : Colors.orange),
                size: 30,
              ),
              title: Text(
                isUncertain
                    ? 'Analysis Status'
                    : (isHealthy ? 'Plant Health Status' : 'Disease Detected (Unconfirmed)'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.disease,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isUncertain
                      ? Colors.amber.shade900
                      : (isHealthy ? Colors.green.shade700 : Colors.deepOrange),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.analytics,
                color: Colors.green,
                size: 30,
              ),
              title: Text(isUncertain ? 'Model Certainty Score' : 'Confidence Score'),
              subtitle: Text(
                isUncertain
                    ? '${widget.confidence.toStringAsFixed(2)}% (Unvalidated)'
                    : '${widget.confidence.toStringAsFixed(2)}% (Prototype Score)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isUncertain ? Colors.amber.shade800 : Colors.green,
                ),
              ),
            ),
          ),

          if (isUncertain && widget.topCandidate != null && widget.topCandidate!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                title: const Text(
                  'AI’s Closest Match (Unconfirmed)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${widget.topCandidate!}\nThis is the model’s highest-scoring category, not a confirmed diagnosis.',
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          Text(
            isUncertain ? 'Recommended Action' : 'Recommended Treatment',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                getTreatment(),
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            isUncertain ? 'Image & Diagnostics Tips' : 'Prevention Advice',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                getPrevention(),
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaved ? null : _saveScan,
              icon: Icon(_isSaved ? Icons.check_circle : Icons.history),
              label: Text(
                _isSaved ? 'Saved to History' : 'Save Scan to History',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= HISTORY PAGE =================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder<List<ScanRecord>>(
            valueListenable: ScanHistoryStore.scansNotifier,
            builder: (context, scans, _) {
              if (scans.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear History',
                onPressed: () {
                  ScanHistoryStore.clearHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan history cleared')),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ScanRecord>>(
        valueListenable: ScanHistoryStore.scansNotifier,
        builder: (context, scans, _) {
          if (scans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 80,
                      color: Colors.green.shade200,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No Saved Scans Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan a plant leaf and tap "Save Scan to History" to view your saved scan records here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final record = scans[index];
              final isHealthy = record.disease.toLowerCase().contains('healthy');
              final isUncertain = record.disease.toLowerCase().contains('unable') ||
                  record.disease.toLowerCase().contains('uncertain') ||
                  record.disease.toLowerCase().contains('unsupported');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: isUncertain
                          ? Colors.amber.shade50
                          : (isHealthy ? Colors.green.shade50 : Colors.orange.shade50),
                      child: record.imageBytes != null
                          ? Image.memory(
                              record.imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : record.imagePath != null
                              ? (kIsWeb
                                  ? Image.network(record.imagePath!, fit: BoxFit.cover)
                                  : Image.file(File(record.imagePath!), fit: BoxFit.cover))
                              : Icon(
                                  isUncertain
                                      ? Icons.help_outline
                                      : (isHealthy ? Icons.local_florist : Icons.warning_amber),
                                  color: isUncertain
                                      ? Colors.amber.shade800
                                      : (isHealthy ? Colors.green : Colors.orange),
                                ),
                    ),
                  ),
                  title: Text(
                    record.disease,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    isUncertain
                        ? 'Unvalidated Score: ${record.confidence.toStringAsFixed(1)}%'
                        : 'Confidence: ${record.confidence.toStringAsFixed(1)}% (Prototype)',
                    style: TextStyle(
                      color: isUncertain
                          ? Colors.amber.shade800
                          : (isHealthy ? Colors.green.shade700 : Colors.deepOrange),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    _formatDate(record.timestamp),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          imagePath: record.imagePath,
                          imageBytes: record.imageBytes,
                          disease: record.disease,
                          confidence: record.confidence,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= PROFILE PAGE =================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Plant User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'plantuser@example.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}