# Woutalma Keur — interaction and feedback contract

Version 1.0 — applies to every screen, sheet, field and meaningful action.

## 1. Objective

The app must acknowledge intent immediately, show what it understood, and explain how to recover.
This is essential for users with low literacy, limited digital confidence, environmental noise or
stress. We reduce cognitive burden without removing user control or talking down to anyone.

Feedback is multimodal: visual, motion, haptic and auditory/spoken. No single mode carries meaning
alone. “Everywhere” means every meaningful action has a response; it does not mean every tap triggers
a vibration, sound and sentence.

## 2. Feedback ladder

| Recipe | Use | Visual | Motion | Haptic | Sound / speech |
|:--|:--|:--|:--|:--|:--|
| F0 Pressed | finger-down acknowledgment | tonal pressed state, no layout shift | 80 ms | none | none |
| F1 Selected | tab, chip, star, option, toggle | check/indicator + label/state | 140 ms | `selectionClick` | optional system tick only for picker |
| F2 Valid | field or step is complete | trailing check + short positive helper | check fades in 140 ms | none per field; `lightImpact` when a whole step completes | spoken only in guided mode |
| F3 Warning | reversible risk or incomplete prerequisite | amber icon + consequence + clear action | message reveals 180 ms | `warning()` once after user action | short earcon only if sounds enabled |
| F4 Error | action failed or submitted value invalid | error icon, plain correction, focus first error | message reveals 180 ms; never shake | `error()` once | error earcon; concise speech in guided mode |
| F5 Success | durable task completed | check + concrete result and next action | 220–320 ms, no confetti | `success()` once | success earcon; concise speech in guided mode |
| F6 Listening | microphone/recording lifecycle | state, timer/waveform and transcript | continuous only while active | light on start, medium on stop/cancel | distinct start/stop earcons |
| F7 Progress | operation exceeds 300 ms | control keeps size; spinner/progress + verb | fade 140 ms | none | spoken once only if operation exceeds 2 s in guided mode |

Rules:

- F0 is present on every enabled control. Disabled controls still explain why when focused/tapped.
- F1 is not combined with success vibration for ordinary choices.
- F2 never vibrates for every field; that would punish normal typing. A completed step may vibrate once.
- F4 fires once per failed attempt, not on every rebuild or keystroke.
- Automatic/background failures never buzz or sound unless the user is waiting on that operation.
- Sound is enhancement only. The visual and semantic response remains complete when muted/unavailable.
- Custom TTS never speaks over TalkBack/VoiceOver. Semantic live regions take priority.
- Respect app sound/haptic preferences, device silent/DND behavior where exposed, and
  `MediaQuery.disableAnimationsOf(context)`.

## 3. Form validation contract

Every `WkTextField`, `WkPhoneField`, `WkOtpField`, selector and media field uses these states:

`untouched → editing → checking? → valid | invalid → submitting → success | failure`

### While typing

- Show formatting and remaining constraints immediately without declaring an incomplete value wrong.
- Run cheap synchronous validation after a **400 ms** pause, and only when the value is long enough
  to be meaningfully evaluated. This is the **only** debounce in the field lifecycle; no second
  delay may be added before showing the outcome.
- Run validation immediately on blur, Next and Submit.
- Never move focus, open another screen, submit or clear input merely because the value became
  valid. **Exception — fixed-length codes:** a field whose completion is unambiguous by
  construction may advance or submit on completion. This covers `WkOtpField` only: the sixth digit
  advances nothing and submits once, which is why G04 has no Validate button. Any other
  auto-advance requires a recorded decision.
- Never reformat in a way that moves the cursor unexpectedly.

### Valid value

- Reveal the check icon and short confirmation such as « Numéro correct » or « Prix ajouté »
  **as soon as validity is determined** — that is, at the end of the 400 ms debounce, or immediately
  on blur, Next or Submit. Waiting again after the debounce would make a correct number sit
  unacknowledged for close to a second, which reads as the app ignoring the user.
