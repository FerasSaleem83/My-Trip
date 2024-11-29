import 'package:flutter/material.dart';

class StyleAppBarMyTrip extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actionBar;
  const StyleAppBarMyTrip({Key? key, required this.title, this.actionBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(255, 38, 35, 35),
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      actions: actionBar != null ? [actionBar!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class StyleAppBarKhdamati extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final Widget? actionBar;
  final PreferredSize? bottom;
  const StyleAppBarKhdamati(
      {Key? key, required this.title, this.actionBar, this.bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: title,
      backgroundColor: const Color.fromARGB(255, 38, 35, 35),
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      actions: actionBar != null ? [actionBar!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class StyleAppBarTawselti extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final Widget? actionBar;
  const StyleAppBarTawselti({Key? key, required this.title, this.actionBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: title,
      backgroundColor: const Color.fromARGB(255, 1, 64, 7),
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      actions: actionBar != null ? [actionBar!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
