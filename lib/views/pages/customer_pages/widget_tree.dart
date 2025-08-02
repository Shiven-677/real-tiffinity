import 'package:flutter/material.dart';
import 'package:practise/data/constants.dart';
import 'package:practise/data/notifiers.dart';
import 'package:practise/views/pages/customer_pages/home_page.dart';
import 'package:practise/views/pages/customer_pages/profile_page.dart';
import 'package:practise/views/pages/customer_pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/navbar_widget.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [HomePage(), ProfilePage()];
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: Text("Tiffinity", style: TextStyle(fontSize: 29)), //title

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () async {
              isDarkModeNotifier.value =
                  !isDarkModeNotifier.value; //toggle dark mode
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool(
                KConstants.themeModeKey,
                isDarkModeNotifier.value,
              );
            }, //action button
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode);
              },
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage(
                      title: 'Settingsss',
                    ); //navigate to settings page
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),

      //bottom navigation bar
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
