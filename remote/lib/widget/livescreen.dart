import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class LiveScreenViewer extends StatefulWidget {
  final String serverAddress;

  LiveScreenViewer({required this.serverAddress});

  @override
  _LiveScreenViewerState createState() => _LiveScreenViewerState();
}

class _LiveScreenViewerState extends State<LiveScreenViewer> {
  late WebSocketChannel channel;
  Uint8List? imageData;
  bool _hasError = false;
  bool _isConnected = false; // Connection state
  String _orientation = 'Portrait'; // Default orientation

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(widget.serverAddress));
      setState(() {
        _isConnected = true; // Update connection state
      });

      channel.stream.listen((message) {
        setState(() {
          imageData = base64Decode(message);
          _hasError = false;
        });
      }, onError: (error) {
        setState(() {
          _hasError = true;
        });
      }, onDone: () {
        setState(() {
          _hasError = true;
        });
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _disconnect() {
    channel.sink.close();
    setState(() {
      _isConnected = false; // Update connection state
    });
    Navigator.of(context).pop(); // Return to previous screen
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Paramètres",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Détails du serveur :",
                  style: TextStyle(color: Colors.white)),
              Text("Adresse : ${widget.serverAddress}",
                  style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centrer horizontalement
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centrer verticalement
                children: [
                  Text(
                    _isConnected ? 'Connecté' : 'Déconnecté',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8), // Espace entre l'icône et le texte
                  Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Orientation : $_orientation",
                  style: TextStyle(color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.rotate_right,
                        color: _orientation == 'Portrait'
                            ? Colors.green
                            : Colors.white),
                    onPressed: () {
                      setState(() {
                        _orientation = 'Portrait';
                        _setOrientation(_orientation);
                      });
                      Navigator.of(context).pop(); // Ferme la boîte de dialogue
                    },
                    tooltip: 'Portrait',
                  ),
                  IconButton(
                    icon: Icon(Icons.rotate_90_degrees_ccw,
                        color: _orientation == 'Paysage'
                            ? Colors.green
                            : Colors.white),
                    onPressed: () {
                      setState(() {
                        _orientation = 'Paysage';
                        _setOrientation(_orientation);
                      });
                      Navigator.of(context).pop(); // Ferme la boîte de dialogue
                    },
                    tooltip: 'Paysage',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _disconnect(),
                  child: Text("Se déconnecter",
                      style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => {_showQRCode()},
                  child: Text("Afficher QR Code",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _setOrientation(String orientation) {
    if (orientation == 'Portrait') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Scannez ce code pour vous connecter :"),
              Text("${widget.serverAddress}"), // Simulate a QR Code
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partage de flux video'),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: Center(
          child: _hasError
              ? Text('Erreur de connexion. Vérifiez l\'adresse IP et le port.')
              : imageData != null
                  ? Image.memory(imageData!, gaplessPlayback: true)
                  : Text('En attente du flux vidéo...'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