- Preserve the field height when helper text changes; reserve helper/error space or animate size
  without moving the active control away from the finger.
- Do not play sound or haptic for each valid field. F2 haptic occurs only when a complete step becomes
  ready to continue.

### Invalid value

- Use border + icon + plain correction, for example « Ajoutez 9 chiffres après +221 » rather than
  « Valeur invalide ».
- On Submit, focus and scroll to the first invalid field, announce one summary, and leave every value
  intact.
- Do not show red while the user is still producing a potentially valid value.
- An async failure such as duplicate phone or failed media processing stays distinct from a format
  error and offers Retry where appropriate.

### Button readiness

**The primary action stays enabled while the form is incomplete.** A greyed-out button tells a user
who cannot read fluently that the app is broken; it never tells her which field is missing. Tapping
is how she asks the app what is left to do, and the answer must be the recovery path defined above:
validate everything, focus and scroll to the first invalid field, announce one summary, keep every
value.

This replaces an earlier rule that disabled the primary until every input was valid. That rule made
the "focus the first invalid field on Submit" path unreachable, since Submit could not fire while
anything was invalid. The two cannot both hold.

- Disable the primary only when submitting would be **destructive, chargeable or irreversible** with
  incomplete data — not merely inconvenient. A disabled action stays legible and carries a visible
  reason plus a semantic hint, never colour alone.
- A tap on an incomplete form is `error()` **once**, not once per invalid field.
- While a submission is in flight, the control switches to F7 and refuses further taps without
  changing width. Duplicate submissions are impossible.

## 4. Motion and timing

| Token | Duration | Use |
|:--|:--|:--|
| instant | 80 ms | pressed state |
| fast | 140 ms | check, chip, icon or helper transition |
| standard | 220 ms | sheet content, result replacement, progress completion |
| slow | 320 ms | full success confirmation only |

- Route transitions use platform defaults; sheets use one shared transition.
- Motion changes opacity, color or bounded position; it never changes fixed control dimensions.
- No field shake, bounce, confetti, pulsing CTA or decorative parallax.
- Skeleton shimmer becomes static in reduced-motion or light-data mode.
- Voice waveform is the only continuous motion and stops immediately when recording stops.
- If animations are disabled, state changes are immediate while haptic/semantic feedback remains.

### Frame budget on entry-level Android

The first acceptance target is a low-cost phone. Motion that is free on a flagship drops frames
there, and a stuttering waveform reads as "the app did not hear me".

- **Two animated properties at most** at any moment, preferably `opacity` and `transform`. Animating
  colour, shadow, blur or size on a scrolling list is forbidden.
- The voice waveform is the **only** thing animating while it runs: no simultaneous list entry
  animation, no shimmer, no transition underneath. It samples at **20 fps**, not per frame, and
  repaints an isolated `RepaintBoundary`.
- No entry animation per item on list scroll. A result list replaces content without staggering.
- Any screen that cannot hold 60 fps on the reference device with its heaviest state loses motion
  before it loses information.

## 5. Sound, speech and haptics

### Haptics

Flutter's `HapticFeedback` exposes exactly five primitives: `selectionClick`, `lightImpact`,
`mediumImpact`, `heavyImpact` and `vibrate`. **There is no success, warning or error notification
haptic in the SDK** — those belong to iOS `UINotificationFeedbackGenerator` and are only reachable
through a package or a platform channel.

Decision for the UX phase: **no extra haptic package.** Semantic intents map onto the five
primitives as follows, inside `InteractionFeedbackService`:

| Intent | Flutter primitive | Occurs on |
|:--|:--|:--|
| `selection()` | `selectionClick()` | discrete choice changed |
| `stepValid()` | `lightImpact()` | a whole form step became ready to continue |
| `recordingStarted()` | `lightImpact()` | microphone opened |
| `recordingStopped()` | `mediumImpact()` | microphone stopped or cancelled |
| `warning()` | `mediumImpact()` | user-triggered reversible risk |
| `success()` | `mediumImpact()` | contact logged, review sent, property published, verification submitted, mode switched |
| `error()` | `heavyImpact()` | failed submit, invalid OTP, media or seed operation failed |

