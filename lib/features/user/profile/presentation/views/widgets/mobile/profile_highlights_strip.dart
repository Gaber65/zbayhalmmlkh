import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/domain/entities/profile.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/jabin_highlight_widget.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/highlight_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/highlight_state.dart';
import '../../highlight_editor_screen.dart';

class ProfileHighlightsStrip extends StatelessWidget {
  final UserProfile profile;

  const ProfileHighlightsStrip({super.key, required this.profile});

  void _pickMedia(BuildContext context, HighlightCubit cubit) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.image_rounded, color: Colors.blue),
                ),
                title: Text(
                  isAr ? 'اختيار صورة من المعرض' : 'Select Image from Gallery',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null && context.mounted) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: HighlightEditorScreen(
                            filePath: image.path,
                            mediaType: 'image',
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Colors.purple),
                ),
                title: Text(
                  isAr ? 'اختيار فيديو من المعرض' : 'Select Video from Gallery',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final video = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (video != null && context.mounted) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: HighlightEditorScreen(
                            filePath: video.path,
                            mediaType: 'video',
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openViewer(
    BuildContext context,
    List<HighlightEntity> highlights,
    int initialIndex,
  ) {
    final highlightGroup = JabinHighlightEntity(
      user: HighlightUser(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
      ),
      highlights: highlights,
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
          return FullStoryViewerModal(
            highlightsGroup: [highlightGroup],
            initialGroupIndex: 0,
            onUserStoryViewed: (_) {},
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<HighlightCubit>();

    return BlocConsumer<HighlightCubit, HighlightState>(
      listener: (context, state) {
        if (state is HighlightError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        List<HighlightEntity> highlights = [];
        bool isUploading = state is HighlightUploading;

        if (state is HighlightLoaded) highlights = state.highlights;
        if (state is HighlightUploadSuccess) highlights = state.highlights;
        if (state is HighlightDeleteSuccess) highlights = state.highlights;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. "Add New" button
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: GestureDetector(
                      onTap: () =>
                          isUploading ? null : _pickMedia(context, cubit),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                                width: 1,
                              ),
                              color: colorScheme.surface,
                            ),
                            child: isUploading
                                ? Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.add_rounded,
                                    size: 32,
                                    color: colorScheme.onSurface,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 65,
                            child: Text(
                              isAr ? 'جديد' : 'New',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Single "Highlights" group
                  if (highlights.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: GestureDetector(
                        onTap: () => _openViewer(context, highlights, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: highlights
                                        .last
                                        .mediaUrl, // Show latest media as cover
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.broken_image_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 65,
                              child: Text(
                                isAr ? 'القصص' : 'Highlights',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
