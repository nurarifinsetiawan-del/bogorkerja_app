import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class JobDescriptionSection extends StatelessWidget {
  final String description;
  final String? requirementsHtml;

  const JobDescriptionSection({
    super.key,
    required this.description,
    this.requirementsHtml,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bodyColor = theme.textTheme.bodyLarge?.color;

    final htmlStyle = {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(16),
        color: bodyColor,
        lineHeight: const LineHeight(1.5),
      ),
      'p': Style(
        margin: Margins.only(bottom: 10),
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
      ),
      'h3': Style(
        fontSize: FontSize(18),
        fontWeight: FontWeight.w600,
        margin: Margins.only(
          top: 18,
          bottom: 8,
        ),
      ),
      'ul': Style(
        margin: Margins.only(
          top: 4,
          bottom: 8,
        ),
        padding: HtmlPaddings.only(left: 20),
      ),
      'ol': Style(
        margin: Margins.only(
          top: 4,
          bottom: 8,
        ),
        padding: HtmlPaddings.only(left: 20),
      ),
      'li': Style(
        margin: Margins.only(bottom: 6),
        fontSize: FontSize(16),
        lineHeight: const LineHeight(1.5),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Lowongan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Ringkasan menggunakan ukuran font yang sama
        // dengan isi Deskripsi dan Persyaratan.
        Html(
  data: description,
  style: {
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(16),
      color: bodyColor,
      lineHeight: const LineHeight(1.5),
    ),
    'p': Style(
      margin: Margins.only(bottom: 10),
    ),
    'strong': Style(
      fontWeight: FontWeight.bold,
    ),
  },
),

        if (requirementsHtml != null &&
            requirementsHtml!.trim().isNotEmpty) ...[
          const SizedBox(height: 24),

          Html(
            data: requirementsHtml!,
            style: htmlStyle,
          ),
        ],
      ],
    );
  }
}
