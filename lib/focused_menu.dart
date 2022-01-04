library focused_menu;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'modals.dart';

export 'modals.dart';

const kItemExtent = 45.0;

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final VoidCallback? onPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Open with tap insted of long press.
  final bool openWithTap;

  final bool right;

  /// Whether the item is not visible in the screen, needing to request a
  /// scroll
  final bool Function()? onScrollRequested;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.menuItems,
    this.onScrollRequested,
    this.right = false,
    this.onPressed,
    this.duration,
    this.menuBoxDecoration,
    this.blurSize,
    this.blurBackgroundColor,
    this.menuWidth,
    this.bottomOffsetHeight,
    this.menuOffset,
    this.openWithTap = false,
  }) : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = const Offset(0, 0);
  Size childSize = Size.zero;

  void getOffset(BuildContext context) {
    final renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    childSize = size;
    childOffset = Offset(offset.dx, offset.dy);

    /// If it's offscreen, add a padding of 10.0
    if (childOffset.dy.isNegative) {
      childOffset = Offset(
        childOffset.dx,
        10.0,
      );
    }
  }

  Widget get child => Hero(
        tag: containerKey,
        child: Material(
          type: MaterialType.transparency,
          child: widget.child,
        ),
      );

  double _currentScale = 1.0;
  static const double _pressScale = 0.85;
  static const _animationDuration = Duration(milliseconds: 100);

  Future<void> resetScale([double value = 1.0]) async {
    setState(() => _currentScale = value);
    return Future.delayed(_animationDuration);
  }

  double _visibilityFraction = 0.0;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: containerKey,
      onVisibilityChanged: (visibilityInfo) {
        _visibilityFraction = visibilityInfo.visibleFraction;
      },
      child: GestureDetector(
        onSecondaryTap: () async {
          widget.onPressed?.call();
          await openMenu(context);
        },
        onTapDown: (_) => resetScale(_pressScale),
        onTapUp: (_) {
          resetScale();
          widget.onPressed?.call();
          if (widget.openWithTap) {
            openMenu(context);
          }
        },
        onLongPress: () async {
          if (!widget.openWithTap) {
            await resetScale();
            openMenu(context);
          }
        },
        onLongPressEnd: (_) => resetScale(),
        onTapCancel: () => resetScale(),
        child: AnimatedScale(
          duration: _animationDuration,
          scale: _currentScale,
          child: child,
        ),
      ),
    );
  }

  Future<void> openMenu(BuildContext context) async {
    getOffset(context);

    // debugPrint('widget visible $_visibilityFraction');

    // if (_visibilityFraction < 0.5) {
    //   if (!(widget.onScrollRequested?.call() ?? false)) return;
    // }

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
            widget.duration ?? const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          animation = Tween(begin: 0.0, end: 1.0).animate(animation);
          return _FocusedMenuDetails(
            animation: animation,
            menuBoxDecoration: widget.menuBoxDecoration,
            child: child,
            childOffset: childOffset,
            childSize: childSize,
            menuItems: widget.menuItems,
            blurSize: widget.blurSize,
            menuWidth: widget.menuWidth,
            blurBackgroundColor: widget.blurBackgroundColor,
            bottomOffsetHeight: widget.bottomOffsetHeight ?? 20.0,
            menuOffset: widget.menuOffset ?? 0,
            right: widget.right,
          );
        },
        fullscreenDialog: true,
        opaque: false,
      ),
    );
  }
}

class _FocusedMenuDetails extends StatefulWidget {
  final Animation<double> animation;
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final Size? childSize;
  final Widget child;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double bottomOffsetHeight;
  final double menuOffset;
  final bool right;

  const _FocusedMenuDetails({
    Key? key,
    required this.animation,
    required this.menuItems,
    required this.child,
    required this.childOffset,
    required this.childSize,
    required this.menuBoxDecoration,
    required this.blurSize,
    required this.blurBackgroundColor,
    required this.menuWidth,
    required this.bottomOffsetHeight,
    required this.menuOffset,
    required this.right,
  }) : super(key: key);

  @override
  State<_FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<_FocusedMenuDetails> {
  Animation<double> get _animation => CurvedAnimation(
        parent: widget.animation,
        // curve: Curves.easeInOutBack,
        curve: Curves.linear,
      );
  // .drive(Tween<double>(
  //   begin: 0.83,
  //   end: 1.0,
  // ));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = widget.menuItems.length * kItemExtent;

    final maxMenuWidth = widget.menuWidth ?? 250.0;
    final double menuHeight = listHeight.clamp(0, maxMenuHeight);
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize!.width);
    final double topOffset = (widget.childOffset.dy + widget.childSize!.height)
        .clamp(0, size.height - menuHeight - widget.bottomOffsetHeight);

    return Scaffold(
      backgroundColor:
          (widget.blurBackgroundColor ?? Colors.black).withOpacity(0.3),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: const AbsorbPointer(),
              ),
            ),
            Positioned(
              top: topOffset + (widget.bottomOffsetHeight / 2),
              left: widget.right ? null : leftOffset,
              right: widget.right ? 12.0 : null,
              child: ScaleTransition(
                scale: _animation,
                alignment:
                    widget.right ? Alignment.centerRight : Alignment.centerLeft,
                // sizeFactor: _animation,
                // axisAlignment: 1.0,
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: maxMenuWidth,
                    height: menuHeight,
                    decoration: widget.menuBoxDecoration ??
                        BoxDecoration(
                          color: const Color(0xFFBFC0C2),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Column(
                        children:
                            List.generate(widget.menuItems.length, (index) {
                          final item = widget.menuItems[index];
                          return Container(
                            alignment: Alignment.center,
                            height: kItemExtent,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  style: index == widget.menuItems.length - 1
                                      ? BorderStyle.none
                                      : BorderStyle.solid,
                                  width: 0.33,
                                  color:
                                      const Color(0xFF6F6F6E).withOpacity(0.33),
                                ),
                              ),
                            ),
                            child: item,
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: topOffset - widget.childSize!.height,
              left: widget.childOffset.dx,
              child: IgnorePointer(
                child: SizedBox(
                  width: widget.childSize!.width,
                  // height: widget.childSize!.height,
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
