# Heddle — Build Specification

> Portfolio app 188, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Attach a daily caption, photo, or voice note to beads on a vertical thread.

| Field | Value |
| --- | --- |
| Product name | Heddle |
| Bundle identifier | `com.heddle.bead` |
| Domain | https://heddle-bead.pro |
| Contact URL | https://heddle-bead.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `hed_` |
| User-Agent | `Heddle/1.0 (iOS; +https://heddle-bead.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Heddle -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A bead diarist ties a caption knot on the vertical thread and strings a photo or voice note so the bead files and the year cloth gains weft.

### 2.1 User flow

1. String a photo or voice clip onto the open knot that is already tied for today
2. Tie a new caption knot when today has no open Tied bead
3. Scroll the vertical thread to read an earlier bead
4. Open the year cloth sheet to see weekly weft density from strung knots
5. Open on-this-day to compare strung knots from prior years on this calendar date
6. Browse the gallery sheet for all strung media
7. Export or reset from Settings

### 2.2 Essential behaviour

- Vertical thread timeline with knot beads (UIKit scroll representable)
- Tie step: short caption KnotMark without media
- String step: PhotosPicker or AVAudioRecorder attaches to Tied knot
- Year cloth weave from ISO-week strung counts
- On-this-day panel for same month-day across years
- Gallery of strung knots
- Peel undo for last StringMark or KnotMark
- Local-only UserDefaults+Codable document and media in Application Support

---

## 3. Uniqueness assignment for Heddle

| Axis | Assigned value |
| --- | --- |
| Architecture | **Knot ADT fold (Loose | Tied | Strung); the thread is a fold over Knots; Tie writes a KnotMark with caption and folds Loose to Tied; String writes a StringMark when photo or voice attaches and folds Tied to Strung; String on Loose writes DriftMark; a second Tie on the same daykey writes FullMark until Peel; Peel drops the last StringMark or KnotMark; OnThisDay selects Strung knots sharing month-day across years; Cloth density folds Strung counts by ISO week; empty thread writes Loose** |
| UI approach | **SwiftUI Layout protocol · realitykit-lite** |
| Naming convention | **Tapestry / heddle-bead lexicon (Hub, Knot, Bead, Tie, StringMark, Cloth, Weft, OnThisDay, Peel)** |
| File organization | **By thread role (Hub, Knot, Bead, TieMark, StringMark, Cloth, WeftRow, GalleryTile, Loose) · bead** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **shadcn · thick-frame · mid** |
| Typography | **Trebuchet MS** |
| Navigation pattern | **Thread-locked chrome (the vertical thread never leaves; Cloth, Gallery, On-this-day and Settings arrive as sheets; tie and string fuse on Hub; no tab bar) · bead** |
| AI art style | **High contrast black and white photography · mixed-media** |
| Functional twist | **Tie-then-string (Tie opens a caption-only KnotMark; String attaches local photo or voice and folds Tied to Strung; String without Tie writes DriftMark; one Tie per daykey unless Peel; On-this-day compares prior years; Cloth weaves weekly Strung density; seed leaves Tied so String is live)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — moment_thread

**Core** — A bead diarist ties a caption knot on the vertical thread and strings a photo or voice note so the bead files and the year cloth gains weft.

**Audience** — People who think in knots on a string, not a reverse-chronological feed or a random past draw.

**User flow**

1. String a photo or voice clip onto the open knot that is already tied for today
2. Tie a new caption knot when today has no open Tied bead
3. Scroll the vertical thread to read an earlier bead
4. Open the year cloth sheet to see weekly weft density from strung knots
5. Open on-this-day to compare strung knots from prior years on this calendar date
6. Browse the gallery sheet for all strung media
7. Export or reset from Settings

**Essential features**

- Vertical thread timeline with knot beads (UIKit scroll representable)
- Tie step: short caption KnotMark without media
- String step: PhotosPicker or AVAudioRecorder attaches to Tied knot
- Year cloth weave from ISO-week strung counts
- On-this-day panel for same month-day across years
- Gallery of strung knots
- Peel undo for last StringMark or KnotMark
- Local-only UserDefaults+Codable document and media in Application Support

**Twist** — Tie-then-string. Home is the vertical thread. Tie writes a KnotMark with caption and folds Loose to Tied for that bead. String on Tied attaches local photo or voice, writes StringMark, and folds Tied to Strung. String on Loose writes DriftMark. A second Tie on the same daykey writes FullMark until Peel. Peel drops the last StringMark or KnotMark and may reopen Tied. On-this-day gathers Strung knots sharing month-day across prior years. Cloth rows derive Strung count per ISO week. Seed already Tie one caption-only knot for today so the opening tap is String. Home verb: tie-the-knot — not catch-the-glow and not seat-the-frame. Local only.

**Why this is not a repeat** — First shipped moment_thread: persisted tie and string on a vertical bead thread with a derived year cloth and on-this-day recall. Not Aedicule's coverflow catch, midnight wick, or random ray draw; not Autochrome seat/develop/flare; not year-mood canvas strokes or a plain dated list.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Vertical thread of beads. Year becomes a cloth.
- Invariant: Bead density per day. On-this-day = same calendar day in prior years.
- Never: Photo/voice stay on device.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

A Knot is a three-case fold of Loose, Tied, or Strung, and the thread is the ordered fold of those Knots. Tie on Loose writes a KnotMark that stores a short caption and folds that bead to Tied, while a second Tie on the same daykey writes FullMark and adds no bead until Peel. String on Tied writes a StringMark, attaches one local photo or voice file, and folds Tied to Strung, while String on Loose writes DriftMark and leaves every bead unstrung. Peel drops the newest StringMark or KnotMark and also drops a newest FullMark or DriftMark, reopening Tied when strung media leaves and Loose when the caption knot leaves. Bead density for a daykey is the count of Knots on that key, OnThisDay keeps Strung knots that share today's month and day in earlier years, Cloth density is the derived count of Strung knots in each ISO week, and an empty thread writes Loose.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Hub places the vertical thread with a custom SwiftUI Layout inside a ScrollView: one large open bead, then smaller strung beads at uneven gaps, edge to edge, using the remaining height and the full iPad width. That open bead is the only RealityKit surface, an ARView in non-AR camera mode with no session and no camera permission, one solid bead entity. Cloth, Gallery, OnThisDay, Thread, and Settings are stock List, Form, and sheet. Tie and String are native buttons on Hub with one ButtonStyle for default, pressed, disabled, and loading, the live verb in the accent, hit area at least 44 points with contentShape on the whole control. Thick frame and hairline depth use the kit radii only. One spring on a successful Tie or String, ease-out otherwise, and Reduce Motion fades with no spring. The layout name and RealityKit never appear as titles.

### 3.3 Naming contract

Convention: Tapestry / heddle-bead lexicon (Hub, Knot, Bead, Tie, StringMark, Cloth, Weft, OnThisDay, Peel).

Examples to follow: `HubView`, `KnotFold`, `StringMark`, `WeftRow`

### 3.4 Dependency contract

Heddle links no Swift package and no CocoaPods and no vendored source. project.yml has no packages key. System frameworks only: SwiftUI, UIKit, RealityKit, PhotosUI, AVFoundation, and Core Graphics. AVFoundation is AVAudioRecorder for a voice note and not a metadata capture session. URLSession is unused. The cgi search endpoint is unused so nothing leaves the device. PhotosPicker needs no library grant. Trebuchet MS ships as a font file in the app target and not as a package.

### 3.5 Navigation contract

The vertical thread never leaves Hub. There is no tab bar and no three-destination TabView. Cloth, Gallery, Thread, OnThisDay, and Settings arrive as sheets over that thread. Tie and String fuse on Hub. OnThisDay opens from the hub header. After onboarding, the today launch key stays on Hub, the log launch key presents Gallery, and the goals launch key presents Cloth. The thread, onthisday, and settings launch keys present Thread, OnThisDay, and Settings. Arguments are read once and only after onboarding is finished. Each key shows a different screen.

### 3.6 Screen composition contract

Thread-root fused hub (Hub holds the vertical thread and fused tie and string; Cloth, Gallery and Settings arrive as sheets; On-this-day from the hub header; no tab bar). Physical screens: Onboarding, Hub, Thread, Cloth, Gallery, OnThisDay, Settings. Onboarding is three or four full pages. Continue or Next is full width at the bottom. Skip still writes Loose and the completion flag. Settings can run it again. Hub is home and fills the device. Tie and String fuse here. After seed, today is Tied and String is the enabled primary verb. An empty thread is a full page with generated art, the headline The thread has no knots, the line Tie a caption on today, and a full-width Tie button. The today launch key stays on Hub. Thread is a sheet for one earlier bead, caption and media large, opened by tapping a bead. Cloth is a sheet of ISO-week weft rows derived from Strung counts. The goals launch key opens Cloth. Its empty page reads No weft this year, then A strung knot fills a week, with String. Gallery is a sheet of strung media. Each tile is framed and clipped. The log launch key opens Gallery. Its empty page reads No strung beads, then String a photo or a voice note on today's knot, with String. OnThisDay is a sheet from the hub header listing Strung knots from prior years on this month and day. Its empty page reads No prior year on this date, then String today to leave a knot for next year, with String. Settings holds local export, reset, onboarding again, and a tappable contact link to https://heddle-bead.pro/contact-us. Reset confirms that the thread and its media files will be deleted. FullMark copy is Today already has a knot. Peel to tie again. DriftMark copy is That string did not tie. Tie a caption first.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By thread role (Hub, Knot, Bead, TieMark, StringMark, Cloth, WeftRow, GalleryTile, Loose) · bead**

```
Heddle/
  Hub/HubView.swift
