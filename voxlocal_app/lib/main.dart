import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const VoxLocalApp());
}

class VoxLocalApp extends StatelessWidget {
  const VoxLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoxLocal AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ⚠️ REMPLACE CETTE URL PAR TON LIEN CLOUDFLARE !
  // N'oublie pas le "/chat" à la fin.
  final String apiUrl = "http://localhost:8000/chat";

  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, String>> messages = [];
  bool isTyping = false;

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    String userText = _textController.text;
    setState(() {
      messages.add({"sender": "user", "text": userText});
      isTyping = true;
    });
    _textController.clear();

    try {
      // 1. Envoi de la requête au serveur NixOS (via Cloudflare)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"texte": userText}),
      );

      if (response.statusCode == 200) {
        // 2. On récupère le texte de l'IA caché dans les headers HTTP
        String iaText = response.headers['x-response-text'] ?? "Audio reçu";

        setState(() {
          messages.add({"sender": "ia", "text": iaText});
          isTyping = false;
        });

        // 3. On lit directement le fichier audio .wav reçu
        await _audioPlayer.play(BytesSource(response.bodyBytes));
      } else {
        _showError("Erreur du serveur : ${response.statusCode}");
      }
    } catch (e) {
      _showError("Impossible de joindre le serveur. Le tunnel est-il allumé ?");
    }
  }

  void _showError(String errorMsg) {
    setState(() => isTyping = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMsg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎙️ VoxLocal AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Parlez à Llama...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
