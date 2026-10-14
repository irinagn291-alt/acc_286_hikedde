<!-- gf-brief source=0d7af7ff4f1a93241392a84b70f9df0daed616233a9747ce479b2706c466989b written=2026-10-14T17:46:32+03:00 -->
# Сhikedde
## What it is
A daily bead diary. Each day you tie a short caption on today's bead, then string a photo or a voice note so that day stays on a vertical thread. It is for people who keep days as knots on a string, not as a reverse-chronological feed.

## Launch and onboarding
On a cold launch the system shows a generated dark launch screen, then a brief wait. If the wait lasts more than a moment, a spinner appears with the accessibility name "Loading".

The first launch is four onboarding pages. Each page shows a page number at the top left ("1", "2", "3", "4"), a "Skip" button at the top right, an illustration, a title, a line of copy, and a full-width button at the bottom.

1. Title "Tie a caption". Line "A knot is a short line on today's bead." Button "Next".
2. Title "String the knot". Line "Add a photo or a voice note. It stays on this device." Button "Next".
3. Title "Read the cloth". Line "Each strung knot fills a week on the year cloth." Button "Next".
4. Title "Look back". Line "On this day lines up the same date in prior years." Button "Continue".

"Next" advances one page. "Continue" on the last page closes onboarding and opens the home thread with no knots. "Skip" on any page does the same: onboarding is marked done and the home thread opens empty.

Later, "Show introduction" in Settings plays these four pages again. "Skip" or "Continue" then returns to the thread. Knots already tied stay on the thread.

## Screens
There is no tab bar. Home is the vertical thread. "On this day", "Weeks", "Gallery", and "Settings" open as sheets over it. Every sheet has a close control named "Close".

### Home (the thread)
The header always names today's job, then a count of strung knots and the words "strung on the thread". Four header controls open sheets: "On this day", "Weeks", "Gallery", "Settings". Notices and recovery lines, when present, sit under that row.

Today's job title and line change with the open bead:

- Loose: "Tie the knot" / "Write a caption, then tie today."
- Tied: "String today's knot" / "Add a photo or a voice note."
- Strung: "Today is strung" / "Peel to tie again."

**Empty thread.** The header above still shows. Below it, a full page: illustration, "The thread has no knots", "Tie a caption on today", a "Caption" field, and "Tie". A keyboard bar offers "Close" to dismiss the keyboard. There is no "String" or "Peel" on this empty page. "Tie" with a non-empty caption writes today's knot, clears the field, and shows "Saved." for a moment. "Tie" with an empty caption stays on this page and shows "Write a caption, then Tie."

**Thread with knots.** A tall open bead for today sits at the top of a vertical thread. It shows a phase chip "Loose", "Tied", or "Strung"; the caption, or "Today is open" if today has no caption yet; and today's date in the device's medium date style. A strung photo is labeled "Strung photo". A strung voice note shows a play control whose visible label is "Voice" until a duration is known, then a clock such as "0:12". That control is "Play voice note" or "Stop voice note". While a voice note is being recorded, a banner reads "Recording the voice note".

Earlier days sit below as beads. Each shows the caption or "No caption", the date, and the phase "Loose", "Tied", or "Strung". Tapping one opens the Thread sheet for that bead. Today's open bead is not a button.

Bottom controls, once at least one knot exists:

- "Caption" field, hidden while today is Tied. Keyboard bar "Close" dismisses the keyboard.
- "Tie" writes today's caption when today is Loose. It is the live verb while today is Loose.
- "String" opens the String sheet when today is Tied. It is the live verb while today is Tied. While recording it reads "Stop & String" and finishes the voice note onto today's knot.
- "Peel" undoes the newest action on the thread.

A successful Tie or String shows "Saved." and a brief success mark on the open bead. While a photo or voice file is being saved, "Tie", "String", and "Peel" are disabled and "String" can show a spinner.

**String sheet** (title "String"):

- "Photo" opens the system photo picker for images. A chosen photo strings onto today's Tied knot.
- "Voice" starts a voice-note recording after the system microphone prompt. If a recording is already running, this control reads "Stop" and finishes it.
- "Close" dismisses the sheet.

If the microphone was refused: alert "Microphone is off", message "Voice notes need the microphone. Open Settings to turn it on.", buttons "Open Settings" and "Close".

