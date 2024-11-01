import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  Future<void> _showMyDialog(String title, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // dart function to verifiy the email of the user
  bool _verifyEmail(String email) {
    final emailPattern = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        caseSensitive: false,
        multiLine: false);
    return emailPattern.hasMatch(email);
  }

  // dart function to verify the password of the user 8+ characters, containing: 1. at least one uppercase letter 2. one lowercase letter 3. one number 4. one special character
  bool _verifyPassword(String password) {
    final passwordPattern = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$',
        caseSensitive: false,
        multiLine: false);
    return passwordPattern.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Account'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _email,
            enableSuggestions: true,
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter Email ID"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: "Enter Password",
                helperText:
                    "Password should be at least 8 characters, containing: \n1. at least one uppercase letter\n2. at least one lowercase letter\n3. at least one number\n4. at least one special character"),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                if (!_verifyEmail(email)) {
                  setState(() {
                    _showMyDialog(
                        'Invalid Email', 'Please enter a valid email address');
                  });
                  return;
                }
                if (!_verifyPassword(password)) {
                  setState(() {
                    _showMyDialog('Invalid Password',
                        'Password should be at least 8 characters, containing: \n1. at least one uppercase letter\n2. at least one lowercase letter\n3. at least one number\n4. at least one special character');
                  });
                  return;
                }
                String msg, title;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email, password: password);
                  title = 'Account Registered';
                  msg = 'Account created successfully with $email';
                  setState(() {
                    if (mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/notes', (route) => false);
                    }
                  });
                } on FirebaseAuthException catch (e) {
                  title = e.code.replaceAll('-', ' ');
                  msg = e.message.toString();
                } catch (e) {
                  title = 'Unknown Error';
                  msg = e.toString();
                }
                setState(() {
                  _showMyDialog(title, msg);
                });
              },
              child: const Text(
                'Register Account',
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already registered? Click here to'),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Login!'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
