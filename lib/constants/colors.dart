import 'package:flutter/material.dart';

// Modern WhatsApp 2024 renk şeması
class AppColors {
  // Ana renkler - Yeni WhatsApp yeşili
  static const Color primaryColor = Color(0xFF00A884); // Modern yeşil
  static const Color secondaryColor = Color(0xFF25D366); // Açık yeşil
  static const Color accentColor = Color(0xFF06CF9C); // Parlak yeşil
  
  // Arka plan renkleri - Minimal
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color chatBackgroundColor = Color(0xFFEFEFEF);
  static const Color cardBackground = Colors.white;
  
  // Mesaj balonu renkleri - Modern
  static const Color senderMessageColor = Color(0xFF00A884); // Yeşil balon
  static const Color receiverMessageColor = Color(0xFFFFFFFF); // Beyaz balon
  
  // Metin renkleri
  static const Color textColor = Color(0xFF111B21);
  static const Color textColorLight = Color(0xFF667781);
  static const Color textColorWhite = Colors.white;
  static const Color textColorGreen = Color(0xFF00A884);
  
  // Diğer renkler
  static const Color dividerColor = Color(0xFFE9EDEF);
  static const Color iconColor = Color(0xFF54656F);
  static const Color onlineColor = Color(0xFF25D366);
  static const Color greyColor = Color(0xFF8696A0);
  
  // Gradient renkler
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00A884), Color(0xFF06CF9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark mode renkleri
  static const Color darkBackground = Color(0xFF0B141A);
  static const Color darkCardBackground = Color(0xFF1F2C34);
  static const Color darkSenderMessage = Color(0xFF005C4B);
  static const Color darkReceiverMessage = Color(0xFF202C33);
}