Hub/ThreadLayout.swift
Hub/OpenBeadView.swift
Hub/ThreadSheet.swift
Hub/OnThisDaySheet.swift
Hub/SettingsSheet.swift
Knot/Knot.swift
Knot/KnotFold.swift
Knot/Peel.swift
Knot/ThreadDocument.swift
Bead/BeadView.swift
TieMark/KnotMark.swift
TieMark/FullMark.swift
StringMark/StringMark.swift
StringMark/DriftMark.swift
Cloth/ClothSheet.swift
WeftRow/WeftRow.swift
GalleryTile/GallerySheet.swift
GalleryTile/GalleryTile.swift
Loose/LoosePage.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Hub
A first-class screen for **Hub**. Must render empty, populated and error states.

### 5.3 Thread
A first-class screen for **Thread**. Must render empty, populated and error states.

### 5.4 Gallery
A first-class screen for **Gallery**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Knot** — named per this app's convention.
- **Attachment** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **shadcn · thick-frame · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#28482E` | Screen background |
| `surface` | `#38573D` | Cards, rows, sheets |
| `ink` | `#F4F6F4` | Primary text and icons |
| `accent` | `#7BD58A` | Primary action, key figure, progress fill |
| `muted` | `#B6C3B8` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Heddle/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Trebuchet MS**

