import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/data/services/staging_auth_service.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_busy_indicator.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// G03 — Numéro de téléphone.
///
/// Demandé **juste avant** une action qui l'exige, jamais à l'ouverture : on
/// ne bloque pas la découverte avec un formulaire.
/// Ce qu'on vient chercher sur G03.
///
/// La raison seule ne suffisait pas : la porte de l'espace courtier envoyait
/// ici avec le motif client et l'interrupteur courtier éteint, si bien qu'on
/// ouvrait une session **cliente**, qu'on se retrouvait sans profil courtier,
/// et que la même porte renvoyait au même écran. Une boucle fermée.
@immutable
class AuthRequest {
  const AuthRequest({required this.reason, this.asBroker = false});

  /// Pourquoi on demande à s'identifier, dit à la première personne.
  final String reason;

  /// Vrai quand la session doit ouvrir un espace courtier.
  final bool asBroker;
}

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({
    required this.reason,
    this.asBroker = false,
    required this.onBack,
    required this.onCodeSent,
    required this.onSignedIn,
    super.key,
  });

  /// Pourquoi le numéro est demandé, en une phrase. Déjà localisé.
  final String reason;

  /// Pré-coche « Ouvrir un espace courtier » : on vient de l'espace courtier.
  final bool asBroker;

  final VoidCallback onBack;
  final void Function(String phone, String? simulatedCode, bool asBroker)
  onCodeSent;
  final VoidCallback onSignedIn;

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phone = TextEditingController();
  bool _submitted = false;
  bool _sending = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String get _localDigits {
    final String digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('221') ? digits.substring(3) : digits;
  }

  bool get _isValid => _localDigits.length == 9;

  /// Message de la dernière tentative échouée. Nul tant que rien n'a raté.
  ///
  /// Un texte et non un booléen : « Connexion impossible, vérifiez le réseau »
  /// était faux dans le cas le plus fréquent — un build lancé sans ses
  /// `--dart-define`, où le réseau va très bien et c'est la connexion Google
  /// qui n'existe pas sur ce serveur.
  String? _failure;

  /// Recette : ouvrir la session avec un profil courtier. Pré-coché quand on
  /// arrive depuis l'espace courtier, sinon on rouvre une session cliente et
  /// la porte se referme aussitôt.
  late bool _asBroker = widget.asBroker;

  @override
  Widget build(BuildContext context) {
    return WkScaffold(
      topBar: WkTopBar(
        title: context.l10n.authPhoneTitle,
        onBack: widget.onBack,
      ),
      bottomAction: WkButton(
        label: context.l10n.authPhoneContinue,
        loading: _sending,
        onPressed: _send,
      ),
      body: ListView(
        children: <Widget>[
          _AuthContextCard(
            icon: Icons.lock_outline,
            title: context.l10n.authPhoneTitle,
            body: widget.reason,
          ),
          const SizedBox(height: WkSpacing.lg),
          _GoogleAuthButton(
            label: context.l10n.authGoogleContinue,
            onPressed: _signInWithGoogle,
          ),
          const SizedBox(height: WkSpacing.md),
          Text(
            context.l10n.authPhoneFallback,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (context.read<AuthService>() is StagingAuthService) ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            // Recette uniquement : absent de tout build ordinaire, puisque le
            // service de recette n'y est pas branché.
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _asBroker,
              onChanged: (bool v) => setState(() => _asBroker = v),
              title: Text(
                context.l10n.authStagingAsBroker,
                style: context.text.bodyMedium,
              ),
              subtitle: Text(
                context.l10n.authStagingAsBrokerHelp,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (_failure != null) ...<Widget>[
            const SizedBox(height: WkSpacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                _failure!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: WkSpacing.md),
          WkTextField(
            label: context.l10n.authPhoneLabel,
            controller: _phone,
            hint: context.l10n.authPhoneHint,
            helper: context.l10n.authPhoneCountrySenegal,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            maxLength: 12,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            revalidateTick: _submitted ? 1 : 0,
            readyToEvaluate: (_) => _localDigits.length >= 9,
            validator: (_) => _isValid ? null : context.l10n.authPhoneInvalid,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    // Le bouton reste actif : c'est en appuyant qu'on apprend ce qui manque.
    setState(() => _submitted = true);
    if (!_isValid) {
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }

    setState(() {
      _sending = true;
      _failure = null;
    });
    final AuthService auth = context.read<AuthService>();
    final String phone = '+221$_localDigits';

    // Sans ce catch, un échec laissait `_sending` à vrai pour toujours : le
    // bouton tournait sans fin et devenait intouchable, sans un mot.
    String? code;
    try {
      code = await auth.requestCode(phone);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sending = false;
        _failure = _messageFor(context, error);
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    widget.onCodeSent(phone, auth.isSimulated ? code : null, _asBroker);
  }

  /// Traduit un échec d'identification en une phrase vraie.
  ///
  /// Les trois causes réelles sur ce déploiement ne se ressemblent pas, et les
  /// confondre sous « vérifiez le réseau » a déjà coûté du temps : le SMS
  /// n'existe pas dans ce build, la connexion Google n'est pas configurée
  /// côté serveur, ou le réseau est vraiment coupé.
  static String _messageFor(BuildContext context, Object error) {
    if (error is UnimplementedError) {
      return context.l10n.authSmsUnavailable;
    }
    if (error is DioException) {
      final int? status = error.response?.statusCode;
      if (status == 503) {
        return context.l10n.authGoogleUnavailable;
      }
      if (status == 401 || status == 404) {
        return context.l10n.authStagingClosed;
      }
    }
    return context.l10n.authFailed;
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _sending = true;
      _failure = null;
    });
    AuthResult result;
    try {
      result = await context.read<AuthService>().signInWithGoogle();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sending = false;
        _failure = _messageFor(context, error);
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    if (result == AuthResult.signedIn || result == AuthResult.linked) {
      context.read<InteractionFeedbackService?>()?.emit(
        FeedbackIntent.success,
        eventId: 'G03:success:google',
      );
      widget.onSignedIn();
    }
  }
}

class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({required this.label, required this.onPressed});

  static const Color _fill = Color(0xFFFFFFFF);
  static const Color _stroke = Color(0xFF747775);
  static const Color _text = Color(0xFF1F1F1F);

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: _fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WkRadius.md),
          side: const BorderSide(color: _stroke),
        ),
        child: InkWell(
          onTap: () {
            context.read<InteractionFeedbackService?>()?.emit(
              FeedbackIntent.selection,
            );
            onPressed();
          },
          borderRadius: BorderRadius.circular(WkRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: WkTouch.min),
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              top: WkSpacing.sm,
              bottom: WkSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/brand/google_signin_light_square_2x.png',
                  width: 18,
                  height: 18,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: context.text.labelLarge?.copyWith(color: _text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// G04 — Code reçu par SMS.
///
/// Le code se soumet **seul** dès le sixième chiffre : un bouton Valider ici
/// n'ajoute qu'un geste, la complétion est sans ambiguïté.
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.phone,
    required this.simulatedCode,
    required this.onBack,
    required this.onVerified,
    this.asBroker = false,
    super.key,
  });

  final String phone;

  /// Ouvre un espace courtier à la vérification.
  ///
  /// Porté par l'écran plutôt que retenu dans le service : le drapeau était
  /// posé sur G03 et lu sur G04, donc une reconstruction ou un retour en
  /// arrière entre les deux le perdait, et on rouvrait une session cliente
  /// sans que rien ne le signale.
  final bool asBroker;

  /// Affiché tant qu'aucun SMS réel n'est envoyé.
  final String? simulatedCode;
  final VoidCallback onBack;
  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _code = TextEditingController();
  Timer? _countdown;
  int _secondsLeft = 30;
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    setState(() => _secondsLeft = 30);
    _countdown = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.authOtpTitle, onBack: widget.onBack),
      body: ListView(
        children: <Widget>[
          _AuthContextCard(
            icon: Icons.sms_outlined,
            title: context.l10n.authOtpSentTo(widget.phone),
            body: widget.simulatedCode == null
                ? context.l10n.authOtpCodeHint
                : context.l10n.authOtpSimulated(widget.simulatedCode!),
          ),
          const SizedBox(height: WkSpacing.lg),
          WkTextField(
            label: context.l10n.authOtpCodeLabel,
            controller: _code,
            autofocus: true,
            hint: context.l10n.authOtpCodeHint,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            showSuccessIcon: false,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: _onCodeChanged,
            onSubmitted: _verifyIfComplete,
          ),
          SizedBox(
            height: 28,
            child: _error == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: WkSpacing.xs),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: WkSpacing.md),
          WkButton(
            label: _secondsLeft > 0
                ? context.l10n.authOtpResendIn(_secondsLeft)
                : context.l10n.authOtpResend,
            variant: WkButtonVariant.secondary,
            onPressed: _secondsLeft > 0 ? null : _resend,
            disabledReason: context.l10n.authOtpResendIn(_secondsLeft),
          ),
          const SizedBox(height: WkSpacing.betweenTargets),
          WkButton(
            label: context.l10n.authOtpChangeNumber,
            variant: WkButtonVariant.ghost,
            onPressed: widget.onBack,
          ),
          if (_checking)
            Padding(
              padding: const EdgeInsets.only(top: WkSpacing.md),
              child: _CheckingPill(label: context.l10n.authOtpChecking),
            ),
        ],
      ),
    );
  }

  Future<void> _resend() async {
    try {
      await context.read<AuthService>().requestCode(widget.phone);
    } on Object {
      if (mounted) {
        setState(() => _error = context.l10n.authFailed);
      }
      return;
    }
    if (mounted) {
      _startCountdown();
    }
  }

  void _onCodeChanged(String value) {
    if (_error != null) {
      setState(() => _error = null);
    }
    _verifyIfComplete(value);
  }

  void _verifyIfComplete(String value) {
    if (value.length == 6 && !_checking) {
      unawaited(_verify(value));
    }
  }

  Future<void> _verify(String entered) async {
    setState(() {
      _checking = true;
      _error = null;
    });

    OtpResult result;
    try {
      final AuthService auth = context.read<AuthService>();
      if (auth is StagingAuthService) {
        auth.signUpAsBroker = widget.asBroker;
      }
      result = await auth.verify(widget.phone, entered);
    } on Object {
      // Sinon `_checking` restait vrai : la pastille « Vérification… » ne
      // repartait jamais et le champ devenait inerte.
      if (!mounted) {
        return;
      }
      setState(() {
        _checking = false;
        _error = context.l10n.authFailed;
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() => _checking = false);
    final InteractionFeedbackService? feedback = context
        .read<InteractionFeedbackService?>();

    switch (result) {
      case OtpResult.verified:
        feedback?.emit(FeedbackIntent.success, eventId: 'G04:success:otp');
        widget.onVerified();
      case OtpResult.wrongCode:
      case OtpResult.tooManyAttempts:
        feedback?.emit(FeedbackIntent.error);
        setState(() {
          _error = context.l10n.authOtpWrong;
          // Le code reste sélectionnable : on corrige un chiffre, on ne
          // retape pas tout.
          _code.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _code.text.length,
          );
        });
    }
  }
}

class _AuthContextCard extends StatelessWidget {
  const _AuthContextCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(WkRadius.full),
              ),
              child: Icon(icon, color: context.colors.onPrimaryContainer),
            ),
            const SizedBox(width: WkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: context.text.headlineMedium),
                  const SizedBox(height: WkSpacing.xs),
                  Text(
                    body,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckingPill extends StatelessWidget {
  const _CheckingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(WkRadius.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WkSpacing.md,
            vertical: WkSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              WkBusyIndicator(
                color: context.colors.onPrimaryContainer,
                size: 20,
              ),
              const SizedBox(width: WkSpacing.sm),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
