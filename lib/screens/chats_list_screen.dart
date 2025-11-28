import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/chat_contact.dart';
import '../providers/theme_provider.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  final String userName;
  final String userPhone;

  const ChatsListScreen({
    super.key,
    required this.userName,
    required this.userPhone,
  });

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> with TickerProviderStateMixin {
  late AnimationController _listController;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  
  final List<ChatContact> _demoChats = [
    ChatContact(
      name: 'Ahmet Yılmaz',
      profilePic: '',
      contactId: '1',
      timeSent: DateTime.now().subtract(const Duration(minutes: 5)),
      lastMessage: 'Merhaba, nasılsın?',
    ),
    ChatContact(
      name: 'Ayşe Demir',
      profilePic: '',
      contactId: '2',
      timeSent: DateTime.now().subtract(const Duration(hours: 1)),
      lastMessage: 'Yarın görüşürüz 👋',
    ),
    ChatContact(
      name: 'Mehmet Kaya',
      profilePic: '',
      contactId: '3',
      timeSent: DateTime.now().subtract(const Duration(hours: 3)),
      lastMessage: 'Toplantı saat kaçta?',
    ),
    ChatContact(
      name: 'Fatma Şahin',
      profilePic: '',
      contactId: '4',
      timeSent: DateTime.now().subtract(const Duration(days: 1)),
      lastMessage: 'Teşekkürler 😊',
    ),
    ChatContact(
      name: 'Ali Özkan',
      profilePic: '',
      contactId: '5',
      timeSent: DateTime.now().subtract(const Duration(days: 2)),
      lastMessage: 'Proje nasıl gidiyor?',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    
    _listController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa';
    } else {
      return '${difference.inDays} gün';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAnimatedAppBar(themeProvider, isDark),
      body: Column(
        children: [
          // Animated Search Bar
          _buildAnimatedSearchBar(isDark),
          
          // Animated Chat List
          Expanded(
            child: _demoChats.isEmpty
                ? _buildEmptyState()
                : _buildAnimatedChatList(isDark),
          ),
        ],
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar(ThemeProvider themeProvider, bool isDark) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                '1Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        // Theme Toggle with Animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _AnimatedThemeButton(
                isDark: isDark,
                onPressed: () => themeProvider.toggleTheme(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildAppBarButton(Icons.camera_alt_outlined, isDark, 200),
        _buildAppBarButton(Icons.search_rounded, isDark, 300),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarButton(IconData icon, bool isDark, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutBack,
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
              child: Icon(
                icon,
                color: isDark ? Colors.white70 : AppColors.iconColor,
                size: 20,
              ),
            ),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSearchBar(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _listController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      )),
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'Sohbetlerde ara',
              hintStyle: TextStyle(color: AppColors.greyColor, fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.greyColor, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Henüz sohbet yok',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni bir sohbet başlatın',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedChatList(bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: _demoChats.length,
      itemBuilder: (context, index) {
        final chat = _demoChats[index];
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _ChatListItem(
                  chat: chat,
                  isDark: isDark,
                  timeAgo: _getTimeAgo(chat.timeSent),
                  onTap: () => _navigateToChat(chat),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToChat(ChatContact chat) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
          contactName: chat.name,
          contactId: chat.contactId,
          currentUserId: widget.userPhone,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: _AnimatedFAB(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Yeni sohbet özelliği yakında!'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }
}

// Animated Theme Button
class _AnimatedThemeButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const _AnimatedThemeButton({
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<_AnimatedThemeButton> createState() => _AnimatedThemeButtonState();
}

class _AnimatedThemeButtonState extends State<_AnimatedThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(_AnimatedThemeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(widget.isDark),
            color: widget.isDark ? Colors.amber : AppColors.iconColor,
            size: 24,
          ),
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}

// Chat List Item with Hover Effect
class _ChatListItem extends StatefulWidget {
  final ChatContact chat;
  final bool isDark;
  final String timeAgo;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.isDark,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1))
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
              blurRadius: _isPressed ? 4 : 10,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Gradient
            Hero(
              tag: 'avatar_${widget.chat.contactId}',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.chat.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Chat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.greyColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Animated FAB
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedFAB({required this.onPressed});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(_isPressed ? 0.3 : 0.5),
                  blurRadius: _isPressed ? 8 : (15 + _controller.value * 5),
                  spreadRadius: _controller.value * 2,
                  offset: Offset(0, _isPressed ? 3 : 6),
                ),
              ],
            ),
            child: Transform.scale(
              scale: _isPressed ? 0.9 : 1.0,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }
}
