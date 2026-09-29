import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

/// Centralized Icon definition class using the Iconly package.
/// This ensures consistent iconography across the application.
class AppIcons {
  AppIcons._();

  // Navigation Items
  static const IconData homeOutline = IconlyLight.home;
  static const IconData homeBold = IconlyBold.home;
  static const IconData categoryOutline = IconlyLight.category;
  static const IconData categoryBold = IconlyBold.category;
  static const IconData bagOutline = IconlyLight.buy; // Iconly uses buy for cart/shopping bag
  static const IconData bagBold = IconlyBold.buy;
  static const IconData profileOutline = IconlyLight.profile;
  static const IconData profileBold = IconlyBold.profile;
  
  // General & Actions
  static const IconData search = IconlyLight.search;
  static const IconData notification = IconlyLight.notification;
  static const IconData notificationBold = IconlyBold.notification;
  static const IconData location = IconlyLight.location;
  static const IconData locationBold = IconlyBold.location;
  static const IconData filter = IconlyLight.filter;
  static const IconData heartOutline = IconlyLight.heart;
  static const IconData heartBold = IconlyBold.heart;
  static const IconData calendar = IconlyLight.calendar;
  static const IconData shield = IconlyLight.shield_done;
  static const IconData lock = IconlyLight.lock;
  static const IconData email = IconlyLight.message;
  static const IconData show = IconlyLight.show;
  static const IconData hide = IconlyLight.hide;
  static const IconData arrowLeft = IconlyLight.arrow_left_2;
  static const IconData arrowRight = IconlyLight.arrow_right_2;
  static const IconData arrowDown = IconlyLight.arrow_down_2;
  static const IconData image = IconlyLight.image;
  static const IconData close = IconlyLight.close_square;
  
  // New Icons for Web & General
  static const IconData documentOutline = IconlyLight.document;
  static const IconData documentBold = IconlyBold.document;
  static const IconData camera = IconlyLight.camera;
  static const IconData chat = IconlyLight.chat;
  static const IconData message = IconlyLight.message;
  static const IconData globe = Icons.public; // Using Material for Globe
}
