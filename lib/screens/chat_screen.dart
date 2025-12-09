import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:video_player/video_player.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _sendButtonController;
  late AnimationController _typingController;
  late AnimationController _attachmentMenuController;
  late Animation<double> _sendButtonScale;
  bool _isTyping = false;
  bool _showEmojiPicker = false;
  bool _showAttachmentMenu = false;
  final FocusNode _focusNode = FocusNode();
  List<XFile> _selectedMedia = [];

  Timer? _autoMessageTimer;
  bool _isContactTyping = false;
  bool _showScrollToBottom = false;
  int _unreadCount = 0;
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

    _attachmentMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

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

    final isAtBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (_showScrollToBottom == isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
        // En alta gelince okunmamış sayısını sıfırla
        if (isAtBottom) {
          _unreadCount = 0;
        }
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
    // En alta indiğinde okunmamış sayısını sıfırla
    setState(() {
      _unreadCount = 0;
    });
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
    final isAtBottom =
        _scrollController.hasClients &&
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
      // Kullanıcı yukarıdaysa okunmamış sayısını artır
      if (!isAtBottom) {
        _unreadCount++;
      }
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
    _attachmentMenuController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ===== MEDIA FUNCTIONS =====

  void _toggleAttachmentMenu() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
      if (_showAttachmentMenu) {
        _attachmentMenuController.forward();
        // Emoji picker'ı kapat
        if (_showEmojiPicker) {
          _showEmojiPicker = false;
        }
      } else {
        _attachmentMenuController.reverse();
      }
    });
  }

  void _closeAttachmentMenu() {
    if (_showAttachmentMenu) {
      setState(() {
        _showAttachmentMenu = false;
        _attachmentMenuController.reverse();
      });
    }
  }

  Widget _buildIMessageAttachmentMenu(bool isDark) {
    return AnimatedBuilder(
      animation: _attachmentMenuController,
      builder: (context, child) {
        final slideAnimation = CurvedAnimation(
          parent: _attachmentMenuController,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(slideAnimation),
          child: FadeTransition(
            opacity: _attachmentMenuController,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildIMessageOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      color: const Color(0xFFFF9500),
                      delay: 0,
                      onTap: () {
                        _closeAttachmentMenu();
                        _takePhoto();
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Fotoğraflar',
                      color: const Color(0xFF34C759),
                      delay: 50,
                      onTap: () {
                        _closeAttachmentMenu();
                        _pickMultipleImages();
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: const Color(0xFFFF2D55),
                      delay: 100,
                      onTap: () {
                        _closeAttachmentMenu();
                        _showVideoOptions();
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.folder_rounded,
                      label: 'Dosya',
                      color: const Color(0xFF007AFF),
                      delay: 150,
                      onTap: () {
                        _closeAttachmentMenu();
                        _showSnackBar('Dosya seçme yakında eklenecek');
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.location_on_rounded,
                      label: 'Konum',
                      color: const Color(0xFF5856D6),
                      delay: 200,
                      onTap: () {
                        _closeAttachmentMenu();
                        _showSnackBar('Konum paylaşma yakında eklenecek');
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.person_rounded,
                      label: 'Kişi',
                      color: const Color(0xFF00C7BE),
                      delay: 250,
                      onTap: () {
                        _closeAttachmentMenu();
                        _showSnackBar('Kişi paylaşma yakında eklenecek');
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.mic_rounded,
                      label: 'Ses',
                      color: const Color(0xFFFF3B30),
                      delay: 300,
                      onTap: () {
                        _closeAttachmentMenu();
                        _pickAudio();
                      },
                    ),
                    _buildIMessageOption(
                      icon: Icons.poll_rounded,
                      label: 'Anket',
                      color: const Color(0xFFAF52DE),
                      delay: 350,
                      onTap: () {
                        _closeAttachmentMenu();
                        _showSnackBar('Anket oluşturma yakında eklenecek');
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIMessageOption({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: _showAttachmentMenu ? value : 1.0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAttachmentBottomSheet(),
    );
  }

  Widget _buildAttachmentBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Medya Paylaş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showVideoOptions();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Dosya',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Dosya seçme yakında eklenecek');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.location_on_rounded,
                  label: 'Konum',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Konum paylaşma yakında eklenecek');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.person_rounded,
                  label: 'Kişi',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Kişi paylaşma yakında eklenecek');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.poll_rounded,
                  label: 'Anket',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Anket oluşturma yakında eklenecek');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.headphones_rounded,
                  label: 'Ses',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.pop(context);
                    _pickAudio();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images.isNotEmpty) {
        _selectedMedia = images;
        _showMediaPreview(images, isVideo: false);
      }
    } catch (e) {
      _showSnackBar('Resim seçilirken bir hata oluştu');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        _selectedMedia = [photo];
        _showMediaPreview([photo], isVideo: false);
      }
    } catch (e) {
      _showSnackBar('Fotoğraf çekilirken bir hata oluştu');
    }
  }

  void _showVideoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Video Seç',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.video_library_rounded,
                      label: 'Galeriden',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideo();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam_rounded,
                      label: 'Kaydet',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _takeVideo();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        _selectedMedia = [video];
        _showMediaPreview([video], isVideo: true);
      }
    } catch (e) {
      _showSnackBar('Video seçilirken bir hata oluştu');
    }
  }

  Future<void> _takeVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        _selectedMedia = [video];
        _showMediaPreview([video], isVideo: true);
      }
    } catch (e) {
      _showSnackBar('Video kaydedilirken bir hata oluştu');
    }
  }

  void _pickAudio() {
    _showSnackBar('Ses dosyası seçme yakında eklenecek');
  }

  void _showMediaPreview(List<XFile> media, {required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MediaPreviewSheet(
        media: media,
        isVideo: isVideo,
        onSend: (caption) {
          Navigator.pop(context);
          _sendMediaMessage(media, caption, isVideo: isVideo);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _sendMediaMessage(
    List<XFile> media,
    String caption, {
    required bool isVideo,
  }) {
    final mediaUrls = media.map((m) => m.path).toList();

    setState(() {
      _messages.add(
        MessageModel(
          senderId: widget.currentUserId,
          receiverId: widget.contactId,
          text: caption.isEmpty
              ? (media.length > 1
                    ? '📷 ${media.length} medya'
                    : (isVideo ? '🎬 Video' : '📷 Fotoğraf'))
              : caption,
          type: isVideo ? MessageType.video : MessageType.image,
          timeSent: DateTime.now(),
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          isSeen: false,
          mediaUrls: mediaUrls,
        ),
      );
    });

    _selectedMedia = [];

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

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController.text += emoji.emoji;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primaryColor,
      ),
    );
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
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.4),
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
                                // Okunmamış mesaj badge
                                if (_unreadCount > 0)
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.elasticOut,
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(
                                                    0.4,
                                                  ),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              _unreadCount > 99
                                                  ? '99+'
                                                  : _unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
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
                color: _isContactTyping
                    ? AppColors.primaryColor
                    : AppColors.onlineColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isContactTyping
                                ? AppColors.primaryColor
                                : AppColors.onlineColor)
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
                  color: _isContactTyping
                      ? AppColors.primaryColor
                      : AppColors.onlineColor,
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
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.backgroundColor,
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
                child: _MessageBubble(
                  message: message,
                  isMe: isMe,
                  isDark: isDark,
                ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // iMessage Style Attachment Menu
                    if (_showAttachmentMenu)
                      _buildIMessageAttachmentMenu(isDark),
                    Row(
                      children: [
                        // iMessage style + button
                        GestureDetector(
                          onTap: _toggleAttachmentMenu,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: _showAttachmentMenu
                                  ? AppColors.primaryGradient
                                  : null,
                              color: _showAttachmentMenu
                                  ? null
                                  : (isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : AppColors.backgroundColor),
                              shape: BoxShape.circle,
                            ),
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: _showAttachmentMenu
                                  ? 0.125
                                  : 0, // 45 derece dönüş
                              child: Icon(
                                Icons.add,
                                color: _showAttachmentMenu
                                    ? Colors.white
                                    : AppColors.greyColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _isTyping
                                    ? AppColors.primaryColor.withOpacity(0.5)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _showEmojiPicker
                                        ? Icons.keyboard_rounded
                                        : Icons.emoji_emotions_outlined,
                                    color: _showEmojiPicker
                                        ? AppColors.primaryColor
                                        : AppColors.greyColor,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _closeAttachmentMenu();
                                    _toggleEmojiPicker();
                                  },
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    focusNode: _focusNode,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textColor,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Mesaj',
                                      hintStyle: TextStyle(
                                        color: AppColors.greyColor,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                    maxLines: null,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    onSubmitted: (_) => _sendMessage(),
                                    onTap: () {
                                      _closeAttachmentMenu();
                                      if (_showEmojiPicker) {
                                        setState(
                                          () => _showEmojiPicker = false,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.greyColor,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _closeAttachmentMenu();
                                    _takePhoto();
                                  },
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
                    // Emoji Picker
                    if (_showEmojiPicker)
                      SizedBox(
                        height: 280,
                        child: EmojiPicker(
                          onEmojiSelected: _onEmojiSelected,
                          config: Config(
                            height: 280,
                            checkPlatformCompatibility: true,
                            emojiViewConfig: EmojiViewConfig(
                              emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                              columns: 8,
                              backgroundColor: isDark
                                  ? const Color(0xFF1F2C34)
                                  : Colors.white,
                            ),
                            skinToneConfig: const SkinToneConfig(),
                            categoryViewConfig: CategoryViewConfig(
                              indicatorColor: AppColors.primaryColor,
                              iconColorSelected: AppColors.primaryColor,
                              backgroundColor: isDark
                                  ? const Color(0xFF1F2C34)
                                  : Colors.white,
                            ),
                            bottomActionBarConfig: const BottomActionBarConfig(
                              enabled: false,
                            ),
                            searchViewConfig: SearchViewConfig(
                              backgroundColor: isDark
                                  ? const Color(0xFF1F2C34)
                                  : Colors.white,
                              buttonIconColor: AppColors.primaryColor,
                            ),
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
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                      ),
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
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
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

class _MessageBubbleState extends State<_MessageBubble>
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
        onTap: () {
          // Medya mesajına tıklandığında tam ekran göster
          if (widget.message.type == MessageType.image ||
              widget.message.type == MessageType.video) {
            _showMediaFullScreen(context);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: widget.message.type == MessageType.text
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
              : const EdgeInsets.all(4),
          transform: Matrix4.identity()..scale(_isPressed ? 1.05 : 1.0),
          decoration: BoxDecoration(
            gradient: widget.isMe ? AppColors.primaryGradient : null,
            color: widget.isMe
                ? null
                : (widget.isDark ? Theme.of(context).cardColor : Colors.white),
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: _buildMessageContent(),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.message.text,
          style: TextStyle(
            fontSize: 15,
            color: widget.isMe
                ? Colors.white
                : (widget.isDark ? Colors.white : AppColors.textColor),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        _buildTimeAndStatus(),
      ],
    );
  }

  Widget _buildImageMessage() {
    final mediaUrls = widget.message.mediaUrls ?? [];
    final imageCount = mediaUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageCount == 1
              ? _buildSingleImage(mediaUrls.first)
              : _buildImageGrid(mediaUrls),
        ),
        if (widget.message.text.isNotEmpty &&
            !widget.message.text.startsWith('📷'))
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.message.text,
              style: TextStyle(
                fontSize: 15,
                color: widget.isMe
                    ? Colors.white
                    : (widget.isDark ? Colors.white : AppColors.textColor),
                height: 1.4,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: _buildTimeAndStatus(),
        ),
      ],
    );
  }

  Widget _buildSingleImage(String path) {
    return Stack(
      children: [
        Image.file(
          File(path),
          width: 250,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 250,
            height: 200,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildTimeAndStatus(lightMode: true),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(List<String> urls) {
    final displayCount = urls.length > 4 ? 4 : urls.length;
    final remaining = urls.length - 4;

    return SizedBox(
      width: 250,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: displayCount <= 2 ? displayCount : 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          final isLast = index == 3 && remaining > 0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(urls[index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (isLast)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoMessage() {
    final mediaUrls = widget.message.mediaUrls ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 200,
                color: Colors.black,
                child: mediaUrls.isNotEmpty
                    ? _VideoThumbnail(videoPath: mediaUrls.first)
                    : const Icon(
                        Icons.video_library,
                        color: Colors.white54,
                        size: 50,
                      ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildTimeAndStatus(lightMode: true),
                ),
              ),
            ],
          ),
        ),
        if (widget.message.text.isNotEmpty &&
            !widget.message.text.startsWith('🎬'))
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.message.text,
              style: TextStyle(
                fontSize: 15,
                color: widget.isMe
                    ? Colors.white
                    : (widget.isDark ? Colors.white : AppColors.textColor),
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeAndStatus({bool lightMode = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('HH:mm').format(widget.message.timeSent),
          style: TextStyle(
            fontSize: 11,
            color: lightMode
                ? Colors.white.withOpacity(0.9)
                : (widget.isMe
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.greyColor),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.isMe) ...[
          const SizedBox(width: 4),
          Icon(
            widget.message.isSeen ? Icons.done_all_rounded : Icons.done_rounded,
            size: 16,
            color: lightMode
                ? Colors.white.withOpacity(0.9)
                : (widget.message.isSeen
                      ? Colors.white
                      : Colors.white.withOpacity(0.7)),
          ),
        ],
      ],
    );
  }

  void _showMediaFullScreen(BuildContext context) {
    final mediaUrls = widget.message.mediaUrls ?? [];
    if (mediaUrls.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MediaFullScreenView(
          mediaUrls: mediaUrls,
          isVideo: widget.message.type == MessageType.video,
        ),
      ),
    );
  }
}

// Video Thumbnail Widget
class _VideoThumbnail extends StatefulWidget {
  final String videoPath;

  const _VideoThumbnail({required this.videoPath});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      // Video yüklenemedi
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

// Media Full Screen View
class _MediaFullScreenView extends StatefulWidget {
  final List<String> mediaUrls;
  final bool isVideo;

  const _MediaFullScreenView({required this.mediaUrls, required this.isVideo});

  @override
  State<_MediaFullScreenView> createState() => _MediaFullScreenViewState();
}

class _MediaFullScreenViewState extends State<_MediaFullScreenView> {
  late PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.isVideo && widget.mediaUrls.isNotEmpty) {
      _initVideoPlayer(widget.mediaUrls.first);
    }
  }

  Future<void> _initVideoPlayer(String path) async {
    _videoController = VideoPlayerController.file(File(path));
    await _videoController!.initialize();
    _videoController!.play();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isVideo
              ? 'Video'
              : '${_currentIndex + 1} / ${widget.mediaUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: widget.isVideo ? _buildVideoPlayer() : _buildImageViewer(),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          if (!_videoController!.value.isPlaying)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primaryColor,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.mediaUrls.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.file(
              File(widget.mediaUrls[index]),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 100,
                color: Colors.white54,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Media Preview Sheet
class _MediaPreviewSheet extends StatefulWidget {
  final List<XFile> media;
  final bool isVideo;
  final Function(String caption) onSend;
  final VoidCallback onCancel;

  const _MediaPreviewSheet({
    required this.media,
    required this.isVideo,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<_MediaPreviewSheet> createState() => _MediaPreviewSheetState();
}

class _MediaPreviewSheetState extends State<_MediaPreviewSheet> {
  final TextEditingController _captionController = TextEditingController();
  late PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.isVideo && widget.media.isNotEmpty) {
      _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    _videoController = VideoPlayerController.file(
      File(widget.media.first.path),
    );
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onCancel,
                ),
                Text(
                  widget.isVideo
                      ? 'Video Önizleme'
                      : '${_currentIndex + 1} / ${widget.media.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Media Preview
          Expanded(
            child: widget.isVideo ? _buildVideoPreview() : _buildImagePreview(),
          ),

          // Bottom Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Açıklama ekle...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => widget.onSend(_captionController.text),
                    child: Container(
                      width: 50,
                      height: 50,
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
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
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

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (!_videoController!.value.isPlaying)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.media.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        return Center(
          child: Image.file(
            File(widget.media[index].path),
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
