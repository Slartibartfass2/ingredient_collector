# Audit Report: `ingredient_collector` (v0.8.0)

*Flutter architecture, parsing robustness, and client-side security audit — 2026-07-14*

## 1. System Design Summary

This is a **vanilla-Flutter, fully client-side scraping app** with no state-management framework: a `StatefulWidget` + `setState` UI (`lib/src/widgets/recipe_input_form.dart`) drives three plain singletons — `RecipeController` (fetch + orchestrate), `RecipeCache` (in-memory `Map`), and `LocalStorageController` (SharedPreferences for user notes/modifications). Models are `freezed` data classes; localization is `easy_localization` (en/de). It ships to Web, Windows, Linux, and Android.

The parsing pipeline: form submit → `mergeRecipeParsingJobs` deduplicates URLs (summing servings) → optional redirect resolution (`sharing.kptncook.com` → real recipe URL) → `http.Client().get()` per job, sequentially → the `html` package's `parse()` on the raw body → a per-site parser selected by **exact host match** in the `RecipeWebsite` enum → ingredient merge + servings scaling → plaintext/markdown shopping list in a text area.

There are effectively three parser families:

- `WordPressParser` — scrapes WP Recipe Maker `wprm-*` CSS classes; shared by Bianca Zapatka, Nora Cooks, and Eat This's new design.
- `ChefkochParser` — with old/new site-design branches.
- `KptnCookParser` — positional scraping of `col-md-offset-3` containers.

There is **no WebView, no backend, no image handling, and no telemetry** — the app is a pure HTML-to-text transformer.

## 2. Architectural & UX Strengths

- **Clean parser abstraction.** The `RecipeParser` interface + `RecipeWebsite` enum makes adding a site a genuinely three-step task, and the README documents that flow accurately. `WordPressParser` reuse across three sites is the right generalization — WPRM's markup is stable across WP blogs.
- **Structured, localized error reporting.** The `JobLog` hierarchy (`completeFailure`, `ingredientParsingFailure`, `AmountParsingFailureJobLog` with the offending amount string) surfaces *partial* parse failures per ingredient instead of failing the whole recipe. This is better than most hobby scrapers.
- **Thoughtful domain logic.** Job merging (same URL twice → summed servings), ingredient merging by name+unit, and the user-defined `RecipeModification` overlay (add/remove/scale ingredients per recipe, persisted locally) show real product thinking.
- **Regression test corpus.** `test/recipe_parser_tests/parser_test_files/` holds recorded expected outputs per site, with fuzzy matching (relative Levenshtein < 15%) to tolerate cosmetic site edits, plus a script to generate new fixtures.
- **Graceful design-migration handling.** `ChefkochParser` and `EatThisParser` both detect old vs. new site designs at parse time and branch — the codebase has already survived two upstream redesigns.

## 3. Parsing & Performance Bottlenecks (high priority)

1. **No Schema.org / JSON-LD extraction — the single biggest miss.** Every supported site except KptnCook embeds `<script type="application/ld+json">` with a `schema.org/Recipe` object (WPRM emits it automatically; Chefkoch does too). The code scrapes presentation CSS classes exclusively (`wprm-recipe-ingredient`, `ds-ingredients-table`, `kptn-ingredient`), which break on redesigns, while the JSON-LD `recipeIngredient` / `recipeYield` fields would survive them. A generic JSON-LD parser would also make *most recipe sites on the internet* work without a dedicated parser, and would obsolete the fragile amount/unit splitting heuristics in `lib/src/recipe_parser/chefkoch_parser.dart:130-145` (already marked `// TODO this can be done better, eat this has similar problems`).

