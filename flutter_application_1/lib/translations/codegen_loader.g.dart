// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _en = {
  "registration": "Registration",
  "name": "Name",
  "email": "Email",
  "phone": "Phone",
  "password": "Password",
  "register": "Register",
  "success": "Registration successful",
  "enter_name": "Please enter your name",
  "enter_email": "Enter a valid email",
  "enter_phone": "Enter a valid phone number",
  "password_error": "Password must be at least 6 characters",
  "required": "Required field"
};
static const Map<String,dynamic> _kk = {
  "registration": "Тіркелу",
  "name": "Аты",
  "email": "Email",
  "phone": "Телефон",
  "password": "Құпия сөз",
  "register": "Тіркелу",
  "success": "Тіркеу сәтті аяқталды",
  "enter_name": "Атыңызды енгізіңіз",
  "enter_email": "Дұрыс email енгізіңіз",
  "enter_phone": "Дұрыс телефон нөмірін енгізіңіз",
  "password_error": "Құпия сөз кемінде 6 таңбадан тұруы керек",
  "required": "Міндетті өріс"
};
static const Map<String,dynamic> _ru = {
  "registration": "Регистрация",
  "name": "Имя",
  "email": "Email",
  "phone": "Телефон",
  "password": "Пароль",
  "register": "Зарегистрироваться",
  "success": "Регистрация прошла успешно",
  "enter_name": "Введите имя",
  "enter_email": "Введите корректный email",
  "enter_phone": "Введите корректный номер",
  "password_error": "Пароль должен содержать минимум 6 символов",
  "required": "Обязательное поле"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": _en, "kk": _kk, "ru": _ru};
}
