---
name: AeroTech Reservas
description: An air-operations control surface where routes, status, and action stay immediately legible.
colors:
  midnight-navy: "#071A2E"
  operations-navy: "#102A43"
  route-cyan: "#20C7E5"
  action-blue: "#2477F3"
  alert-coral: "#FF6B5E"
  success-emerald: "#17B890"
  ice: "#F2F8FC"
  rule: "#D7E4EC"
  flight-ink: "#102235"
  telemetry-muted: "#63788A"
  white: "#FFFFFF"
typography:
  display:
    fontFamily: "SpaceGrotesk, Arial, sans-serif"
    fontSize: "46px"
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: "-1.2px"
  headline:
    fontFamily: "SpaceGrotesk, Arial, sans-serif"
    fontSize: "27px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.5px"
  title:
    fontFamily: "SpaceGrotesk, Arial, sans-serif"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "1.1px"
  body:
    fontFamily: "SpaceGrotesk, Arial, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "normal"
  label:
    fontFamily: "SpaceGrotesk, Arial, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "1px"
rounded:
  chip: "9px"
  control: "12px"
  card: "16px"
  panel: "18px"
  form: "20px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "24px"
  panel: "30px"
components:
  button-primary:
    backgroundColor: "{colors.route-cyan}"
    textColor: "{colors.midnight-navy}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "16px 20px"
    height: "52px"
  button-operations:
    backgroundColor: "{colors.midnight-navy}"
    textColor: "{colors.white}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "8px 16px"
  input:
    backgroundColor: "{colors.white}"
    textColor: "{colors.flight-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.control}"
    padding: "16px"
  flight-card:
    backgroundColor: "{colors.white}"
    textColor: "{colors.flight-ink}"
    rounded: "{rounded.card}"
    padding: "16px"
---

# Design System: AeroTech Reservas

## Overview

**Creative North Star: "The Illuminated Flight Path"**

AeroTech is a crisp air-operations control surface: midnight navigation chrome frames cool, highly legible work areas while cyan traces the active journey through the interface. The FlyGo login opens this system with a layered aviation hero: a sky background plate supports a transparent full-aircraft cutout beside a calm white authentication surface. Route data remains the visual protagonist after entry. The custom A-wing mark, airport codes, fine rules, and route illumination create an unmistakable aviation identity without turning operational tasks into decoration.

The system feels precise, assured, and energetic. Dense information is grouped into calm white or ice surfaces, with coral reserved for route nodes and exceptions and emerald reserved for successful or available states. Motion tells the story of travel without delaying the task: the login photograph drifts and zooms almost imperceptibly while its content enters once, and every moving treatment resolves immediately when reduced motion is requested.

**Key Characteristics:**

- Midnight navy operational framing with cool white and ice work surfaces.
- Cyan route lines, focus states, and primary actions.
- Compact Space Grotesk hierarchy with bold airport and status labels.
- One-pixel rules, 12–16px control geometry, and restrained shadows.
- Route-driven storytelling, anchored by the featured UIO→GYE journey.
- Layered FlyGo welcome with a sky plate, transparent full-aircraft cutout, and soft white edge blend into authentication.
- Top-down narrow-body cabin maps that turn A–D seat data into an immediately legible 2–2 aircraft interior.
- Admin-only operations intelligence that pairs a white/ice overview with navy commercial analysis and durable coral audit evidence.

## Colors

The palette pairs dark cockpit framing with bright route telemetry and quiet, cool work surfaces.

### Primary

- **Midnight Flight Deck:** The structural color for app bars, login atmosphere, operational buttons, and the dark A-wing tile.
- **Route Illumination:** The active-route color for primary actions, icons, focus borders, dividers, and animated paths.

### Secondary

- **Operations Navy:** A softer dark layer for supporting structure and tonal variation.
- **Action Blue:** A secondary interactive blue when a distinct action family is required.

### Tertiary

