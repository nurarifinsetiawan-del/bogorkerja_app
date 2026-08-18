import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../models/taxonomy_model.dart';
import '../../../widgets/common/company_initials_avatar.dart';

class CompanyGrid extends StatelessWidget {
  final List companies;
  final void Function(CompanyModel company) onTap;

  const CompanyGrid({
    super.key,
    required this.companies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: companies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final company = companies[index];

          return InkWell(
            onTap: () => onTap(company),
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CompanyLogo(
                    logoUrl: company.logoUrl,
                    companyName: company.name,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  company.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CompanyLogo extends StatelessWidget {
  final String? logoUrl;
  final String companyName;

  const CompanyLogo({
    super.key,
    required this.logoUrl,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final value = logoUrl?.trim() ?? '';
    final fallback = CompanyInitialsAvatar(name: companyName, size: 56);

    // Tidak ada logo
    if (value.isEmpty) {
      return fallback;
    }

    // ============================================================
    // 1. BASE64 DATA URI
    // Contoh:
    // data:image/jpeg;base64,/9j/4AAQSk...
    // ============================================================
    if (value.startsWith('data:image/')) {
      try {
        final commaIndex = value.indexOf(',');

        if (commaIndex != -1) {
          final base64Data = value.substring(commaIndex + 1);
          final Uint8List bytes = base64Decode(base64Data);

          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );
        }
      } catch (_) {
        return fallback;
      }
    }

    // ============================================================
    // 2. URL RELATIF
    // Contoh:
    // /uploads/company/logo.webp
    // ============================================================
    String finalUrl = value;

    if (value.startsWith('/')) {
      finalUrl = '${ApiConstants.baseUrl}$value';
    }

    // ============================================================
    // 3. URL NORMAL
    // https://bogorkerja.id/uploads/...
    // ============================================================
    return CachedNetworkImage(
      imageUrl: finalUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) {
        return const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorWidget: (context, url, error) => fallback,
    );
  }
}