Consequence to accept explicitly: **haptics carry intensity, not category.** `warning()` and
`success()` feel identical. That is acceptable only because §1 forbids any mode from carrying
meaning alone — category always comes from the visual state and, when enabled, the earcon. Never
design a flow that requires telling two haptics apart.

`vibrate()` is reserved for a blocking error the user is actively waiting on, never for routine
events. Unsupported haptics fail silently.

**Entry-level Android caveat.** `selectionClick()` is frequently a no-op or imperceptible on
low-cost devices. The service probes haptic capability **once per app start**, caches the result,
and falls back to `lightImpact()` for `selection()` when the probe reports nothing. The probe never
runs during a user gesture.

Revisit this decision only if device testing shows the intensity-only mapping confuses users; it is
recorded here so a future package addition is a deliberate change, not a silent one.

### Sound and speech

- Ordinary button presses are silent.
- Haptics are enabled by default where supported. Interaction sounds are enabled by default only for
  F4, F5 and F6 and must follow device sound/silent behavior as far as the platform exposes it.
- Guided voice starts off unless the user chooses an audio-assisted onboarding path or enables it.
- System click/tick may accompany explicit picker changes when supported.
- Start/stop recording, major success, warning and blocking error may use short local earcons through
  the already-required audio layer; no melody or branded jingle.
- Guided mode speaks the concrete result: « Recherche terminée, 6 courtiers trouvés » or
  « Photo non ajoutée, essayez encore ». It does not read every animation or duplicate TalkBack.
- Settings expose Sounds, Vibrations and Guided voice independently, with a preview action.

### Earcon inventory

Five earcons, no more. One family, each under 400 ms, mixed low, no melody. **None of them exist
yet**; they are a production task, not an implementation detail, and the audio layer ships muted
until they land.

| Asset | Fires on | Notes |
|:--|:--|:--|
| `success` | F5 — review sent, property published, contact logged, mode switched | also covers verification submitted |
| `error` | F4 — failed submit, invalid OTP, failed media or seed operation | the only earcon allowed to bypass silent mode, and only when the user is waiting on that operation |
| `warning` | F3 — user-triggered reversible risk | distinct from `error`, quieter |
| `listening-start` | F6 — microphone opens | must be recognisable at arm's length outdoors |
| `listening-stop` | F6 — microphone stops or is cancelled | shares timbre with `listening-start` |

No navigation earcon, no keystroke earcon, no branded startup sound.

### Silent mode and Do Not Disturb

Flutter exposes no ringer state. Reading it needs a package or a platform channel, and Android
fragments hard on the API. Decision for the UX phase: **the app does not read the ringer.** Instead:

- Earcons play through the media audio session, so the hardware volume rocker already controls them.
- The Sounds preference in S01 is the app-level mute, defaulted per §5.
- No earcon plays when the app is not foregrounded.

If field testing shows earcons firing in inappropriate settings, add a ringer-state package as a
recorded decision. Until then, "follow device silent behaviour where the platform exposes it" means
exactly the volume rocker and nothing more.

### Guided voice against a screen reader

Guided voice and TalkBack/VoiceOver serve two different populations and must never speak together.
The rule is mechanical, not editorial:

- When `MediaQuery.accessibleNavigationOf(context)` is true, **guided voice is suppressed for the
  whole session** and semantic live regions carry every announcement instead. The preference keeps
  its stored value; it simply has no effect while a screen reader is running.
- S01 shows the suppression in words when it applies, so a user who enabled guided voice is not left
  wondering why it went quiet.
- `announceStatus()` always routes to `SemanticsService.announce`, screen reader or not. It is the
  single announcement path; guided voice is an additional output on top of it, never a replacement.

## 6. Screen-by-screen audit

### Common and settings

