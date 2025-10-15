import 'package:flutter/material.dart';

/// A reusable button widget with consistent hover effects across the app
class HoverButton extends StatefulWidget {
  final Color baseColor;
  final Color? hoverColor;
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? elevation;
  final bool filled;

  const HoverButton({
    super.key,
    required this.baseColor,
    required this.onPressed,
    required this.child,
    this.hoverColor,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.filled = true,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    
    // Simplified hover effects based on button type
    Color backgroundColor;
    List<BoxShadow> boxShadow = [];
    
    if (widget.filled) {
      // For filled buttons: slight color change and shadow
      final hoverColor = widget.hoverColor ?? widget.baseColor.withOpacity(0.9);
      backgroundColor = _isHovered ? hoverColor : widget.baseColor;
    } else {
      // For transparent buttons: keep transparent, only add subtle shadow
      backgroundColor = Colors.transparent;
    }
    
    // Add shadow on hover for all button types
    if (_isHovered) {
      boxShadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ];
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: widget.border,
          boxShadow: boxShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: borderRadius,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}