Trebuchet MS is the Heddle face loaded as TrebuchetMS and TrebuchetMS-Bold through one accessor of six steps scaled with Dynamic Type. Display is short and wide for Tie and String usually one or two lines. Body sits near 17 points with generous leading for captions on beads. Weft counts and ISO week indexes go through NumberFormatter with monospaced digits. A single hairline rule separates the open bead from the thread. No second family. At the largest accessibility size the display step shrinks before it clips. Day edges use Calendar.current.startOfDay.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **24pt** for cards, sheets and primary surfaces; **10pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI Layout protocol · realitykit-lite**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI Layout protocol · realitykit-lite** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **shadcn** — steal rhythm and restraint, not their colours or logos.

Mood: **Shadcn/ui-inspired design with minimal, clean components, monochrome palette, and utility-first patterns.**.

Home rhythm (`thick-frame`, airy): Thick frames, hard corners, one loud accent.

High-end agency: huge type, air, one accent, hairline depth. Layout `thick-frame`, density airy. Kit 24/10, shadow, filled capsule. Palette recipe `mid`. One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Editorial measure, generous leading, one rule. Reference type feel: agency.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

One Codable Thread document is the only UserDefaults record under the single key hed.thread.v1 with schemaVersion starting at 1. It holds Knot beads plus KnotMark captions plus StringMark file names plus DriftMark rows plus FullMark rows. Photo and voice bytes live in Application Support and the document stores file names only. Weft counts and OnThisDay lists are derived and never stored. In-memory ThreadStore is the source of truth and UserDefaults is the projection. Saves debounce after each mark and flush when scenePhase becomes inactive or background and after Peel or reset. A decode failure restores the backup and otherwise starts from Loose without crashing. resetAllData() lives on Settings and deletes media files. Views never touch UserDefaults. Day keys are Int values in YYYYMMDD form taken from Calendar.current.startOfDay. Simulator seed runs once behind hed.demo.v1 and marks onboarding complete and files several Strung knots across weeks and one prior year on this month-day and leaves today Tied with a real caption so String is enabled and never seeds FullMark as the first frame. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Heddle/1.0 (iOS; +https://heddle-bead.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Tie-then-string (Tie opens a caption-only KnotMark; String attaches local photo or voice and folds Tied to Strung; String without Tie writes DriftMark; one Tie per daykey unless Peel; On-this-day compares prior years; Cloth weaves weekly Strung density; seed leaves Tied so String is live)

Tie then string is the home pair: Tie writes a caption-only KnotMark and folds Loose to Tied, and String runs only on that Tied bead. String takes a photo from PhotosPicker or a voice clip from AVAudioRecorder, writes StringMark, stores the file in Application Support, and folds Tied to Strung so the year cloth gains weft. String with no Tied bead today writes DriftMark and does not invent a Strung knot, and a second Tie on that daykey writes FullMark until Peel. Peel removes the last StringMark or KnotMark and can reopen Tied, which is the only way to tie again that day. On this day lines up Strung knots that share this month and day in prior years, and each Cloth row is the Strung count for one ISO week. The simulator seed already ties one caption-only knot for today so the opening tap is String, and it files earlier Strung knots so the thread is already in use.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **High contrast black and white photography · mixed-media**


Base prompt, reused and extended for every asset:

```
High-contrast black and white photography mixed with cut paper, fiber thread, and a solid photographic bead. Hard tonal separation, visible grain, mixed-media collage, quiet negative space around the subject, no lettering, no glossy glass, no hollow frames.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `hed_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `hed_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `hed_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `hed_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `hed_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `hed_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `hed_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `hed_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `hed_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `hed_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `hed_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Tie-then-string (Tie opens a caption-only KnotMark; String attaches local photo or voice and folds Tied to Strung; String without Tie writes DriftMark; one Tie per daykey unless Peel; On-this-day compares prior years; Cloth weaves weekly Strung density; seed leaves Tied so String is live)' feature screen. |
| 11 | `hed_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `hed_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`hed_AppIcon`** — 1024x1024

```
High-contrast monochrome photograph of one solid bead knotted on a vertical thread, mixed-media paper and fiber, subject centered and filling the canvas edge to edge, no text, no letters, no transparency, no rounded mask.
```

**`hed_Splash`** — 1290x2796

```
Vertical high-contrast monochrome photograph of a long thread with a few solid beads, mixed-media paper and fiber, quiet uncluttered center band, fills the canvas, no text in the image.
```

**`hed_Onboarding1`** — 1024x1536

```
Solid photographic bead on a short vertical thread, mixed-media paper and fiber, high-contrast monochrome, opaque subject centered, not glass, not a hollow frame.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_Onboarding2`** — 1024x1536

```
Solid hands stringing a photographic print onto a tied knot, mid gesture, high-contrast monochrome mixed-media, opaque forms, not glass.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_Onboarding3`** — 1024x1536

```
Solid woven year cloth with dense weft bands, high-contrast monochrome mixed-media textile, opaque subject, not a wire grid.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_EmptyHome`** — 1024x1024

```
Folded solid cloth with an empty vertical thread and no beads, high-contrast monochrome, opaque fabric, not glass, not hollow.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_EmptyList`** — 1024x1024

```
Empty photographic contact sheet with no frames filled, solid paper object, high-contrast monochrome, opaque, not a hollow window.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_CardBackdrop`** — 1200x800

```
Wide abstract mixed-media field of thread and torn photographic paper, high-contrast monochrome, low detail so type can sit on it, fills the canvas, no text.
```

**`hed_ControlFace`** — 512x512

```
Solid shuttle bead used as a control face, mixed-media, high-contrast monochrome, opaque center, not a thin ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_TwistHero`** — 1024x1024

```
Solid caption knot being tied on a vertical thread, high-contrast monochrome mixed-media, opaque subject, not an outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_SuccessMark`** — 512x512

```
Solid filled bead as a confirmation mark, ceramic or metal, high-contrast monochrome, opaque middle, not an outline, not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hed_HeaderDecor`** — 1200x600

```
Wide band of mixed-media thread and photographic strips, high-contrast monochrome, solid ornament, not a hollow frame.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`hed.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `HeddleTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Heddle/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Heddle -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Knot ADT fold (Loose | Tied | Strung); the thread is a fold over Knots; Tie writes a KnotMark with caption and folds Loose to Tied; String writes a StringMark when photo or voice attaches and folds Tied to Strung; String on Loose writes DriftMark; a second Tie on the same daykey writes FullMark until Peel; Peel drops the last StringMark or KnotMark; OnThisDay selects Strung knots sharing month-day across years; Cloth density folds Strung counts by ISO week; empty thread writes Loose** with no leakage across layers.
- [ ] UI approach matches **SwiftUI Layout protocol · realitykit-lite**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Thread-locked chrome (the vertical thread never leaves; Cloth, Gallery, On-this-day and Settings arrive as sheets; tie and string fuse on Hub; no tab bar) · bead**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Trebuchet MS** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Heddle
xcodegen generate
xcodebuild build-for-testing -scheme Heddle -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.heddle.bead/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Heddle -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.heddle.bead/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Heddle -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.heddle.bead/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