| ID | Meaningful event | Required feedback and recovery |
|:--|:--|:--|
| G00 | local data opens | Under 300 ms: no fake loader. Over 300 ms: F7 with « Ouverture ». Failure shows G05; no background vibration before user interaction. |
| G01 | language chosen/previewed — **screen is out of the flow while a single locale ships** | F1 selection, immediate sample spoken in that language, selected check, Continue enabled. Audio failure keeps text choice usable. |
| G02 | role chosen | F1 selection + pictogram/label confirmation; one spoken summary in guided mode. Continue routes only after explicit tap. |
| G03 | phone entered | Live country formatting; F2 after stable valid number. On Submit, F7 while OTP is prepared; F4 with exact correction/failure without clearing number. |
| G04 | OTP entered | Filled cells are visibly distinct. Complete code triggers F7 verification once; valid F5 and route; invalid F4, focus first cell, keep code selectable and allow correction. Resend has visible countdown. |
| G05 | Retry/help | Error state names what failed and one next action. Retry gives F0 then F7; success F5 and returns; repeated failure F4 once per attempt. |
| S01 | preference changed | Toggle uses F1, state word On/Off and immediate preview for sound/haptic/voice. Destructive mode/data changes open M10/M09, never happen on toggle alone. |
| S02 | component state changed | Every catalogue control demonstrates its visual, semantic, motion, haptic-disabled and reduced-motion states; no real data mutation. |

### Client

| ID | Meaningful event | Required feedback and recovery |
|:--|:--|:--|
| C01 | query/filter/location changes | Debounced search shows F7 only after 300 ms. Results replace without jumping scroll; live status announces count once. Applied filters use F1. Voice uses F6. Empty/error always offers one clear recovery. |
| C02 | profile understood/contact requested | Scroll and property taps use normal F0. Contact CTA gives F0 then M04. Profile-view logging is silent. Missing channel/profile data is shown before contact, not discovered after leaving. |
| C03 | photo/property/contact | Gallery position has visible count and optional selection tick, no vibration per swipe. Status changes are visual + semantic. Contact follows M04. Reporting bad information confirms receipt with F5. |
| C04 | history filtered/contact selected | Filter uses F1 and count update. Eligible review CTA visibly differs from completed/pending. Empty history points to C01. No haptic when background status refreshes. |
| C05 | stars/criteria/review submitted | Each star/criterion uses F1. When all required ratings exist, step gets F2 once. Missing rating on Next uses F4 and focuses it. Submit F7 then F5 with « Avis envoyé pour modération »; failure retains all input. |
| C06 | identity/settings/data deletion | Profile fields follow form contract. Successful identity save F5. Phone change requires OTP. Data deletion requires M09 and reports exactly what was removed. |

### Broker / agency

| ID | Meaningful event | Required feedback and recovery |
|:--|:--|:--|
| B01 | dashboard loads/action chosen | Counts appear without celebratory motion. New actionable activity may show one badge, not sound. Primary Add property uses F0 then route. Partial profile shows one clear completion action. |
| B02 | filter/property action/status | Filters use F1 and stable scroll. Status uses M08. Delete uses M09. Successful mutation F5 and updates card in place; failure F4 restores previous state. |
| B03 | property fields/steps/photos/draft | Every field follows form contract. A complete step gets F2 once; Next animates standard. Draft save is a subtle check/status, silent. Photo and voice use M11/F6. Submit invalid focuses first issue; publish F7 then F5. |
| B04 | preview/publish/status/delete | Preview clearly says Draft/Preview. Publish uses F7/F5. Status uses M08; delete M09. Client visibility consequence is stated before change. |
| B05 | activity segment/read status | Segment F1. Opening an item marks read with subtle visual update only. Empty states differ for consultations and contacts. Background events never vibrate in prototype. |
| B06 | review response/report | Response field validates length and preserves draft. Send F7/F5. Report opens M12; result shows moderation status. Failed send/report F4 without losing text. |
| B07 | profile completeness/action | Completeness is words + progress, not color alone. Preview and ranking taps use F0. Verification status changes appear with one semantic announcement when screen is open. |
| B08 | profile fields/coverage/save | Form contract on all fields; phone validates and may require OTP. Coverage selections use F1. Save F7/F5; verification prerequisite explains next action rather than generic failure. |
| B09 | document capture/submission/status | Capture uses M11; quality checks show F2 or corrective F4. Submission F7 then F5 « Envoyé pour vérification ». Refusal explains reason and one restart action, no blame language. |
| B10 | ranking inputs/zone | Zone selection F1; score breakdown updates with bounded standard motion. Explain changes in plain language. No sounds, rank-loss vibration or manipulative gamification. |

