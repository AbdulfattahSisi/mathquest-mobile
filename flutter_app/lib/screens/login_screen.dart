import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().login(_userCtrl.text.trim(), _passCtrl.text);
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
            colors: [Color(0xFF0B0F19), Color(0xFF1A1145), Color(0xFF0F2B4C)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Mesh gradient circles
            Positioned(
              top: -80, right: -80,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF7C3AED).withOpacity(0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120, left: -60,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF1E88E5).withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.35, left: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFEC4899).withOpacity(0.12), Colors.transparent],
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
                        width: 130, height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.25), blurRadius: 60, spreadRadius: 10),
                            BoxShadow(color: const Color(0xFF1E88E5).withOpacity(0.15), blurRadius: 40, spreadRadius: 5),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white.withOpacity(0.05),
                            child: Lottie.asset('assets/animations/brain.json', repeat: true),
                          ),
                        ),
                      )
                          .animate()
                          .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), duration: 800.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 500.ms),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF7C3AED), Color(0xFFEC4899)],
                        ).createShader(bounds),
                        child: const Text(
                          'MathQuest',
                          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 1, decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.3)]),
                          )),
                          const SizedBox(width: 12),
                          Text('Apprenez les maths en vous amusant',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.3)),
                          const SizedBox(width: 12),
                          Container(width: 30, height: 1, decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.3), Colors.transparent]),
                          )),
                        ],
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      const SizedBox(height: 36),
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
                                    gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF1E88E5)]),
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 12)],
                                  ),
                                  child: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Connexion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text('Bienvenue !', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ]),
                              ]),
                              const SizedBox(height: 26),
                              _buildInput(
                                controller: _userCtrl,
                                label: "Nom d'utilisateur",
                                icon: FontAwesomeIcons.userLarge,
                                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
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
                                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 26),
                              GestureDetector(
                                onTap: _loading ? null : _submit,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7C3AED), Color(0xFF1E88E5)],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(height: 22, width: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : const Row(mainAxisSize: MainAxisSize.min, children: [
                                            Text('Se connecter', style: TextStyle(
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
                          Text('Pas encore de compte ?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                          TextButton(
                            onPressed: () => context.go('/signup'),
                            child: const Text("S'inscrire", style: TextStyle(
                              color: Color(0xFF00D4FF), fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.08))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('ou', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                        ),
                        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.08))),
                      ]).animate().fadeIn(delay: 650.ms),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthService>().loginAsGuest();
                          context.go('/home');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(FontAwesomeIcons.userSecret, color: Colors.white54, size: 16),
                            const SizedBox(width: 12),
                            Text("Continuer en tant qu'invite", style: TextStyle(
                              color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 14)),
                          ]),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.15, end: 0),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      validator: validator,
    );
  }

  List<Widget> _buildFloatingSymbols() {
    final symbols = ['pi', 'sum', 'integral', 'sqrt', 'delta', 'infinity', 'lambda', 'theta', 'pm', 'div', 'times', 'percent', 'phi', 'omega', 'partial'];
    final rnd = Random(42);
    return List.generate(18, (i) {
      final sym = symbols[i % symbols.length];
      final top = rnd.nextDouble() * 800;
      final left = rnd.nextDouble() * 400;
      final size = 12.0 + rnd.nextDouble() * 24;
      final opacity = 0.03 + rnd.nextDouble() * 0.06;
      return Positioned(
        top: top, left: left,
        child: Text(sym, style: TextStyle(fontSize: size, color: Colors.white.withOpacity(opacity), fontWeight: FontWeight.w900))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: Duration(milliseconds: 2000 + rnd.nextInt(3000)))
            .moveY(begin: 0, end: -12 - rnd.nextDouble() * 20, duration: Duration(milliseconds: 3000 + rnd.nextInt(4000))),
      );
    });
  }
}
