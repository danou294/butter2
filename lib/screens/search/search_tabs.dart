import 'package:flutter/material.dart';

const _primaryColor = Colors.black;
const _secondaryColor = Colors.black;
const _indicatorColor = Colors.black;
const _fontFamilySans = 'InriaSans';

class SearchTabs extends StatelessWidget {
  const SearchTabs({
    Key? key,
    required this.controller,
    required this.sections,
  }) : super(key: key);

  final TabController controller;
  final List<String> sections;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _indicatorColor, width: 4),
          insets: EdgeInsets.symmetric(horizontal: 20),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: _primaryColor,
        unselectedLabelColor: _secondaryColor,
        labelStyle: const TextStyle(
          fontFamily: _fontFamilySans,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamilySans,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        tabs: sections.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
