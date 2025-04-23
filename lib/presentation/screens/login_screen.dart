import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('LoginScreen: initState called');
    // Проверяем состояние авторизации после первого рендеринга
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('LoginScreen: Checking auth state');
      _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    setState(() {
      _isLoading = true;
      print('LoginScreen: Setting _isLoading to true');
    });

    try {
      final user = _auth.currentUser;
      print('LoginScreen: Current user: $user');
      if (user != null) {
        if (user.emailVerified) {
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          final role = userDoc['role'] ?? 'user';
          print('LoginScreen: User role: $role');
          if (mounted) {
            if (role == 'admin') {
              print('LoginScreen: Redirecting to /admin');
              context.go('/admin');
            } else {
              print('LoginScreen: Redirecting to /main');
              context.go('/main');
            }
          }
        } else {
          if (mounted) {
            print('LoginScreen: Redirecting to /verify-code');
            context.go('/verify-code');
          }
        }
      } else {
        print('LoginScreen: No user logged in');
      }
    } catch (e) {
      print('LoginScreen: Error in _checkAuthState: $e');
      setState(() {
        _errorMessage = "Error checking auth state: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          print('LoginScreen: Setting _isLoading to false');
        });
      }
    }
  }

  Future<void> _login() async {
    print('LoginScreen: Login button pressed');
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        print('LoginScreen: Starting login process');
      });

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        print('LoginScreen: Login successful, user: $user');
        if (user != null) {
          if (user.emailVerified) {
            final userDoc = await _firestore.collection('users').doc(user.uid).get();
            final role = userDoc['role'] ?? 'user';
            print('LoginScreen: User role after login: $role');
            if (mounted) {
              if (role == 'admin') {
                print('LoginScreen: Redirecting to /admin after login');
                context.go('/admin');
              } else {
                print('LoginScreen: Redirecting to /main after login');
                context.go('/main');
              }
            }
          } else {
            if (mounted) {
              print('LoginScreen: Redirecting to /verify-code after login');
              context.go('/verify-code');
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        print('LoginScreen: FirebaseAuthException: ${e.message}');
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        print('LoginScreen: General error: $e');
        setState(() {
          _errorMessage = "An error occurred: $e";
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            print('LoginScreen: Login process finished');
          });
        }
      }
    }
  }

  @override
  void dispose() {
    print('LoginScreen: dispose called');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('LoginScreen: build called, _isLoading: $_isLoading');
    if (_isLoading) {
      print('LoginScreen: Showing CircularProgressIndicator');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    print('LoginScreen: Rendering login UI');
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Login",
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  print('LoginScreen: Navigating to /register');
                  context.go('/register');
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}