import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _loading = false;

  String get formattedPhone => formatPhoneNumber(_phoneController.text.trim());

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  void _onSuivantPressed() async {
    final phone = formattedPhone;

    if (phone.isEmpty || !_isValidPhone(phone)) {
      _showSnack('Numéro invalide, utilise +33...');
      return;
    }

    setState(() => _loading = true);

    try {
      final userDoc = await _userService.getUserByPhone(phone);
      if (userDoc == null) {
        _showSnack("Aucun compte n'est associé à ce numéro.");
        setState(() => _loading = false);
        return;
      }

      final prenom = userDoc['prenom'] ?? '';

      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          setState(() => _loading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationPage(
                phoneNumber: phone,
                verificationId: verificationId,
                prenom: prenom,
                dateNaissance: '',
              ),
            ),
          );
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (e) {
          _showSnack('Erreur : ${e.message}');
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      _showSnack('Une erreur est survenue.');
      setState(() => _loading = false);
    }
  }

  String formatPhoneNumber(String input) {
    input = input.replaceAll(' ', '').replaceAll('-', '');
    if (input.startsWith('0')) {
      return input.replaceFirst('0', '+33');
    } else if (input.startsWith('+33')) {
      return input;
    } else {
      return '';
    }
  }

  bool _isValidPhone(String phone) {
    return phone.startsWith('+33') && phone.length >= 12;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isEnabled = _isValidPhone(formattedPhone) && !_loading;

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
                          'Se connecter',
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontFamily: 'InriaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Ex : +33 6 00 00 00 00',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF1EFEB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Un code de vérification va t’être envoyé par SMS.',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'InriaSans',
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: isEnabled ? _onSuivantPressed : null,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isEnabled ? Colors.white : const Color(0xFF535353),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Suivant',
                          style: const TextStyle(
                            fontFamily: 'InriaSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF111111),
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
