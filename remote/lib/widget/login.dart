import 'package:flutter/material.dart';
import 'package:remote/widget/livescreen.dart';
import 'package:remote/widget/qr_code.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _ip = '';
  String _port = '';
  bool _isConnecting = false;

  void _connect() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isConnecting = true;
      });

      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => LiveScreenViewer(
            serverAddress: 'ws://$_ip:$_port',
          ),
        ),
      )
          .then((_) {
        setState(() {
          _isConnecting = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion au serveur'),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color.fromARGB(255, 30, 30, 30), // Fond sombre pour le body
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/logo.png', // Remplacez par le chemin de votre image
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ndao Ho Hita',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 24.0), // Espace entre l'image et le formulaire
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Adresse IP du serveur',
                      prefixIcon: const Icon(Icons.wifi, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.white), // Bordure par défaut
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme
                              .primaryColor, // Bordure quand l'input est focus
                          width: 2.0, // Épaisseur de la bordure en focus
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(
                          255, 30, 30, 30), // Couleur de fond pour le champ
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse IP valide';
                      }
                      return null;
                    },
                    onSaved: (value) => _ip = value!,
                  ),

                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Port du serveur',
                      prefixIcon: const Icon(Icons.portable_wifi_off,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.white), // Bordure par défaut
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme
                              .primaryColor, // Bordure quand l'input est focus
                          width: 2.0, // Épaisseur de la bordure en focus
                        ),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(
                          255, 30, 30, 30), // Couleur de fond pour le champ
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le port';
                      }
                      return null;
                    },
                    onSaved: (value) => _port = value!,
                  ),

                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double
                        .infinity, // Largeur maximale pour correspondre aux inputs
                    child: _isConnecting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _connect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                            ),
                            child: const Text(
                              'Se connecter',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24.0),
// Ligne de séparation avec texte personnalisé
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white54,
                          thickness: 1.0,
                          endIndent: 10, // Ajoute un espacement avant le texte
                        ),
                      ),
                      const Text(
                        'ou',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white54,
                          thickness: 1.0,
                          indent: 10, // Ajoute un espacement après le texte
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double
                        .infinity, // Largeur maximale pour correspondre aux inputs
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QRViewExample(
                            connectCallback: (String result) {
                              final parts = result.split(':');
                              if (parts.length == 2) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LiveScreenViewer(
                                      serverAddress:
                                          'ws://${parts[0]}:${parts[1]}',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Format QR Code invalide'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 30, 30,
                            30), // Même couleur que le bouton "Se connecter"
                        side: BorderSide(
                          color: theme.primaryColor, // Même couleur de bordure
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                      ),
                      child: const Text(
                        'Scanner QR Code',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
