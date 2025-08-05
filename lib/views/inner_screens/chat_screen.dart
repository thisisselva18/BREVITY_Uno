import 'dart:ui';
import 'package:brevity/controller/bloc/chat_bloc/chat_bloc.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/controller/services/gemini_service.dart';
import 'package:brevity/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:brevity/models/theme_model.dart';

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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<ThemeCubit>().currentTheme;
    final theme = Theme.of(context);

    return BlocProvider(
      create:
          (context) =>
              ChatBloc(geminiService: GeminiFlashService())
                ..add(InitializeChat(article: widget.article)),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                appTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
                theme.colorScheme.surface,
                appTheme.primaryColor.withAlpha((0.05 * 255).toInt()),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildGlassAppBar(appTheme),
                _buildFloatingArticleCard(appTheme),
                Expanded(child: _buildMessageList(appTheme)),
                _buildGlassInputField(appTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar(AppTheme appTheme) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: baseColor.withAlpha((0.2 * 255).toInt())),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Row(
              children: [
                _buildGlassButton(
                  Icons.arrow_back_ios_new,
                  appTheme.primaryColor,
                  () => Navigator.pop(context),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [
                                theme.colorScheme.onSurface,
                                appTheme.primaryColor,
                              ],
                            ).createShader(bounds),
                        child: Text(
                          'NewsAI Assistant',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Colors
                                    .white, // Color must be white for ShaderMask
                          ),
                        ),
                      ),
                      Text(
                        'Powered by Gemini',
                        style: TextStyle(
                          color: appTheme.primaryColor.withAlpha((0.8 * 255).toInt()),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return _buildGlassButton(
                      Icons.delete_outline,
                      Colors.red,
                      () {
                        context.read<ChatBloc>().add(ClearChat());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha((0.2 * 255).toInt()), color.withAlpha((0.1 * 255).toInt())],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingArticleCard(AppTheme appTheme) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appTheme.primaryColor.withAlpha((0.15 * 255).toInt()),
              appTheme.primaryColor.withAlpha((0.05 * 255).toInt()),
              theme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: appTheme.primaryColor.withAlpha((0.3 * 255).toInt())),
          boxShadow: [
            BoxShadow(
              color: appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        appTheme.primaryColor.withAlpha((0.4 * 255).toInt()),
                        appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: appTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                    ),
                  ),
                  child: Icon(
                    Icons.article,
                    color: appTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Article Context',
                        style: TextStyle(
                          color: appTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        widget.article.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(AppTheme appTheme) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded || state is MessageSending) _scrollToBottom();
      },
      builder: (context, state) {
        if (state is ChatLoaded) {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.chatWindow.conversations.length,
            itemBuilder: (context, index) {
              final conversation = state.chatWindow.conversations[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          _buildUserMessage(conversation.request, appTheme),
                          const Gap(16),
                          _buildAiMessage(
                            conversation.response,
                            appTheme,
                            shouldAnimate:
                                index ==
                                state.chatWindow.conversations.length - 1,
                          ),
                          const Gap(24),
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
            padding: const EdgeInsets.all(16),
            itemCount: state.chatWindow.conversations.length + 1,
            itemBuilder: (context, index) {
              if (index < state.chatWindow.conversations.length) {
                final conversation = state.chatWindow.conversations[index];
                return Column(
                  children: [
                    _buildUserMessage(conversation.request, appTheme),
                    const Gap(16),
                    _buildAiMessage(
                      conversation.response,
                      appTheme,
                      shouldAnimate: false,
                    ),
                    const Gap(24),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildUserMessage(_pendingMessage, appTheme),
                    const Gap(16),
                    _buildTypingIndicator(appTheme),
                  ],
                );
              }
            },
          );
        } else if (state is ChatError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withAlpha((0.15 * 255).toInt()),
                    Colors.red.withAlpha((0.05 * 255).toInt()),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withAlpha((0.3 * 255).toInt())),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.red.withAlpha((0.3 * 255).toInt()),
                          Colors.red.withAlpha((0.1 * 255).toInt()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state is ChatInitial) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: appTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                  size: 60,
                ),
                Gap(20),
                Text(
                  'Start a conversation about the article!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Gap(10),
                Text(
                  'Your chat history will appear here.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        // This 'return' should only catch truly unexpected states,
        // or a genuine loading state if introduced separately from ChatInitial.
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                      appTheme.primaryColor.withAlpha((0.05 * 255).toInt()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CircularProgressIndicator(
                  color: appTheme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
              const Gap(20),
              Text(
                'Initializing chat...',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(String message, AppTheme appTheme) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appTheme.primaryColor,
                        appTheme.primaryColor.withAlpha((0.7 * 255).toInt()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.primaryColor.withAlpha((0.4 * 255).toInt()),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiMessage(
    String message,
    AppTheme appTheme, {
    bool shouldAnimate = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-30 * (1 - value), 0),
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withAlpha((0.8 * 255).toInt()),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(color: baseColor.withAlpha((0.2 * 255).toInt())),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              appTheme.primaryColor.withAlpha((0.4 * 255).toInt()),
                              appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: appTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child:
                            shouldAnimate
                                ? TypewriterText(
                                  text: message,
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    height: 1.4,
                                  ),
                                )
                                : Text(
                                  message,
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    height: 1.4,
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
      },
    );
  }

  Widget _buildTypingIndicator(AppTheme appTheme) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor.withAlpha((0.8 * 255).toInt()),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: baseColor.withAlpha((0.2 * 255).toInt())),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            appTheme.primaryColor.withAlpha((0.4 * 255).toInt()),
                            appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        color: appTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const Gap(16),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(16),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              appTheme.primaryColor,
                              theme.colorScheme.onSurface,
                            ],
                          ).createShader(bounds),
                      child: const Text(
                        'Thinking...',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassInputField(AppTheme appTheme) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: baseColor.withAlpha((0.2 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: theme.textTheme.bodyLarge,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged:
                      (text) => setState(() => _isComposing = text.isNotEmpty),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about this article...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                    ),
                    prefixIcon: Icon(
                      Icons.auto_awesome_outlined,
                      color: appTheme.primaryColor.withAlpha((0.8 * 255).toInt()),
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const Gap(8),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  final isLoading = state is MessageSending;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient:
                          _isComposing && !isLoading
                              ? LinearGradient(
                                colors: [
                                  appTheme.primaryColor,
                                  appTheme.primaryColor.withAlpha((0.7 * 255).toInt()),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : LinearGradient(
                                colors: [
                                  theme.disabledColor.withAlpha((0.3 * 255).toInt()),
                                  theme.disabledColor.withAlpha((0.1 * 255).toInt()),
                                ],
                              ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow:
                          _isComposing && !isLoading
                              ? [
                                BoxShadow(
                                  color: appTheme.primaryColor.withAlpha((0.4 * 255).toInt()),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                              : null,
                    ),
                    child: IconButton(
                      icon:
                          isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.send_rounded,
                                color:
                                    _isComposing
                                        ? theme.colorScheme.onPrimary
                                        : theme.disabledColor,
                                size: 24,
                              ),
                      onPressed:
                          _isComposing && !isLoading
                              ? () {
                                final message = _controller.text.trim();
                                if (message.isNotEmpty) {
                                  final currentState =
                                      context.read<ChatBloc>().state;
                                  if (currentState is ChatLoaded) {
                                    _pendingMessage = message;
                                    context.read<ChatBloc>().add(
                                      SendMessage(
                                        message: message,
                                        chatWindow: currentState.chatWindow,
                                      ),
                                    );
                                  }
                                  _controller.clear();
                                  setState(() => _isComposing = false);
                                }
                              }
                              : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 50),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.duration.inMilliseconds,
      ),
      vsync: this,
    );
    _charAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charAnimation,
      builder: (context, child) {
        return Text(
          widget.text.substring(0, _charAnimation.value),
          style: widget.style,
        );
      },
    );
  }
}
