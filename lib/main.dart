import 'package:butterflies/components/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDWKZd29xncdLubNCQHeqPtTzvlzSG3LWU",
          authDomain: "butterflies-7fea8.firebaseapp.com",
          projectId: "butterflies-7fea8",
          storageBucket: "butterflies-7fea8.appspot.com",
          messagingSenderId: "537373805092",
          appId: "1:537373805092:web:e84b80d3ed8f7f2f8266b1"));
  runApp(const MyApp());
}
