import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glowing_container.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<QuickQuestion> _quickQuestions = [
    QuickQuestion('🎨 How to use air drawing?', 'Air drawing uses your camera to track finger movements. Enable it in Mode Selection, then move your finger in front of the camera. For best results, ensure good lighting and steady hand movement.'),
    QuickQuestion('✨ What can AI correct?', 'Our AI can detect and correct basic shapes like circles, squares, triangles, and straight lines. It also offers intelligent suggestions for improving your artwork based on pattern recognition.'),
    QuickQuestion('💾 How to save my drawing?', 'Tap the save icon in the top right corner of the canvas. You can save as PNG, JPEG, or share directly to social media. All saves are stored in your gallery.'),
    QuickQuestion('🎯 Best practices for drawing?', '1. Start with basic shapes\n2. Use light strokes first\n3. Let AI correct shapes\n4. Add details last\n5. Use reference images for complex drawings'),
    QuickQuestion('🖌️ What brush tools available?', 'We offer 12+ brush types including pencil, marker, watercolor, oil brush, airbrush, and calligraphy pen. Each brush has adjustable size, opacity, and pressure sensitivity.'),
    QuickQuestion('🤖 How does AI correction work?', 'AI correction uses machine learning models trained on millions of drawings. It analyzes your strokes in real-time and suggests improvements for shapes, lines, and proportions.'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController);

    _messages.add(ChatMessage(
      text: 'Hello! 👋 I\'m your AI Drawing Assistant. I\'m here to help you create amazing artwork. Feel free to ask me anything about drawing, tools, or AI features!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      _generateAIReply(text);
    });
  }

  void _generateAIReply(String userMessage) {
    String reply = '';
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('air') && (lowerMessage.contains('draw') || lowerMessage.contains('track'))) {
      reply = '✋ **Air Drawing Tips:**\n\n• Keep your hand 6-12 inches from the camera\n• Ensure good lighting conditions\n• Use slow, steady movements\n• Make sure your finger is clearly visible\n• Try the gesture controls for color switching\n\nPro tip: Practice simple shapes first!';
    }
    else if (lowerMessage.contains('ai') && (lowerMessage.contains('correct') || lowerMessage.contains('fix'))) {
      reply = '🧠 **AI Correction Features:**\n\n• Shape recognition (circles, squares, triangles)\n• Line smoothing and straightening\n• Auto-completion of symmetrical shapes\n• Pattern recognition for complex drawings\n• Real-time suggestions\n\nOur AI learns from millions of drawings to help you create perfect sketches!';
    }
    else if (lowerMessage.contains('save') || lowerMessage.contains('export') || lowerMessage.contains('share')) {
      reply = '💾 **Saving & Export Options:**\n\n• Save as PNG (transparent background)\n• Save as JPEG (smaller file size)\n• Share directly to social media\n• Cloud backup (Premium feature)\n• Auto-save to gallery\n\nAll your drawings are stored in the "My Drawings" section.';
    }
    else if (lowerMessage.contains('brush') || lowerMessage.contains('color') || lowerMessage.contains('tool')) {
      reply = '🖌️ **Drawing Tools Available:**\n\n• **Brushes:** 12+ types (pencil, marker, watercolor, oil, airbrush, calligraphy)\n• **Colors:** Full RGB color picker + 24 preset colors\n• **Size:** Adjustable from 1px to 100px\n• **Opacity:** 0-100% control\n• **Effects:** Glow, shadow, neon, and more\n\nTry the gradient tool for stunning color blends!';
    }
    else if (lowerMessage.contains('layer') || lowerMessage.contains('undo') || lowerMessage.contains('redo')) {
      reply = '📑 **Layer Management:**\n\n• Create up to 10 layers\n• Merge, duplicate, and reorder layers\n• Adjust opacity per layer\n• Lock layers to prevent changes\n• Unlimited undo/redo history\n\nLayers help you work on different elements separately!';
    }
    else if (lowerMessage.contains('background') || lowerMessage.contains('scene')) {
      reply = '🌄 **Background & Scene Options:**\n\n• **Pre-made backgrounds:** Room walls, nature scenes, sky\n• **Custom backgrounds:** Upload your own images\n• **Scene suggestions:** AI suggests matching backgrounds\n• **Auto-placement:** Objects snap to realistic positions\n\nTry placing your drawing in different scenes!';
    }
    else if (lowerMessage.contains('help') || lowerMessage.contains('how to')) {
      reply = '🎯 **How can I help you today?**\n\nI can assist with:\n• 📱 Using air drawing\n• 🎨 AI correction features\n• 💾 Saving and sharing drawings\n• 🖌️ Brush and tool tutorials\n• 🎯 Drawing techniques\n• 🌄 Background placement\n• 🤖 AI features explanation\n\nWhat would you like to learn about?';
    }
    else {
      final genericResponses = [
        'I love helping creative artists like you! 🌟 Our AI features are designed to make drawing accessible to everyone. Would you like to know more about a specific tool?',
        'Great question! 🎨 The canvas drawing mode supports pressure sensitivity and palm rejection. Try drawing with a stylus for even better control!',
        'That\'s an interesting topic! 💡 Did you know our AI can recognize over 50 different shapes and patterns? It\'s trained on millions of artworks.',
        'I\'m here to help! ✨ Whether you need technical help or creative inspiration, feel free to ask. What specific feature interests you most?',
        'Drawing is a journey! 🚀 Start with simple shapes and let our AI guide you. The more you practice, the better your creations will become!',
      ];
      reply = genericResponses[DateTime.now().millisecond % genericResponses.length];
    }

    setState(() {
      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _askQuickQuestion(QuickQuestion question) {
    _textController.text = question.question;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.3),
                  AppTheme.darkBg,
                  AppTheme.darkerBg,
                ],
              ),
            ),
          ),

          // Floating Particles
          ...List.generate(15, (index) => _AssistantParticle(index: index)),

          SafeArea(
            child: Column(
              children: [
                // Premium App Bar
                _buildPremiumAppBar(),

                // Quick Questions Section
                _buildQuickQuestionsSection(),

                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: _PremiumChatBubble(message: _messages[index]),
                        );
                      } else {
                        return const _PremiumTypingIndicator();
                      }
                    },
                  ),
                ),

                // Input Area
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          FadeInLeft(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.glassBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 50),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GlowingContainer(
                    size: 45,
                    color: AppTheme.neonYellow,
                    child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online • Ready to help',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.neonGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInRight(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.neonGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionsSection() {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Suggested Questions',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.electricBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                return FadeInLeft(
                  delay: Duration(milliseconds: 200 + (index * 50)),
                  child: _QuickQuestionChip(
                    question: _quickQuestions[index],
                    onTap: () => _askQuickQuestion(_quickQuestions[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassBg,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 30,
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: AppTheme.electricBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: AppTheme.neonPink, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎤 Voice input coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.cardBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _AnimatedPremiumButton(
            onTap: _sendMessage,
            child: GlowingContainer(
              size: 50,
              color: AppTheme.electricBlue,
              child: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Question Chip Widget
class _QuickQuestionChip extends StatelessWidget {
  final QuickQuestion question;
  final VoidCallback onTap;

  const _QuickQuestionChip({
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.glassBg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Text(
              question.question,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.electricBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 12, color: AppTheme.electricBlue),
          ],
        ),
      ),
    );
  }
}

// Quick Question Model
class QuickQuestion {
  final String question;
  final String answer;

  QuickQuestion(this.question, this.answer);
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Premium Chat Bubble
class _PremiumChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _PremiumChatBubble({required this.message});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            GlowingContainer(
              size: 40,
              color: AppTheme.neonYellow,
              child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? LinearGradient(
                      colors: [AppTheme.primaryPurple, AppTheme.neonPurple],
                    )
                        : null,
                    color: message.isUser ? null : AppTheme.glassBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// Premium Typing Indicator
class _PremiumTypingIndicator extends StatelessWidget {
  const _PremiumTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlowingContainer(
            size: 40,
            color: AppTheme.neonYellow,
            child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + 0.5 * sin(value * 2 * pi + index * 2),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.electricBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Assistant Particle Widget
class _AssistantParticle extends StatefulWidget {
  final int index;
  const _AssistantParticle({required this.index});

  @override
  State<_AssistantParticle> createState() => _AssistantParticleState();
}

class _AssistantParticleState extends State<_AssistantParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.index % 5),
      vsync: this,
    )..repeat(reverse: true);

    _verticalAnimation = Tween<double>(begin: 0, end: 80 + (widget.index % 120)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _opacityAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final leftValue = (20 + (widget.index * 45) % screenWidth.toInt()).toDouble();

        return Positioned(
          left: leftValue,
          top: _verticalAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 2 + (widget.index % 4).toDouble(),
              height: 2 + (widget.index % 4).toDouble(),
              decoration: BoxDecoration(
                color: [
                  AppTheme.electricBlue,
                  AppTheme.neonPink,
                  AppTheme.neonYellow,
                  AppTheme.neonGreen,
                ][widget.index % 4].withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animated Premium Button
class _AnimatedPremiumButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedPremiumButton({
    required this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedPremiumButton> createState() => _AnimatedPremiumButtonState();
}

class _AnimatedPremiumButtonState extends State<_AnimatedPremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}