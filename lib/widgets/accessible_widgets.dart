import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }
}

class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;
  final double? iconSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: iconSize),
        ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      child: Card(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AccessibleTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final String? semanticHint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AccessibleTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.semanticHint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? labelText,
      hint: semanticHint ?? hintText,
      textField: true,
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }
}

class ScreenReaderAnnouncer extends StatefulWidget {
  final Widget child;
  final String? announcement;
  final bool announceOnMount;

  const ScreenReaderAnnouncer({
    super.key,
    required this.child,
    this.announcement,
    this.announceOnMount = false,
  });

  @override
  State<ScreenReaderAnnouncer> createState() => _ScreenReaderAnnouncerState();
}

class _ScreenReaderAnnouncerState extends State<ScreenReaderAnnouncer> {
  @override
  void initState() {
    super.initState();
    if (widget.announceOnMount && widget.announcement != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announce(widget.announcement!);
      });
    }
  }

  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

