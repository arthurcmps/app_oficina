import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../home/home_view.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'login_view.dart';

class BiometricView extends StatefulWidget {
  const BiometricView({super.key});

  @override
  State<BiometricView> createState() => _BiometricViewState();
}

class _BiometricViewState extends State<BiometricView> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Inicia a biometria assim que a tela abre
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    bool authenticated = false;

    try {
      // Verifica se o celular possui biometria cadastrada
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Se o celular não tiver senha/biometria, libera o acesso direto (opcional)
        _liberarAcesso();
        return;
      }

      authenticated = await _auth.authenticate(
        localizedReason: 'Desbloqueie para acessar a Forja ERP',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite usar o PIN/Padrão do celular se a biometria falhar
        ),
      );
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() => _isAuthenticating = false);
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      _liberarAcesso();
    } else {
      setState(() => _isAuthenticating = false);
    }
  }

  void _liberarAcesso() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  void _forcarLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C), // Fundo "Senhor da Forja"
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Color(0xFF5D9CEC)), // Azul Ogum
            const SizedBox(height: 24),
            const Text(
              'Aplicativo Bloqueado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            if (_isAuthenticating)
              const CircularProgressIndicator(color: Color(0xFF5D9CEC))
            else
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint, size: 28),
                label: const Text('USAR BIOMETRIA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D9CEC),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _forcarLogout,
              child: const Text('Entrar com outra conta', style: TextStyle(color: Color(0xFF90A4AE))),
            )
          ],
        ),
      ),
    );
  }
}