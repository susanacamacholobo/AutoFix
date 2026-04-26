import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificacionService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> inicializar() async {
    // Pedir permisos
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificaciones concedidos');
    }

    // Obtener token FCM
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Manejar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida: ${message.notification?.title}');
    });

    // Manejar cuando el usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.notification?.title}');
    });
  }

  Future<String?> obtenerToken() async {
    return await _messaging.getToken();
  }
}