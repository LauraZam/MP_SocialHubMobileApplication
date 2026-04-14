import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/bloc/auth/auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/pages/main_page.dart';
import 'package:flutter_application_1/translations/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  State<RegisterFormPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegisterFormPage> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      _hidePass = !_hidePass;
    });
  }

  void _clearName() {
    setState(() {
      _nameController.clear();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      const url = 'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user.json';

      try {
        await http.post(
          Uri.parse(url),
          body: jsonEncode({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'Email': _emailController.text.trim(),
          }),
        );

        if (mounted) {
          context.read<AuthBloc>().add(
            RegisterEvent(
              email: _emailController.text.trim(),
              password: _passController.text.trim(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.required.tr();
    }
    if (!_emailRegex.hasMatch(value)) {
      return LocaleKeys.enter_email.tr();
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.required.tr();
    }
    if (value.length < 10) {
      return LocaleKeys.enter_phone.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.registration.tr()),
        centerTitle: true,
      ),

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final nameToPass = _nameController.text.trim();
            final emailToPass = _emailController.text.trim();
            final phoneToPass = _phoneController.text.trim();

            if (mounted) {
              // Navigator.of(context, rootNavigator: true).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(
                    name: nameToPass,
                    email: emailToPass,
                    phone: phoneToPass,
                  ),
                ),
              );
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(
                child: Lottie.asset(
                  'assets/lottie/success.json',
                  width: 200,
                  repeat: false,
                ),
              ),
            );

            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Lottie.asset(
                      'assets/lottie/error.json',
                      width: 200,
                      height: 200,
                      repeat: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error)),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: LocaleKeys.name.tr(),
                  hintText: LocaleKeys.enter_name.tr(),
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _clearName,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: LocaleKeys.email.tr(),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: _validateEmail,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  labelText: LocaleKeys.phone.tr(),
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: _validatePhone,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _passController,
                obscureText: _hidePass,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: LocaleKeys.password.tr(),
                  hintText: LocaleKeys.password_error.tr(),
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePassword,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  if (value.length < 6) {
                    return LocaleKeys.password_error.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/cat.json', width: 120),
                          SizedBox(height: 16),
                          Text("Signing in..."),
                        ],
                      ),
                    );
                  }

                  return ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      LocaleKeys.register.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await context.setLocale(const Locale('ru'));
                    },
                    child: const Text('RU'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await context.setLocale(const Locale('kk'));
                    },
                    child: const Text('KZ'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await context.setLocale(const Locale('en'));
                    },
                    child: const Text('EN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
