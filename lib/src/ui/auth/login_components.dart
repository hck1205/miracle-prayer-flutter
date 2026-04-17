import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../localization/app_strings.dart";
import "google_sign_in_button.dart";

const String _googleLogoSvg = '''
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

class PresenceWordmark extends StatelessWidget {
  const PresenceWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Presence",
      style: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
    );
  }
}

class LoginHero extends StatelessWidget {
  const LoginHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.displayMedium?.copyWith(
            fontSize: 30,
            height: 1.18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: EditorialSpacing.small),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    if (kIsWeb) {
      return const GoogleWebSignInButton();
    }

    return _GoogleButtonShell(
      child: Semantics(
        button: true,
        label: strings.authSignInWithGoogle,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: onPressed,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return const Color(0x1F303030);
              }

              if (states.contains(WidgetState.hovered)) {
                return const Color(0x14303030);
              }

              return null;
            }),
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const SizedBox(width: 20, height: 20, child: _GoogleGlyph()),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        strings.authSignInWithGoogle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontFamily: "Roboto",
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButtonShell extends StatelessWidget {
  const _GoogleButtonShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF747775)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D3C4043),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x263C4043),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GuestLoginButton extends StatelessWidget {
  const GuestLoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return _GuestButtonShell(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    strings.authContinueAsGuest,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: EditorialColors.onSurface,
                      letterSpacing: 0.25,
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

class _GuestButtonShell extends StatelessWidget {
  const _GuestButtonShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EditorialColors.surfaceLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EditorialColors.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x062D3435),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _googleLogoSvg,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
    );
  }
}

class LoginSupportNote extends StatelessWidget {
  const LoginSupportNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: EditorialColors.onSurfaceMuted,
        height: 1.6,
      ),
    );
  }
}

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            color: EditorialColors.outlineVariant,
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: EditorialSpacing.small,
          ),
          child: Text(
            strings.authOr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: EditorialColors.onSurfaceMuted,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: EditorialColors.outlineVariant,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class LoginStatusNote extends StatelessWidget {
  const LoginStatusNote({
    super.key,
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EditorialStatusMessage(message: message, color: color);
  }
}
