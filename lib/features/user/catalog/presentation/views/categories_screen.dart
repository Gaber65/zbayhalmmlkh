import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import '../manager/catalog_cubit.dart';

import 'widgets/mobile/categories_mobile_view.dart';
import 'widgets/web/catalog_web_view.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasCatalogCubit = false;
    try {
      context.read<CatalogCubit>();
      hasCatalogCubit = true;
    } catch (_) {}

    const child = ResponsiveLayout(
      mobile: CategoriesMobileView(),
      desktop: CatalogWebView(), // Unified web view, no initial category selected
    );

    if (hasCatalogCubit) {
      return child;
    }

    return BlocProvider(
      create: (context) => getIt<CatalogCubit>()..fetchCatalog(),
      child: child,
    );
  }
}
