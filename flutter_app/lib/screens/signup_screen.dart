import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().register(
        _userCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F19), Color(0xFF0F2B4C), Color(0xFF1A1145)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Mesh gradient circles
            Positioned(
              top: -100, left: -60,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.neonGreen.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80, right: -80,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.royalBlue.withOpacity(0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
            ..._buildFloatingSymbols(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: AppTheme.neonGreen.withOpacity(0.25), blurRadius: 60, spreadRadius: 10),
                            BoxShadow(color: AppTheme.royalBlue.withOpacity(0.15), blurRadius: 40, spreadRadius: 5),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white.withOpacity(0.05),
                            child: Lottie.asset('assets/animations/rocket.json', repeat: true),
                          ),
                        ),
                      )
                          .animate()
                          .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), duration: 800.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 500.ms),
                      const SizedBox(height: 18),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF00D4FF), Color(0xFF1E40AF)],
                        ).createShader(bounds),
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      Text('Rejoignez MathQuest dès maintenant',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500))
                          .animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 16)),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.3), blurRadius: 12)],
                                  ),
                                  child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Inscription', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text('Remplissez vos informations', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ]),
                              ]),
                              const SizedBox(height: 24),
                              _buildInput(
                                controller: _userCtrl,
                                label: "Nom d'utilisateur",
                                icon: FontAwesomeIcons.userLarge,
                                validator: (v) => (v == null || v.length < 3) ? 'Minimum 3 caractères' : null,
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _emailCtrl,
                                label: 'Email',
                                icon: FontAwesomeIcons.envelope,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _passCtrl,
                                label: 'Mot de passe',
                                icon: FontAwesomeIcons.lock,
                                obscure: _obscure,
                                suffix: IconButton(
                                  icon: Icon(_obscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                                      size: 15, color: Colors.white38),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _confirmCtrl,
                                label: 'Confirmer mot de passe',
                                icon: FontAwesomeIcons.lock,
                                obscure: _obscureConfirm,
                                suffix: IconButton(
                                  icon: Icon(_obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                                      size: 15, color: Colors.white38),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                validator: (v) => v != _passCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                              ),
                              const SizedBox(height: 26),
                              GestureDetector(
                                onTap: _loading ? null : _submit,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.neonGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(height: 22, width: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : const Row(mainAxisSize: MainAxisSize.min, children: [
                                            Text("S'inscrire", style: TextStyle(
                                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                                            SizedBox(width: 10),
                                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                          ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 700.ms).slideY(begin: 0.12, end: 0),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Déjà un compte ?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Se connecter', style: TextStyle(
                              color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 15, color: Colors.white.withOpacity(0.3)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      validator: validator,
    );
  }

  List<Widget> _buildFloatingSymbols() {
    final symbols = ['plus', 'equals', 'x', 'div', 'sqrt', 'pi', 'sum', 'delta', 'alpha', 'beta', 'gamma', 'infinity'];
    final rnd = Random(123);
    return List.generate(16, (i) {
      final sym = symbols[i % symbols.length];
      final top = rnd.nextDouble() * 700;
      final left = rnd.nextDouble() * 400;
      final size = 12.0 + rnd.nextDouble() * 20;
      final opacity = 0.03 + rnd.nextDouble() * 0.05;
      return Positioned(
        top: top, left: left,
        child: Text(sym, style: TextStyle(fontSize: size, color: Colors.white.withOpacity(opacity), fontWeight: FontWeight.w900))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: Duration(milliseconds: 2000 + rnd.nextInt(3000)))
            .moveY(begin: 0, end: -10 - rnd.nextDouble() * 18, duration: Duration(milliseconds: 3000 + rnd.nextInt(4000))),
      );
    });
  }
}
