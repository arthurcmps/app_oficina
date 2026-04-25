import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// O 'hide' é essencial para evitar o conflito com a nossa classe AuthProvider
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// Importação das configurações automáticas do Firebase
import 'firebase_options.dart';

// Importação dos seus Providers (Lógica de Negócio)
import 'providers/auth_provider.dart';
import 'providers/empresa_provider.dart';
import 'providers/servico_provider.dart';

// Importação das Telas (UI)
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  // Inicialização obrigatória para apps Flutter com Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conecta o app às configurações geradas pelo FlutterFire CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Injeção de dependências: Disponibiliza os dados para todo o app
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
      
      // Configuração Global do Design System "Forja & Futuro"
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Ônix Profundo
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD85A36),       // Laranja Terracota
          secondary: Color(0xFF39FF14),     // Verde Neon
          surface: Color(0xFF1E1E1E),       // Cinza Metálico
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),

        // Estilização padrão da AppBar (Cabeçalho)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD85A36),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        // Estilização do Botão Flutuante (+)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF39FF14),
          foregroundColor: Color(0xFF121212),
        ),

        // Estilização de Campos de Texto (Inputs)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          labelStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
          ),
        ),
      ),

      // Lógica de Roteamento Baseada em Estado
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o cache do dispositivo
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFD85A36))),
            );
          }
          
          // Se o usuário já está logado, entra direto
          if (snapshot.hasData) {
            return const HomeView();
          }
          
          // Se não há usuário, exige login
          return const LoginView();
        },
      ),
    );
  }
}