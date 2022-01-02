library focused_menu;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final bool? animateMenuItems;
  final BoxDecoration? menuBoxDecoration;
  final Function onPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Open with tap insted of long press.
  final bool openWithTap;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.menuItems,
    this.duration,
    this.menuBoxDecoration,
    this.menuItemExtent,
    this.animateMenuItems,
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
  Offset childOffset = Offset(0, 0);
  Size? childSize;

  getOffset() {
    RenderBox renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: () async {
        widget.onPressed();
        if (widget.openWithTap) {
          await openMenu(context);
        }
      },
      onLongPress: () async {
        if (!widget.openWithTap) {
          await openMenu(context);
        }
      },
      child: widget.child,
    );
  }

  Future<void> openMenu(BuildContext context) async {
    getOffset();
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: widget.duration ?? Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) {
          animation = Tween(begin: 0.0, end: 1.0).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: FocusedMenuDetails(
              itemExtent: widget.menuItemExtent,
              menuBoxDecoration: widget.menuBoxDecoration,
              child: widget.child,
              childOffset: childOffset,
              childSize: childSize,
              menuItems: widget.menuItems,
              blurSize: widget.blurSize,
              menuWidth: widget.menuWidth,
              blurBackgroundColor: widget.blurBackgroundColor,
              bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
              menuOffset: widget.menuOffset ?? 0,
            ),
          );
        },
        fullscreenDialog: true,
        opaque: false,
      ),
    );
  }
}

class FocusedMenuDetails extends StatefulWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double? itemExtent;
  final Size? childSize;
  final Widget child;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  const FocusedMenuDetails({
    Key? key,
    required this.menuItems,
    required this.child,
    required this.childOffset,
    required this.childSize,
    required this.menuBoxDecoration,
    required this.itemExtent,
    required this.blurSize,
    required this.blurBackgroundColor,
    required this.menuWidth,
    this.bottomOffsetHeight,
    this.menuOffset,
  }) : super(key: key);

  @override
  State<FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<FocusedMenuDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late final Animation<double> _animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = widget.menuItems.length * (widget.itemExtent ?? 45.0);

    final maxMenuWidth = widget.menuWidth ?? 250.0;
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize!.width);
    final topOffset = (widget.childOffset.dy +
                menuHeight +
                widget.childSize!.height) <
            size.height - widget.bottomOffsetHeight!
        ? widget.childOffset.dy + widget.childSize!.height + widget.menuOffset!
        : widget.childOffset.dy - menuHeight - widget.menuOffset!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: ColoredBox(
                color: (widget.blurBackgroundColor ?? Colors.black)
                    .withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            top: topOffset,
            left: leftOffset,
            child: SizeTransition(
              sizeFactor: _animation,
              axisAlignment: 1.0,
              child: SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: _animation,
                axisAlignment: -1.0,
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: widget.menuBoxDecoration ??
                      BoxDecoration(
                        color: Color(0xFFBFC0C2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Column(
                      children: List.generate(widget.menuItems.length, (index) {
                        final item = widget.menuItems[index];
                        Widget listItem = GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            item.onPressed();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: widget.itemExtent ?? 45.0,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  style: index == widget.menuItems.length - 1
                                      ? BorderStyle.none
                                      : BorderStyle.solid,
                                  width: 0.33,
                                  color: Color(0xFF6F6F6E).withOpacity(0.33),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 18.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  item.title,
                                  if (item.trailingIcon != null) ...[
                                    item.trailingIcon!
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                        return TweenAnimationBuilder(
                          builder: (context, dynamic value, child) {
                            return Transform(
                              transform: Matrix4.rotationX(1.5708 * value),
                              alignment: Alignment.bottomCenter,
                              child: child,
                            );
                          },
                          tween: Tween(begin: 1.0, end: 0.0),
                          // duration: Duration(milliseconds: index * 200),
                          duration: Duration.zero,
                          child: listItem,
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: widget.childOffset.dy,
            left: widget.childOffset.dx,
            child: AbsorbPointer(
              absorbing: true,
              child: SizedBox(
                width: widget.childSize!.width,
                height: widget.childSize!.height,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
