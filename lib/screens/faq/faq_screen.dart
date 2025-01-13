import 'package:flutter/material.dart';
import '../../widgets/layout/base_layout.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseLayout(
      title: 'FAQ',
      child: Center(
        child: Text('FAQ Screen'),
      ),
    );
  }
}
