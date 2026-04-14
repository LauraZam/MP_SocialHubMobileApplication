import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const MainPage({super.key, this.name = '', this.email = '', this.phone = ''});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  String _fetchedPhone = "Loading. . . ";

  @override
  void initState() {
    super.initState();
    if (widget.phone.isEmpty) {
      _fetchUserData();
    } else {
      _fetchedPhone = widget.phone;
    }
  }

  Future<void> _fetchUserData() async {
    const url = 'https://myflutterproject-9958d-default-rtdb.asia-southeast1.firebasedatabase.app/user.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return;

        final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
        
        data.forEach((key, value) {
          if (value['Email'] == currentUserEmail) {
            if (mounted) {
              setState(() {
                _fetchedPhone = value['phone'] ?? "Not set"; 
              });
            }
          }
        });
      } else {
        if (mounted) setState(() => _fetchedPhone = "Not set");
      }
    } catch (e) {
      if (mounted) setState(() => _fetchedPhone = "Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final String displayName = widget.name.isEmpty
        ? (user?.email?.split('@')[0] ?? "User")
        : widget.name;
    final String displayEmail = widget.email.isEmpty
        ? (user?.email ?? "No Email")
        : widget.email;

    final List<Widget> pages = [
      const HomePage(title: 'Home'),
      const ProfilePage(),
      UserSettingsPage(
        name: displayName,
        email: displayEmail,
        phone: _fetchedPhone,
      ),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("App"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: pages[currentPageIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: currentPageIndex == 0
                  ? Lottie.asset('assets/lottie/home.json', width: 30, height: 30)
                  : const Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: currentPageIndex == 1
                  ? Lottie.asset('assets/lottie/profile.json', width: 30, height: 30)
                  : const Icon(Icons.person),
              label: 'User',
            ),
            NavigationDestination(
              icon: currentPageIndex == 2
                  ? Lottie.asset('assets/lottie/user.json', width: 30, height: 30)
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class UserSettingsPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const UserSettingsPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $name!",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text("Name: $name", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text("Email: $email", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text("Phone: $phone", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Center(
            child: Lottie.asset(
              'assets/lottie/cat.json',
              height: 200.0,
              repeat: true,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }
}