### Sheets, overlays and transient surfaces

| ID | Meaningful event | Required feedback and recovery |
|:--|:--|:--|
| M01 | filter toggled/applied | Each choice F1, result count preview updates politely. Apply F2/F5 only if state changed; reset requires explicit tap but no destructive warning. |
| M02 | location searched/chosen | Search follows form contract. GPS acquisition F7; position found F2 + map marker; timeout/denial gives manual option, not repeated prompt or blame. |
| M03 | voice listening/understanding | F6 start/listen/processing/stop. Show live level, timer and transcript. Understood command is read back before Apply. Silence, ambiguity and an unrecognised command each have specific retry/manual actions. |
| M04 | contact channel chosen | Available channel F1/F0, then ContactLog F5 before external launch. Failed launch F4 and remains open. Recording voice uses F6 and preview before send/share. |
| M05 | contact outcome chosen | Choice F1; save F5 and update review eligibility visibly. « Pas de réponse » never produces failure haptic. Later dismisses quietly. |
| M06 | permission decision | Explain benefit and alternative first. Continue opens system prompt. Denial is a valid choice: no F4/haptic/sound; show manual path. Settings shortcut only after permanent denial. |
| M07 | option selected | F1 selection, check moves, sheet closes after 140 ms and field receives F2 if now valid. Search errors never clear existing choice. |
| M08 | property status changed | Explain public effect. Selection F1; commit F7/F5. Failure restores previous status and uses F4. Sold/rented disappearance from client views is stated before commit. |
| M09 | destructive/unsaved confirmation | Opening may use F3 only after a user action. Consequence and object named. Confirm F0 then F7/F5 or F4; Cancel is silent and preserves state. |
| M10 | demo mode switch | Preview item counts and data loss. Confirm F3 then F7 with progress; complete F5 and clean route reset. Transaction failure F4 and old mode/data remain intact. |
| M11 | photo source/processing | Source F1, capture returns placeholder immediately, processing F7 per item, success F2, failure F4 on that item only with Retry/Remove. Show count/size remaining. |
| M12 | review response/report | Selection F1; text follows form contract. Submit F7/F5; failure F4 and keeps text/reason. Moderation-pending status is persistent, not toast-only. |
| M13 | transient confirmation | Reveals in 220 ms then **stays 6 s**, extended to **10 s** above ×1.2 text scale and while a screen reader is active. Icon + concrete message, semantic live region. Carrying an Undo extends it to the full undo window. Never the only error explanation, never the only destructive action. Duplicate messages coalesce instead of stacking. |

## 7. Cross-screen continuity

- A control responds within 100 ms even if the operation is slow.
- Loading appears only after 300 ms to avoid flicker; once shown it stays at least **400 ms**, so a
  fast result does not read as a flash. Repeated taps are blocked without changing width.
- Optimistic updates are used only when reversible. On failure, restore prior state and explain it.
- Navigating back restores field values, scroll, filters, selected segment and draft state.
- Returning from phone/WhatsApp/photo/permission shows the result of that interruption exactly once.

### Confirm or undo, never both

An action gets a confirmation sheet **or** an undo affordance. Never the two. A product that asks
first and offers undo afterwards teaches its users to confirm without reading, which is exactly the
habit that makes a destructive sheet useless later.

| Nature | Treatment |
|:--|:--|
| Reversible — property status, filter removal, unpublished photo removal, read/unread | optimistic change, then M13 carrying **Undo** |
| Irreversible or destructive — delete a property, purge demo data, leave a modified form | M09 naming the object and the consequence, no undo afterwards |

