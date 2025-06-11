// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search/search_page.dart';
import 'favorites_page.dart';
import 'AccountPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);
  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),      // notre SearchPage refondue
    FavoritesPage(),
    AccountPage(),
  ];
  void onTab(int i) => setState(() => _selectedIndex = i);
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, 'Explorer','Explorer'),
            _navItem(1, 'Rechercher','rechercher'),
            _navItem(2, 'Favoris','favoris'),
            _navItem(3, 'Compte','compte'),
          ],
        )
      ),
    );
  }
  Widget _navItem(int idx, String label, String asset) {
    final sel = _selectedIndex==idx;
    return GestureDetector(
      onTap: ()=>onTab(idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Image.asset(
            sel
              ? 'assets/navigation-tools/${asset}_black.png'
              : 'assets/navigation-tools/$asset.png',
            width:28, height:28,
          ),
          Text(label, style: TextStyle(
            fontSize:12,
            fontWeight:sel?FontWeight.bold:FontWeight.normal
          )),
        ]
      )
    );
  }
}
