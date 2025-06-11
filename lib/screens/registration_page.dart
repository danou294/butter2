import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import '../services/auth_service.dart';
import 'otp_verification_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _prenomController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prenomController.addListener(() => setState(() {}));
    _dateController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  String get formattedPhone => formatPhoneNumber(_phoneController.text.trim());

  bool get isFormValid =>
      _prenomController.text.trim().isNotEmpty &&
      _dateController.text.trim().isNotEmpty &&
      _isValidPhone(formattedPhone) &&
      !_loading;

  void _onSuivantPressed() async {
    final prenom = _prenomController.text.trim();
    final dateNaissance = _dateController.text.trim();
    final phone = formattedPhone;

    if (!isFormValid) return;

    setState(() => _loading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          setState(() => _loading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                phoneNumber: phone,
                verificationId: verificationId,
                prenom: prenom,
                dateNaissance: dateNaissance,
              ),
            ),
          );
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (_) {
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String formatPhoneNumber(String input) {
    input = input.replaceAll(' ', '').replaceAll('-', '');
    if (input.startsWith('0') && RegExp(r'^0[67]\d{8}$').hasMatch(input)) {
      return input.replaceFirst('0', '+33');
    } else if (RegExp(r'^\+33[67]\d{8}$').hasMatch(input)) {
      return input;
    } else {
      return '';
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+33[67]\d{8}$').hasMatch(phone);
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
                          'Devenir membre',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.12),
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
                      'Prénom',
                      style: TextStyle(
                        fontFamily: 'InriaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        hintText: 'Votre prénom',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF1EFEB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Date de naissance',
                      style: TextStyle(
                        fontFamily: 'InriaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        picker.DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1900),
                          maxTime: DateTime.now(),
                          currentTime: DateTime(2000),
                          locale: picker.LocaleType.fr,
                          theme: picker.DatePickerTheme(
                            backgroundColor: Colors.white,
                            itemStyle: const TextStyle(
                              fontFamily: 'InriaSans',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            doneStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          onConfirm: (date) {
                            final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          },
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            hintText: 'JJ/MM/AAAA',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF1EFEB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      decoration: const InputDecoration(
                        hintText: 'Ex : +33 6 00 00 00 00',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF1EFEB),
                      ),
                      keyboardType: TextInputType.phone,
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
                onTap: isFormValid ? _onSuivantPressed : null,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isFormValid ? Colors.white : const Color(0xFF535353),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Suivant',
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
