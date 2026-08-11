import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';

/// Étapes de vie d'un champ, de `docs/INTERACTION-FEEDBACK.md` §3.
enum WkFieldStatus { untouched, editing, valid, invalid }

/// Champ de saisie unique de l'application.
///
/// Il porte la politique de validation, qui est la partie la plus facile à
/// rater : valider trop tôt punit quelqu'un qui n'a pas fini d'écrire.
///
/// - Rien n'est déclaré faux avant la perte de focus, **sauf** si la valeur
///   peut devenir valide sans ambiguïté ([readyToEvaluate]).
/// - Une fois une erreur affichée, chaque frappe revalide : la correction doit
///   être récompensée tout de suite.
/// - Le succès est discret. L'erreur émet un retour **une seule fois** par
///   transition valide → invalide.
class WkTextField extends StatefulWidget {
  const WkTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.readyToEvaluate,
    this.hint,
    this.helper,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.revalidateTick = 0,
    this.showSuccessIcon = true,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
    super.key,
  });

  /// Déjà localisé, toujours visible : un libellé qui disparaît à la saisie
  /// oblige à se souvenir de ce qu'on remplit.
  final String label;

  final TextEditingController controller;

  /// Renvoie un message **disant quoi faire** — « Il manque 2 chiffres » — ou
  /// `null` si la valeur est acceptable.
  final String? Function(String value)? validator;

  /// Vrai quand la valeur est assez avancée pour être jugée. Sans cela, on
  /// attend la perte de focus. Par défaut : dès que le champ n'est pas vide.
  final bool Function(String value)? readyToEvaluate;

  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final int? maxLength;

  /// Filtre la frappe à la source — un champ numérique n'accepte pas de
  /// lettres plutôt que de les refuser après coup.
  final List<TextInputFormatter>? inputFormatters;

  /// Incrémenté par l'écran à la soumission pour forcer une réévaluation.
  ///
  /// Sans ce déclencheur, un formulaire soumis incomplet ne montrerait rien :
  /// les champs n'évaluent que sur frappe ou perte de focus, et l'utilisateur
  /// resterait devant un bouton qui ne fait « rien ».
  final int revalidateTick;
  final bool showSuccessIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  State<WkTextField> createState() => _WkTextFieldState();
}

class _WkTextFieldState extends State<WkTextField> {
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  WkFieldStatus _status = WkFieldStatus.untouched;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    if (widget.revalidateTick > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _evaluate(silent: true);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WkTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revalidateTick != oldWidget.revalidateTick) {
      _debounce?.cancel();
      // Silencieux : une revalidation groupée appartient à l'écran, qui émet
      // **une** erreur pour la soumission entière. Sinon un formulaire à
      // quatre champs vides ferait vibrer quatre fois.
      _evaluate(silent: true);
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _status != WkFieldStatus.untouched) {
      _debounce?.cancel();
      _evaluate();
    }
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    _debounce?.cancel();

    if (_status == WkFieldStatus.invalid) {
      // Déjà en erreur : on revalide à chaque frappe pour que la correction se
      // voie immédiatement.
      _evaluate();
      return;
    }

    setState(() => _status = WkFieldStatus.editing);

    final bool ready = (widget.readyToEvaluate ?? (String v) => v.isNotEmpty)(
      value,
    );
    if (!ready) {
      return;
    }

    // Unique anti-rebond du cycle de vie. Aucun second délai n'est ajouté
    // avant d'afficher le résultat.
    _debounce = Timer(WkMotion.validationDebounce, _evaluate);
  }

  void _evaluate({bool silent = false}) {
    if (!mounted) {
      return;
    }
    final String value = widget.controller.text;
    final String? message = widget.validator?.call(value);
    final WkFieldStatus previous = _status;

    setState(() {
      _error = message;
      _status = message == null ? WkFieldStatus.valid : WkFieldStatus.invalid;
    });

    if (!silent && message != null && previous != WkFieldStatus.invalid) {
      // Une seule fois par transition, pas une par frappe.
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = _status == WkFieldStatus.invalid;
    final Color borderColor = hasError
        ? context.colors.error
        : _focus.hasFocus
        ? context.colors.primary
        : context.colors.outline;
    final double borderWidth = hasError || _focus.hasFocus ? 2 : 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: WkSpacing.xs),
        Container(
          constraints: const BoxConstraints(minHeight: WkTouch.comfy),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(WkRadius.md),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  style: context.text.bodyLarge,
                  onChanged: _onChanged,
                  onSubmitted: (String v) {
                    _debounce?.cancel();
                    _evaluate();
                    widget.onSubmitted?.call(v);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: context.text.bodyLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: WkSpacing.md,
                    ),
                  ),
                ),
              ),
              if (widget.showSuccessIcon && _status == WkFieldStatus.valid)
                Icon(Icons.check, color: context.colors.statusAvailable)
              else if (hasError)
                Icon(Icons.error_outline, color: context.colors.error),
              ?widget.trailing,
            ],
          ),
        ),
        // L'espace d'aide est réservé en permanence : sans cela, l'apparition
        // d'un message pousse le champ hors du doigt.
        SizedBox(
          height: 24,
          child: _HelperLine(
            message: _error ?? widget.helper,
            isError: hasError,
          ),
        ),
      ],
    );
  }
}

class _HelperLine extends StatelessWidget {
  const _HelperLine({required this.message, required this.isError});

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: WkSpacing.xs),
      child: Semantics(
        liveRegion: isError,
        child: Text(
          message!,
          style: context.text.bodySmall?.copyWith(
            color: isError
                ? context.colors.error
                : context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
