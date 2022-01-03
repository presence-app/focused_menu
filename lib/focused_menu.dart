library focused_menu;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Function onPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Open with tap insted of long press.
  final bool openWithTap;

  final bool right;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.menuItems,
    required this.right,
    this.duration,
    this.menuBoxDecoration,
    this.menuItemExtent,
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
  late Size childSize;

  void getOffset() {
    final renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    childOffset = Offset(offset.dx, offset.dy);
    childSize = size;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onSecondaryTap: () async {
        widget.onPressed();
        await openMenu(context);
      },
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
        transitionDuration:
            widget.duration ?? const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          animation = Tween(begin: 0.0, end: 1.0).animate(animation);
          return _FocusedMenuDetails(
            animation: animation,
            itemExtent: widget.menuItemExtent,
            menuBoxDecoration: widget.menuBoxDecoration,
            child: widget.child,
            childOffset: childOffset,
            childSize: childSize,
            menuItems: widget.menuItems,
            blurSize: widget.blurSize,
            menuWidth: widget.menuWidth,
            blurBackgroundColor: widget.blurBackgroundColor,
            bottomOffsetHeight: widget.bottomOffsetHeight ?? 10.0,
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
  final double? itemExtent;
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
    required this.itemExtent,
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
    final listHeight = widget.menuItems.length * (widget.itemExtent ?? 45.0);

    final maxMenuWidth = widget.menuWidth ?? 250.0;
    final double menuHeight = listHeight.clamp(0, maxMenuHeight);
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize!.width);
    final double topOffset = (widget.childOffset.dy + widget.childSize!.height)
        .clamp(0, size.height - menuHeight - widget.bottomOffsetHeight);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);
              },
              child: ColoredBox(
                color: (widget.blurBackgroundColor ?? Colors.black)
                    .withOpacity(0.3),
                child: const AbsorbPointer(),
              ),
            ),
          ),
          Positioned(
            top: topOffset,
            left: leftOffset,
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
                      children: List.generate(widget.menuItems.length, (index) {
                        final item = widget.menuItems[index];
                        return GestureDetector(
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
                                  color:
                                      const Color(0xFF6F6F6E).withOpacity(0.33),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 18.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                item.title,
                                if (item.trailingIcon != null)
                                  item.trailingIcon!
                              ],
                            ),
                          ),
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
