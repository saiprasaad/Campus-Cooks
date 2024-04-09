import 'package:flutter/material.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class VerticalCardPagerDemo extends StatefulWidget {
  const VerticalCardPagerDemo({super.key});

  @override
  _VerticalCardPagerDemoState createState() => _VerticalCardPagerDemoState();
}

class _VerticalCardPagerDemoState extends State<VerticalCardPagerDemo> {
  final List<String> titles = [
    "A",
    "C",
    "C",
    "C",
    "C",
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> images = [
      Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text("Hello"),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vertical Card Pager',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body:  Container(
            child: VerticalCardPager(
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              titles: titles,
              images: images,
              onPageChanged: (page) {},
              align: ALIGN.CENTER,
              onSelectedItem: (index) {},
            ),
          ),
        );
  }
}