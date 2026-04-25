import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// Importação dos Providers
import 'providers/auth_provider.dart';
import 'providers/empresa_provider.dart';
import 'providers/servico_provider.dart';

// Importação das Views
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  // Garante que o binding do Flutter esteja inicializado antes de chamadas nativas assíncronas
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase (certifique-se de ter rodado o flutterfire configure)
  await Firebase.initializeApp();

  runApp(
    // Injeção de Dependências Global
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
        ChangeNotifierProvider(create: (_) => ServicoProvider()),
      ],
      child: const ForjaApp(),
    ),
  );
}

class ForjaApp extends StatelessWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forja ERP',
      debugShowCheckedModeBanner: false,
      // Aplicação do Design System "Forja & Futuro" em nível global
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo Ônix/Grafite
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD85A36),     // Laranja Terracota
          secondary: Color(0xFF39FF14),   // Verde Neon
          surface: Color(0xFF1E1E1E),     // Cinza Metálico
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD85A36),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF39FF14),
          foregroundColor: Color(0xFF121212),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD85A36),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          labelStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
          ),
        ),
      ),
      // Roteamento de inicialização baseado no estado de autenticação
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto o Firebase verifica o cache de login, exibe um loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF121212),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFD85A36)),
              ),
            );
          }
          
          // Se possuir dados (usuário logado), direciona para a Home
          if (snapshot.hasData) {
            return const HomeView();
          }
          
          // Caso contrário, direciona para o Login
          return const LoginView();
        },
      ),
    );
  }
}