import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Importações dos nossos arquivos locais
import 'services/auth_service.dart';
import 'pages/auth/auth_gateway.dart';

void main() async {
  // Garante que o Flutter amarre os widgets antes de inicializar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa a conexão com o Firebase
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MeuApp(),
    ),
  );
}

// Esta é a classe que o VS Code estava reclamando que não existia
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Oficina',
      debugShowCheckedModeBanner: false, // Remove a faixa de 'DEBUG'
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        // Você pode customizar essas cores depois para aplicar aquela sua 
        // estética tech-tribal aos botões e fundos do app da oficina.
      ),
      // O AuthGateway é a raiz do app. Ele define se vai para Login ou Home.
      home: const AuthGateway(), 
    );
  }
}