import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studymate/features/auth/presentation/cubits/auth_cubits.dart';
import '../bottom_nav_bar/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreenPage extends StatefulWidget {
  const MainScreenPage({super.key});
  @override
  State<MainScreenPage> createState() => _MainScreenPage();
}

class _MainScreenPage extends State<MainScreenPage> {
  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.uid ?? "Guest User";
    String email = user?.email ?? "guest@example.com";

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 105,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(name),
                accountEmail: Text(email),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                // update bottom nav
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_box),
              title: Text("To-Do"),
              onTap: () {
                // _selectedIndex = 1;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.note),
              title: Text("Notes"),
              onTap: () {
                // _selectedIndex = 2;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text("ChatBot"),
              onTap: () {
                // _selectedIndex = 3;
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),

      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.account_circle_outlined, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('StudyMate'),
        actions: [
          IconButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(children: [
        ],
      ),
      bottomNavigationBar: Mybottomnavbar(),
    );
  }
}
