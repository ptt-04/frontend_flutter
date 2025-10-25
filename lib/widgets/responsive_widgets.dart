import 'package:flutter/material.dart';

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      // Mobile: Full width card with minimal padding
      return Card(
        margin: margin ?? const EdgeInsets.all(8),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      );
    } else if (screenWidth < 1200) {
      // Tablet: Medium padding
      return Card(
        margin: margin ?? const EdgeInsets.all(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    } else {
      // Desktop: Larger padding
      return Card(
        margin: margin ?? const EdgeInsets.all(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      );
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.5,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1; // Mobile: Single column
    } else if (screenWidth < 900) {
      crossAxisCount = 2; // Tablet: Two columns
    } else if (screenWidth < 1200) {
      crossAxisCount = 3; // Large tablet: Three columns
    } else {
      crossAxisCount = 4; // Desktop: Four columns
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

class ResponsiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  const ResponsiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      // Mobile: Compact list tile
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );
    } else {
      // Tablet/Desktop: Normal list tile
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        dense: dense,
      );
    }
  }
}

class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isFullWidth;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (screenWidth < 600 && isFullWidth) {
      // Mobile: Full width button
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    TextStyle? responsiveStyle = style;
    
    if (screenWidth < 600) {
      // Mobile: Smaller text
      responsiveStyle = style?.copyWith(
        fontSize: (style?.fontSize ?? 14) * 0.9,
      );
    } else if (screenWidth > 1200) {
      // Desktop: Larger text
      responsiveStyle = style?.copyWith(
        fontSize: (style?.fontSize ?? 14) * 1.1,
      );
    }

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