2. **Everything runs on the UI thread.** `parse(response.body)` in `lib/src/recipe_controller/recipe_controller.dart:195` and the full ingredient extraction run on the main isolate. A Chefkoch page is ~1 MB of HTML; parsing several recipes in a row will produce visible jank. This should be `Isolate.run(...)` / `compute(...)` (with a fallback on web, where `parse` in a web worker isn't available but batching/yielding is).

3. **Sequential fetch loop with no timeout.** `collectRecipes` awaits each `client.get` in a `for` loop with **no `.timeout(...)`**. One slow/hung site blocks all subsequent recipes indefinitely, with the UI stuck on the "processing recipes" snackbar. Fetches should be concurrent (`Future.wait`) with per-request timeouts, and no `User-Agent` is set — the default Dart UA is a common target for bot-blocking (Cloudflare will 403 it), which the app can't distinguish from a layout break.

4. **Hard-coded parsing rules require an app release to fix.** Host lists, CSS class names, the Eat This regex patterns, and even a hard-coded blocklist of 6 individual unsupported Eat This URLs (`lib/src/recipe_parser/eat_this_parser.dart:5-12`) are compiled in. There is no remote config, no rule versioning, no kill switch. When a site redesigns (which has already happened twice), users get `completeFailure` errors until a new build ships — significant for the GitHub-Pages web build, fatal for the Android APK.

5. **Recipe cache is session-only and unbounded.** `RecipeCache` is a plain `Map` — no persistence (nothing survives restart, so no offline capability at all), no TTL (a recipe edited upstream is stale for the whole session), and no size cap. Given the app already depends on `shared_preferences` and `path_provider`, persisting parsed recipes (or moving to Hive/Drift) is low-hanging fruit. Network efficiency of images is a non-issue — the app never touches images.

## 4. Security & UX Vulnerabilities

- **The web build's official workaround is "disable CORS in your browser"** (`resources/langs/en.json:36` links to *Allow CORS* extensions for Chrome/Firefox/Edge). Instructing users to install an extension that strips CORS enforcement **for every site they browse** is a real security harm to users, and at minimum belongs in the README with a scoping warning. The sustainable fix is a CORS proxy or a tiny fetch backend for the web target.
- **Misleading error on native platforms.** *Any* `http.ClientException` — DNS failure, airplane mode, connection reset on Windows/Android — is mapped to `missingCorsPlugin` (`lib/src/recipe_controller/recipe_controller.dart:175-181`), telling desktop users to install a browser plugin. Network errors need to be distinguished from CORS, and platform-gated (`kIsWeb`).
- **HTTPS→HTTP downgrade bug in the redirect parser.** `lib/src/recipe_parser/redirect_parser/kptncook_sharing_url_parser.dart:16-19`: `if (!href.startsWith("http://")) href = "http://$href";` — an `https://...` href fails this check and becomes the garbage URL `http://https://...`; a scheme-less href is *downgraded to plain HTTP*. The check should be `startsWith("http")` (or `Uri.tryParse` + scheme inspection) and default to `https://`.
- **Crash window before form validation.** In `lib/src/widgets/recipe_input_form.dart:114-121`, `Uri.parse(...)` and `int.parse(...)` run on raw field text *before* `formState.validate()` is consulted at line 130. `Uri.parse` throws `FormatException` on inputs like `http://[bad` (the validator uses `Uri.tryParse`, but it hasn't gated anything yet at this point), and a pasted servings value exceeding 2⁶³ throws on native platforms — either kills `_submitForm` with no user feedback. Reorder validation before job construction.
- **Division-by-zero on parsed servings.** `WordPressParser` accepts `int.tryParse("0")` and every parser computes `job.servings / recipeServings` unguarded — a site listing "0 servings" (or a stray `value="0"` on Chefkoch) yields `Infinity` multipliers and a shopping list of "∞ g flour". Fraction/amount parsing itself (`tryParseAmountString`) is defensively written — unparseable amounts degrade to a warning log, not a crash — which is good.
- **No WebView = no WebView attack surface** (genuinely good), and scraped names are only ever rendered into a plain `TextField`, so injection risk is minimal. The lone sanitization, `_escapeName` (`"` → `'`, `lib/src/recipe_controller/recipe_controller.dart:253`), has an unclear purpose worth documenting.

## 5. Documentation Gaps

- **There is no wiki** — documentation is README + CHANGELOG only. The README roadmap *does* match the code (all five sites in `RecipeWebsite` are checked off; BBC Good Food correctly unchecked).
- **Supported URL *forms* are undocumented.** The code supports `mobile.kptncook.com`, `share.kptncook.com`, and `sharing.kptncook.com` — but **not** `www.kptncook.com`, which is exactly what the README's roadmap links to. A user pasting a normal kptncook.com URL gets "unsupported". Same for Eat This: only `www.eat-this.org` (host match is exact, so `eat-this.org` without `www.` fails).
- **The contributing example is out of date.** README shows `exampleWebsite("https://www.example.org", ExampleParser())` — the actual enum takes a *list of hosts*, not a full URL: `exampleWebsite(["www.example.org"], ExampleParser())`.
- **The Eat This URL blocklist** (6 recipes deliberately unsupported) and the CORS-plugin requirement for the hosted web demo are invisible until users hit them at runtime.
- The web demo link ("Test it out") doesn't mention that nothing will parse without the CORS workaround.

## 6. Inquiry List

1. **JSON-LD**: Was Schema.org extraction evaluated and rejected (e.g., because KptnCook's mobile pages lack it), or simply not yet attempted? It would collapse three of your four parser families into one.
2. **Layout-break detection**: `testParsingTestFiles` performs **live HTTP fetches against the production websites in CI** — is that the intended monitoring mechanism for upstream redesigns? It makes tests flaky and rate-limit-prone; have you considered committing HTML snapshots for regression tests and running the live suite on a schedule instead? Relatedly: there is no crash/error telemetry (Sentry etc.) — how do you currently learn that a site broke, other than bug reports?
3. **Encoding**: `response.body` falls back to Latin-1 when a site omits the charset in `Content-Type`. Have you seen mojibake in German umlauts from any of the supported sites, and should the body be decoded with a charset sniff from the `<meta>` tag?
4. **Eat This regex** (`_servingsTextPatterns` with the composed/decomposed umlaut alternation, and the `einen|eine|ein` word-numbers): what real-world variants drove these, and could the word-number handling move into `tryParseAmountString` so all parsers benefit?
5. **`_escapeName`** (double→single quote): what consumer does this protect — the markdown output, the JSON test fixtures, or something else? It looks like sanitization for a context that no longer exists.
6. **Web strategy**: is the long-term plan to keep the client-only architecture (accepting the CORS plugin situation), or would a minimal proxy/function backend be acceptable? That decision gates most of the robustness options above (remote parser rules, bot-block handling, shared caching).

## Suggested priority order

1. Guard the servings division-by-zero and validation-ordering crashes — small fixes.
2. Add per-request timeouts + concurrent fetches.
3. Build a generic JSON-LD parser with the existing parsers as fallback.
4. Move HTML parsing off the main isolate.
5. Split the CORS message from generic network failure by platform.
