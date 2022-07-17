library focused_menu;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'modals.dart';

export 'modals.dart';

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Duration? duration;
  final Color? routeBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Open with tap insted of long press.
  final bool openWithTap;

  final bool right;

  final double pressScale;

  final bool enabled;

  final double itemExtent;

  final FocusedMenuHeader? menuHeader;
  final double headerHeight;
  final EdgeInsets headerPadding;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.menuItems,
    this.right = true,
    this.duration,
    this.menuBoxDecoration,
    this.routeBackgroundColor,
    this.menuWidth,
    this.bottomOffsetHeight,
    this.menuOffset,
    this.openWithTap = false,
    this.pressScale = 0.925,
    this.enabled = true,
    this.itemExtent = 42.0,
    this.menuHeader,
    this.headerHeight = 35,
    this.headerPadding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();

  Offset childOffset = const Offset(0, 0);
  Size? childSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getOffset(context));
  }

  void getOffset(BuildContext context) {
    final renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );
    childSize = size;
    childOffset = Offset(offset.dx, offset.dy);

    /// If it's offscreen, add a padding of 10.0
    if (childOffset.dy.isNegative) {
      childOffset = Offset(
        childOffset.dx,
        MediaQuery.of(context).padding.top + 10.0,
      );
    }
  }

  Widget get child => Hero(
        tag: containerKey,
        createRectTween: (a, b) {
          return CustomRectTween(a: a, b: b);
        },
        // flightShuttleBuilder:
        //     (context, animation, direction, fromContext, toContext) {
        //   return Material(
        //     type: MaterialType.transparency,
        //     child: SizedBox(
        //       height: childSize?.height,
        //       width: childSize?.width,
        //       child: widget.child,
        //     ),
        //   );
        // },
        child: AnimatedScale(
          duration: _animationDuration,
          scale: _currentScale,
          curve: Curves.ease,
          child: Material(
            type: MaterialType.transparency,
            child: widget.child,
          ),
        ),
      );

  double _currentScale = 1.0;
  static const _animationDuration = Duration(milliseconds: 100);

  Future<void> resetScale([double value = 1.0]) async {
    if (!widget.enabled) return;
    setState(() => _currentScale = value);
    return Future.delayed(_animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onSecondaryTap: () async {
        await openMenu(context);
      },
      onTapDown: (_) => resetScale(widget.pressScale),
      onTapUp: (_) {
        resetScale();
        if (widget.openWithTap) {
          openMenu(context);
        }
      },
      onLongPress: () async {
        if (!widget.openWithTap) {
          resetScale();
          openMenu(context);
        }
      },
      onLongPressEnd: (_) => resetScale(),
      onTapCancel: () => resetScale(),
      child: child,
    );
  }

  Future<void> openMenu(BuildContext context) async {
    if (!widget.enabled) return;

    getOffset(context);

    HapticFeedback.mediumImpact();

    FocusScope.of(context).unfocus();

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
            widget.duration ?? const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          animation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutExpo,
          );
          return _FocusedMenuDetails(
            animation: animation,
            menuBoxDecoration: widget.menuBoxDecoration,
            child: child,
            childOffset: childOffset,
            childSize: childSize!,
            menuItems: widget.menuItems,
            menuWidth: widget.menuWidth,
            routeBackgroundColor: widget.routeBackgroundColor,
            bottomOffsetHeight: widget.bottomOffsetHeight ?? 20.0,
            menuOffset: widget.menuOffset ?? 0,
            right: widget.right,
            itemExtent: widget.itemExtent,
            headerHeight: widget.headerHeight,
            menuHeader: widget.menuHeader,
            headerPadding: widget.headerPadding,
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
  final Size childSize;
  final Widget child;
  final double? menuWidth;
  final Color? routeBackgroundColor;
  final double bottomOffsetHeight;
  final double menuOffset;
  final bool right;
  final double itemExtent;
  final double headerHeight;
  final FocusedMenuHeader? menuHeader;
  final EdgeInsets headerPadding;

  const _FocusedMenuDetails({
    Key? key,
    required this.animation,
    required this.menuItems,
    required this.child,
    required this.childOffset,
    required this.childSize,
    required this.menuBoxDecoration,
    required this.routeBackgroundColor,
    required this.menuWidth,
    required this.bottomOffsetHeight,
    required this.menuOffset,
    required this.right,
    required this.itemExtent,
    required this.headerHeight,
    required this.menuHeader,
    required this.headerPadding,
  }) : super(key: key);

  @override
  State<_FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<_FocusedMenuDetails> {
  Animation<double> get _animation => widget.animation;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;

    final menuHeight = widget.menuItems.length * widget.itemExtent;

    final maxMenuWidth = widget.menuWidth ?? 250.0;
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize.width);
    final topOffset = (widget.childOffset.dy + widget.childSize.height).clamp(
      0.0,
      size.height - menuHeight - widget.bottomOffsetHeight - mq.padding.bottom,
    );
    final double rightOffset =
        (leftOffset + widget.childSize.width - maxMenuWidth)
            .clamp(leftOffset, size.width);

    return Material(
      type: MaterialType.canvas,
      color: (widget.routeBackgroundColor) ?? Colors.black.withOpacity(0.35),
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
            top: topOffset -
                widget.childSize.height -
                widget.headerHeight -
                widget.headerPadding.bottom,
            left: widget.right ? rightOffset : leftOffset,
            width: widget.menuWidth ?? maxMenuWidth,
            child: Align(
              alignment: widget.right ? Alignment.topLeft : Alignment.topRight,
              child: widget.menuHeader,
            ),
          ),
          Positioned(
            top: topOffset + (widget.bottomOffsetHeight / 2),
            left: widget.right ? rightOffset : leftOffset,
            child: ScaleTransition(
              scale: _animation,
              alignment: Alignment.center,
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
                      children: List.generate(widget.menuItems.length, (index) {
                        final item = widget.menuItems[index];
                        return Container(
                          alignment: Alignment.center,
                          height: widget.itemExtent,
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
            top: topOffset - widget.childSize.height,
            left: widget.childOffset.dx,
            // width: widget.childSize.width,
            // height: widget.childSize.height,
            child: IgnorePointer(
              child: SizedBox(
                width: widget.childSize.width,
                height: widget.childSize.height,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRectTween extends RectTween {
  CustomRectTween({this.a, this.b}) : super(begin: a, end: b);

  final Rect? a;
  final Rect? b;

  // @override
  // Rect? lerp(double t) {
  //   // MaterialRectArcTween();
  //   // return Rect.lerp(a, b, Curves.easeInOutExpo.transform(t));
  // }
}
