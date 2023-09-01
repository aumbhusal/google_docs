import 'package:flutter/material.dart';
import 'package:google_docs/screen/document_screen.dart';
import 'package:google_docs/screen/homescreen.dart';
import 'package:google_docs/screen/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomePage()),
  '/document/:id': (route) => MaterialPage(
          child: DocumentScreen(
        id: route.pathParameters['id'] ?? '',
      ),),
});