- **Coral Route Node:** Marks route endpoints, errors, destructive or administrator-specific signals; never a general accent.
- **Emerald Clearance:** Communicates success, availability, and confirmed operations.

### Neutral

- **Hangar Ice:** Default application canvas behind working surfaces.
- **Flight Rule:** One-pixel borders, separators, and field outlines.
- **Flight Ink:** Primary text on light surfaces.
- **Telemetry Muted:** Supporting labels, timestamps, and secondary explanations.
- **Cool White:** Cards, fields, and high-contrast text on navy.

### Named Rules

**The Route Has One Light Rule.** Cyan identifies the active journey or action; do not spread it across passive decoration.

**The Operational Signal Rule.** Coral means exception or endpoint, and emerald means success or availability. Never swap their semantics for variety.

## Typography

**Display Font:** Space Grotesk (with Arial and sans-serif fallback)  
**Body Font:** Space Grotesk (with Arial and sans-serif fallback)  
**Label Font:** Space Grotesk (with Arial and sans-serif fallback)

**Character:** One geometric family keeps the interface technical and direct. Weight, tracking, and case establish hierarchy; alternate decorative typefaces are unnecessary.

### Hierarchy

- **Display** (700, 46px, 1.05): Desktop welcome statements and rare identity moments.
- **Headline** (700, 27px, 1.15): Page and panel entry headings.
- **Title** (700, 18px, 1.2): Wordmarks, card titles, and operational section labels.
- **Body** (400, 14px, 1.4): Instructions, field content, and supporting detail; keep long copy concise.
- **Label** (700, 12px, 1.2): Airport codes, statuses, chips, and compact actions; tracked uppercase is appropriate for operational metadata.

### Named Rules

**The Call-Sign Rule.** Use uppercase and wider tracking for short operational labels, never for paragraphs or validation messages.

## Layout

Desktop surfaces sit in centered working areas up to 1180px wide; focused forms narrow to roughly 440–780px. The FlyGo login is a split composition: a sky background plate and a white authentication panel meet through a narrow, soft white gradient blend, never a hard blue/white curve. A transparent full-aircraft cutout sits above both layers, crosses the fade, and extends slightly into the white form zone while remaining clear of every field, label, and action. A 16px core rhythm governs cards and fields, expanding to 20–30px for panels and 56px outer gutters on wide screens. At widths below 820–850px, side-by-side storytelling collapses into a single scrollable column; below 440px, panels preserve 18–20px side gutters rather than forcing desktop widths.

Route information reads directionally from origin to destination. Keep airport codes, time, status, and price aligned into scannable clusters, with the primary action at the terminal edge of the row. Desktop pairs may collapse or wrap on narrow screens, but their semantic order must remain intact.

Seat selection centers a narrow-body cabin at up to 430px wide inside a broader 620px content area. The 2–2 seat grid compresses from 58px to 48px seat columns and from 58px to 44px aisle width on compact screens. Normal phone widths keep the cabin centered without horizontal scrolling; only viewports narrower than 300px may use a minimal horizontal fallback. The checkout summary must remain flexible: seat labels can wrap or ellipsize, totals stay legible, and the confirmation action must not be pushed off-screen. Reservation-card actions use a wrapping row with 8px horizontal and 6px vertical gaps so PDF, cancellation, and seat-change actions remain reachable without shrinking labels or overflowing.

Administrative intelligence uses a full-width ice work surface with 20px content padding. The metric band flows from four columns at 720px and above, to two columns between 480px and 719px, then one column below 480px. The overview pair uses a 5:3 split between upcoming departures and commercial activity on wide screens, stacking vertically below 850px. Audit records keep route identity and evidence on one row when space permits, then stack their metadata below 680px without hiding timestamps or related-reservation counts.

## Elevation & Depth

The system is flat by default and uses borders and tonal contrast for structure. Working cards carry a one-pixel cool rule; a restrained navy-tinted shadow may lift flight cards, while the complete split login shell receives the strongest ambient shadow against the pale page canvas.

