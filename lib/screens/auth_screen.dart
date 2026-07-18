import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredConfirmPassword = '';
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();

    final auth = ref.read(firebaseAuthProvider);

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
      if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Falha na autenticação.',
            style: GoogleFonts.inriaSans(),
          ),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ASI',
                          style: GoogleFonts.inriaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 71, 143, 211),
                          ),
                        ),
                        TextSpan(
                          text: 'CITY',
                          style: GoogleFonts.inriaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: GoogleFonts.inriaSans(
                                color: const Color.fromARGB(255, 52, 71, 102)),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 145, 161, 187)),
                            ),
                          ),
                          style: GoogleFonts.inriaSans(),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Por favor, insira um e-mail válido.';
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredEmail = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: GoogleFonts.inriaSans(
                                color: const Color.fromARGB(255, 52, 71, 102)),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 145, 161, 187)),
                            ),
                          ),
                          style: GoogleFonts.inriaSans(),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredPassword = value!,
                        ),
                        
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirmar Senha',
                              labelStyle: GoogleFonts.inriaSans(
                                  color:
                                      const Color.fromARGB(255, 52, 71, 102)),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 145, 161, 187)),
                              ),
                            ),
                            style: GoogleFonts.inriaSans(),
                            obscureText: true,
                            validator: (value) {
                              if (value != _enteredPassword) {
                                return 'As senhas não coincidem.';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                _enteredConfirmPassword = value!,
                          ),
                        ],
                        const SizedBox(height: 40),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 52, 71, 102)),
                          )
                        else ...[
                          SizedBox(
                            width: 160,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 52, 71, 102),
                                foregroundColor: const Color.fromARGB(255, 249, 252, 255),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 145, 161, 187),
                                  width: 3.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'ENTRAR' : 'CADASTRAR',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Criar uma conta'
                                  : 'Já possuo uma conta',
                              style: GoogleFonts.inriaSans(
                                color: const Color.fromARGB(255, 52, 71, 102),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
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