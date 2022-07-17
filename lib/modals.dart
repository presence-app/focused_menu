import 'package:flutter/material.dart';

class FocusedMenuItem extends StatelessWidget {
  final Color? backgroundColor;
  final Widget title;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;

  final TextStyle style;
  final TextStyle pressingTextStyle;

  const FocusedMenuItem({
    Key? key,
    required this.title,
    this.onPressed,
    this.trailingIcon,
    this.backgroundColor,
    this.style = const TextStyle(),
    this.pressingTextStyle = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PressingEffect(
      onPressed: onPressed ?? Navigator.of(context).pop,
      builder: (context, pressing) {
        return DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'SF',
            fontSize: 16.0,
            letterSpacing: -0.391,
            color: Colors.black,
          ).merge(style).merge(pressing ? pressingTextStyle : null),
          child: IconTheme.merge(
            data: const IconThemeData(size: 20.0),
            child: Container(
              height: double.infinity,
              color: pressing ? Colors.grey : backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: title),
                  if (trailingIcon != null) trailingIcon!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PressingEffect extends StatefulWidget {
  const _PressingEffect({
    Key? key,
    required this.builder,
    this.onPressed,
  }) : super(key: key);

  final Widget Function(BuildContext context, bool pressing) builder;

  final VoidCallback? onPressed;

  @override
  __PressingEffectState createState() => __PressingEffectState();
}

class __PressingEffectState extends State<_PressingEffect> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: widget.builder(context, _pressing),
    );
  }
}

class FocusedMenuHeader extends StatefulWidget {
  const FocusedMenuHeader({
    Key? key,
    this.height,
    this.width,
    this.decoration,
    this.child,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  final BoxDecoration? decoration;
  final double? height;
  final double? width;
  final Clip clipBehavior;
  final Widget? child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;

  @override
  State<FocusedMenuHeader> createState() => _FocusedMenuHeaderState();
}

class _FocusedMenuHeaderState extends State<FocusedMenuHeader> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      clipBehavior: widget.clipBehavior,
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        height: widget.height,
        width: widget.width,
        clipBehavior: widget.clipBehavior,
        decoration: widget.decoration,
        child: widget.child,
      ),
    );
  }
}
