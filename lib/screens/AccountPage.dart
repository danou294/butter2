import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final PageController _pageController;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85);
  }

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.28;
    final pageViewHeight = screenHeight - headerHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background-liste.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.45),
          ),
          Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Mon compte',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: 'InriaSerif',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTab('Tes recos', 0),
                                const SizedBox(width: 24),
                                _buildTab('Profil', 1),
                                const SizedBox(width: 24),
                                _buildTab('Feedbacks', 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  children: const [
                    RecoTab(),
                    ProfileTab(),
                    FeedbackTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'InriaSerif',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '•',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.transparent,
              fontSize: 18,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? 'Laura';
    _emailController.text = user?.email ?? '+33 6 65 44 31 67';
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_formKey.currentState!.validate()) {
      await user?.updateDisplayName(_nameController.text);
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF1EFEB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            if (_editing)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Nom complet', _nameController),
                    const SizedBox(height: 12),
                    _buildTextField('Téléphone', _emailController),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontFamily: 'InriaSans', fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                _nameController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InriaSerif',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text,
                style: const TextStyle(fontSize: 14, fontFamily: 'InriaSans'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _editing = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Modifier mon profil', style: TextStyle(color: Colors.white, fontFamily: 'InriaSans', fontSize: 16)),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Déconnecté !')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Se déconnecter', style: TextStyle(color: Colors.white, fontFamily: 'InriaSans', fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Membre Butter depuis\n2025',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'InriaSans', fontSize: 14, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEDE9E0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
      style: const TextStyle(fontFamily: 'InriaSans'),
    );
  }
}

class RecoTab extends StatefulWidget {
  const RecoTab({super.key});

  @override
  State<RecoTab> createState() => _RecoTabState();
}

class _RecoTabState extends State<RecoTab> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _arrController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('recommandations').add({
        'nom': _nomController.text.trim(),
        'arrondissement': _arrController.text.trim(),
        'date': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      setState(() {
        _nomController.clear();
        _arrController.clear();
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour ta recommandation !')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _nomController.text.trim().isEmpty || _arrController.text.trim().isEmpty;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF1EFEB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recommande un restaurant !',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'InriaSerif',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du restaurant',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Champ requis' : null,
                style: const TextStyle(fontFamily: 'InriaSans'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _arrController,
                decoration: const InputDecoration(
                  labelText: 'Arrondissement',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Champ requis' : null,
                style: const TextStyle(fontFamily: 'InriaSans'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEmpty || _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmpty || _loading ? Colors.black12 : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Envoyer',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'InriaSans'),
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

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _loading = false;

  int get _wordCount {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'feedback': _feedbackController.text.trim(),
        'date': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      setState(() {
        _feedbackController.clear();
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour ton feedback !')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _feedbackController.text.trim().isEmpty;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF1EFEB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Remarque, conseil, demande…\nOn t\'écoute !',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'InriaSerif',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  TextFormField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      labelText: 'Feedback (500 mots max)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    ),
                    minLines: 8,
                    maxLines: 16,
                    maxLength: 3000, // 500 mots ≈ 3000 caractères
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Champ requis' : null,
                    style: const TextStyle(fontFamily: 'InriaSans'),
                    onChanged: (_) => setState(() {}),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 10,
                    child: Text(
                      '${_wordCount} Mots',
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'InriaSans'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEmpty || _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmpty || _loading ? Colors.black12 : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Envoyer',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'InriaSans'),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Contact :',
                style: TextStyle(fontSize: 12, fontFamily: 'InriaSans'),
                textAlign: TextAlign.center,
              ),
              const Text(
                'contact@butterguide.com',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  fontFamily: 'InriaSans',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
