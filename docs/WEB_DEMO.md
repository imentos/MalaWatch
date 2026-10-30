# MalaWatch web demo

The existing GitHub Pages homepage is now an interactive free mala counter.
The native iOS and watchOS targets are unchanged.

## Included

- Three.js beads, downward drag or tap counting, and a red starting bead.
- Goals of 27, 54, and 108; progress and completed rounds.
- Om Mani Padme Hum, Namo Amitabha Buddha, and custom mantras.
- Opt-in browser speech; silent by default on each visit.
- Sandalwood, rosewood, jade, and obsidian visual styles.
- English, Traditional Chinese, Simplified Chinese, and Japanese.
- Browser-local saved progress, language, mantra, and material.
- Native share sheet where available; copy-link fallback.
- App Store links using `ct=web-mala-demo` and the existing provider token.

Visitors can switch between iPhone and Apple Watch frames on desktop and
mobile. Apple Watch is the default; the selection is saved in local storage.
Counts, chant position, and settings are shared across both previews. The Watch
has a woven green band and a clickable crown that counts a bead. This is an interactive web demo,
not a pixel-identical capture of the native watchOS app. No account, backend, ads, analytics scripts,
or build step is required. Three.js and Lucide are vendored with their licenses.

## Preview

From the repository root:

```sh
python3 -m http.server 8765 --directory docs
```

Open http://localhost:8765. JavaScript modules require an HTTP server rather
than opening index.html as a local file.

## GitHub Pages

Expected public URL: https://imentos.github.io/MalaWatch/

Keep the existing Pages setup serving `/docs` on `main`. Commit and push the
website changes only; unrelated native-app edits need not be included. No
Node build or GitHub Actions workflow is needed for branch-based Pages.
The live site has been confirmed accessible, but its authenticated Pages
configuration could not be read from this environment.

## Browser limitations

Speech voices and pronunciation depend on the browser and installed voices;
they are not identical to the native app. Some voices may use browser-provider
network services. Physical iPhone Safari speech should be checked before a
marketing launch. Vibration is best-effort and not supported on every device.
If WebGL is unavailable, the counter uses a simpler visual fallback.
Progress is local to a browser, does not sync with the native app, and may be
cleared by browser settings. This is not an Apple Watch web companion.

## Verification

Check desktop and phone layouts; tap, held drag, and keyboard counting; a full
27-bead round; 27 remaining visible before wrap; continuous chant across wrap;
reset; long custom mantra scrolling; saved progress; all four languages;
material switching; sound on/off; and a WebGL-unavailable fallback.
Check Apple campaign results in App Store Connect after promotion; this site
does not add visitor tracking or claim a conversion rate.
