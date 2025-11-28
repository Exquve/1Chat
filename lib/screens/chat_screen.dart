import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  
  late AnimationController _sendButtonController;
  late AnimationController _typingController;
  late Animation<double> _sendButtonScale;
  bool _isTyping = false;
  
  Timer? _autoMessageTimer;
  bool _isContactTyping = false;
  bool _showScrollToBottom = false;
  final List<String> _autoMessages = [
    'Ne yapıyorsun? 🤔',
    'Bugün hava nasıl orada?',
    'Akşam buluşalım mı? ☕',
    'Bu fotoğrafı gördün mü? 📸',
    'Çok komik bir şey oldu! 😂',
    'Seni özledim 💕',
    'İş nasıl gidiyor?',
    'Yemek yedin mi?',
    'Film izleyelim mi bu akşam? 🎬',
    'Günaydın! ☀️',
    'Bana yardım eder misin?',
    'Harika bir haber var! 🎉',
    'Ne zaman müsaitsin?',
    'Kahve içelim mi? ☕',
    'Bu şarkıyı dinle! 🎵',
  ];

  @override
  void initState() {
    super.initState();
    
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    _sendButtonScale = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
    
    _loadDemoMessages();
    
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
    
    // Scroll listener - kullanıcı yukarıdaysa butonu göster
    _scrollController.addListener(_onScroll);
    
    // Her 10 saniyede bir otomatik mesaj başlat
    _startAutoMessages();
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final isAtBottom = _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100;
    
    if (_showScrollToBottom == isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _startAutoMessages() {
    _autoMessageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _showTypingIndicator();
    });
  }
  
  void _showTypingIndicator() {
    // Önce "yazıyor..." göster
    setState(() {
      _isContactTyping = true;
    });
    
    // 2-3 saniye sonra mesajı gönder
    Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(1500)), () {
      if (mounted) {
        _receiveAutoMessage();
      }
    });
  }
  
  void _receiveAutoMessage() {
    final random = Random();
    final message = _autoMessages[random.nextInt(_autoMessages.length)];
    
    // Kullanıcı en altta mı kontrol et (scroll yapmadan önce)
    final isAtBottom = _scrollController.hasClients &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100;
    
    setState(() {
      _isContactTyping = false;
      _messages.add(
        MessageModel(
          senderId: widget.contactId,
          receiverId: widget.currentUserId,
          text: message,
          type: MessageType.text,
          timeSent: DateTime.now(),
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          isSeen: false,
        ),
      );
    });
    
    // Sadece kullanıcı en alttaysa scroll yap
    if (isAtBottom) {
      Future.delayed(const Duration(milliseconds: 100), () {
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
  
  void _loadDemoMessages() {
    _messages.addAll([
      MessageModel(
        senderId: widget.contactId,
        receiverId: widget.currentUserId,
        text: 'Merhaba! Nasılsın?',
        type: MessageType.text,
        timeSent: DateTime.now().subtract(const Duration(minutes: 10)),
        messageId: '1',
        isSeen: true,
      ),
      MessageModel(
        senderId: widget.currentUserId,
        receiverId: widget.contactId,
        text: 'İyiyim, teşekkürler! Sen nasılsın?',
        type: MessageType.text,
        timeSent: DateTime.now().subtract(const Duration(minutes: 8)),
        messageId: '2',
        isSeen: true,
      ),
      MessageModel(
        senderId: widget.contactId,
        receiverId: widget.currentUserId,
        text: 'Ben de iyiyim. Bugün hava çok güzel!',
        type: MessageType.text,
        timeSent: DateTime.now().subtract(const Duration(minutes: 5)),
        messageId: '3',
        isSeen: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _autoMessageTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        MessageModel(
          senderId: widget.currentUserId,
          receiverId: widget.contactId,
          text: _messageController.text.trim(),
          type: MessageType.text,
          timeSent: DateTime.now(),
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          isSeen: false,
        ),
      );
    });

    _messageController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAnimatedAppBar(isDark),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMessageList(isDark),
                // Aşağı kaydır butonu
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: GestureDetector(
                            onTap: _scrollToBottom,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          _buildAnimatedInputBar(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0.5,
      leading: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isDark ? Colors.white : AppColors.textColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
      title: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.contactId}',
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.contactName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contactName,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildOnlineStatus(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        _buildAnimatedAppBarAction(Icons.videocam_rounded, isDark, 0),
        _buildAnimatedAppBarAction(Icons.call_rounded, isDark, 100),
        _buildAnimatedAppBarAction(Icons.more_vert_rounded, isDark, 200),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOnlineStatus() {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isContactTyping ? AppColors.primaryColor : AppColors.onlineColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isContactTyping ? AppColors.primaryColor : AppColors.onlineColor)
                        .withOpacity(0.5 + _typingController.value * 0.3),
                    blurRadius: 4 + _typingController.value * 2,
                    spreadRadius: _typingController.value,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _isContactTyping ? 'yazıyor...' : 'çevrimiçi',
                key: ValueKey(_isContactTyping),
                style: TextStyle(
                  color: _isContactTyping ? AppColors.primaryColor : AppColors.onlineColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedAppBarAction(IconData icon, bool isDark, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? Colors.white70 : AppColors.iconColor, size: 20),
            ),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == widget.currentUserId;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(isMe ? 30 * (1 - value) : -30 * (1 - value), 0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: _MessageBubble(message: message, isMe: isMe, isDark: isDark),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedInputBar(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isTyping ? AppColors.primaryColor.withOpacity(0.5) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.emoji_emotions_outlined, color: AppColors.greyColor, size: 24),
                              onPressed: () {},
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColors.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Mesaj',
                                  hintStyle: TextStyle(color: AppColors.greyColor),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file_rounded, color: AppColors.greyColor, size: 24),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.camera_alt_outlined, color: AppColors.greyColor, size: 24),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSendButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTapDown: (_) => _sendButtonController.forward(),
      onTapUp: (_) {
        _sendButtonController.reverse();
        _sendMessage();
      },
      onTapCancel: () => _sendButtonController.reverse(),
      child: AnimatedBuilder(
        animation: _sendButtonController,
        builder: (context, child) {
          return Transform.scale(
            scale: _sendButtonScale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: _isTyping 
                    ? AppColors.primaryGradient 
                    : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isTyping 
                        ? AppColors.primaryColor.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: _isTyping ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                  key: ValueKey(_isTyping),
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPressStart: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onLongPressEnd: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          transform: Matrix4.identity()..scale(_isPressed ? 1.05 : 1.0),
          decoration: BoxDecoration(
            gradient: widget.isMe ? AppColors.primaryGradient : null,
            color: widget.isMe ? null : (widget.isDark ? Theme.of(context).cardColor : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(widget.isMe ? 20 : 6),
              bottomRight: Radius.circular(widget.isMe ? 6 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isMe 
                    ? AppColors.primaryColor.withOpacity(_isPressed ? 0.4 : 0.2)
                    : Colors.black.withOpacity(_isPressed ? 0.1 : 0.05),
                blurRadius: _isPressed ? 15 : 8,
                offset: Offset(0, _isPressed ? 5 : 3),
              ),
            ],
          ),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isMe ? Colors.white : (widget.isDark ? Colors.white : AppColors.textColor),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(widget.message.timeSent),
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isMe ? Colors.white.withOpacity(0.8) : AppColors.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      widget.message.isSeen ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 16,
                      color: widget.message.isSeen ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