### Shadow Vocabulary

- **Flight card:** `0 4px 10px rgba(7,26,46,0.05)` provides minimal separation from the ice canvas.
- **Login shell:** `0 18px 42px rgba(7,26,46,0.12)` contains the photographic hero and white authentication panel as one elevated object.

### Named Rules

**The Instruments, Not Tiles Rule.** Prefer one-pixel rules and surface contrast; use shadow only when a layer must clearly sit above its environment.

## Shapes

Controls use crisp 12px corners, cards use 14–16px corners, and major panels use 18–20px corners. Chips tighten to 9–10px. Borders stay one pixel except the 2px cyan focus state. The A-wing mark uses a compact rounded-square enclosure with a traced angular silhouette, a white crossbar, and a coral route node.

## Components

### Buttons

- **Shape:** Confident compact rectangle with a 12px radius and 52px height for primary form actions.
- **Primary:** Route cyan on midnight navy text with 16px vertical and 20px horizontal padding.
- **Hover / Focus:** Increase cyan intensity or darken the navy text relationship; retain a clearly visible cyan focus outline without moving layout.
- **Operations:** Midnight navy with white text for booking; administrator edit may use cyan text on navy. Destructive actions use coral/red only.

### Chips

- **Style:** Translucent white on navy or ice on light surfaces, with a compact 9px radius, cyan icon, and bold 12px label.
- **State:** Chips summarize capabilities or route metadata; selected filters must gain a clear cyan border or fill rather than rely on colorless weight changes.

### Cards / Containers

- **Corner Style:** 16px for flight cards and 18–20px for primary panels.
- **Background:** Cool white over the ice canvas; translucent white may appear only on navy atmospheric surfaces.
- **Shadow Strategy:** Border-first, with flight-card or login-panel shadow only where documented above.
- **Border:** One-pixel Flight Rule on light surfaces; low-opacity white on navy.
- **Internal Padding:** 16px for data cards, 30px for focused form panels.

### Inputs / Fields

- **Style:** White fill, one-pixel Flight Rule outline, 12px radius, and 16px internal padding; a navy leading icon reinforces field meaning.
- **Focus:** A 2px Route Illumination border is the canonical focus signal.
- **Error / Disabled:** Error messaging uses a pale coral field with coral iconography; disabled actions visibly lose contrast while preserving labels.

### Navigation

The app bar is midnight navy with cool-white content, an A-wing logo, and short uppercase operational subtitles in cyan. Keep navigation titles left aligned and pair the user's role or current operation with the title when it improves recognition.

### Route Story

The featured UIO→GYE route uses airport codes at opposing ends of a cyan line with a flight glyph between them. On dark canvases, the line may illuminate over 3200ms; when reduced motion is enabled, show the completed route without animation. Coral endpoint nodes are the signature visual motif.

### FlyGo Login Hero

Build the desktop hero from two distinct image layers. The sky background plate fills the left side and carries a subtle navy vertical wash for white-copy legibility. A transparent cutout must show the complete aircraft and render above the sky, soft fade, and white form layer; let it cross the seam and extend slightly into the form zone, but establish a protected control area so it never covers fields, labels, validation, or actions. Blend the sky plate into the white form with a short transparent-to-white gradient; never substitute a hard blue/white curve. Apply the 8-second transform-only drift and zoom loop (approximately ±5px translation and 1.035–1.053 scale) to the aircraft composition without clipping the plane. Hero content enters once over 900ms with eased opacity and a 24px upward settle. Both animations must read `MediaQuery.disableAnimationsOf(context)`: reduced motion stops the controller, uses a stable transform, and makes content visible immediately.

**The Aircraft Bridge Rule.** The full aircraft bridges sky and form as a foreground cutout, but the form's interactive control area always remains unobstructed.

### Cabin Seat Map

