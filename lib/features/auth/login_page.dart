// lib/features/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import '../home/home_page.dart';

const Color kPrimaryColor = Color(0xFF641515);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController npmC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  late AnimationController _anim;
  bool _navigatedToHome = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    npmC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    /// Auto login: kalau sudah ada session, langsung ke Home
    final session = authState.asData?.value;
    if (!_navigatedToHome && session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigatedToHome = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 170,
              width: double.infinity,
              color: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lock_outline, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    "Selamat datang kembali!",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Silahkan Login Untuk Melanjutkan",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    /// CARD LOGIN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// NPM Input
                          TextField(
                            controller: npmC,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "NPM",
                              prefixIcon: const Icon(Icons.badge_outlined),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// Password Input
                          TextField(
                            controller: passC,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// Lupa Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: aksi lupa password
                              },
                              child: const Text(
                                "Lupa Password?",
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// REMEMBER + BUTTON LOGIN
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (v) {},
                          activeColor: kPrimaryColor,
                        ),
                        const Text("Remember me"),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Kalau authState lagi loading, tampilkan loading
                    authState.maybeWhen(
                      loading: () => const CircularProgressIndicator(),
                      orElse: () => _buildLoginButton(ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// LOGIN BUTTON WITH ANIMATION EFFECT
  Widget _buildLoginButton(WidgetRef ref) {
    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) => _anim.reverse(),
      onTapCancel: () => _anim.reverse(),
      onTap: () async {
        final npm = npmC.text.trim();
        final pass = passC.text.trim();

        if (npm.isEmpty || pass.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("NPM dan Password wajib diisi")),
          );
          return;
        }

        // panggil login ke API (AuthNotifier akan simpan session + token)
        await ref.read(authProvider.notifier).login(
          npm: npm,
          password: pass,
        );

        if (!mounted) return;

        // cek kalau ada error, tampilkan pesan
        final authState = ref.read(authProvider);
        if (authState.hasError) {
          final rawError = authState.error;
          var msg = rawError?.toString() ?? 'Login gagal';

          // hilangkan prefix "Exception: " kalau ada
          if (msg.startsWith('Exception: ')) {
            msg = msg.replaceFirst('Exception: ', '');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // kalau sukses, navigasi akan ditangani oleh blok auto-redirect di build()
      },
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final scale = 1 - _anim.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kPrimaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
