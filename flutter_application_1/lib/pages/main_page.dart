import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/theme/theme_cubit.dart';
import 'package:flutter_application_1/pages/create_post_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/post/post_cubit.dart';
import 'home_page.dart';
import 'explore.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthSuccess) {
          context.read<PostCubit>().fetchPosts();
          final String displayName = state.name.isEmpty
              ? (state.email.split('@')[0])
              : state.name;

          final List<Widget> pages = [
            HomePage(),
            const CreatePostPage(),
            const ExploreScreen(),
            UserSettingsPage(
              name: displayName,
              email: state.email,
              phone: state.phone.isEmpty ? "not_set".tr() : state.phone,
              userId: state.uid,
            ),
          ];

          return Scaffold(
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => currentPageIndex = index);
              },
              children: pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
              destinations: [
                _navItem(0, 'assets/lottie/home.json', Icons.home, "home".tr()),
                _navItem(1, 'assets/lottie/profile.json', Icons.post_add, "create_post".tr()),
                _navItem(2, 'assets/lottie/quote.json', Icons.explore, "explore".tr()),
                _navItem(3, 'assets/lottie/user.json', Icons.person, "profile".tr()),
              ],
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: Text((state is AuthFailure) ? state.error : "unknown_error".tr()),
          ),
        );
      },
    );
  }

  NavigationDestination _navItem(int index, String lottiePath, IconData fallback, String label) {
    return NavigationDestination(
      icon: currentPageIndex == index
          ? Lottie.asset(lottiePath, width: 30, height: 30)
          : Icon(fallback),
      label: label,
    );
  }
}

class UserSettingsPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String userId;

  const UserSettingsPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.userId,
  });

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPhone(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return rawPhone;
    return "${digits[0]} (${digits.substring(1, 4)})-${digits.substring(4, 7)}-${digits.substring(7)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildInfoCard(),
                const SizedBox(height: 24),
                Text("lang_pref".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildLanguageChips(),
                const SizedBox(height: 32),
                Text("my_activity".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildPostsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            "account_overview".tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Text(
              widget.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _infoRow(Icons.person, "name".tr(), widget.name, onEdit: () => _showEditNameDialog(context)),
            const Divider(height: 24),
            _infoRow(Icons.email, "email".tr(), widget.email),
            const Divider(height: 24),
            _infoRow(Icons.phone, "phone".tr(), widget.phone == "Not set" ? widget.phone : _formatPhone(widget.phone)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChips() {
    return Row(
      children: ['en', 'kk', 'ru'].map((lang) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ActionChip(
          label: Text(lang.toUpperCase()),
          onPressed: () => context.setLocale(Locale(lang)),
        ),
      )).toList(),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoaded) {
          final myPosts = state.posts.where((p) => p.userId == widget.userId).toList();
          if (myPosts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text("no_posts_user".tr()),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myPosts.length,
            itemBuilder: (context, index) {
              final post = myPosts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(post.content),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(post.createdAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, post.postId),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {VoidCallback? onEdit}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.lime.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.lime, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blueGrey), onPressed: onEdit),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("change_name".tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "your_name_label".tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthBloc>().add(
                  UpdateNameEvent(controller.text.trim()),
                );
                Navigator.pop(context);
              }
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_post_title".tr()),
        content: Text("delete_post_msg".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCubit>().removePost(postId);
              Navigator.pop(context);
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
  
