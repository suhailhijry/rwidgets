import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// TappedCard
///
/// A card similar to that of iOS's app store cards, with support for a little
/// customization.
class TappedCard extends StatefulWidget {
  /// The card's background, can be any widget, it will get animated when users
  /// tap on the card.
  final Widget background;

  /// A title that appears at the bottom right corner of the card.
  final Widget? title;

  /// Provide a style for the title to give it correct font or weight.
  final TextStyle? titleStyle;

  /// How far is title is going to be from the card corners.
  final double titlePadding;

  /// Width of the card. Provide this when the parent has no constraints over
  /// the card's width, or wrap the card in constraining widget.
  final double? width;

  /// Height of the card. Provide this when the parent has no constraints over
  /// the card's height, or wrap the card in constraining widget.
  final double? height;

  /// Card's border radius. Prefer using [BorderRadius.circular].
  final BorderRadius? borderRadius;

  /// This affects the strength of the animation, higher values mean more intense
  /// animations.
  final double animationScale;

  /// A callback that is called after the user taps on the card. WARNING: the
  /// callback is only called AFTER the animation is finished; this is to ensure
  /// that animations feel contiguous, and not janky like in native android.
  ///
  /// Note: if this is [null], no animation will occur.
  final VoidCallback? onTap;

  TappedCard({
    required this.background,
    this.title,
    this.titleStyle,
    this.titlePadding = 16,
    this.width,
    this.height,
    this.borderRadius,
    this.animationScale = 1.0,
    this.onTap,
  });

  @override
  _TappedCardState createState() => _TappedCardState();
}

class _TappedCardState extends State<TappedCard> with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final AnimationController _backgroundAnimation;
  late final AnimationController _titleAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      lowerBound: 0.94 / widget.animationScale,
      upperBound: 1.0,
      value: 1.0,
      duration: Duration(milliseconds: 80),
    );
    _backgroundAnimation = AnimationController(
      vsync: this,
      lowerBound: 1.25,
      upperBound: 1.40 * widget.animationScale,
      value: 1.25,
      duration: Duration(milliseconds: 80),
    );
    _titleAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
      lowerBound: 1,
      upperBound: 1.1 * widget.animationScale,
      value: 1,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _backgroundAnimation.dispose();
    _titleAnimation.dispose();
    super.dispose();
  }

  TickerFuture? _tapTicker;
  TickerFuture? _upTicker;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.onTap == null,
      child: InkResponse(
        mouseCursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          enabled: widget.onTap != null,
          child: GestureDetector(
            onTapDown: (details) {
              if (_upTicker != null) {
                _upTicker?.whenComplete(() {
                  _tapTicker =
                      _cardController.animateTo(_cardController.lowerBound);
                  _backgroundAnimation
                      .animateTo(_backgroundAnimation.upperBound);
                  _titleAnimation.animateTo(_titleAnimation.upperBound);
                });
              } else {
                _tapTicker =
                    _cardController.animateTo(_cardController.lowerBound);
                _backgroundAnimation.animateTo(_backgroundAnimation.upperBound);
                _titleAnimation.animateTo(_titleAnimation.upperBound);
              }
            },
            onTapUp: (details) {
              _tapTicker?.whenComplete(() {
                _upTicker =
                    _cardController.animateTo(_cardController.upperBound);
                if (widget.onTap != null) {
                  _upTicker?.whenComplete(widget.onTap!);
                }
                _backgroundAnimation.animateTo(_backgroundAnimation.lowerBound);
                _titleAnimation.animateTo(_titleAnimation.lowerBound);
              });
              Feedback.forTap(context);
            },
            onTapCancel: () {
              _tapTicker?.whenComplete(() {
                _upTicker =
                    _cardController.animateTo(_cardController.upperBound);
                _backgroundAnimation.animateTo(_backgroundAnimation.lowerBound);
                _titleAnimation.animateTo(_titleAnimation.lowerBound);
              });
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
                    animation: _cardController,
                    builder: (context, child) => ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(16),
                      child: SizedBox(
                        height: (widget.height ?? constraints.maxHeight) *
                            _cardController.value,
                        width: (widget.width ?? constraints.maxWidth) *
                            _cardController.value,
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
                                fontSize: widget.titleStyle!.fontSize! *
                                    _titleAnimation.value,
                              ) ??
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * _titleAnimation.value,
                              ),
                          child: widget.title!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