Render seat data as a top-down narrow-body aircraft rather than a generic grid. Derive rows from seat identifiers and place letters A–B to the left of the central aisle and C–D to the right. Use a rounded navy cockpit at the front, slim side windows aligned with every row, centered row numbers in the aisle, and a clearly labeled rear exit. The aircraft shell is cool white/ice with a fine rule and restrained navy shadow.

- **Available:** Pale blue fill, cyan outline, navy seat icon and label.
- **Selected:** FlyGo action blue fill and outline, white check and label, with a restrained blue lift.
- **Occupied:** Neutral gray fill and outline, muted lock and label; it is visibly and behaviorally unavailable unless it belongs to the reservation currently being edited.
- **Transition:** Seat state changes use a fast 180ms ease-out treatment; state must never depend on animation alone.

**The Data Defines the Cabin Rule.** Generate rows from A–D seat identifiers and preserve gaps for missing seats; never fabricate capacity to complete the silhouette.

**The Aisle Stays Legible Rule.** Row numbers remain centered between B and C at every supported width, with windows outside A and D.

**The Concurrency Contract Rule.** The cabin presentation does not change booking concurrency logic: if another passenger takes a seat, refresh availability, restore the valid selection state, explain the conflict, and ask the client to choose again.

### Reservation Modification State

Client reservations permit one confirmed modification maximum. During that change, clients may replace existing seats or expand the reservation by adding seats, but they may not reduce the original seat count. A change is consumed only after the user selects a genuinely different seat set and the update succeeds; opening the editor, submitting the original seats, validation failure, cancelling the confirmation, or a failed request must not consume it. Before confirmation, disable the action and explain that at least one seat must differ.

The final confirmation is deliberately explicit and irreversible. Show the resulting seat count and recalculated total, call out the number of additional seats when the reservation expands, and offer “Volver y revisar” beside a lock-marked “Sí, confirmar” action. After success, replace the edit affordance with a permanent amber lock warning stating that the reservation can no longer be modified.

**The Real Difference Rule.** A one-time reservation change is spent only by a successful, materially different seat selection.

**The Permanent Warning Rule.** Once spent, the locked state and its explanation remain visible wherever the reservation is shown.

**The Preserve-or-Expand Rule.** The definitive change may replace or add seats, but it never reduces the reservation below its original passenger count.

### Ticket PDF

Active reservations expose a “Boletos PDF” action with a PDF icon. After a successful definitive seat change, generate and download the refreshed tickets automatically. The success dialog must distinguish between complete success and a download failure: the reservation remains irreversibly modified in either case, while a failed download directs the client to retry from “Mis reservas.” Use a FlyGo-branded filename tied to the reservation code or identifier; do not imply that PDF generation controls whether the reservation update committed.

Reservation-card actions are responsive as a group. Let “Boletos PDF,” “Cancelar,” and “Cambiar Asientos” wrap onto additional lines in their existing semantic order, preserving readable labels and tap targets. PDF remains available only for active reservations; the seat-change action disappears once the one-time modification has been consumed.

**The Commit Before Document Rule.** The reservation update is authoritative before ticket generation begins; a PDF failure is recoverable and never rolls back or disguises the confirmed change.

### Session Continuity

Keep the authenticated experience continuous until the JWT expires. On web, write and read the FlyGo token and role directly from `localStorage`; migrate away any legacy `flutter.`-prefixed copy when saving and remove both key forms when clearing the session. A valid stored token and role restore the correct working surface on launch without sending the user through login again. Session restoration is invisible: do not add an intermediate welcome, confirmation, or repeated credential prompt when the token is still valid.

At the JWT expiry time—or immediately after any authenticated request returns 401—clear the stored credentials and role, remove the protected navigation stack, and return automatically to the FlyGo login. Protected screens must not remain visible behind a dialog or back gesture. When copy is needed, use the specific message “La sesión expiró. Inicie sesión nuevamente.” rather than a generic network error.

**The Token Is the Clock Rule.** Session duration follows the JWT expiry claim; interface timers never extend or invent authentication validity.

