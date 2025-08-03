import 'package:flutter/material.dart';
import '../services/AuthService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _loginGoogle() async {
    setState(() => _isLoading = true);
    final userCred = await AuthService().signInWithGoogle();
    setState(() => _isLoading = false);
    if (userCred != null) {
      // Tu peux naviguer vers l’accueil ou la page d’accueil de l’app
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign In Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton.icon(
          icon: Icon(Icons.email, color: Colors.white),
          label: Text("Continue with Google"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6B4EFF),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _loginGoogle,
        ),
      ),
    );
  }
}
