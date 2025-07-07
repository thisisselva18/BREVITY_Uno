import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:ui';
import 'package:brevity/controller/bloc/chat_bloc/chat_bloc.dart';
import 'package:brevity/controller/services/gemini_service.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/models/article_model.dart';

class ChatScreen extends StatefulWidget {
  final Article article;
  const ChatScreen({super.key, required this.article});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController, _slideController, _pulseController;
  late Animation<double> _fadeAnimation, _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isComposing = false;
  String _pendingMessage = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))..repeat(reverse: true);
    
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart));
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({required Widget child, required Color primaryColor, double? opacity, List<BoxShadow>? shadows, EdgeInsets? margin, EdgeInsets? padding}) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity ?? 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: shadows ?? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().currentTheme;
    
    return BlocProvider(
      create: (context) => ChatBloc(geminiService: GeminiFlashService())..add(InitializeChat(article: widget.article)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [theme.primaryColor.withOpacity(0.08), Colors.black, theme.primaryColor.withOpacity(0.03)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(theme),
                _buildArticleCard(theme),
                Expanded(child: _buildMessageList(theme)),
                _buildInputField(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIconButton(Icons.arrow_back_ios_new, theme.primaryColor, () => Navigator.pop(context)),
            Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: [Colors.white, theme.primaryColor]).createShader(bounds),
                    child: Text('NewsAI Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                  Text('Powered by Gemini', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
            _buildIconButton(Icons.delete_outline, Colors.red.shade400, () => context.read<ChatBloc>().add(ClearChat())),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: EdgeInsets.all(10), child: Icon(icon, color: color, size: 18)),
        ),
      ),
    );
  }

  Widget _buildArticleCard(theme) {
    return SlideTransition(
      position: _slideAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(18),
        shadows: [BoxShadow(color: theme.primaryColor.withOpacity(0.15), blurRadius: 15, offset: Offset(0, 6))],
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withOpacity(0.4), width: 1),
              ),
              child: Icon(Icons.auto_awesome, color: theme.primaryColor, size: 22),
            ),
            Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Article Context', style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  Gap(4),
                  Text(widget.article.title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(theme) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded || state is MessageSending) _scrollToBottom();
      },
      builder: (context, state) {
        if (state is ChatLoaded) {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            itemCount: state.chatWindow.conversations.length,
            itemBuilder: (context, index) {
              final conversation = state.chatWindow.conversations[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Column(
                        children: [
                          _buildUserMessage(conversation.request, theme),
                          Gap(12),
                          _buildAiMessage(conversation.response, theme, shouldAnimate: index == state.chatWindow.conversations.length - 1),
                          Gap(20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (state is MessageSending) {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            itemCount: state.chatWindow.conversations.length + 1,
            itemBuilder: (context, index) {
              if (index < state.chatWindow.conversations.length) {
                final conversation = state.chatWindow.conversations[index];
                return Column(
                  children: [_buildUserMessage(conversation.request, theme), Gap(12), _buildAiMessage(conversation.response, theme, shouldAnimate: false), Gap(20)],
                );
              } else {
                return Column(children: [_buildUserMessage(_pendingMessage, theme), Gap(12), _buildTypingIndicator(theme)]);
              }
            },
          );
        } else if (state is ChatError) {
          return Center(
            child: _buildGlassContainer(
              primaryColor: Colors.red,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.error_outline, color: Colors.red, size: 32),
                  ),
                  Gap(16),
                  Text('Something went wrong', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
                  Gap(6),
                  Text(state.message, style: TextStyle(color: Colors.red.shade300, fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 2.5),
              ),
              Gap(16),
              Text('Initializing chat...', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(String message, theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(4)),
          boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Text(message, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
      ),
    );
  }

  Widget _buildAiMessage(String message, theme, {bool shouldAnimate = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.primaryColor.withOpacity(0.4), width: 1)),
                  child: Icon(Icons.smart_toy, color: theme.primaryColor, size: 16),
                ),
                Gap(12),
                Expanded(
                  child: shouldAnimate
                      ? TypewriterText(text: message, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.4))
                      : Text(message, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.smart_toy, color: theme.primaryColor, size: 16),
                ),
                Gap(12),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor))),
                  builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
                ),
                Gap(12),
                Text('Thinking...', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(theme) {
    return _buildGlassContainer(
      primaryColor: theme.primaryColor,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isComposing ? theme.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.15), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) => setState(() => _isComposing = text.isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about this article...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.auto_awesome_outlined, color: theme.primaryColor.withOpacity(0.7), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap(12),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state is MessageSending;
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _isComposing && !isLoading ? LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)]) : null,
                  color: _isComposing && !isLoading ? null : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isComposing ? theme.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.15), width: 1.5),
                  boxShadow: _isComposing && !isLoading ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))] : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: IconButton(
                      icon: isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isComposing && !isLoading
                          ? () {
                              final message = _controller.text.trim();
                              if (message.isNotEmpty) {
                                final currentState = context.read<ChatBloc>().state;
                                if (currentState is ChatLoaded) {
                                  _pendingMessage = message;
                                  context.read<ChatBloc>().add(SendMessage(message: message, chatWindow: currentState.chatWindow));
                                }
                                _controller.clear();
                                setState(() => _isComposing = false);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TypewriterText({Key? key, required this.text, required this.style, this.duration = const Duration(milliseconds: 40)}) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds), vsync: this);
    _charAnimation = IntTween(begin: 0, end: widget.text.length).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _charAnimation, builder: (context, child) => Text(widget.text.substring(0, _charAnimation.value), style: widget.style));
  }
}