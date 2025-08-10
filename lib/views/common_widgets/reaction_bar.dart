import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';

enum ReactionType {
  like('👍'),
  love('❤️'),
  fire('🔥'),
  wow('😮'),
  laugh('😂');

  const ReactionType(this.emoji);
  final String emoji;
}

class ReactionData {
  final ReactionType type;
  final int count;
  final bool isSelected;

  const ReactionData({
    required this.type,
    required this.count,
    required this.isSelected,
  });

  ReactionData copyWith({
    ReactionType? type,
    int? count,
    bool? isSelected,
  }) {
    return ReactionData(
      type: type ?? this.type,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ReactionBar extends StatefulWidget {
  final String articleId;
  final Function(ReactionType, bool)? onReactionTap;
  final List<ReactionData>? initialReactions;

  const ReactionBar({
    super.key,
    required this.articleId,
    this.onReactionTap,
    this.initialReactions,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar>
    with TickerProviderStateMixin {
  late Map<ReactionType, ReactionData> _reactions;
  late Map<ReactionType, AnimationController> _animationControllers;
  late Map<ReactionType, Animation<double>> _scaleAnimations;
  late Map<ReactionType, Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _initializeReactions();
    _initializeAnimations();
  }

  void _initializeReactions() {
    _reactions = {};

    // Initialize with provided reactions or defaults
    if (widget.initialReactions != null) {
      for (final reaction in widget.initialReactions!) {
        _reactions[reaction.type] = reaction;
      }
    }

    // Ensure all reaction types exist with defaults
    for (final type in ReactionType.values) {
      _reactions[type] ??= ReactionData(
        type: type,
        count: 0,
        isSelected: false,
      );
    }
  }

  void _initializeAnimations() {
    _animationControllers = {};
    _scaleAnimations = {};
    _bounceAnimations = {};

    for (final type in ReactionType.values) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 120),
        vsync: this,
      );

      _animationControllers[type] = controller;

      _scaleAnimations[type] = Tween<double>(
        begin: 1.0,
        end: 1.15,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));

      _bounceAnimations[type] = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleReactionTap(ReactionType type) {
    final currentReaction = _reactions[type]!;
    final isCurrentlySelected = currentReaction.isSelected;

    setState(() {
      if (isCurrentlySelected) {
        // If tapping the already selected reaction, deselect it
        _reactions[type] = currentReaction.copyWith(
          isSelected: false,
          count: currentReaction.count - 1,
        );
        widget.onReactionTap?.call(type, false);
      } else {
        // Find and deselect any currently selected reaction
        ReactionType? previouslySelected;
        for (final entry in _reactions.entries) {
          if (entry.value.isSelected) {
            previouslySelected = entry.key;
            _reactions[entry.key] = entry.value.copyWith(
              isSelected: false,
              count: entry.value.count - 1,
            );
            break;
          }
        }

        // Select the new reaction
        _reactions[type] = currentReaction.copyWith(
          isSelected: true,
          count: currentReaction.count + 1,
        );

        // Callback for deselected reaction (if any)
        if (previouslySelected != null) {
          widget.onReactionTap?.call(previouslySelected, false);
        }

        // Callback for newly selected reaction
        widget.onReactionTap?.call(type, true);
      }
    });

    // Optimized animation - only animate the tapped reaction
    _triggerReactionAnimation(type);
  }

  void _triggerReactionAnimation(ReactionType type) {
    final controller = _animationControllers[type]!;

    // Reset and play animation smoothly
    controller.reset();
    controller.forward().whenComplete(() {
      if (mounted) {
        controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionType.values.map((type) {
          final reaction = _reactions[type]!;
          final controller = _animationControllers[type]!;
          final scaleAnimation = _scaleAnimations[type]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: _ReactionButton(
                    reaction: reaction,
                    onTap: () => _handleReactionTap(type),
                    primaryColor: currentTheme.primaryColor,
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final ReactionData reaction;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ReactionButton({
    required this.reaction,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: widget.reaction.isSelected
                    ? widget.primaryColor.withAlpha(51)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: widget.reaction.isSelected
                    ? Border.all(color: widget.primaryColor.withAlpha(128), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: widget.reaction.isSelected ? 18 : 16,
                      shadows: widget.reaction.isSelected
                          ? [
                        Shadow(
                          blurRadius: 8,
                          color: widget.primaryColor.withAlpha(128),
                          offset: const Offset(0, 0),
                        ),
                      ]
                          : null,
                    ),
                    child: Text(widget.reaction.type.emoji),
                  ),
                  if (widget.reaction.count > 0) ...[
                    const Gap(4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: widget.reaction.isSelected
                            ? widget.primaryColor
                            : Colors.white.withAlpha(178),
                        fontSize: 12,
                        fontWeight: widget.reaction.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(
                        widget.reaction.count > 999
                            ? '${(widget.reaction.count / 1000).toStringAsFixed(1)}k'
                            : widget.reaction.count.toString(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
