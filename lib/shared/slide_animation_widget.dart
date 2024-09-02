import 'package:flutter/material.dart';

class SlideAnimationWidget extends StatefulWidget {
  final Widget chatPage;
  final Widget nonChatPage;
  final ValueNotifier<bool> isShowingChatPage;
  final Duration duration;

  final VoidCallback? onReturnToMenuCompleted;

  const SlideAnimationWidget({
    Key? key,
    required this.chatPage,
    required this.nonChatPage,
    required this.isShowingChatPage,
    required this.onReturnToMenuCompleted,
    this.duration = const Duration(milliseconds: 280),
  }) : super(key: key);

  @override
  _SlideAnimationWidgetState createState() => _SlideAnimationWidgetState();
}

class _SlideAnimationWidgetState extends State<SlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _chatPageSlideAnimation;
  late Animation<Offset> _nonChatPageSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _initializeAnimations();

    // Do not start the animation on initialization
    print("initializing slide animation");
    if (widget.isShowingChatPage.value) {
      _controller.value = 1.0; // Set the initial state to fully shown
    } else {
      _controller.value = 0.0; // Set the initial state to fully hidden
    }

    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        // if (widget.onSlideAnimationCompleted != null) {
        //   if (!widget.isShowingChatPage.value) {
        //     print("completed");
        //     widget.onSlideAnimationCompleted!();
        //   }
        // }
      }
    });
  }

  void _initializeAnimations() {
    _chatPageSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _nonChatPageSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.isShowingChatPage.value) {
      // Adjust the controller value directly during the drag
      _controller.value -= details.primaryDelta! / context.size!.width;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.isShowingChatPage.value) {
      // Continue the animation based on the drag velocity
      if (details.primaryVelocity! > 0) {
        _controller.reverse();

        // widget.isShowingChatPage.value = false;
        if (widget.onReturnToMenuCompleted != null) {
          widget.onReturnToMenuCompleted!();
        }
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isShowingChatPage,
      builder: (context, isShowingChatPage, child) {
        // Trigger the animation based on the value change
        if (isShowingChatPage) {
          _controller.forward();
        } else {
          _controller.reverse();
        }

        return GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Stack(
            children: [
              SlideTransition(
                position: _nonChatPageSlideAnimation,
                child: widget.nonChatPage,
              ),
              SlideTransition(
                position: _chatPageSlideAnimation,
                child: widget.chatPage,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
