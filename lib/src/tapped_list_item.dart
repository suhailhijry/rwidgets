import 'package:flutter/material.dart';

class TappedListItem extends StatefulWidget {
  final Widget title;
  final Widget description;
  final TextStyle textStyle;
  final Widget leadingIconContent;
  final BorderRadius leadingIconBorderRadius;
  final Widget trailingAction;
  final Color backgroundColor;
  final EdgeInsets padding;
  final EdgeInsets contentSpacing;
  final double animationScale;
  final VoidCallback onTap;

  TappedListItem({
    @required this.title,
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
  });

  @override
  _TappedListItemState createState() => _TappedListItemState();
}

class _TappedListItemState extends State<TappedListItem>
    with TickerProviderStateMixin {
  AnimationController _tapController;

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

  void onAnimationFinished(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onTap?.call();
    }

    _tapController.removeStatusListener(onAnimationFinished);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        (widget.textStyle ?? Theme.of(context).textTheme.headline6);
    final titleStyle = textStyle.copyWith(
      fontWeight: FontWeight.w700,
    );
    final descriptionStyle = widget.description == null
        ? null
        : textStyle.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: textStyle.fontSize * 0.7,
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
            child: widget.description,
          );

    final contentSpacing = widget.contentSpacing ?? EdgeInsets.all(8);

    return GestureDetector(
      onTapDown: (details) {
        _tapController.animateTo(_tapController.lowerBound);
      },
      onTapUp: (details) {
        _tapController.animateTo(_tapController.upperBound);
        _tapController.addStatusListener(onAnimationFinished);
      },
      onTapCancel: () {
        _tapController.animateTo(_tapController.upperBound);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _tapController,
            builder: (context, child) => Transform.scale(
              scale: _tapController.value,
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
            ),
          );
        },
      ),
    );
  }
}
