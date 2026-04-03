import 'package:flutter/material.dart';
import '../../../../core/widgets/section_placeholder.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholder(
      title: 'Отзывы',
      description: 'Здесь будет список отзывов и управление своими отзывами.',
      icon: Icons.reviews,
    );
  }
}