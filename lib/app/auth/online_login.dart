import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/background.dart';

class OnlineLoginScreen extends StatefulWidget {
  const OnlineLoginScreen({super.key});

  @override
  State<OnlineLoginScreen> createState() => _OnlineLoginScreenState();
}

class _OnlineLoginScreenState extends State<OnlineLoginScreen> {
  static final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPassword = '';
  bool _showPassword = false;
  bool _isLoading = false;

  void showSnackAlert(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        showCloseIcon: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

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
          email: _enteredEmail, password: _enteredPassword);
    } on FirebaseAuthException catch (e) {
      showSnackAlert(e.message ?? 'Authentication Error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            const Background(
              shape: BackgroundShape.oval,
              style: LinearGradient(
                colors: [
                  Color.fromARGB(255, 202, 208, 255),
                  Color.fromARGB(255, 227, 227, 227),
                ],
              ),
              topHeight: 180,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'example@email.com',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.none,
                          validator: (val) {
                            return _emailValidator(val);
                          },
                          onSaved: (val) {
                            _enteredEmail = val!;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: !_showPassword,
                          validator: (val) {
                            return _passwordValidator(val);
                          },
                          onSaved: (val) {
                            _enteredPassword = val!;
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              label: Text(
                                _showPassword
                                    ? 'Hide password'
                                    : 'Show password',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (_isLoading)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Authenticating ..',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Transform.scale(
                                scale: 0.6,
                                child: const CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        if (!_isLoading)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.keyboard_arrow_left),
                            onPressed: handelSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                            label: const Text('Log In'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.pacifico(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
