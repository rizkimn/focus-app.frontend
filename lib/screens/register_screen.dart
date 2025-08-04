import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final apiUrl = dotenv.env['API_BASE_URL'];

      final bodyParams = jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'password_confirmation': confirmPassword,
          });

      print(bodyParams);

      try {
        // Tampilkan loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        // Kirim permintaan POST
        final response = await http.post(
          Uri.parse('$apiUrl/auth/register'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: bodyParams
        );

        // Tutup loading indicator
        Navigator.of(context).pop();

        // Proses response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Login sukses
          final responseData = jsonDecode(response.body);
          print('Registrasi berhasil: $responseData');

          // Navigasi ke halaman home
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Login gagal
          final errorData = jsonDecode(response.body);
          _showErrorDialog(errorData['message'] ?? 'Login failed');
        }
      } catch (e) {
        // Tangani error
        _showErrorDialog('Network error: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 84),
                      child: Wrap(
                        children: [
                          const Text(
                            "Get More Productive,",
                            style: TextStyle(
                              fontSize: 32,
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "You ",
                                style: TextStyle(
                                  fontSize: 32,
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Procraster!",
                                style: TextStyle(
                                  fontSize: 32,
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromRGBO(157, 207, 251, 1),
                            const Color.fromRGBO(157, 207, 251, 0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6)
                                )
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16
                                ),
                                child: Column(
                                  children: [
                                    // Username Field with underline border
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        prefixIcon: const Icon(BootstrapIcons.person),
                                        border: const UnderlineInputBorder(),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueGrey.shade100),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your username';
                                        }
                                        return null;
                                      },
                                    ),
                                    // Email Field with underline border
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: const Icon(BootstrapIcons.envelope),
                                        border: const UnderlineInputBorder(),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueGrey.shade100),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        // TAMBAHKAN VALIDASI EMAIL
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    // Password Field with underline border (no gap)
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(BootstrapIcons.key),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? BootstrapIcons.eye_slash
                                                : BootstrapIcons.eye,
                                            color: Colors.black.withAlpha(60),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: const UnderlineInputBorder(),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueGrey.shade100),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    // Password Confirmation Field with underline border (no gap)
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        prefixIcon: const Icon(BootstrapIcons.key),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? BootstrapIcons.eye_slash
                                                : BootstrapIcons.eye,
                                            color: Colors.black.withAlpha(60),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                        border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password confirmation';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Login Button
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(21),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade500,
                                      Colors.lightBlueAccent.shade200,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.lightBlueAccent.shade100,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 4,
                                      blurRadius: 16,
                                    ),
                                  ]
                                ),
                                child: ElevatedButton(
                                  onPressed: _registerUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Register Now',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                        ),
                                      ),
                                      const Icon(
                                        BootstrapIcons.arrow_right,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    ],
                                  )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Logic of redirecting
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(21),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
