import 'package:flutter/material.dart';

/// Centralized themed scaffold with dashboard mode support.
///
/// When [isOnDashboard] is `true` (default), the [appBar] is omitted (`null`).
/// When [isOnDashboard] is `false`, [appBar] is used if provided, or a themed
/// [AppBar] is built from [title], [actions], and [leading].
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.isOnDashboard = true,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.centerTitle = true,
  });

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool isOnDashboard;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;
  final bool centerTitle;

  PreferredSizeWidget? _resolveAppBar() {
    if (isOnDashboard) {
      return null;
    }
    if (appBar != null) {
      return appBar;
    }

    Widget? titleWidget;
    if (title != null) {
      titleWidget = Text(title!);
    }

    return AppBar(
      title: titleWidget,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (useSafeArea) {
      content = SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _resolveAppBar(),
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
