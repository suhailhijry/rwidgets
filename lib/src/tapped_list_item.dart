import 'package:flutter/material.dart';

/// TappedListItem
///
/// A widget for use in lists views and listed containers.
class TappedListItem extends StatefulWidget {
  /// The item's title, cannot be null
  final Widget title;

  /// The item's description, rendered with a thinner and lighter style than
  /// that of the title.
  final Widget? description;

  /// Title and description style, provide one if you want to apply a custom
  /// text styling.
  final TextStyle? textStyle;

  /// Contents of the leading icon that appears before the title and the
  /// description.
  final Widget? leadingIconContent;

  /// Border radius of the leading icon. Prefer using [BorderRadius.circular].
  final BorderRadius? leadingIconBorderRadius;

  /// A widget that appears at the end, this widget should be an action that the
  /// user can make.
  final Widget? trailingAction;

  /// Background color for the item, if not provided it is transparent.
  final Color backgroundColor;

  /// Padding for the item's contents.
  final EdgeInsets? padding;

  /// Spacing between contents
  final EdgeInsets? contentSpacing;

  /// This affects the strength of the animation, higher values mean more intense
  /// animations.
  final double animationScale;

  /// A callback that is called when the user taps on the item. WARNING: the
  /// callback is only called AFTER the animation is finished; this is to ensure
  /// that animations feel contiguous, and not janky like in native android.
  ///
  /// Note: if this is [null], no animation will occur.
  final VoidCallback? onTap;

  TappedListItem({
    required this.title,
    this.description,
    this.textStyle,
    this.leadingIconContent,
    this.leadingIconBorderRadius,
    this.trailingAction,
    this.backgroundColor = Colors.transparent,
    this.padding,
    this.contentSpacing,
    this.animationScale = 1.0,
    this.onTap,
  }) : assert(title != null);

  @override
  _TappedListItemState createState() => _TappedListItemState();
}

class _TappedListItemState extends State<TappedListItem>
    with TickerProviderStateMixin {
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      lowerBound: 0.975 * widget.animationScale,
      upperBound: 1.0,
      value: 1.0,
      duration: Duration(milliseconds: 80),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  TickerFuture? _tapTicker;
  TickerFuture? _upTicker;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        (widget.textStyle ?? Theme.of(context).textTheme.headline6);
    final titleStyle = textStyle!.copyWith(
      fontWeight: FontWeight.w700,
    );
    final descriptionStyle = widget.description == null
        ? null
        : textStyle.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: textStyle.fontSize! * 0.7,
          );
    final titleWidget = DefaultTextStyle.merge(
      textAlign: TextAlign.left,
      style: titleStyle,
      child: widget.title,
    );
    final descriptionWidget = widget.description == null
        ? null
        : DefaultTextStyle.merge(
            textAlign: TextAlign.left,
            style: descriptionStyle,
            child: widget.description!,
          );

    final contentSpacing = widget.contentSpacing ?? EdgeInsets.all(8);

    return GestureDetector(
      onTapDown: (details) {
        if (widget.onTap == null) return;
        if (_upTicker != null) {
          _upTicker?.whenComplete(() {
            _tapTicker = _tapController.animateTo(_tapController.lowerBound);
          });
        } else {
          _tapTicker = _tapController.animateTo(_tapController.lowerBound);
        }
      },
      onTapUp: (details) async {
        if (widget.onTap == null) return;
        _tapTicker?.whenComplete(() {
          _upTicker = _tapController.animateTo(_tapController.upperBound)
            ..whenComplete(widget.onTap!);
        });
        Feedback.forTap(context);
      },
      onTapCancel: () {
        if (widget.onTap == null) return;
        _tapTicker?.whenComplete(() {
          _upTicker = _tapController.animateTo(_tapController.upperBound);
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _tapController,
            child: Container(
              padding: widget.padding ?? contentSpacing,
              width: constraints.maxWidth,
              color: widget.backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.leadingIconContent != null)
                        ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: widget.leadingIconBorderRadius ??
                              BorderRadius.circular(8),
                          child: SizedBox(
                            height: 36,
                            width: 36,
                            child: widget.leadingIconContent,
                          ),
                        ),
                      descriptionWidget != null
                          ? Container(
                              margin: contentSpacing,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  titleWidget,
                                  descriptionWidget,
                                ],
                              ),
                            )
                          : Container(
                              margin: contentSpacing,
                              alignment: Alignment.centerLeft,
                              child: titleWidget,
                            ),
                    ],
                  ),
                  if (widget.trailingAction != null)
                    Container(
                      margin: contentSpacing,
                      alignment: Alignment.centerRight,
                      child: widget.trailingAction,
                    ),
                ],
              ),
            ),
            builder: (context, child) => Transform.scale(
              scale: _tapController.value,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
