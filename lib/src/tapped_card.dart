import 'package:flutter/material.dart';

/// TappedCard
///
/// A card similar to that of iOS's app store cards, with support for a little
/// customization.
class TappedCard extends StatefulWidget {
  /// The card's background, can be any widget, it will get animated when users
  /// tap on the card.
  final Widget background;

  /// A title that appears at the bottom right corner of the card.
  final Text title;

  /// Provide a style for the title to give it correct font or weight.
  final TextStyle titleStyle;

  /// How far is title is going to be from the card corners.
  final double titlePadding;

  /// Width of the card. Provide this when the parent has no constraints over
  /// the card's width, or wrap the card in constraining widget.
  final double width;

  /// Height of the card. Provide this when the parent has no constraints over
  /// the card's height, or wrap the card in constraining widget.
  final double height;

  /// Card's border radius. Prefer using [BorderRadius.circular].
  final BorderRadius borderRadius;

  /// A callback that is called after the user taps on the card. WARNING: the
  /// callback is only called AFTER the animation is finished; this is to ensure
  /// that animations feel contiguous, and not janky like in native android.
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
      onTapCancel: () {
        _cardController.animateTo(_cardController.upperBound);
        _backgroundAnimation.animateTo(_backgroundAnimation.lowerBound);
        _titleAnimation.animateTo(_titleAnimation.lowerBound);
      },
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: widget.height ?? constraints.maxHeight,
              width: widget.width ?? constraints.maxWidth,
            ),
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
