import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import '../../domain/entities/category.dart';
import '../manager/catalog_cubit.dart';

import 'widgets/mobile/products_by_category_mobile_view.dart';
import 'widgets/web/catalog_web_view.dart';

class ProductsByCategoryScreen extends StatelessWidget {
  final Category category;

  const ProductsByCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CatalogCubit>()..fetchProductsByCategory(category.id),
      child: ResponsiveLayout(
        mobile: ProductsByCategoryMobileView(category: category),
        desktop: CatalogWebView(initialCategory: category),
      ),
    );
  }
}
