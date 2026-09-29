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
    return BlocProvider(
      create: (context) => getIt<CatalogCubit>()..fetchCategories(),
      child: const ResponsiveLayout(
        mobile: CategoriesMobileView(),
        desktop: CatalogWebView(), // Unified web view, no initial category selected
      ),
    );
  }
}
