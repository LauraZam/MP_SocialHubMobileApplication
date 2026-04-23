import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/bloc/auth/auth_bloc.dart';
import 'package:lottie/lottie.dart';
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
  final RegExp _passRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _hidePass = !_hidePass);
  }

  void _clearName() {
    setState(() => _nameController.clear());
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passController.text.trim(),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return LocaleKeys.required.tr();
    if (!_emailRegex.hasMatch(value)) return LocaleKeys.enter_email.tr();
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return LocaleKeys.required.tr();
    if (value.length < 10) return LocaleKeys.enter_phone.tr();
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
            Navigator.pushReplacementNamed(context, '/home');
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
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
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _clearName,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? LocaleKeys.required.tr()
                    : null,
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
                  LengthLimitingTextInputFormatter(11),
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
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  if (!_passRegex.hasMatch(val)) {
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
                        children: [
                          Lottie.asset('assets/lottie/cat.json', width: 120),
                          const SizedBox(height: 8),
                          Text("creating_account".tr()),
                        ],
                      ),
                    );
                  }

                  return ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.register.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text("already_have_account".tr()),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => context.setLocale(const Locale('ru')),
                    child: const Text('RU'),
                  ),
                  TextButton(
                    onPressed: () => context.setLocale(const Locale('kk')),
                    child: const Text('KZ'),
                  ),
                  TextButton(
                    onPressed: () => context.setLocale(const Locale('en')),
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