### On this day
Title "On this day". Close is "Close".

Empty: "No prior year on this date", "String today to leave a knot for next year", button "String". "String" closes the sheet and opens the home String sheet.

Filled: section "Today" with today's bead (caption or "No caption", date, and a voice play control when the media is a voice note). That Today card does not open. Section "Earlier years" lists strung knots from prior years on this same month and day. Tapping one opens the Thread sheet. A voice note on a card also has the play control.

If the list cannot be read: "On this day could not be read", the recovery line, button "Retry".

### Weeks
Title "Weeks". Close is "Close".

Empty: "No weft this year", "A strung knot fills a week", button "String". "String" closes the sheet and opens the home String sheet.

Filled: a "Tension" block with "N weeks in a row" and "N strung across N years" (counts use the device's decimal style). Then a heading for each year, and a card "Week N" with that week's strung count. Tapping a week expands or collapses it. Expanded rows show each knot's caption, or the date if the caption is empty. Tapping a row opens the Thread sheet.

If the list cannot be read: "Weeks could not be read", the recovery line, button "Retry".

### Gallery
Title "Gallery". Close is "Close".

Empty: "No strung beads", "String a photo or a voice note on today's knot", button "String". "String" closes the sheet and opens the home String sheet.

Filled: one tile per strung knot — photo or drawn bead, caption or "No caption", date, and "Strung". Tapping a tile opens the Thread sheet.

If the list cannot be read: "Gallery could not be read", the recovery line, button "Retry".

### Thread
Title "Thread". Close is "Close". Opened by tapping an earlier bead, a Gallery tile, a Weeks row, or an earlier-year On this day card.

Filled: the photo (labeled "Strung photo"), the voice note (labeled "Voice note", with the play control), or a drawn bead; the caption or "No caption"; the date; and a phase line:

- "Loose. Tie a caption."
- "Tied. String a photo or a voice note."
- "Strung."

If nothing was selected: "No bead selected", "Tap a knot on the thread.", button "Close".

If the bead cannot be read: "This bead could not be read", the recovery line, button "Retry".

### Settings
Title "Settings". Close is "Close".

If a recovery line is showing: that line and "Close", which dismisses Settings.

If the thread is empty: "The thread has no knots" and "Tie a caption on today".

If the thread has knots: "Knots on the thread" and the knot count.

Always available below that:

- "Show introduction" — plays onboarding again, then returns to the thread.
- "Export thread" — first tap prepares the thread; the same label then opens the system share sheet.
- "Export weft" — first tap prepares a printed weft; the same label then opens the system share sheet. The printed page is titled "Сhikedde", subtitled "Weft broadsheet", then one line per knot: date, phase ("Tied" or "Strung"), and caption. If there are no knots it prints "The thread has no knots."
- "Haptics" — toggle, on by default.
- "Reset thread" — alert "Reset thread", message "The thread and its media files will be deleted.", buttons "Delete thread" and "Close". "Delete thread" clears every knot and every photo and voice note, then returns to the four onboarding pages.
- "Contact" — opens the support page.

Failed export shows "The thread could not be exported." or "The weft could not be printed." on the home header.

## Features
- Tie a caption on today's bead ("Tie", field "Caption").
- One knot per calendar day unless you Peel.
- String a photo onto a Tied knot ("String" → "Photo").
- String a voice note onto a Tied knot ("String" → "Voice", then "Stop & String").
- Play or stop a strung voice note ("Play voice note" / "Stop voice note", visible "Voice" or a duration).
- Peel the newest action ("Peel"): unstringing returns Tied; removing the caption returns Loose.
- Vertical thread of earlier beads, newest open bead on top.
- "On this day": today's knot beside strung knots from prior years on the same month and day.
- "Weeks": year cloth of ISO weeks; "Tension" streak and totals; expand a week to read its knots.
- "Gallery": every strung photo or voice note.
- "Thread": one earlier bead, large.
- "Saved." confirmation after a successful Tie or String.
- "Export thread" and "Export weft" from Settings.
- "Haptics" on or off.
- "Show introduction" to replay onboarding.
- "Reset thread" to delete the thread and its media.
- "Contact" for support.
- Dark appearance only.

## Behaviours that can look like bugs
- **Empty "Caption" refuses Tie.** The field stays, and the header shows "Write a caption, then Tie." Type any caption, then "Tie".
- **String before Tie does nothing on the thread.** The header shows "That string did not tie. Tie a caption first." Tie a caption first. The empty pages in Gallery, Weeks, and On this day still offer "String"; on a clean install that tap opens the String sheet and then refuses until today is Tied.
- **One knot per day.** A second "Tie" shows "Today already has a knot. Peel to tie again." A second "String" shows "Today is already strung. Peel to string again." After today is Strung, the "Caption" field and "Tie" come back; they refuse until Peel.
- **The first Peel after a refused Tie can look like a no-op.** The notice told you to Peel, but one Peel only clears the refused attempt and today stays Tied. Peel again to drop the caption and return to Loose. The same quiet first Peel happens after a refused String.
- **Peel undoes the newest action on the whole thread, not always today.** If the newest action was on another day, Peel changes that day and today looks unchanged.
- **Empty On this day cannot fill in the first session.** "No prior year on this date" / "String today to leave a knot for next year" is correct: this list only shows earlier years. "String" does not add a row today.
- **Empty Weeks and Gallery stay empty until a knot is Strung.** "No weft this year" and "No strung beads" remain after Tie alone. String a photo or a voice note, then reopen.
- **"String", "Tie", and "Peel" disable** while a photo or voice file is being saved. Wait for "Saved." or an error.
- **Today's On this day card does not open.** Only "Earlier years" cards open Thread.
- **A caption typed but not Tied is lost** if you leave the field or the app. Only "Tie" writes it.
- **A new calendar day** (device time zone, including while the app stays open) makes a new Loose bead for today. Yesterday stays on the thread. The header returns to "Tie the knot".
- **Reset thread** deletes everything and shows onboarding again. That is intended.
- **"Saved." disappears** on its own after a moment.
- **Unreadable photo or voice** shows "That photo could not be read." or "That voice note could not be read." Pick another photo or record again.
- **Microphone refused.** Alert "Microphone is off". "Open Settings" to turn the microphone on, or "Close". Photo stringing still works.
- **Recovery lines** can appear on home and in Settings: "Restored the thread file.", "Restored the last good thread.", "The thread file was unreadable. Started loose.", "The media file could not be saved.", "The media file could not be removed.", "The thread could not be cleared.", "Media files could not be deleted.", "The thread could not be saved." "Retry" on an error page reloads the thread. Settings "Close" on a recovery section only dismisses the sheet.
- **The system microphone prompt body names "Heddle"** even though the Home Screen name is "Сhikedde". The body is "Heddle records a voice note onto today's knot. The clip stays on this device."

## Starter content and resume
None on a device. A clean install opens an empty thread after onboarding.

Unfinished work resumes. A Tied day without a photo or voice note is still Tied after relaunch ("String today's knot"). A Strung day stays Strung. Earlier beads stay on the thread. A caption that was never Tied does not come back. "Show introduction" does not erase the thread. "Reset thread" does.

## Permissions
Microphone, when the user taps "Voice" (or starts a recording from "String"). System usage string: "Heddle records a voice note onto today's knot. The clip stays on this device." If access was refused earlier, the app shows "Microphone is off" and "Open Settings" instead of asking again.

Photo uses the system picker after "Photo". The app does not ask for a photo-library or camera permission of its own.

## Absent
Login or accounts. In-app purchase. Ads. Analytics. Account deletion flow. App Tracking Transparency prompt.

Captions, photos, and voice notes are private diary entries on this device, not a public feed. There is no report or block UI.

## Data and support
Captions, photos, and voice notes stay on this device. Onboarding says "It stays on this device." The microphone prompt says the clip stays on this device.

Support control: "Contact" in Settings. It opens the support page.

## Scanning and health
None.

## Platform
English UI. Dates use the device's calendar and medium date style. Counts use the device's decimal style. Day boundaries follow the device time zone. Weeks on the cloth are ISO weeks (Monday start). No region lock.

Portrait only, full screen, dark appearance. iPhone and iPad. Minimum iOS 17.0. Home Screen name "Сhikedde".

## Category
Lifestyle.
