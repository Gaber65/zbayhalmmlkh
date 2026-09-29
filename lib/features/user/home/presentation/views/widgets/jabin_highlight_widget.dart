import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../domain/entities/home_data.dart';

class JabinHighlightWidget extends StatefulWidget {
  final List<JabinHighlightEntity> highlights;

  const JabinHighlightWidget({super.key, required this.highlights});

  @override
  State<JabinHighlightWidget> createState() => _JabinHighlightWidgetState();
}

class _JabinHighlightWidgetState extends State<JabinHighlightWidget> {
  // Track viewed stories by user ID for visual indicator state
  final Set<int> _viewedUserIds = {};

  void _openStoryViewer(BuildContext context, int initialIndex) {
    if (widget.highlights.isEmpty) return;

    setState(() {
      _viewedUserIds.add(widget.highlights[initialIndex].user.id);
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, _) {
          return FullStoryViewerModal(
            highlightsGroup: widget.highlights,
            initialGroupIndex: initialIndex,
            onUserStoryViewed: (userId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _viewedUserIds.add(userId);
                  });
                }
              });
            },
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
    if (widget.highlights.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 114,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.highlights.length,
            itemBuilder: (context, index) {
              final group = widget.highlights[index];
              final isViewed = _viewedUserIds.contains(group.user.id);

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: GestureDetector(
                  onTap: () => _openStoryViewer(context, index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gradient Animated Ring Avatar Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isViewed
                              ? LinearGradient(
                                  colors: [
                                    colorScheme.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                    colorScheme.outlineVariant.withValues(
                                      alpha: 0.3,
                                    ),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    const Color(
                                      0xFFFF9E00,
                                    ), // Premium Amber/Gold accent
                                    colorScheme.tertiary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: isViewed
                              ? []
                              : [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            child: ClipOval(
                              child: group.user.avatarUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: group.user.avatarUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        child: Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.person_rounded,
                                            color: colorScheme.onSurfaceVariant,
                                            size: 28,
                                          ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // User Name label
                      SizedBox(
                        width: 74,
                        child: Text(
                          group.user.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: isViewed
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: isViewed
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Full-Screen Senior Interactive Story Viewer Modal
class FullStoryViewerModal extends StatefulWidget {
  final List<JabinHighlightEntity> highlightsGroup;
  final int initialGroupIndex;
  final ValueChanged<int> onUserStoryViewed;

  const FullStoryViewerModal({
    super.key,
    required this.highlightsGroup,
    required this.initialGroupIndex,
    required this.onUserStoryViewed,
  });

  @override
  State<FullStoryViewerModal> createState() => FullStoryViewerModalState();
}

class FullStoryViewerModalState extends State<FullStoryViewerModal>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentGroupIndex;
  int _currentStoryIndex = 0;

  AnimationController? _animController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: _currentGroupIndex);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _startStory();
  }

  void _startStory() {
    widget.onUserStoryViewed(
      widget.highlightsGroup[_currentGroupIndex].user.id,
    );
    _animController?.stop();
    _animController?.reset();
    _animController?.forward();
  }

  void _nextStory() {
    final currentHighlights =
        widget.highlightsGroup[_currentGroupIndex].highlights;

    if (_currentStoryIndex < currentHighlights.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _startStory();
    } else {
      // Move to next user highlight group if available
      if (_currentGroupIndex < widget.highlightsGroup.length - 1) {
        setState(() {
          _currentGroupIndex++;
          _currentStoryIndex = 0;
        });
        _pageController.animateToPage(
          _currentGroupIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
        _startStory();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStory();
    } else if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
        final prevHighlights =
            widget.highlightsGroup[_currentGroupIndex].highlights;
        _currentStoryIndex = prevHighlights.isNotEmpty
            ? prevHighlights.length - 1
            : 0;
      });
      _pageController.animateToPage(
        _currentGroupIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      _startStory();
    } else {
      _startStory();
    }
  }

  void _pauseStory() {
    if (!_isPaused) {
      _animController?.stop();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      _animController?.forward();
      setState(() {
        _isPaused = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPressStart: (_) => _pauseStory(),
          onLongPressEnd: (_) => _resumeStory(),
          child: Stack(
            children: [
              // Page View for User Groups
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.highlightsGroup.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentGroupIndex = index;
                    _currentStoryIndex = 0;
                  });
                  _startStory();
                },
                itemBuilder: (context, groupIndex) {
                  final group = widget.highlightsGroup[groupIndex];
                  if (group.highlights.isEmpty) {
                    return Center(
                      child: Text(
                        S.of(context).no_media_available,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final currentHighlight =
                      group.highlights[_currentStoryIndex.clamp(
                        0,
                        group.highlights.length - 1,
                      )];

                  final isVideo =
                      currentHighlight.mediaType.toLowerCase() == 'video' ||
                      currentHighlight.mediaUrl.toLowerCase().contains('/video') ||
                      currentHighlight.mediaUrl.toLowerCase().endsWith('.mp4');

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Media Background Content (Image or Real Video Player)
                      if (isVideo)
                        _StoryVideoPlayer(
                          videoUrl: currentHighlight.mediaUrl,
                          onVideoFinished: _nextStory,
                        )
                      else
                        CachedNetworkImage(
                          imageUrl: currentHighlight.mediaUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  S.of(context).unable_load_highlight,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Story Title overlay at bottom
                      if (currentHighlight.name.isNotEmpty)
                        Positioned(
                          bottom: 40,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              currentHighlight.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Touch Controls (Tap Left / Tap Right)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _previousStory,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _nextStory,
                      ),
                    ),
                  ],
                ),
              ),

              // Top Bar Header & Progress Bars
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(
                        widget
                            .highlightsGroup[_currentGroupIndex]
                            .highlights
                            .length,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: _buildProgressBar(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // User Profile Bar & Close Button
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              widget
                                  .highlightsGroup[_currentGroupIndex]
                                  .user
                                  .avatarUrl
                                  .isNotEmpty
                              ? CachedNetworkImageProvider(
                                  widget
                                      .highlightsGroup[_currentGroupIndex]
                                      .user
                                      .avatarUrl,
                                )
                              : null,
                          child:
                              widget
                                  .highlightsGroup[_currentGroupIndex]
                                  .user
                                  .avatarUrl
                                  .isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget
                                    .highlightsGroup[_currentGroupIndex]
                                    .user
                                    .name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    if (index < _currentStoryIndex) {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (index == _currentStoryIndex) {
      return AnimatedBuilder(
        animation: _animController!,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _animController!.value,
            backgroundColor: Colors.white.withValues(alpha: 0.35),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 3,
          );
        },
      );
    } else {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }
}

class _StoryVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onVideoFinished;

  const _StoryVideoPlayer({
    required this.videoUrl,
    required this.onVideoFinished,
  });

  @override
  State<_StoryVideoPlayer> createState() => _StoryVideoPlayerState();
}

class _StoryVideoPlayerState extends State<_StoryVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller?.play();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

    _controller?.addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        _controller!.value.position >= _controller!.value.duration &&
        !_controller!.value.isPlaying) {
      widget.onVideoFinished();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_camera_back_rounded, color: Colors.white54, size: 50),
            const SizedBox(height: 12),
            Text(
              S.of(context).unable_play_video,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

