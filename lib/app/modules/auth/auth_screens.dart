import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart' show FSwitch;
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/data/services/staging_auth_service.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Ce qu'on vient chercher sur G03.
///
/// La raison seule ne suffisait pas : la porte de l'espace courtier envoyait
/// ici avec le motif client et l'interrupteur courtier éteint, si bien qu'on
/// ouvrait une session cliente et que la même porte y renvoyait aussitôt.
@immutable
class AuthRequest {
  const AuthRequest({required this.reason, this.asBroker = false});
  final String reason;
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

  final String reason;
  final bool asBroker;
  final VoidCallback onBack;
  final void Function(String phone, String? simulatedCode, bool asBroker)
  onCodeSent;
  final VoidCallback onSignedIn;

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phone = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.SN, nsn: ''),
  );
  bool _sending = false;

  /// Message de la dernière tentative échouée. Un texte et non un booléen :
  /// « vérifiez le réseau » était faux dans le cas le plus fréquent.
  String? _failure;

  late bool _asBroker = widget.asBroker;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final staging = context.read<AuthService>() is StagingAuthService;
    return AppScaffold(
      onBack: widget.onBack,
      bottom: AppButton(
        l.authPhoneContinue,
        loading: _sending,
        onPressed: _send,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xxl,
        ),
        children: [
          AppTitle(l.authPhoneTitle),
          FAlert(
            icon: const Icon(FIcons.lockKeyhole),
            title: Text(widget.reason),
          ),
          const SizedBox(height: Insets.xl),
          _GoogleButton(label: l.authGoogleContinue, onPressed: _google),
          const SizedBox(height: Insets.lg),
          Text(
            l.authPhoneFallback,
            style: context.text.bodySmall!.copyWith(
              color: context.tones.inkSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Insets.lg),
          PhoneFormField(
            controller: _phone,
            isCountrySelectionEnabled: false,
            countryButtonStyle: const CountryButtonStyle(
              showDialCode: true,
              showIsoCode: false,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _send(),
            validator: (p) =>
                p == null || !p.isValid() ? l.authPhoneInvalid : null,
            decoration: InputDecoration(
              labelText: l.authPhoneLabel,
              hintText: l.authPhoneHint,
              filled: true,
              fillColor: context.tones.sunken,
              border: const OutlineInputBorder(
                borderRadius: Radii.control,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (staging) ...[
            const SizedBox(height: Insets.lg),
            AppCard.rows([
              AppRow(
                leading: const Icon(FIcons.store),
                title: l.authStagingAsBroker,
                subtitle: l.authStagingAsBrokerHelp,
                onTap: () => setState(() => _asBroker = !_asBroker),
                trailing: FSwitch(
                  value: _asBroker,
                  semanticsLabel: l.authStagingAsBroker,
                  onChange: (v) => setState(() => _asBroker = v),
                ),
              ),
            ]),
          ],
          if (_failure != null) ...[
            const SizedBox(height: Insets.lg),
            Semantics(
              liveRegion: true,
              child: FAlert(
                variant: .destructive,
                icon: const Icon(FIcons.circleAlert),
                title: Text(_failure!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _send() async {
    // Le bouton reste actif : c'est en appuyant qu'on apprend ce qui manque.
    final number = _phone.value;
    if (!number.isValid()) {
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      setState(() => _failure = context.l10n.authPhoneInvalid);
      return;
    }

    setState(() {
      _sending = true;
      _failure = null;
    });
    final auth = context.read<AuthService>();

    String? code;
    try {
      code = await auth.requestCode(number.international);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _failure = _messageFor(context, error);
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }

    if (!mounted) return;
    setState(() => _sending = false);
    widget.onCodeSent(
      number.international,
      auth.isSimulated ? code : null,
      _asBroker,
    );
  }

  Future<void> _google() async {
    setState(() {
      _sending = true;
      _failure = null;
    });
    AuthResult result;
    try {
      result = await context.read<AuthService>().signInWithGoogle();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _failure = _messageFor(context, error);
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    if (!mounted) return;
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

/// Les causes réelles ne se ressemblent pas : le SMS n'existe pas dans ce
/// build, Google n'est pas configuré côté serveur, ou le réseau est coupé.
String _messageFor(BuildContext context, Object error) {
  if (error is UnimplementedError) return context.l10n.authSmsUnavailable;
  if (error is DioException) {
    if (error.response == null) return context.l10n.failureNetwork;
    final status = error.response?.statusCode;
    if (status == 503) return context.l10n.authGoogleUnavailable;
    if (status == 401 || status == 404) return context.l10n.authStagingClosed;
  }
  return context.l10n.authFailed;
}

/// Bouton de marque : ses couleurs sont imposées par Google, pas par le thème.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onPressed});
  static const _fill = Color(0xFFFFFFFF);
  static const _stroke = Color(0xFF747775);
  static const _text = Color(0xFF1F1F1F);
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FTappable(
    semanticsLabel: label,
    behavior: HitTestBehavior.opaque,
    onPress: () {
      context.read<InteractionFeedbackService?>()?.emit(
        FeedbackIntent.selection,
      );
      onPressed();
    },
    child: ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _fill,
          borderRadius: Radii.control,
          border: Border.all(color: _stroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/brand/google_signin_light_square_2x.png',
                width: 18,
                height: 18,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: Insets.sm),
              Flexible(
                child: Text(
                  label,
                  style: AppText.label.copyWith(color: _text),
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

/// G04 — le code se soumet seul dès le sixième chiffre.
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

  /// Porté par l'écran plutôt que retenu dans le service : posé sur G03 et lu
  /// sur G04, un retour en arrière entre les deux le perdait.
  final bool asBroker;
  final String? simulatedCode;
  final VoidCallback onBack;
  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  Timer? _countdown;
  int _secondsLeft = 30;
  String? _error;
  bool _checking = false;

  /// Le code montré en recette change à chaque renvoi : garder celui de la
  /// route faisait retaper un code que le serveur avait déjà remplacé.
  late String? _simulatedCode = widget.simulatedCode;

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
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pin = PinTheme(
      width: 42,
      height: 52,
      textStyle: context.text.titleLarge,
      decoration: BoxDecoration(
        color: context.tones.sunken,
        borderRadius: Radii.control,
      ),
    );
    return AppScaffold(
      onBack: widget.onBack,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            _secondsLeft > 0
                ? l.authOtpResendIn(_secondsLeft)
                : l.authOtpResend,
            variant: AppButtonVariant.secondary,
            onPressed: _secondsLeft > 0 ? null : _resend,
          ),
          const SizedBox(height: Insets.sm),
          AppButton(
            l.authOtpChangeNumber,
            variant: AppButtonVariant.ghost,
            onPressed: widget.onBack,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xxl,
        ),
        children: [
          AppTitle(l.authOtpTitle),
          FAlert(
            icon: const Icon(FIcons.smartphone),
            title: Text(l.authOtpSentTo(widget.phone)),
            subtitle: Text(l.authOtpCodeHint),
          ),
          if (_simulatedCode != null) ...[
            const SizedBox(height: Insets.md),
            FAlert(
              icon: const Icon(FIcons.key),
              title: Text(l.authOtpSimulated(_simulatedCode!)),
            ),
          ],
          const SizedBox(height: Insets.xxl),
          Semantics(
            label: l.authOtpCodeLabel,
            textField: true,
            child: Pinput(
              length: 6,
              controller: _code,
              autofocus: true,
              defaultPinTheme: pin,
              focusedPinTheme: pin.copyBorderWith(
                border: Border.all(color: context.colors.onSurface, width: 2),
              ),
              errorPinTheme: pin.copyBorderWith(
                border: Border.all(color: context.colors.error, width: 2),
              ),
              forceErrorState: _error != null,
              separatorBuilder: (_) => const SizedBox(width: Insets.xs),
              onChanged: _onChanged,
              onCompleted: (value) => unawaited(_verify(value)),
            ),
          ),
          const SizedBox(height: Insets.lg),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_checking)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Insets.sm,
              children: [
                const FCircularProgress(),
                Text(l.authOtpChecking, style: context.text.bodyMedium),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _resend() async {
    final auth = context.read<AuthService>();
    String? code;
    try {
      code = await auth.requestCode(widget.phone);
    } on Object {
      if (mounted) setState(() => _error = context.l10n.authFailed);
      return;
    }
    if (!mounted) return;
    setState(() => _simulatedCode = auth.isSimulated ? code : null);
    _startCountdown();
  }

  void _onChanged(String value) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _verify(String entered) async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _error = null;
    });

    OtpResult result;
    try {
      final auth = context.read<AuthService>();
      if (auth is StagingAuthService) auth.signUpAsBroker = widget.asBroker;
      result = await auth.verify(widget.phone, entered);
    } on Object catch (error) {
      // Sinon `_checking` restait vrai : la pastille « Vérification… » ne
      // repartait jamais et le champ devenait inerte.
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = _messageFor(context, error);
      });
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    if (!mounted) return;

    setState(() => _checking = false);
    final feedback = context.read<InteractionFeedbackService?>();
    switch (result) {
      case OtpResult.verified:
        feedback?.emit(FeedbackIntent.success, eventId: 'G04:success:otp');
        widget.onVerified();
      case OtpResult.wrongCode:
      case OtpResult.tooManyAttempts:
        feedback?.emit(FeedbackIntent.error);
        setState(() {
          _error = result == OtpResult.tooManyAttempts
              ? context.l10n.authOtpTooManyAttempts
              : context.l10n.authOtpWrong;
          // Le code reste sélectionnable : on corrige un chiffre, on ne retape
          // pas tout.
          _code.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _code.text.length,
          );
        });
    }
  }
}
