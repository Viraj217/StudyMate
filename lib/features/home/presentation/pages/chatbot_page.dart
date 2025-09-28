import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

final String geminiApiKey = dotenv.env['GEMINI_API_KEY']!; 

final model = GenerativeModel(
  model: 'gemini-2.5-flash', 
  apiKey: geminiApiKey, 
);

class ApiService {
  final String _apiKey = dotenv.env['API_KEY'] ?? 'API_KEY not found';

  void makeApiCall() {
    print('Using API Key: $_apiKey');
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final String _modelName = 'gemini-2.5-flash';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  void _initializeGemini() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("GEMINI_API_KEY not found in .env file. Please check your .env configuration.");
      }
      
      _model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
      );
      
      _chat = _model.startChat(
        history: [
          Content.model([
            TextPart('Hello! I am a friendly AI assistant powered by Gemini. Ask me anything!')
          ])
        ]
      );
      
      setState(() {
        _messages.add(ChatMessage(
          text: 'Hello! I am a friendly AI assistant powered by Gemini. Ask me anything!',
          isUser: false,
        ));
      });
      
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '⚠️ Initialization Error: ${e.toString()}',
          isUser: false,
        ));
        _isLoading = false; 
      });
    }
  }

  void _sendMessage() async {
    final messageText = _textController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      _isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final response = await _chat.sendMessage(Content.text(messageText));

      setState(() {
        _messages.add(ChatMessage(
          text: response.text ?? 'I did not receive a valid response.',
          isUser: false,
        ));
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Network Error: Could not reach the API or request failed. $e',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chatbot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Gemini is thinking...', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),

          // Input Area
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            // Input Field
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Send a message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
              ),
            ),
            
            // Send Button
            Container(
              margin: const EdgeInsets.only(left: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? Colors.blue.shade500 : Colors.grey.shade200;
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, 
          ),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: Radius.circular(message.isUser ? 16.0 : 4.0),
                bottomRight: Radius.circular(message.isUser ? 4.0 : 16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}
