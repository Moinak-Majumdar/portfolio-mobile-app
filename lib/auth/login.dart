import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/submit_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPassword = '';
  bool _isLoading = false;

  void handelSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );
    } on FirebaseAuthException catch (e) {
      GetSnack.error(message: e.message ?? "Authentication error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.houseLaptop,
                color: Colors.purple[300],
                size: 60,
              ),
              const SizedBox(height: 32),
              Text(
                "Hello Again !",
                style: GoogleFonts.comicNeue().copyWith(fontSize: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                "Welcome back, you've been missed!",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@email.com',
                ),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                textCapitalization: TextCapitalization.none,
                validator: _emailValidator,
                onSaved: (val) {
                  _enteredEmail = val!;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: _passwordValidator,
                textCapitalization: TextCapitalization.none,
                onSaved: (val) {
                  _enteredPassword = val!;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: SubmitButton(
                  onTap: handelSubmit,
                  loading: _isLoading,
                  title: "Login",
                  onLoadText: "Authenticating ...",
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

String? _passwordValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  if (!val.contains('@') &&
      !val.contains('!') &&
      !val.contains('#') &&
      !val.contains('\$') &&
      !val.contains('%') &&
      !val.contains('^') &&
      !val.contains('&') &&
      !val.contains('*')) {
    return 'Password must contains any one of !,@,#,\$,%,^,&,*';
  }
  if (!val.contains('0') &&
      !val.contains('1') &&
      !val.contains('2') &&
      !val.contains('3') &&
      !val.contains('4') &&
      !val.contains('5') &&
      !val.contains('6') &&
      !val.contains('7') &&
      !val.contains('8') &&
      !val.contains('9')) {
    return 'Password must contains a digit.';
  }
  if (val.trim().length < 6) {
    return 'Password must be at least 6 characters long. ';
  }
  return null;
}

String? _emailValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  if (!val.contains('@')) {
    return 'Please enter a valid email address.';
  }
  return null;
}