**The Clean Return Rule.** Expiry and 401 responses end the protected session globally and return to login with no route back into stale authenticated state.

**The One Web Store Rule.** Web session truth lives directly in `localStorage`; compatibility reads may recover a legacy prefixed value, but new writes leave one canonical unprefixed key.

In local web development, unregister existing service workers before Flutter starts and keep service-worker versioning disabled for that development entry point. This prevents an obsolete cached build from running session-clearing code against the current `localStorage` contract. Treat this as development hygiene, not as a user-visible loading state or a production caching doctrine.

**The Current Build Owns Development Rule.** Development web must remove obsolete service-worker registrations before app startup so an old build cannot erase or reinterpret the active session.

### Silent Synchronization & Concurrency

Live operational surfaces refresh without interrupting the task. The seat map synchronizes every 5 seconds and “Mis reservas” every 10 seconds, while both retain explicit pull-to-refresh or direct reload behavior. Periodic refreshes are silent: do not show a full-page spinner, clear content, steal focus, or announce routine success. Prevent overlapping refreshes and stop the timer when its surface is disposed.

The complete flight catalog synchronizes every 6 seconds while the flight route is visible. Refresh both the full catalog that feeds origin/destination choices and the currently filtered results, preserving active filters. Pause polling when another route covers the surface, resume with an immediate refresh on return, and prevent overlapping requests. Routine price or availability changes use the existing fresh-data notice; a newly published flight gets the specific message “Se publicó un nuevo vuelo. El catálogo y los filtros ya fueron actualizados.” Use the counted plural form for multiple new flights. Replace the current snackbar rather than stacking repeated notices.

When a silent seat refresh invalidates part of the current selection, remove only the seats that became unavailable, preserve every still-valid choice, update the map, and show a specific amber conflict message. Name one lost seat directly—“El asiento [número] acaba de ser reservado por otra persona…”—or list multiple seats and use the plural form. The message must state that the map was updated and ask the client to select alternatives.

For server-detected conflicts, explain the collided operation and the recovery already performed:

- **Seat booking:** Another client reserved one of those seats; the map was updated, so review availability and select another.
- **Reservation expansion/change:** Availability changed during confirmation; seats were updated, so review the selection before continuing.
- **Reservation cancellation:** The reservation changed during cancellation; its state was refreshed, so review before retrying.
- **Flight deletion:** The flight changed during deletion; the list was refreshed, so review its state before retrying.
- **Last capacity:** Another client took the remaining capacity; flight availability was refreshed, so choose another option.

When the same user opens one reservation in two tabs and the other tab confirms its one allowed modification first, do not show the generic concurrency banner or leave the stale editor usable. Present a non-dismissible amber/orange dialog with the sync-problem icon, title “Reserva actualizada en otra pestaña,” and the explanation: “Esta misma reserva ya fue modificada y confirmada desde otra pestaña. La información de esta pantalla quedó desactualizada; volveremos a Mis reservas para mostrar los asientos definitivos.” Provide one receipt-marked action, “Ver mis reservas.” After acknowledgement, close the stale seat editor and return to the refreshed “Mis reservas” surface.

Use an amber/orange treatment for recoverable concurrency conflicts and reserve coral/red for validation or unrecoverable errors. The message should describe what changed, what FlyGo refreshed, and the user's next action; never reduce a conflict to “Something went wrong.”

**The Quiet Until Relevant Rule.** Routine synchronization is invisible; surface feedback only when new data changes the user's selection or requested action.

**The Preserve Valid Work Rule.** A conflict removes only invalid state and keeps every still-valid selection and input intact.

**The Stale Tab Must Exit Rule.** Once another tab consumes the reservation's definitive change, the stale editor explains the cross-tab update and returns to “Mis reservas”; it never invites another retry.

**The Full Catalog Rule.** Background refresh updates the unfiltered catalog and filtered results together, so selectors can discover newly published cities without clearing the user's query.

