import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JobCardShimmer extends StatelessWidget {
  final bool horizontal;
  const JobCardShimmer({super.key, this.horizontal = false});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: horizontal ? 260 : double.infinity,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 44, height: 44, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 120, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 10, width: 150, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 20, width: 90, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