Undo window: **6 s**, **10 s** above ×1.2 text scale or with a screen reader active — the same
figure as the M13 lifetime, because the affordance and its carrier are the same object. An undo
restores the previous state exactly, scroll position included.

### Feedback event identity

"A stable ID" needs a defined scope, otherwise it cannot prevent the case it exists for.

- An event ID is `<screen or sheet id>:<intent>:<subject key>` — for example
  `B02:success:property-42`. The subject key is the domain identifier, never a list index.
- The ID is held by the **view model that owns the flow**, not by the widget, and dies with it. A
  rebuild, a `notifyListeners()` or a re-entry through `go_router` restoration therefore finds the
  ID already consumed and stays silent.
- Consumption is recorded when the feedback is **emitted**, not when the operation starts, so a
  retry of the same operation after a real failure emits again.
- Two different subjects never share an ID: publishing two properties in a row is two successes.

## 8. Repetition and second-time use

Feedback answers "did it hear me". This section answers "why am I typing this again". Moussa
publishes ten properties; a client contacts four brokers in an afternoon. **The second pass must be
shorter than the first**, or the app is only pleasant to use once.

- **Prefill from the last saved record** in B03 step 1 and B08: type, transaction, neighbourhood.
  Prefilled values are visibly marked as prefilled and are one tap from being cleared.
- **"Comme le précédent"** appears in B03 step 1 as soon as one property exists, and fills type,
  transaction, neighbourhood and price band in a single tap.
- **After publishing**, the success state offers "Ajouter un autre bien" which returns to step 1
  **keeping the shared values**, not an empty form. Publishing three flats in one building must not
  mean filling the same address three times.
- **Recents first** in M02 and in any `WkOptionSheet` where history is meaningful, above the
  alphabetical list, labelled as recent rather than silently reordered.
- **C04 offers "Rappeler" directly on a history row**, without reopening C02. Re-contacting someone
  already contacted is the most repeated client action in the product.
- **Draft resumption is offered, never automatic**: returning to B03 states which property the draft
  belongs to and how old it is, with Reprendre and Recommencer side by side.
- Filters, segment and neighbourhood survive the session; a segment change never resets them, as
  already required by the C01 contract.

None of this may guess silently. A prefilled field that the user did not notice becomes a wrong
listing published under her name.

## 9. Implementation contract

Use one provider-injected `InteractionFeedbackService` wrapping Flutter platform APIs and the
existing audio layer. It reads preferences and exposes semantic intents, not raw vibration lengths:

`selection()`, `stepValid()`, `warning()`, `error()`, `success()`, `recordingStarted()`,
`recordingStopped()`, `announceStatus()`.

Widgets request an intent only after a user-visible state transition. The service deduplicates by
event ID, respects settings/accessibility, and has a fake for tests. Business services never trigger
UI feedback directly.

Shared UI additions:

- `WkFieldStatus` for checking/valid/error helper space;
- `WkLiveStatus` for result counts, progress and semantic announcements;
- `WkProgressAction` behavior inside `WkButton`, not a second button component;
- feedback states added to existing `WkTextField`, `WkPhoneField`, `WkOtpField`, `WkSelectField`,
  `WkPhotoPicker`, `WkVoiceOverlay` and `WkToast`.

## 10. Verification

- Unit: validation timing/state machine, feedback-policy mapping, event deduplication and preference
  suppression.
- Widget: valid/invalid/checking field states, focus first error, no layout shift, live-region message,
  disabled reason, reduced motion and ×1.3 text.
- Integration: OTP failure/retry, search voice ambiguity, review validation, property draft/publish,
  permission denial and demo-mode transaction failure.
- Manual device: haptic intensity, silent/DND behavior, TalkBack/VoiceOver collision, keyboard, 320 dp,
  low-end Android frame stability and external-app return.

No screen passes review while a meaningful action can appear to do nothing, while feedback repeats
after rebuild, or while recovery requires reading a technical error.
