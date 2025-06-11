import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  void _sendCode() async {
    setState(() => _loading = true);

    await _authService.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      onVerificationCompleted: (credential) async {
        // Connexion automatique (sur Android surtout)
        await _authService.signInWithCredential(credential);
        _showSnack('Connecté automatiquement ✅');
      },
      onVerificationFailed: (e) {
        _showSnack('Erreur : ${e.message}');
        setState(() => _loading = false);
      },
    );
  }

  void _verifyCode() async {
    if (_verificationId != null && _otpController.text.trim().length == 6) {
      setState(() => _loading = true);

      try {
        await _authService.signInWithOTP(
          _verificationId!,
          _otpController.text.trim(),
        );
        _showSnack('Connexion réussie ! 🎉');
        // Redirection possible ici
      } catch (e) {
        _showSnack('Code invalide ❌');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par téléphone')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_codeSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '+33 6 12 34 56 78',
                ),
              ),
            if (_codeSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Code OTP',
                ),
              ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _codeSent ? _verifyCode : _sendCode,
                    child: Text(_codeSent ? 'Valider le code' : 'Envoyer le code'),
                  ),
          ],
        ),
      ),
    );
  }
}
