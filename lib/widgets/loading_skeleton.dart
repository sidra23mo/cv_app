// lib/widgets/shared/loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ResumeCardSkeleton extends StatelessWidget {
  const ResumeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Container(
                height: 16,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Container(
                height: 20,
                width: 80,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                height: 12,
                width: 100,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormFieldSkeleton extends StatelessWidget {
  const FormFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}