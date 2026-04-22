import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/api/api_cubit.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("daily_wisdom".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => context.read<ApiCubit>().fetchExploreData(),
          ),
        ],
      ),
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          if (state is ApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApiError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ApiLoaded) {
            _controller.forward();

            final quoteOfDay = state.quotes.isNotEmpty
                ? state.quotes.first
                : null;
            final otherQuotes = state.quotes.skip(1).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (quoteOfDay != null) ...[
                  _animatedWidget(
                    index: 0,
                    child: _buildQuoteOfDayBanner(quoteOfDay),
                  ),
                  const SizedBox(height: 24),
                  _animatedWidget(
                    index: 1,
                    child: Text(
                      "more_inspirations".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.divider),
                ],

                ...List.generate(otherQuotes.length, (index) {
                  final quote = otherQuotes[index];
                  return _animatedWidget(
                    index: index + 2,
                    child: Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          child: Lottie.asset('assets/lottie/quote_card.json'),
                        ),
                        title: Text(
                          quote.text,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          quote.author,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<ApiCubit>().fetchExploreData(),
              child: Text("explore_quotes".tr()),
            ),
          );
        },
      ),
    );
  }

  Widget _animatedWidget({required int index, required Widget child}) {
    final animationInterval = Interval(
      (index * 0.1).clamp(0.0, 1.0),
      ((index * 0.1) + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = CurvedAnimation(
          parent: _controller,
          curve: animationInterval,
        ).value;
        final slide =
            Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: animationInterval,
                  ),
                )
                .value;

        return Opacity(
          opacity: opacity,
          child: FractionalTranslation(translation: slide, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildQuoteOfDayBanner(dynamic quote) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentLime],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          const SizedBox(height: 16),
          Text(
            "\"${quote.text}\"",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "— ${quote.author.toUpperCase()}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.read<ApiCubit>().fetchExploreData(),
            child: Text("retry".tr()),
          ),
        ],
      ),
    );
  }
}
