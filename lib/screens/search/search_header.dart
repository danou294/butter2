import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * .20;
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background-liste.png', fit: BoxFit.cover),
          Positioned(
            bottom: 10, left: 10,
            child: Image.asset(
              'assets/images/LogoName.png',
              width: MediaQuery.of(context).size.width * .23,
              height: h * .8,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
