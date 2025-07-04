import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsai/controller/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.goToSignupPage});
  final void Function() goToSignupPage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 4, 16, 54),
            Color.fromARGB(255, 20, 25, 78),
            Color.fromARGB(255, 27, 52, 105),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/logos/logo.png'),
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 26, 175, 255),
                            Colors.white,
                          ],
                        ).createShader(bounds),
                    child: const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 167, 255),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle login
                        FocusScope.of(context).unfocus();
                        AuthService().loginWithEmail(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        context.go('/home/0');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        9,
                        121,
                        232,
                      ).withAlpha(225),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    icon: Image.asset('assets/logos/google.png', width: 24),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromARGB(255, 26, 175, 255),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      widget.goToSignupPage();
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 26, 175, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color.fromARGB(255, 26, 175, 255)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.moveTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.moveTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



// // ==================== UPDATED LOGIN SCREEN ====================
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:newsai/controller/services/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key, required this.goToSignupPage});
//   final void Function() goToSignupPage;

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     FocusScope.of(context).unfocus();

//     try {
//       final user = await AuthService().loginWithEmail(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (user != null && mounted) {
//         // Login successful
//         context.go('/home/0');
//       }
//     } catch (e) {
//       if (mounted) {
//         _showErrorDialog(e.toString());
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _handleGoogleSignIn() async {
//     setState(() => _isLoading = true);

//     try {
//       // TODO: Implement Google Sign In when OAuth is added to backend
//       _showErrorDialog('Google Sign In will be available soon!');
//     } catch (e) {
//       if (mounted) {
//         _showErrorDialog(e.toString());
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color.fromARGB(255, 27, 52, 105),
//         title: const Text(
//           'Login Failed',
//           style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
//         ),
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text(
//               'OK',
//               style: TextStyle(
//                 color: Color.fromARGB(255, 26, 175, 255),
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color.fromARGB(255, 4, 16, 54),
//             Color.fromARGB(255, 20, 25, 78),
//             Color.fromARGB(255, 27, 52, 105),
//           ],
//           stops: [0.0, 0.5, 1.0],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 60),
//                   CircleAvatar(
//                     radius: 70,
//                     backgroundColor: Colors.transparent,
//                     child: Image.asset('assets/logos/logo.png'),
//                   ),
//                   const SizedBox(height: 20),
//                   ShaderMask(
//                     shaderCallback: (bounds) => const LinearGradient(
//                       colors: [
//                         Color.fromARGB(255, 26, 175, 255),
//                         Colors.white,
//                       ],
//                     ).createShader(bounds),
//                     child: const Text(
//                       'Welcome Back!',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Poppins',
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Email Field
//                   TextFormField(
//                     controller: _emailController,
//                     enabled: !_isLoading,
//                     keyboardType: TextInputType.emailAddress,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Poppins',
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Email Address',
//                       hintStyle: const TextStyle(
//                         color: Colors.white54,
//                         fontFamily: 'Poppins',
//                       ),
//                       prefixIcon: const Icon(Icons.email, color: Colors.white54),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Colors.white54),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Colors.white54),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                           color: Color.fromARGB(255, 26, 175, 255),
//                         ),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                           .hasMatch(value.trim())) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   // Password Field
//                   TextFormField(
//                     controller: _passwordController,
//                     enabled: !_isLoading,
//                     obscureText: _obscurePassword,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Poppins',
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Password',
//                       hintStyle: const TextStyle(
//                         color: Colors.white54,
//                         fontFamily: 'Poppins',
//                       ),
//                       prefixIcon: const Icon(Icons.lock, color: Colors.white54),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Colors.white54,
//                         ),
//                         onPressed: _isLoading
//                             ? null
//                             : () {
//                                 setState(() => _obscurePassword = !_obscurePassword);
//                               },
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Colors.white54),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Colors.white54),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                           color: Color.fromARGB(255, 26, 175, 255),
//                         ),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 10),

//                   // Forgot Password
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: _isLoading ? null : () {
//                         // TODO: Implement forgot password functionality
//                         _showErrorDialog('Forgot password feature coming soon!');
//                       },
//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           color: Color.fromARGB(255, 26, 167, 255),
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Login Button
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _handleLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 9, 121, 232)
//                           .withAlpha(225),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text(
//                             'LOGIN',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Google Login Button
//                   OutlinedButton.icon(
//                     icon: Image.asset('assets/logos/google.png', width: 24),
//                     label: const Text(
//                       'Continue with Google',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         color: Color.fromARGB(255, 26, 175, 255),
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     onPressed: _isLoading ? null : _handleGoogleSignIn,
//                   ),
//                   const SizedBox(height: 20),

//                   TextButton(
//                     onPressed: _isLoading ? null : widget.goToSignupPage,
//                     child: const Text.rich(
//                       TextSpan(
//                         text: 'Don\'t have an account? ',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontFamily: 'Poppins',
//                         ),
//                         children: [
//                           TextSpan(
//                             text: 'Sign Up',
//                             style: TextStyle(
//                               color: Color.fromARGB(255, 26, 175, 255),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }