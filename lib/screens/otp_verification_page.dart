import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'welcome_page.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String prenom;
  final String dateNaissance;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.prenom,
    required this.dateNaissance,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _loading = false;

  void _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showSnack('Code invalide');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.signInWithOTP(widget.verificationId, code);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;
        final exists = await _userService.userExists(uid);
        if (!exists) {
          await _userService.createUser(
            uid: uid,
            phone: widget.phoneNumber,
            prenom: widget.prenom,
            dateNaissance: widget.dateNaissance,
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomePage(prenom: widget.prenom),
            ),
          );
        }
      } else {
        _showSnack('Erreur : utilisateur introuvable.');
      }
    } catch (e) {
      _showSnack('Code incorrect ou expiré ❌');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(child: SizedBox()),
                      Image(
                        image: AssetImage('assets/images/LogoName_black.png'),
                        height: 22,
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          'assets/icon/precedent.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Vérification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code de vérification',
                      style: TextStyle(
                        fontFamily: 'InriaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _codeController,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 55,
                        fieldWidth: 44,
                        activeColor: Colors.black,
                        inactiveColor: Colors.grey,
                        selectedColor: Colors.black87,
                        inactiveFillColor: Color(0xFFF1EFEB),
                        selectedFillColor: Color(0xFFF1EFEB),
                        activeFillColor: Color(0xFFF1EFEB),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {},
                      backgroundColor: Colors.white,
                      enableActiveFill: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _verifyCode,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Valider',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'InriaSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
