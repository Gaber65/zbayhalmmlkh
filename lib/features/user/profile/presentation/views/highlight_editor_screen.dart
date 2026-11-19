import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import '../manager/highlight_cubit.dart';
import '../manager/highlight_state.dart';

class HighlightEditorScreen extends StatefulWidget {
  final String filePath;
  final String mediaType;

  const HighlightEditorScreen({
    super.key,
    required this.filePath,
    required this.mediaType,
  });

  @override
  State<HighlightEditorScreen> createState() => _HighlightEditorScreenState();
}

class _HighlightEditorScreenState extends State<HighlightEditorScreen> {
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          _videoController?.setLooping(true);
          _videoController?.play();
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _shareToStory() {
    context.read<HighlightCubit>().uploadHighlight(
          filePath: widget.filePath,
          mediaType: widget.mediaType,
          name: _captionController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HighlightCubit, HighlightState>(
      listener: (context, state) {
        if (state is HighlightUploadSuccess) {
          Navigator.of(context).pop(); // Go back after successful upload
        } else if (state is HighlightError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Media Preview
            Positioned.fill(
              child: widget.mediaType == 'video'
                  ? (_videoController != null && _videoController!.value.isInitialized)
                      ? Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Image.file(
                      File(widget.filePath),
                      fit: BoxFit.contain,
                    ),
            ),
            
            // Top Controls (Back Button)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Bottom Controls (Caption & Share)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Caption Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _captionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: Localizations.localeOf(context).languageCode == 'ar'
                                ? 'أضف وصفاً للقصة...'
                                : 'Add a caption...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Share Button
                    BlocBuilder<HighlightCubit, HighlightState>(
                      builder: (context, state) {
                        final isLoading = state is HighlightUploading;
                        final isAr = Localizations.localeOf(context).languageCode == 'ar';
                        return GestureDetector(
                          onTap: isLoading ? null : _shareToStory,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          isAr ? 'نشر' : 'Share',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.send, color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