### Search Dates

Flight-search date pickers begin at today. “Salida desde” cannot select an earlier date; “Salida hasta” cannot precede the chosen start date, and both allow dates up to two years ahead. Empty date fields mean no date filter, not an implied historical range. If stored or typed values are in the past, normalize the date-picker opening state to today without silently submitting a different filter.

**The No Past Search Rule.** New flight searches and flight creation/editing never offer dates before the current local calendar day.

### Flight Capacity Editing

Administrators edit total capacity, not remaining availability. Populate the field from total seats and label it “Capacidad total”; pair it with explicit supporting copy that capacity can never fall below already reserved seats. Increasing total capacity creates additional seat inventory; reducing it is allowed only down to the reserved count. A rejected reduction leaves the editor open with a specific explanation, while a 409 caused by concurrent capacity or availability changes refreshes the panel and asks the administrator to review before retrying.

**The Reserved Floor Rule.** Total capacity may change, but the saved value can never be lower than the number of seats already reserved.

**The Total, Not Available Rule.** Capacity fields and summaries must distinguish aircraft total from remaining availability; never preload an edit field with the available-seat count.

### Admin Operations Dashboard

The admin-only dashboard extends the Operate surface with two explicit tabs: “Resumen” for current network health and “Auditoría” for retained deactivation evidence. Use a white app bar over the ice canvas, navy identity text, and action blue for the active tab indicator, icon, and label. Inactive navigation stays muted. Manual refresh and pull-to-refresh are equivalent recovery actions; initial loading may use a centered progress indicator, while unavailable-server and generic-error states preserve a constrained retry surface.

The summary opens with a responsive metric band for active flights, completed flights, free seats, and active clients. Each metric uses the same white ruled container, a compact tinted icon tile, a strong 22px value, and a muted 12px label. Semantic colors clarify the reading: emerald for live/active capacity, action blue for completed operational counts, warm orange for available-seat inventory, and cyan for clients. These colors reinforce meaning but never replace labels.

“Próximas salidas” is a white ruled list ordered for scanning route, airline/date, departure time, and remaining seats. Route content expands first; time and capacity stay right aligned. Remaining seats use emerald to signal live capacity. An empty schedule stays inside the same container with a concise text state rather than inventing placeholder flights.

“Actividad de reservas” is the signature navy operations panel. It groups active reservations, confirmed passengers, confirmed revenue, and deactivated flights as divided label/value rows. White values carry emphasis; supporting labels use translucent white, and cyan appears only as the section marker. This dark panel is analytical contrast, not a second navigation region.

The audit tab treats soft deletion as evidence. Lead with “Vuelos desactivados,” explanatory copy, and a coral record-count badge. Each white audit record preserves route, airline, flight identifier, scheduled departure, deactivation timestamp, related-reservation count, and an inactive state. Use coral for the inactive/evidence signal and action blue for neutral metadata icons. On compact layouts, present each metadata field as its own labeled row; do not truncate the record into a generic status card. If the deactivation time is unavailable, label it “Registro anterior” rather than fabricating precision.

**The Overview Before Evidence Rule.** “Resumen” presents live operational health first; “Auditoría” preserves inactive evidence separately without mixing historical records into active metrics.

**The Color Carries Status, Labels Carry Meaning Rule.** Emerald denotes live capacity and coral denotes inactive evidence, but every metric and record remains understandable from text alone.

**The Audit Is a Record Rule.** Deactivated flights retain route, timing, identity, and relationship context; never reduce audit evidence to a count or delete affordance.

## Do's and Don'ts

### Do:

