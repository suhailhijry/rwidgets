import 'package:flutter/material.dart';

class TappedCard extends StatefulWidget {
  final Widget background;
  final Text title;
  final TextStyle titleStyle;
  final double titlePadding;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  TappedCard({
    @required this.background,
    this.title,
    this.titleStyle,
    this.titlePadding = 16,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  @override
  _TappedCardState createState() => _TappedCardState();
}

class _TappedCardState extends State<TappedCard> with TickerProviderStateMixin {
  AnimationController _cardController;
  AnimationController _backgroundAnimation;
  AnimationController _titleAnimation;
  Animation _cardAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      lowerBound: 0.7,
      upperBound: 1.0,
      value: 1.0,
      duration: Duration(milliseconds: 80),
    );
    _backgroundAnimation = AnimationController(
      vsync: this,
      lowerBound: 1.25,
      upperBound: 1.40,
      value: 1.25,
      duration: Duration(milliseconds: 80),
    );
    _titleAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
      lowerBound: 1,
      upperBound: 1.1,
      value: 1.1,
    );
    _cardAnimation = CurvedAnimation(
      curve: Curves.linearToEaseOut,
      parent: _cardController,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _backgroundAnimation.dispose();
    _titleAnimation.dispose();
    super.dispose();
  }

  void onCardAnimationFinished(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onTap?.call();
    }

    _cardAnimation.removeStatusListener(onCardAnimationFinished);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _cardController.animateTo(_cardController.lowerBound);
        _backgroundAnimation.animateTo(_backgroundAnimation.upperBound);
        _titleAnimation.animateTo(_titleAnimation.upperBound);
      },
      onTapUp: (details) {
        _cardController.animateTo(_cardController.upperBound);
        _cardAnimation.addStatusListener(onCardAnimationFinished);
        _backgroundAnimation.animateTo(_backgroundAnimation.lowerBound);
        _titleAnimation.animateTo(_titleAnimation.lowerBound);
      },
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) => ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: SizedBox(
                  height: (widget.height ?? constraints.maxHeight) *
                      _cardAnimation.value,
                  width: (widget.width ?? constraints.maxWidth) *
                      _cardAnimation.value,
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _backgroundAnimation.value,
                      child: widget.background,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.title != null)
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) => Positioned(
                  bottom: widget.titlePadding,
                  right: widget.titlePadding,
                  child: DefaultTextStyle.merge(
                    style: widget.titleStyle?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: widget.titleStyle.fontSize *
                              _titleAnimation.value,
                        ) ??
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * _titleAnimation.value,
                        ),
                    child: widget.title,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