- **Do** make route, time, availability, price, and role recognizable within seconds.
- **Do** use one-pixel rules and the 12–16px geometry for most operational surfaces.
- **Do** keep the UIO→GYE route expression directional and preserve its origin-to-destination reading order.
- **Do** honor reduced-motion preferences by resolving animated routes to a complete static state.
- **Do** layer the full-aircraft cutout over the sky plate and soft fade, let it enter the white zone slightly, and keep its 8-second drift transform-only.
- **Do** preserve the one-time modification until a real seat difference is successfully confirmed, then show the permanent warning state.
- **Do** derive the 2–2 cabin from actual A–D seat data and keep cockpit, windows, aisle row numbers, and rear exit visible.
- **Do** reserve horizontal scrolling for widths below 300px and keep the checkout summary flexible at all widths.
- **Do** show added-seat count and recalculated total before the irreversible confirmation.
- **Do** keep PDF, cancellation, and seat-change actions readable by wrapping the action group on narrow cards.
- **Do** offer PDF retry from “Mis reservas” when automatic post-change download fails.
- **Do** restore valid JWT sessions directly into the correct role surface and end them automatically at expiry or 401.
- **Do** refresh seats every 5 seconds and reservations every 10 seconds without replacing content with loading states.
- **Do** identify the affected seat or operation in concurrency messages and state what was refreshed and what to do next.
- **Do** store the web token and role directly in `localStorage`, while cleaning legacy prefixed keys.
- **Do** refresh the complete flight catalog every 6 seconds and announce newly published flights without clearing active filters.
- **Do** start search calendars at today and keep the end date at or after the selected start date.
- **Do** edit total capacity and explain the reserved-seat minimum before submission.
- **Do** distinguish a same-reservation cross-tab update with its dedicated dialog and return path to “Mis reservas.”
- **Do** unregister obsolete service workers before starting the local development web build.
- **Do** keep admin “Resumen” and “Auditoría” as distinct blue-indicated tabs on the white operations bar.
- **Do** let the metric band resolve to four, two, then one column at the established responsive thresholds.
- **Do** pair emerald live capacity with coral inactive evidence while retaining explicit text labels.
- **Do** preserve route, timestamps, and related reservations in every audit record.

### Don't:

- **Don't** use coral or emerald as generic decoration; preserve their operational meaning.
- **Don't** bury flight data under aviation imagery, gradients, or oversized ornamental icons.
- **Don't** introduce soft pill geometry, heavy shadows, or unrelated typefaces that weaken the control-surface character.
- **Don't** animate route illumination when the platform reports that animations are disabled.
- **Don't** introduce a hard blue/white curve between the FlyGo photograph and form.
- **Don't** crop the aircraft into the background plate or let its foreground cutout cover form controls.
- **Don't** consume a client's only modification for an unchanged selection, validation error, or failed request.
- **Don't** recolor occupied seats as errors or allow their locked neutral treatment to imply interactivity.
- **Don't** alter, hide, or optimistically bypass the existing concurrency refresh behavior for visual convenience.
- **Don't** allow the one definitive change to reduce the original seat count.
- **Don't** present PDF download failure as a failed or reversible reservation update.
- **Don't** compress reservation actions into clipped labels or undersized targets when they can wrap.
- **Don't** let a back gesture reopen protected screens after session expiry.
- **Don't** show spinners, success banners, or focus changes for routine periodic synchronization.
- **Don't** discard valid selections when only some seats lose availability.
- **Don't** persist duplicate canonical and `flutter.`-prefixed web session keys after a write.
- **Don't** reset city or date filters when the background catalog refreshes.
- **Don't** offer past dates in search or flight-management date pickers.
- **Don't** confuse available seats with editable total capacity or permit capacity below reserved seats.
- **Don't** treat an already-confirmed change from another tab as a retryable seat-availability conflict.
- **Don't** allow a stale development service worker to boot an older build that clears or rewrites the current session.
- **Don't** expose the admin dashboard or its audit evidence to client-role navigation.
- **Don't** merge inactive audit records into upcoming departures or live operational totals.
- **Don't** flatten the navy commercial-activity panel into an undifferentiated grid of white cards.
- **Don't** hide audit metadata on compact screens; stack it into labeled rows.
