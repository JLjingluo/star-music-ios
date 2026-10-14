# Design reference catalogue

Upstream: https://github.com/VoltAgent/awesome-design-md
Snapshot: `3b605329240ce735b510037cca322f1831fdd7f8`
84 complete design documents and their READMEs are archived under `source/`; MIT notices are retained. All source files were decoded and indexed. The catalogue reviews each system’s theme, core tokens, layouts and guardrails; it is not a claim that their public websites or every linked page were audited. Original typography and component specifications remain in each complete source document.

## 1win
An analysis of 1win's design language — a near-black crypto casino and sportsbook built on Inter at heavy weights, where a vivid green action color and an electric blue secondary carry every CTA across dense, full-bleed game-tile rails, promo cards, and live betting panels on a flat dark-grey surface ladder.
Core tokens: {"primary": "#00b24b", "on-primary": "#ffffff", "canvas": "#141415", "surface": "#2e3035", "hairline": "#2d2f33", "ink": "#f0f2f5", "muted": "#9aa1b1"}
Fonts: ['Inter']
Layout: The shell is a fixed left icon `sidebar-rail` plus a fluid content column. Discovery uses horizontally-scrolling rails (carousels) of `game-tile` thumbnails rather than wrapping grids; the promotions page uses a 2-up card grid, and the sportsbook uses full-width match rows with a docked right-hand `betslip-panel`.

## Do's and Don'ts

### Do
- Reserve `primary` (green) for primary actions — Registration, confirm, place-bet — and `secondary` (blue) for secondary actions, links, and live/betting highlights.
- Build depth with the surface ladder (`canvas` → `surface`) plus a faint `hairline` edge; avoid heavy shadows.
- Set every label in Inter 600+ (`body` / `caption`); use the 800 weight for headlines and bonus figures.
- Let game and promo artwork supply the color — keep the surrounding chrome monochrome dark.
- Use `lg`–`xl` on buttons, `card` (16px) on tiles/cards/panels, and `full` on pills and badges.
- Pair accent fills with `on-primary` (white) text for legibility.

### Don't
- Don't promote game-tile or bonus-banner gradient colors (the purples, reds, violets, ambers) into the UI palette — they are content, not chrome.
- Don't add a third structural accent; the system is green + blue only.
- Don't use pure-regular weights — there is no Inter 400 here; body copy is semibold.
- Don't pad game tiles — artwork is full-bleed inside `card` corners.
- Don't rely on drop shadows for elevation; the surface brightness step is the elevation language.


## airbnb
A warm, generous consumer marketplace anchored on a clean white canvas and Airbnb Rausch (#ff385c), the single brand voltage that carries every primary CTA, search-button orb, and rating dot. Type runs Airbnb Cereal VF at modest weights — display sits at 22–28px in weight 500/600 rather than the heavy 700+ that fintech and enterprise systems use; the brand trusts photography and generous whitespace over typographic muscle. Three product entries (Homes, Experiences, Services) sit in the top nav with hand-illustrated 32-icon glyphs and "NEW" badges, signaling a marketplace expansion rather than a feature dump. Pill-shaped search bars (`full`), softly rounded property cards (`lg` ~14px), and 32px button radii read as friendly and human — there is no hard corner anywhere except the body grid.
Core tokens: {"primary": "#ff385c", "primary-active": "#e00b41", "primary-disabled": "#ffd1da", "primary-error-text": "#c13515", "primary-error-text-hover": "#b32505", "ink": "#222222", "muted": "#6a6a6a", "muted-soft": "#929292", "hairline": "#dddddd", "hairline-soft": "#ebebeb", "canvas": "#ffffff", "surface-soft": "#f7f7f7", "surface-card": "#ffffff", "surface-strong": "#f2f2f2", "on-primary": "#ffffff", "legal-link": "#428bff"}
Fonts: ["'Airbnb Cereal VF', Circular, -apple-system, system-ui, Roboto, 'Helvetica Neue', sans-serif", "'Airbnb Cereal VF', Circular, sans-serif"]
Layout: - **Max content width:** ~1280px centered on the homepage and editorial pages. Listing detail pages cap closer to 1080px to keep the photo banner and reservation rail readable.
- **City link grid (homepage footer):** 6-column grid at desktop with each cell housing a city name in `title-md` and a category sub-label in `body-sm` muted.
- **Listing detail:** 2-column with photo / amenity body on the left (~64% width) and a sticky reservation card (`reservation-card`) on the right (~32%).
- **Footer:** 3-column link list (Support / Hosting / Airbnb) at desktop, collapsing to 1-column on mobile.



## airtable
A sober, editorial workflow-software interface anchored on white canvas and dark-ink type, where brand voltage comes from full-bleed signature cards in coral, dark green, peach, and dark navy that punctuate long-scroll explainer pages. Primary actions use a near-black pill CTA; secondary actions sit in a white outlined button. Type runs Haas Grotesk in modest weights — never bold for its own sake.
Core tokens: {"primary": "#181d26", "primary-active": "#0d1218", "ink": "#181d26", "muted": "#41454d", "hairline": "#dddddd", "canvas": "#ffffff", "surface-soft": "#f8fafc", "surface-strong": "#e0e2e6", "surface-dark": "#181d26", "surface-dark-elevated": "#1d1f25", "on-primary": "#ffffff", "link": "#1b61c9", "link-active": "#1a3866", "pricing-ink": "#1d1f25"}
Fonts: ['Haas Groot Disp, Haas, sans-serif', 'Haas, sans-serif', 'Inter Display, system-ui, sans-serif']
Layout: - **Max content width:** ~1280px centered, with `xxl` (48px) horizontal breathing room.
- **Editorial body:** Single 8/12-column at large breakpoints, collapsing to single-column on mobile.
- **Demo-card grids:** 3 or 4 columns at desktop, 2 at tablet, 1 at mobile. Card sizes are deliberately uneven within the grid to dodge a uniform "spec sheet" feel.
- **Logo strip:** 6 monochrome partner logos in a single row at desktop; wraps to 3-up on mobile.

## Do's and Don'ts

### Do
- Keep `button-primary` near-black. The brand's primary CTA is `primary`, not the link blue. Mixing them up turns a confident hero into a confused one.
- Reserve `button-primary` for one primary action per viewport. The system is designed for scarcity at the brand-action layer.
- Use `button-secondary` (white with hairline outline) as the natural pair with `button-primary`. The two together form Airtable's signature button row.
- Trust whitespace as the hero atmosphere. Hero bands are intentionally calm — no gradient, no mesh, no atmospheric backdrop. Going against this reads as off-brand.
- Use `signature-coral-card`, `signature-forest-card`, and `hero-card-dark` to break editorial monotony. These are the brand's voltage moments.
- Keep `demo-grid-card` heights uneven within a grid. Uniform heights feel like a spec sheet.
- Treat the pricing surface as its own dialect: keep `pricing-display`, `pricing-card-title`, and `button-pricing-pill` together. Mixing them with Haas Grotesk button type breaks the sub-system's voice.
- Anchor every editorial band with `section` (96px) vertical padding.

### Don't
- Don't make `link` (#1b61c9) the primary button color. It is the link color. The primary button is `primary` (#181d26, near-black). Treating link-blue as the brand action is the most common mistake when reading Airtable's CSS variables.
- Don't add a gradient backdrop to the hero. Airtable's hero is white, full stop. Mesh, aurora, spotlight gradients all read as "another SaaS template" — not Airtable.
- Don't bold display-weight type. `display-xl` and `display-lg` are intentionally weight 400 / 500 — going to 700 reads as marketing-page-template.
- Don't use `pill` outside the pricing surface. It's a sub-system signal, not a general radius option.
- Don't repeat the same surface mode in two consecutive bands. The editorial pacing depends on rhythm: white → signature card → white → cream → dark → white. Two whites in a row read as a typography blog.
- Don't add hover state styling beyond what the system already encodes. The system documents Default and Active/Pressed only.
- Don't introduce additional accent colors beyond the documented signature card palette. The system's voltage already uses coral, forest, dark navy, cream, peach, mint, yellow, and mustard.



## aljazeera
An analysis of Al Jazeera's design language — a hard-news editorial system built on flat white paper and dense Roboto headline stacks, signed by one saturated orange used as logo block and section-eyebrow bar, punctuated by a live-red that marks breaking coverage with timeline dots and LIVE badges, and interfaced through compact black pills; the corporate network pages extend the same identity onto a near-black canvas with royal-indigo hero panels, gold rules and amber links, and vivid teal and crimson section rails beside monochrome leadership portraiture.
Core tokens: {"primary": "#fa9000", "on-primary": "#ffffff", "ink": "#000000", "canvas": "#ffffff", "hairline": "#d8d8d8", "network-canvas": "#181818"}
Fonts: ['Roboto']
Layout: - The front page runs a packed 1100px multi-column news grid: lead story + secondary column + rail, then full-width bands (video carousel, features, galleries).
- Live blogs run a single reading column with a right rail; updates stack as timestamped blocks.
- Network pages run full-bleed bands: hero panels, then 4-up portrait grids with the vertical rail occupying the left margin.

## Do's and Don'ts

### Do
- Keep `primary` to identity duty — the logo block and the eyebrow bar — and let black pills carry every action.
- Reserve `live-red` strictly for live/breaking state: badges, bands, timeline dots.
- Open every editorial section with the `section-eyebrow-lockup` (orange bar + 300-weight uppercase label).
- Keep the news surface flat: hairline rules and weight contrast, never shadows or tonal cards.
- Run photography dense and square in article grids; save `md` for carousels and thumbs.
- On network pages, keep the gilded family — `gold` rules, `amber` active links — over the dark `network-canvas`.
- Use the wide Roboto weight spread deliberately: 300 eyebrows, 700 headlines, 900 urgent labels.

### Don't
- Don't fill buttons or links with `primary` — orange interaction chrome breaks the marker-pen rule.
- Don't use `live-red` decoratively; if it isn't live coverage, it isn't red.
- Don't add shadows, gradients, or card fills to news grids — density and rules are the aesthetic.
- Don't round article photography; square crops are part of the wire-service voice.
- Don't mix the network's gold/amber/indigo family into the news surface, or the orange eyebrow system into corporate pages.
- Don't soften the eyebrows — they stay uppercase, light-weight, and barred.
- Don't introduce new accent hues; the palette's color budget is spent on orange, live-red, and the network's gold and rails.


## apple
A photography-first interface that turns marketing into a museum gallery. Edge-to-edge product tiles alternate light and dark canvases, framed by SF Pro Display headlines with negative letter-spacing and a single Action Blue (#0066cc) interactive color. UI chrome recedes so the product can speak — no decorative gradients, no shadows on chrome, only the one signature drop-shadow under product imagery resting on a surface.
Core tokens: {"primary": "#0066cc", "primary-focus": "#0071e3", "primary-on-dark": "#2997ff", "ink": "#1d1d1f", "body-muted": "#cccccc", "ink-muted-80": "#333333", "ink-muted-48": "#7a7a7a", "hairline": "#e0e0e0", "canvas": "#ffffff", "canvas-parchment": "#f5f5f7", "surface-pearl": "#fafafc", "surface-tile-1": "#272729", "surface-tile-2": "#2a2a2c", "surface-tile-3": "#252527", "surface-black": "#000000", "surface-chip-translucent": "#d2d2d7", "on-primary": "#ffffff"}
Fonts: ['SF Pro Display, system-ui, -apple-system, sans-serif', 'SF Pro Text, system-ui, -apple-system, sans-serif']
Layout: - **Max content width:** ~980px on text-heavy sections (environment), ~1440px on product grids (store, accessories), full-bleed for product tiles (homepage).
- **Column patterns:** 3 to 5 column utility card grid on store/accessories; 2-column side-by-side tiles on homepage occasional sections; single-column centered stack on product tile heroes.
- **Gutters:** 20–24px between cards in a utility grid.

## Do's and Don'ts

### Do
- Use `primary` (Action Blue #0066cc) for every interactive element — links, pill CTAs, focus signals — and nothing else. The single accent is non-negotiable.
- Set headlines in `hero-display` or `display-lg` with negative letter-spacing (`-0.28 → -0.374px`) to get the signature "Apple tight" cadence.
- Run body copy at `body` (17px / 400 / 1.47 / -0.374px) — not 16px. The extra pixel defines the brand's reading pace.
- Alternate `product-tile-light` (or parchment) and `product-tile-dark` for full-bleed section rhythm. The color change IS the divider.
- Reserve `pill` for the primary blue CTA and any other element that should read as an "action" (configurator chips, search input, sticky bar CTA).
- Apply the single product-shadow (`rgba(0, 0, 0, 0.22) 3px 5px 30px`) only to product renders resting on a surface — never on cards, buttons, or text.
- Use `transform: scale(0.95)` as the active/press state on every button — it's the system-wide micro-interaction.
- Keep the global nav `surface-black` (true black) — it's the only place pure black appears on most pages.

### Don't
- Don't introduce a second accent color; every "click me" signal is `primary` (Action Blue).
- Don't add shadows to cards, buttons, or text — shadow is reserved for product imagery.
- Don't use gradients as decorative backgrounds; atmosphere comes from photography.
- Don't set body copy at weight 500 — Apple's ladder is 300 / 400 / 600 / 700, with 500 deliberately absent. Body is always 400; strong inline is 600; display is 600.
- Don't round full-bleed tiles — tiles are rectangular and edge-to-edge; the color change is the divider.
- Don't tighten line-height below 1.47 for body copy — the editorial leading is part of the brand.
- Don't mix radii grammars — use `sm` for compact utility, `lg` for utility cards, `pill` for pills, and nothing in between (except the rare `md` Pearl Button).
- Don't use `primary-on-dark` (Sky Link Blue) on light surfaces — it's the dark-tile-only variant. Action Blue is for light surfaces.



## binance
A confident financial-platform interface anchored on a deep near-black canvas, where Binance's iconic yellow (#FCD535) carries every primary CTA, brand accent, and value-claim moment. Type runs Binance's custom BinanceNova / BinancePlex stack at modest weights — the system trusts size and yellow voltage over bold weight. Marketing and product surfaces default to the dark theme; transactional surfaces (buy crypto, deposit, exchange) flip to a light theme that shares the same yellow CTAs and gray-blue hairlines. Trading green (up) and red (down) accents thread through both modes for price-direction signals.
Core tokens: {"primary": "#fcd535", "primary-active": "#f0b90b", "primary-disabled": "#3a3a1f", "ink": "#181a20", "muted": "#707a8a", "muted-strong": "#929aa5", "hairline-on-light": "#eaecef", "hairline-on-dark": "#2b3139", "canvas-light": "#ffffff", "canvas-dark": "#0b0e11", "surface-card-dark": "#1e2329", "surface-elevated-dark": "#2b3139", "surface-soft-light": "#fafafa", "surface-strong-light": "#f5f5f5", "on-primary": "#181a20"}
Fonts: ['BinanceNova, -apple-system, BlinkMacSystemFont, sans-serif', 'BinanceNova, sans-serif', 'BinancePlex, BinanceNova, sans-serif']
Layout: - **Max content width:** ~1280px centered on marketing pages; ~1440px on product surfaces (markets, smart-money tables) where horizontal density matters.
- **Editorial body:** Single 12-column grid; product pages often use 8/4 split (main panel + side rail).
- **Markets table:** 5-column header (Pair / Last Price / 24h Change / 24h Volume / Action), with the first column carrying coin icon + symbol pair.
- **Footer:** 6-column link list at desktop, wrapping to 2-up at tablet and 1-up on mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (Binance Yellow) for primary actions, brand-claim headlines, and the wordmark. Never use it for secondary or decorative purposes — yellow's scarcity is what makes it powerful.
- Keep `button-primary` (yellow with black text) as the universal primary CTA across both dark and light modes. The same button appears identically on `canvas-dark` and `canvas-light`.
- Use `button-trading-up` (green) and `button-trading-down` (red) only for explicit Buy/Sell or Long/Short actions. Never use them for general "confirm" or "cancel" because they carry semantic price-direction meaning.
- Use BinancePlex for every number. Prices, volumes, percentages, stat counters — all BinancePlex. Mixing BinanceNova into a number ticker breaks the trading-platform character.
- Choose canvas mode by surface intent: dark for marketing / product showcase / trading dashboards; light for transactional dialogs (buy / deposit / withdraw / form submission).
- Anchor every editorial band with `section` (80px). Binance is denser than airy marketing sites — 80px is the right rhythm.

### Don't
- Don't introduce a second brand color. The system has exactly one accent (`primary`) and any expansion dilutes the brand identity. The turquoise on Smart Money is a single-product experiment, not a system token.
- Don't use yellow for body text or large surface fills. It is for focal-point CTAs and headlines only.
- Don't use `trading-up` / `trading-down` as background fills on cards. They are price-direction signals, expressed as text color or small badge fill — never as a card surface.
- Don't soften display weight. `hero-display` and `display-lg` are intentionally weight 700 — going to 400 reads as design-portfolio, not trading platform.
- Don't add atmospheric gradients to the canvas (mesh, aurora, glow effects). Binance trusts color-block contrast — adding atmospheric depth muddies the trading-platform feel.
- Don't invert `button-primary`'s text color. Black on yellow is the system's signature — white text on yellow loses contrast and brand recognition.



## bmw
BMW's corporate site — distinct from BMW M's motorsport-bombastic variant, this is a measured and settled corporate-automotive interface. On a light (cream-tinted white) canvas, BMW corporate blue (#1c69d4) carries every primary CTA; dark navy hero bands frame model photography. BMW Type Next Latin sets the entire hierarchy on two weights — heavy 700 display and Light 300 body. Configuration and reservation flows ride a card-based 4-up grid, where each card holds a model render, a name, and a "Learn More" link.
Core tokens: {"primary": "#1c69d4", "primary-active": "#0653b6", "primary-disabled": "#d6d6d6", "ink": "#262626", "muted": "#6b6b6b", "muted-soft": "#9a9a9a", "hairline": "#e6e6e6", "hairline-strong": "#cccccc", "canvas": "#ffffff", "surface-soft": "#f7f7f7", "surface-card": "#fafafa", "surface-strong": "#ebebeb", "surface-dark": "#1a2129", "surface-dark-elevated": "#262e38", "on-primary": "#ffffff"}
Fonts: ["'BMW Type Next Latin', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif", "'BMW Type Next Latin', sans-serif"]
Layout: - **Max content width:** ~1440px center-aligned.
- **Editorial body:** A single 12-column grid.
- **Model card grids:** 4-up or 5-up at desktop, 2-up at tablet, 1-up on mobile.
- **Configurator inventory grids:** 3-up filter row + 4-up vehicle cards, dense layout.

## Do's and Don'ts

### Do
- Sit every page on `canvas` (pure white); reserve `surface-dark` for hero bands only.
- Pair primary CTAs with `primary` (BMW Blue) + `on-primary` white text + `none` 0px corners — the corporate signature.
- Set display headlines in BMW Type Next Latin 700 and body in Light 300. The contrast is non-negotiable.
- Use UPPERCASE letter-spaced links like "LEARN MORE" as inline CTAs.
- Place the model card photo on `surface-card` with the title beneath — the standard BMW corporate pattern.
- Hold section rhythm at `section` (80px) — tighter than BMW M's 96px.
- Reserve the M tricolor stripe for M-model contexts and motorsport dividers.

### Don't
- Don't add a brand color other than blue — BMW Blue is the only primary action color.
- Don't use pill or rounded buttons — `none` (0px) rectangular IS the brand button.
- Don't drop display weight to 500 — the system uses 700 / 400 / 300; 500 is absent.
- Don't bold body type — Light 300 is the BMW corporate editorial voice.
- Don't add drop shadows to cards — depth comes from photo + color-block contrast.
- Don't repeat the same surface mode across two consecutive bands — light → dark hero → light → light feature → dark CTA → light footer rotation is required.
- Don't use the M tricolor stripe as a CTA fill — divider/accent role only.
- Don't mix languages in a single page — UI language must stay consistent.



## bmw-m
A motorsport-engineering interface anchored on a near-black canvas with white BMW Type Next Latin display headlines in confident UPPERCASE. The brand carries no decorative voltage — its energy comes from full-bleed automotive photography (cars on tracks, driver-cockpit shots, carbon-fiber detail) and the iconic M tricolor stripe (light blue → dark blue → red) used sparingly as a brand signature on logos, dividers, and motorsport chrome. Type stays light to medium weight to feel European-engineered, never American-bombastic.
Core tokens: {"primary": "#ffffff", "ink": "#ffffff", "muted": "#7e7e7e", "hairline": "#3c3c3c", "hairline-strong": "#262626", "canvas": "#000000", "surface-card": "#1a1a1a", "surface-elevated": "#262626", "surface-soft": "#0d0d0d", "on-primary": "#000000"}
Fonts: ['BMWTypeNextLatin, sans-serif', 'BMWTypeNextLatin Light, BMWTypeNextLatin, sans-serif', 'BMWTypeNextLatin Light, sans-serif']
Layout: - **Max content width:** ~1440px centered on marketing pages — wider than typical SaaS to give photography breathing room.
- **Editorial body:** Single 12-column grid; photo bands bleed full-bleed (no max-width).
- **Card grids:** 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Footer:** 4-column link list at desktop, 2-up at tablet, 1-up at mobile.

## Do's and Don'ts

### Do
- Anchor every page with full-bleed automotive photography. The cars are the brand voltage; chrome backs off.
- Use UPPERCASE display headlines in `display-xl` or `display-lg`. Sentence-case display reads as off-brand.
- Pair heavy display (700) with light body (300). The weight contrast is the editorial signature.
- Reserve the M tricolor stripe for brand-identity moments — wordmark accents, motorsport chrome, model badges. Never as a button fill or surface.
- Use `none` (0px) by default. Reserve `full` for circular icon buttons only.
- Letter-space all-caps labels at 1.5px. The "machined" feel is non-negotiable.
- Use `section` (96px) between major editorial bands for grid-aligned vertical rhythm.

### Don't
- Don't introduce a brand color outside the M tricolor (`m-blue-light` / `m-blue-dark` / `m-red`) and the heritage `bmw-blue`.
- Don't bold body type. Body stays at 300 (Light) — bumping to 400 or 500 makes the page feel marketing-bombastic instead of European-engineered.
- Don't use rounded buttons. The rectangular silhouette IS the brand. Rounded corners read as consumer-tech, not motorsport.
- Don't put gradient backdrops behind hero type. The hero IS the photography — the page floor stays pure black, and the photo provides the depth.
- Don't repeat the same surface mode in two consecutive bands. Rhythm: photo band → spec table → photo band → magazine grid → photo band. Two text-only bands in a row read as a corporate site.
- Don't use the M stripe as a button fill. The stripe is a divider / accent — never an action surface.
- Don't bold uppercase tracking under 1.5px on button labels — the spacing is what makes them feel "machined."



## bugatti
An austere luxury-automotive interface that uses near-pure black canvas, white uppercase letterspaced display, and full-bleed automotive photography as the only voltage. The system runs three custom Bugatti typefaces — Bugatti Display, Bugatti Text Regular, and Bugatti Monospace — and combines them at modest weights with wide tracking to feel European-engineered, hyper-minimal, and quietly expensive. There is no accent color, no decorative element, no chrome — only photography, typography, and the brand wordmark.
Core tokens: {"primary": "#ffffff", "ink": "#ffffff", "muted": "#999999", "muted-soft": "#666666", "hairline": "#262626", "hairline-strong": "#3a3a3a", "canvas": "#000000", "surface-soft": "#0d0d0d", "surface-card": "#141414", "surface-elevated": "#1f1f1f", "on-primary": "#000000", "link": "#c3d9f3"}
Fonts: ['Bugatti Display, sans-serif', 'Bugatti Display, serif', 'Bugatti Monospace, ui-monospace, monospace', 'Bugatti Text Regular, serif']
Layout: - **Max content width:** ~1280px centered. Hero photo bands bleed full-width with no max.
- **Editorial body:** Single 12-column grid; photo bands are full-bleed.
- **Newsroom layout:** 2-up article grid at desktop, 1-up at tablet+mobile.
- **Career listings:** Single column with 80px row spacing.

## Do's and Don'ts

### Do
- Anchor every page with full-bleed automotive photography. The cars are the brand voltage; chrome backs off entirely.
- Keep all display headlines in UPPERCASE Bugatti Display with 2-4px letter-spacing. The wordmark gets 6px.
- Use Bugatti Display for headlines, Bugatti Text Regular (serif!) for body, Bugatti Monospace for buttons + captions + nav. The trinity is unbreakable.
- Keep `button-primary` transparent with a 1px white outline. The transparent pill IS the brand button.
- Use weight 400 everywhere. Bold breaks the brand voice — the system has no bold weight role.
- Use `section` (120px) between major editorial bands. The whitespace is part of the brand.
- Reserve `link` (#c3d9f3) for inline anchor links only. It's the system's only non-monochrome color.

### Don't
- Don't introduce any accent color outside `link`. Bugatti's brand discipline is total monochrome + photography. Adding a brand-blue or brand-red breaks the contract.
- Don't bold any type. The system has no bold weight — every typeface stays at 400.
- Don't fill primary buttons. Transparent + outline only. A solid white button reads as off-brand.
- Don't compress whitespace between sections. The 120px rhythm is part of the editorial pacing.
- Don't use rounded corners outside buttons. Cards, photos, inputs all stay at 0px. Rounded cards read as consumer-tech, not luxury-engineered.
- Don't tighten letter-spacing on display headlines. 2-4px tracking on Bugatti Display is non-negotiable.
- Don't use Bugatti Display in a button (use Bugatti Monospace) or Bugatti Monospace in a paragraph (use Bugatti Text Regular). The trinity split is the brand voice.



## cal
A clean, calendar-software-first interface anchored on white canvas with black primary CTAs and custom Cal Sans display typography. The system reads as friendly modern SaaS — generous whitespace, soft-rounded cards (~12px), product UI fragments shown directly inside cards, and a dark navy footer that visually closes long-scroll pages. Brand voltage comes from the Cal Sans display headline (a custom geometric face) and from product UI artifacts shown in-card rather than from accent colors.
Core tokens: {"primary": "#111111", "primary-active": "#242424", "primary-disabled": "#e5e7eb", "ink": "#111111", "muted": "#6b7280", "muted-soft": "#898989", "hairline": "#e5e7eb", "hairline-soft": "#f3f4f6", "canvas": "#ffffff", "surface-soft": "#f8f9fa", "surface-card": "#f5f5f5", "surface-strong": "#e5e7eb", "surface-dark": "#101010", "surface-dark-elevated": "#1a1a1a", "on-primary": "#ffffff", "badge-pink": "#ec4899"}
Fonts: ['Cal Sans, Inter, sans-serif', 'Inter, sans-serif', 'JetBrains Mono, ui-monospace, monospace']
Layout: - **Max content width:** ~1200px centered on marketing pages.
- **Editorial body:** Single 12-column grid; hero band often uses 7/5 split (h1 left, app mockup card right).
- **Feature card grids:** 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Pricing grid:** 4-up at desktop, 2-up at tablet, 1-up at mobile.
- **Footer:** 4-column link list at desktop, wrapping to 2-up at tablet, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (#111111) for primary CTAs and h1/h2 type. Cal.com's button is near-black, not blue.
- Use Cal Sans for every display headline. Pair with Inter body. Never blur the boundary.
- Apply negative letter-spacing on display sizes (-0.5 to -2px). Cal Sans without it reads as off-brand.
- Use `feature-card` (light gray) and `product-mockup-card` (white with chrome) deliberately — the gray cards signal "abstract feature claim", white cards signal "look at the actual product".
- Embed real product UI fragments inside marketing cards. Don't paint marketing illustrations of the product when you can show the product itself.
- Keep avatar circles at 36px, perfect circles, sometimes with pastel fills. Avatars are the only place where badge pastels appear.
- Use `nav-pill-group` for grouped sub-nav segments. The pill-in-pill treatment is signature.
- End every page with the dark footer. The light-to-dark transition is part of the editorial rhythm.

### Don't
- Don't use accent colors (`brand-accent`, badge pastels) on primary CTAs. The system is monochrome at the action layer.
- Don't bold display weight beyond 600. Cal Sans at 700 reads as bombastic.
- Don't use rounded radius beyond `xl` (16px) on cards. Larger radii read as consumer-app, not professional booking software.
- Don't put dark surface cards anywhere except the footer and the featured pricing tier. The dark surface is a deliberate, scarce signal.
- Don't repeat the same surface mode in two consecutive bands. Cal.com's pacing alternates white → light-gray → white → product-mockup-card → white → dark-footer.
- Don't add hover state styling beyond what the system already encodes — primary darkens on press; nothing else changes.



## claude
A warm-canvas editorial interface for Anthropic's Claude product. The system anchors on a tinted cream canvas with serif display headlines, warm coral CTAs, and dark navy product surfaces (code editor mockups, model showcase cards). Brand voltage comes from the cream/coral pairing — deliberately warm and humanist where most AI brands use cool blue + slate. Type voice runs a slab-serif display ("Copernicus" / Tiempos Headline) for h1/h2 and a humanist sans for body. The signature Anthropic black-radial-spike mark anchors the wordmark.
Core tokens: {"primary": "#cc785c", "primary-active": "#a9583e", "primary-disabled": "#e6dfd8", "ink": "#141413", "muted": "#6c6a64", "muted-soft": "#8e8b82", "hairline": "#e6dfd8", "hairline-soft": "#ebe6df", "canvas": "#faf9f5", "surface-soft": "#f5f0e8", "surface-card": "#efe9de", "surface-cream-strong": "#e8e0d2", "surface-dark": "#181715", "surface-dark-elevated": "#252320", "surface-dark-soft": "#1f1e1b", "on-primary": "#ffffff"}
Fonts: ['Copernicus, Tiempos Headline, serif', 'StyreneB, Inter, sans-serif', 'JetBrains Mono, ui-monospace, monospace']
Layout: - **Max content width:** ~1200px centered.
- **Editorial body:** Single 12-column grid; hero often uses 6/6 split (h1 left, illustration right).
- **Feature card grids:** 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Connector tile grids:** 4-up or 6-up at desktop, 2-up at tablet, 1-up at mobile.
- **Pricing grid:** 3-up at desktop (Free / Pro / Team / Enterprise often), 1-up at mobile.

## Do's and Don'ts

### Do
- Anchor every page on the cream canvas. Pure white reads as "any other AI tool"; the warm tint is the brand differentiator.
- Use Copernicus serif for every display headline. Pair with StyreneB sans body. Negative letter-spacing on display sizes is non-negotiable.
- Reserve `primary` (coral) for primary CTAs and full-bleed `callout-card-coral` moments. Don't paint accent moments coral elsewhere.
- Use `product-mockup-card-dark` and `code-window-card` to show actual Claude product chrome. Don't paint marketing illustrations of code when you can show real code.
- Pair `feature-card` (cream) with `product-mockup-card-dark` (navy) in alternating bands. The cream-to-dark rhythm is the brand's pacing mechanism.
- Use the Anthropic spike-mark glyph as the brand wordmark prefix. Never invert the mark to white-on-dark within the wordmark itself.
- Apply `section` (96px) between major bands.

### Don't
- Don't use cool grays or pure white for canvas. Cream is the brand.
- Don't bold serif display weight. Copernicus at 700 reads as bombastic; the system stays at 400.
- Don't use cool blue or saturated cyan as a brand accent. The coral is the brand voltage.
- Don't put coral everywhere. The coral is scarce on individual elements and generous only on full-bleed coral callout cards.
- Don't use Inter for display headlines. The serif character is the brand voice.
- Don't repeat the same surface mode in two consecutive bands. The pacing alternates: cream → cream-card → dark-mockup → cream → coral-callout → dark-footer.
- Don't add hover state styling beyond what the system already encodes — primary darkens on press; nothing else changes.



## clay
A vibrant claymation-meets-data interface for Clay.com (GTM data-orchestration platform). Anchors on white canvas with dark-navy primary CTAs, custom rounded display type, and saturated single-color feature cards — hot pink, deep teal, lavender, peach, ochre — that punctuate long-scroll explainer pages. Brand voltage comes from 3D-rendered claymation illustrations (mountains, characters, mascots) used as full-bleed hero artifacts and the bright multi-color card surfaces showing product UI fragments.
Core tokens: {"primary": "#0a0a0a", "primary-active": "#1f1f1f", "primary-disabled": "#e5e5e5", "ink": "#0a0a0a", "muted": "#6a6a6a", "muted-soft": "#9a9a9a", "hairline": "#e5e5e5", "hairline-soft": "#f0f0f0", "canvas": "#fffaf0", "surface-soft": "#faf5e8", "surface-card": "#f5f0e0", "surface-strong": "#ebe6d6", "surface-dark": "#0a1a1a", "surface-dark-elevated": "#1a2a2a", "on-primary": "#ffffff", "brand-pink": "#ff4d8b"}
Fonts: ['Plain Black, Inter, sans-serif', 'Inter, sans-serif']
Layout: - **Max content width:** ~1280px centered.
- **Editorial body:** Single 12-column grid; hero often uses 7/5 split (h1 left, illustration right).
- **Feature card grids:** 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Pricing grid:** 3-4 up at desktop, 1-up at mobile.

## Do's and Don'ts

### Do
- Anchor every page on the cream canvas (`canvas` — #fffaf0). The warm tint differentiates Clay from cool-gray data sites.
- Use 3D claymation illustrations as hero artifacts. Hand-crafted 3D characters and mountains ARE the brand.
- Cycle saturated feature cards across the page — pink → teal → lavender → peach → ochre → cream. Repeating the same color twice in a row reads as off-rhythm.
- Use Plain Black at weight 500 with negative letter-spacing on every display headline.
- Show product UI fragments inside saturated feature cards. The brand voltage is product-driven, not abstract.
- Use cream footer (NOT dark). Clay deliberately closes pages with warm cream rather than the standard dark-footer SaaS template.
- Anchor every band with `section` (96px) vertical rhythm.

### Don't
- Don't use cool grays for canvas. The cream tint is non-negotiable.
- Don't use a 7th brand-color card. The 6-color palette is saturated enough.
- Don't bold display weight beyond 500. Plain Black at 700 reads as bombastic.
- Don't repeat the same brand-color card twice in a row.
- Don't replace claymation illustrations with flat vector art. The hand-crafted 3D character IS the brand voice.
- Don't use a dark footer. The cream footer is part of the system's warm-throughout pacing.
- Don't add hover state styling beyond what the system already encodes.



## clickhouse
A high-performance database interface anchored on near-pure black canvas with electric yellow as the brand voltage. White typography in confident sans, yellow CTAs, and yellow-text stat numbers carry the brand voice across every page. Code blocks and product UI fragments embed directly in dark cards. The yellow + black pairing (and yellow used scarcely as accent) is the system's signature — brand identity without atmospheric decoration.
Core tokens: {"primary": "#faff69", "primary-active": "#e6eb52", "primary-disabled": "#3a3a1f", "ink": "#ffffff", "muted": "#888888", "muted-soft": "#5a5a5a", "hairline": "#2a2a2a", "hairline-strong": "#3a3a3a", "canvas": "#0a0a0a", "surface-soft": "#121212", "surface-card": "#1a1a1a", "surface-elevated": "#242424", "surface-yellow-band": "#faff69", "on-primary": "#0a0a0a"}
Fonts: ['Inter, sans-serif', 'JetBrains Mono, ui-monospace, monospace']
Layout: - **Max content width:** ~1280px centered.
- **Editorial body:** Single 12-column grid; hero often uses 7/5 split (h1 left, code mockup right).
- **Feature card grids:** 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Pricing grid:** 3-4 up at desktop, 1-up at mobile.

## Do's and Don'ts

### Do
- Anchor every page on the black canvas. The yellow + black pairing is the brand voltage.
- Reserve `primary` (yellow) for primary CTAs, stat-callout numbers, and full-bleed yellow CTA bands. The yellow's scarcity at the element level + abundance at the band level is what makes it powerful.
- Use Inter at weight 700 for every display headline, with -1 to -2.5px letter-spacing.
- Show actual SQL code blocks inside `code-window-card` — ClickHouse is a database; show the query, don't paint marketing illustrations of queries.
- Use `stat-callout` numbers to establish credibility (community size, contributors, performance benchmarks). The yellow stat numbers are signature.
- Anchor every band with `section` (96px) vertical rhythm.

### Don't
- Don't introduce a second brand color. ClickHouse is monochromatic + yellow.
- Don't bold display weight beyond 700 or use weight 500 for headlines. The hierarchy depends on size, not on weight gradation.
- Don't use yellow for body text or large surface fills outside of intentional yellow cards.
- Don't use rounded buttons / pills outside of small badges. The standard button radius is 8px (md).
- Don't repeat the same surface mode in two consecutive bands. Black canvas → dark feature card → yellow CTA card → black canvas → code-window card.
- Don't replace SQL code mockups with abstract illustrations. The code IS the marketing voltage.
- Don't add hover state styling beyond what the system already encodes.



## cohere
Cohere's 2026 web system is a controlled enterprise AI interface built from stark white editorial space, deep green-black product bands, soft mineral surfaces, rounded media cards, and a distinctive type split between monospaced-feeling display headlines and precise Unica77 UI text.
Core tokens: {"primary": "#17171c", "ink": "#212121", "canvas": "#ffffff", "hairline": "#d9d9dd", "muted": "#93939f", "body-muted": "#616161", "on-primary": "#ffffff"}
Fonts: ['CohereText', 'Unica77 Cohere Web', 'CohereMono']
Layout: 
- Global nav uses a three-zone layout: logo left, menu centered, sign-in/CTA right.
- Home hero is centered text above a two-card media composition: a wide product mockup card beside a narrower photography card.
- Feature sections commonly use 3-column cards on desktop.
- Product pages alternate centered hero blocks, trust-logo strips, large single-feature bands, and 2- or 3-column card grids.
- Research pages use full-width lists with date and chip columns instead of decorative cards.
- Forms use two-column input rows inside a rounded white card on dark or stone section backgrounds.

## Do's and Don'ts

### Do

- Use white canvas as the default surface; introduce dark green or navy as full-width product bands.
- Keep primary CTAs pill-shaped and near-black on light surfaces.
- Use 22px radius on major media cards and placeholders.
- Use coral for editorial taxonomy and small warm accents, not as the main CTA system.
- Use monochrome trust logos with wide spacing.
- Use thin-line geometric illustrations for research and capability icons.
- Let photography and product mockups carry color, while the UI shell stays restrained.

### Don't

- Do not turn coral or blue into broad decorative surface colors.
- Do not add heavy drop shadows to cards.
- Do not make every section card-based; Cohere often uses unframed rows, rules, and open space.
- Do not use rounded cards below 8px for major media.
- Do not replace the display/body type split with one generic sans-serif voice.
- Do not render undocumented interaction variants in documentation or previews.
- Do not use saturated gradients as normal UI backgrounds; keep gradients media-led.



## coinbase
An institutional-grade crypto exchange whose marketing surfaces read like a quietly-confident financial-services brand. The base canvas is pure white; Coinbase Blue (`#0052ff`) is the single brand voltage, used scarcely on primary CTAs, signature glyphs, and inline accent moments. Type runs Coinbase's licensed CoinbaseDisplay (display) and CoinbaseSans (body) at modest weights — display sits at weight 400 not 700, signaling editorial calm rather than fintech-bombastic. Page rhythm rotates between bright white sections, soft gray elevation bands, and full-bleed dark editorial heroes (`#0a0b0d`) carrying product-ui mockup cards. Iconography is geometric and minimal; depth comes from card-on-card layering, never decorative shadows.
Core tokens: {"primary": "#0052ff", "primary-active": "#003ecc", "primary-disabled": "#a8b8cc", "ink": "#0a0b0d", "muted": "#7c828a", "muted-soft": "#a8acb3", "hairline": "#dee1e6", "hairline-soft": "#eef0f3", "canvas": "#ffffff", "surface-soft": "#f7f7f7", "surface-card": "#ffffff", "surface-strong": "#eef0f3", "surface-dark": "#0a0b0d", "surface-dark-elevated": "#16181c", "on-primary": "#ffffff"}
Fonts: ["'Coinbase Display', -apple-system, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif", "'Coinbase Display', sans-serif", "'Coinbase Sans', sans-serif", "'Coinbase Mono', 'Coinbase Sans', monospace"]
Layout: - **Max content width:** ~1200px centered. Hero photography full-bleed.
- **Editorial body:** Single 12-column grid.
- **Feature card grids:** 2-up at desktop for hero splits, 3-up for benefit grids.
- **Footer:** 6-column link list at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` (Coinbase Blue) for primary CTAs, wordmark, brand-glyph illustrations, inline accent links.
- Set every CTA as `pill` (100px); every asset glyph as `full`.
- Keep CoinbaseDisplay headlines at weight 400.
- Use the dark/light band rotation as page rhythm.
- Render every numerical value in CoinbaseMono via `number-display`.
- Pair every dark hero with a layered product-UI mockup card stack.

### Don't
- Don't introduce a secondary brand color. Coinbase Blue is the only action color; trading green/red are semantic-only.
- Don't bold display copy — display sits at weight 400; bolding shifts the brand voice.
- Don't add drop shadow tiers — system has one shadow tier.
- Don't use sharp `none` (0px) on CTAs.
- Don't mix CoinbaseDisplay and CoinbaseSans inside the same headline.
- Don't use trading green/red as a button background.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA color is what appears on actual product CTAs, not on injected modals.



## composio
A developer-tools brand for AI-agent tool integration whose marketing surfaces lean into a dark, technical aesthetic with a single deep-electric-blue voltage (`#0007cd`). The page floor is near-black (`#0f0f0f`); cards float above on subtle gray-tinted surfaces. abcDiatype carries display and body in a single sans family with weights 400-600. The brand's strongest visual signature is a four-pane terminal-style mockup (a 2×2 grid of dark code/output panels) with a central blue spotlight glow — used as the homepage hero anchor.
Core tokens: {"primary": "#0007cd", "primary-active": "#0005a3", "primary-glow": "#1a26ff", "ink": "#ffffff", "muted": "#888888", "muted-soft": "#666666", "hairline": "#222222", "hairline-soft": "#1a1a1a", "hairline-strong": "#333333", "canvas": "#0f0f0f", "canvas-deep": "#000000", "surface-card": "#181818", "surface-card-elevated": "#222222", "surface-strong": "#2a2a2a", "on-primary": "#ffffff"}
Fonts: ["'abcDiatype', ui-sans-serif, system-ui, sans-serif", "'JetBrains Mono', 'Fira Code', monospace"]
Layout: - Max content width: ~1200px.
- Editorial body: 12-column grid.
- Terminal mockup grid: 2×2 equal-size panes.
- Toolkit grid: 4-up at desktop, 2-up tablet, 1-up mobile.
- Footer: 5-column at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` for primary CTAs, wordmark, and spotlight glows.
- Use `md` (8px) for every CTA — not full pills.
- Use brightness-step ladder for elevation; avoid drop shadows.
- Pair every hero with a centered radial blue spotlight glow.
- Render code, CLI commands in JetBrains Mono via `code`.
- Use the 2×2 terminal-mockup grid as the homepage hero anchor.

### Don't
- Don't introduce a secondary brand color. Cyan and violet are illustrative-only.
- Don't use full pills on CTAs.
- Don't drop display weight to 400.
- Don't add drop shadow tiers.
- Don't use canvas-deep (#000000) outside terminal/code surfaces.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA color is what appears on actual page CTAs.



## cursor
An AI-first code editor whose marketing site reads like a quietly-confident developer-tools brand with a warm-cream editorial canvas (`#f7f7f4`) instead of the typical dark IDE atmosphere. Near-black warm ink (`#26251e`) carries body and display alike — display sits at weight 400 with negative letter-spacing for a magazine feel rather than a bold tech voice. The single brand voltage is **Cursor Orange** (`#f54e00`) reserved for primary CTAs and the wordmark. A signature pastel timeline palette (peach, mint, blue, lavender, gold) marks AI-action stages (Thinking / Reading / Editing / Grepping / Done) — only inside in-product timeline visualizations. Cards use minimal hairlines, no shadows, generous 80px section rhythm. CursorGothic for display/body, JetBrains Mono on every code surface (which is roughly half the page).
Core tokens: {"primary": "#f54e00", "primary-active": "#d04200", "ink": "#26251e", "muted": "#807d72", "muted-soft": "#a09c92", "hairline": "#e6e5e0", "hairline-soft": "#efeee8", "hairline-strong": "#cfcdc4", "canvas": "#f7f7f4", "canvas-soft": "#fafaf7", "surface-card": "#ffffff", "surface-strong": "#e6e5e0", "on-primary": "#ffffff", "timeline-thinking": "#dfa88f"}
Fonts: ["'CursorGothic', system-ui, 'Helvetica Neue', Helvetica, Arial, sans-serif", "'CursorGothic', sans-serif", "'JetBrains Mono', 'Fira Code', monospace"]
Layout: - Max content width: ~1200px.
- Editorial body: 12-column grid.
- Feature card grids: 2-up at desktop for splits, 3-up for benefits.
- Footer: 5-column at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` (Cursor Orange) for primary CTAs and brand wordmark.
- Keep display weight at 400. The editorial voice depends on this.
- Use the cream `canvas` page floor — never pure white.
- Render every code surface (inline, blocks, IDE panes) in JetBrains Mono.
- Use timeline pastels only inside in-product agent visualizations — never as system action colors.

### Don't
- Don't introduce a secondary brand action color. Cursor Orange is the only one.
- Don't drop display to bold weights (700+). Magazine voice depends on 400.
- Don't add drop shadows. Hairlines + ink-on-cream contrast carry the depth.
- Don't use timeline pastels on non-timeline UI. They're scoped to the agent timeline only.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA is what appears on actual product CTAs.



## dell-1996
An inspired interpretation of Dell.com's 1996 design language — a catalog-era enterprise web design built around a literal black page frame, vivid flat color-block "ribbon cards" tinted in sage, salmon, periwinkle, sky, peach and lime, chunky Helvetica-Black display titles, Times Roman body copy, and an entire visual vocabulary of pre-Photoshop hand-cut GIF stickers (NEW! bursts, award seals, beveled product photos).
Core tokens: {"primary": "#e91d2a", "on-primary": "#ffffff", "canvas": "#ffffff", "surface": "#ffffff", "ink": "#000000", "frame-ink": "#000000", "link": "#0000ee", "tint-periwinkle": "#8c9ae0"}
Fonts: ['Arial Black', 'Helvetica', 'Times New Roman']
Layout: - Fixed-width table layout pinned around 760 px wide — the de facto 1996 standard targeting 800×600 monitors with a small scrollbar gutter.
- Two-column outer structure: left rail (~28 %) carries the homepage icon-link grid + CTA red panel; right column (~72 %) carries the product ribbon stack.
- No grid system in the modern sense — every section is its own `<table>` declaration with hard-coded column widths.

## Do's and Don'ts

### Do
- Keep the literal `{components.page-frame}` black border on every page — this is the brand's single most identifiable container chrome.
- Reserve `primary` (Dell red) for the `{components.cta-block-red}` panel and the `{components.phone-callout}` only. Every other use dilutes the urgency signal.
- Use the eight ribbon-card tint colors (`tint-olive` / sage / salmon / peach / lime / sky / steel / periwinkle) as a *family* — pick one per product line and stay with it across the line's marketing surfaces.
- Set every display headline in `display` (Arial Black 36 / weight 900). The brand's typographic register depends on extreme weight against flat color.
- Keep body copy in `body` Times Roman 14 — substituting a modern sans loses the catalog feel entirely.
- Render every CTA / button at `none` (0 px). Modern soft-radius buttons betray the era.
- Use hand-painted bevels / hard-edge GIF shadows on stickers and product photos. Never substitute a soft CSS shadow.

### Don't
- Don't introduce a chromatic accent outside the eight catalog tints + Dell red + Dell yellow + classic link blue. The palette is closed by design.
- Don't soften any corner. `none` is the universal modifier; only award seals get `full`.
- Don't replace Times Roman body with Arial / Helvetica / Inter / a webfont — the serif body is the era's signature.
- Don't add soft drop-shadows or atmospheric gradients. The brand has hard borders and flat fills; everything else reads as anachronism.
- Don't crop or "tuck" product photos with `border-radius` or `clip-path`. The notch into the ribbon-card right edge is the framing — the photo itself stays a hard rectangle.
- Don't pair two `{components.cta-block-red}` panels on the same page. The red fill is meant to be the singular attention pole.
- Don't strip the `{components.phone-callout}` from the top banner. In 1996 the website existed to drive phone-call orders; the phone number IS the navigation.


## dji
An analysis of DJI's design language — a product-photography showroom for drones and cameras, where full-bleed studio renders sit in square, gutter-separated tiles on a white canvas, every action is a rounded pill in a single engineering blue, type is a tightly tracked Open Sans set in near-black ink at stepped opacities, small orange tier labels mark product rank, and the store layers 8px option cards, a sticky purchase bar and pale grey panels on top of the same restrained system before closing on a charcoal footer.
Core tokens: {"primary": "#0070d5", "on-primary": "#ffffff", "link-blue": "#1890ff", "canvas": "#ffffff", "canvas-soft": "#f7f9fa", "ink": "#262626", "ink-secondary": "#595959", "ink-tertiary": "#8c8c8c", "store-ink": "#333333", "nav-ink": "#303233", "footer-link": "#b3b3b3", "hairline": "#f0f0f0"}
Fonts: ['Open Sans']
Layout: - Home and category tiles run full width minus a small outer gutter, two-up below the hero; editorial and field cards run two-up and three-up.
- The comparison table is four columns; explore and support cards are two-up inside a 1200px container.
- The store product page splits into a large photo gallery on the left and a 500px purchase column on the right.

## Do's and Don'ts

### Do
- Let product photography fill square, gutter-separated tiles; keep text centred above the render.
- Use `primary` (brand site) or `store-blue` (store) for every primary action, always as a pill.
- Pair a filled blue pill with a 1px `ink` outline pill for the secondary action.
- Use white `button-hero-ghost` pills over dark hero photography.
- Set all text in Open Sans with slight negative tracking, and use the ink opacity steps (`ink`, `ink-secondary`, `ink-tertiary`) for hierarchy.
- Mark product rank with a small `tier-eyebrow` in `tier-orange`.
- In the store, group choices into `sm` option cards and show selection with a 2px `store-blue` ring.
- Close pages with the `footer` footer on the brand site and `canvas-soft` in the store.

### Don't
- Don't round photo tiles, cards or media tiles; only pills, option cards and small tags are rounded.
- Don't use more than one blue on the same surface; the brand site and the store each have their own.
- Don't use orange for buttons or large fills; it is reserved for small rank labels and the option badge.
- Don't use pure black for text; use `ink`.
- Don't add drop shadows to tiles or cards; keep shadows for floating buttons and the sticky purchase bar.
- Don't set headings heavier than 600 or track type positively.


## elevenlabs

Core tokens: {}
Fonts: []
Layout: - Max content width: ~1200px.
- Editorial body: 12-column grid.
- Feature card grids: 2-up at desktop for hero splits, 3-up for benefit grids.
- Footer: 5-column at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` (ink pill) for primary CTAs.
- Use Waldenburg Light at weight 300 for every display headline. Never bold.
- Use Inter at +0.15-0.18px tracking for body — the editorial dialect.
- Use atmospheric gradient orbs (mint/peach/lavender/sky/rose) as decoration only.
- Use the pill shape for every CTA and badge.

### Don't
- Don't introduce a saturated brand action color. Ink pill is the only CTA color.
- Don't bold display copy. Display sits at weight 300 — bolding shifts the brand voice from editorial to consumer-marketing.
- Don't use gradient orbs as button fills, text colors, or component backgrounds. They are pure atmosphere.
- Don't use sharp `none` (0px) on CTAs. Pill geometry is the brand button.
- Don't drop body Inter to weight 300 to match Waldenburg — body stays at 400/500 for legibility.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA color is what appears on actual product CTAs.



## expo
A React Native developer-platform whose marketing site reads like a quietly-confident infrastructure brand. The base canvas is pure white with a soft sky-blue gradient atmospheric wash behind the hero; near-black ink (`#171717`) carries body and display alike. The single brand voltage is **pure black** (`#000000`) for primary CTAs — minimal and editorial-feeling, paired with a small blue text-link accent (`#0d74ce`) reserved for inline body links. Type pairs Inter at modest weights (display 600, body 400) with JetBrains Mono on every code surface. The brand's strongest visual signature is the **device-mockup hero** — a centered MacBook + iPhone composite showing real Expo dev surfaces — over the gradient sky wash.
Core tokens: {"primary": "#000000", "primary-active": "#1a1a1a", "text-link": "#0d74ce", "text-link-secondary": "#476cff", "ink": "#171717", "muted": "#999999", "muted-soft": "#cccccc", "hairline": "#f0f0f3", "hairline-soft": "#f5f5f7", "hairline-strong": "#dcdee0", "canvas": "#ffffff", "canvas-soft": "#fafafa", "surface-card": "#ffffff", "surface-strong": "#f0f0f3", "surface-dark": "#171717", "surface-dark-elevated": "#1a1a1a", "on-primary": "#ffffff", "accent-link-bright": "#47c2ff"}
Fonts: ["'Inter', -apple-system, system-ui, sans-serif", "'Inter', sans-serif", "'JetBrains Mono', 'Fira Code', monospace"]
Layout: - Max content width: ~1200px.
- Editorial body: 12-column grid.
- Feature card grids: 2-up at desktop for hero splits, 3-up for benefit grids.
- Ecosystem tile grid: 8-up at desktop.
- Footer: 5-column at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` (black) for primary CTAs.
- Use `text-link` (blue) for inline body links only — never on CTAs or buttons.
- Set every CTA at `md` (8px) — developer dialect.
- Use Inter at weight 600 for display, 400 for body.
- Render every code surface in JetBrains Mono.
- Pair the hero with the device-mockup composite — it's the page chrome.

### Don't
- Don't introduce a saturated brand action color. Black is the only CTA fill.
- Don't use blue (`text-link`) on a CTA. Inline links only.
- Don't drop display below weight 600 or above 700.
- Don't use full pills on CTAs — pills are for badges only.
- Don't replicate the sky-blue gradient backdrop outside the hero.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA is what appears on actual page CTAs.



## ferrari
A luxury-automotive brand whose marketing surfaces read as cinematic editorial. The base canvas is **near-black** (`#181818`) holding pure white display type; white-canvas bands appear only inside specific editorial contexts (preowned listings, pricing tables). The single brand voltage is **Rosso Corsa** (`#da291c`) — the iconic Ferrari racing red — used scarcely on primary CTAs, the Cavallino mark, and Formula 1 race-position highlights. Type runs **FerrariSans** at modest weights (display 500, body 400) — never bombastic. Spacing follows an explicit 8px token ladder (`xxxs` 4px through `super` 128px); generous editorial pacing throughout. The brand's strongest visual signature is the **full-bleed cinematic hero photograph** that fills the viewport top with car photography, model details, or trackside livery — followed by a tighter editorial body layout below.
Core tokens: {"primary": "#da291c", "primary-active": "#b01e0a", "primary-hover": "#9d2211", "ink": "#ffffff", "muted": "#666666", "muted-soft": "#8f8f8f", "hairline": "#303030", "hairline-on-light": "#d2d2d2", "hairline-soft": "#ebebeb", "canvas": "#181818", "canvas-elevated": "#303030", "canvas-light": "#ffffff", "surface-card": "#303030", "surface-soft-light": "#f7f7f7", "surface-strong-light": "#ebebeb", "on-primary": "#ffffff"}
Fonts: ["'FerrariSans', -apple-system, system-ui, sans-serif", "'FerrariSans', sans-serif"]
Layout: - Max content width: ~1280px on editorial bands. Hero photography goes full-bleed.
- Editorial body: 12-column grid.
- Feature card grids: 2-up at desktop for hero splits, 3-up for benefit grids, 4-up for preowned listing tiles.
- Footer: 5-column at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` (Rosso Corsa) for primary CTAs, the Cavallino mark, and F1 race-position highlights.
- Set every CTA at `none` (0px sharp corners) — the brand's signature precision.
- Render CTA labels in uppercase with 1.4px tracking via `button`.
- Pair every hero with a full-bleed cinematic photograph — the photograph IS the depth.
- Use the explicit 8px spacing ladder (`xxxs` through `super`) rather than ad-hoc px values.
- Keep display weight at 500 — never bold.

### Don't
- Don't introduce a saturated brand color other than Rosso Corsa.
- Don't use rounded or pill CTAs — sharp 0px corners are the brand button.
- Don't bold display copy. The cinematic photography does the visual heavy-lifting.
- Don't use Hypersail yellow outside the Hypersail sailing program context.
- Don't use pure black canvas. The brand canvas is `canvas` (#181818) — slightly warm.
- Don't add drop shadow tiers. Photography + brightness-step elevation carry the depth.
- Don't extract a CTA color from a third-party widget (cookie consent, OneTrust). The brand's CTA color is what appears on actual product CTAs, not on injected modals.



## figma
A confident black-and-white editorial frame interrupted by oversized, hand-cut pastel color blocks. The marketing canvas is rigorously monochrome — figmaSans variable type, pure white surfaces, pure black ink, pill-shaped CTAs — while each story section drops the page into a saturated lime, lavender, cream, mint, or pink panel that reads like a sticky note placed on a clean desk. The result is a design system that feels both technical and joyful — a tool for serious work, made by people who like color.
Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#000000", "canvas": "#ffffff", "inverse-canvas": "#000000", "inverse-ink": "#ffffff", "hairline": "#e6e6e6", "hairline-soft": "#f1f1f1", "surface-soft": "#f7f7f5", "block-pink": "#efd4d4"}
Fonts: ['figmaSans', 'figmaMono']
Layout: 
- Max content width sits around 1280px (one of the explicit breakpoints), with side gutters that scale from `xxl` on desktop down to `lg` on mobile.
- Three- and four-column grids on the desktop pricing comparison and FigJam template galleries.
- Color-block sections break the column grid — they span content width with full bleed inside the rounded `lg` corners, then place a single editorial column of headline + body inside.

## Do's and Don'ts

### Do

- Reserve `primary` for genuine primary CTAs and selected states (e.g., `pricing-tab-selected`). Don't use it as a decorative accent.
- When introducing a story section, choose **one** color block from the `block-*` family and let it span full content width with `lg` corners and `xxl` interior padding.
- Keep type in `figmaSans` at variable weights — pick from 320, 330, 340, 480, 540, 700 to express hierarchy. Avoid intermediate weights outside this set.
- Use `figmaMono` only for eyebrows and captions, always uppercase, with the documented positive letter-spacing.
- Compose every CTA as a pill (`pill`) and every icon button as a circle (`full`).
- Allow the page to **return to white canvas** between every two color blocks so each block reads as deliberate.
- Pair `button-primary` and `button-secondary` whenever a section needs both a primary action and a sales / secondary action — the black-and-white pair is the brand signature.

### Don't

- Don't introduce mid-gray text. Body hierarchy comes from `figmaSans` weight, not from opacity.
- Don't add drop shadows to color-block sections — the color is the depth device.
- Don't introduce new accent colors outside the documented `block-*` palette and `accent-magenta`. Adding, e.g., a saturated brand orange would break the system.
- Don't combine more than one color block visible inside a single viewport — Figma's pacing always lets the white canvas separate them.
- Don't square off CTAs. Square buttons read as a different brand.
- Don't put `figmaMono` in body copy — it's a taxonomy tool, not a reading typeface.
- Don't replace the `pricing-tab-selected` black fill with a colored tab; the brand pattern is "selected = primary surface".



## framer
A confident dark-canvas builder marketing site that treats the page like a working artboard — pure black surfaces, white display type set in GT Walsheim Medium with aggressive negative tracking, and a single confident blue (#0099ff) reserved for hyperlinks and selection states. The page rhythm is broken by oversized vibrant gradient atmosphere panels — magenta, violet, orange spotlights — that act as living showcase tiles, not decoration. Every CTA is a white pill on dark; every card is a translucent or charcoal surface; every section title pulls letter-spacing tight enough to feel like a poster.
Core tokens: {"primary": "#ffffff", "on-primary": "#000000", "ink": "#ffffff", "ink-muted": "#999999", "canvas": "#090909", "surface-1": "#141414", "surface-2": "#1c1c1c", "hairline": "#262626", "hairline-soft": "#1a1a1a", "inverse-canvas": "#ffffff", "inverse-ink": "#000000"}
Fonts: ['GT Walsheim Framer Medium', 'GT Walsheim Medium', 'Inter', 'Inter Variable']
Layout: 
- Max content width sits around the 1199px breakpoint, with side gutters that scale toward `xl` on desktop.
- Card grids on the home gallery use 2-up at desktop, collapsing to 1-up below 810px.
- Pricing tier grid is 4-up across the documented breakpoints; comparison table beneath it uses fixed-width left column with horizontally scrolling tier columns at narrow widths.

## Do's and Don'ts

### Do

- Reserve `primary` (white) and `canvas` (near-black) as the system's two anchor surfaces. Every band of the page chooses one or the other.
- Push display-size letter-spacing aggressively negative — `display-xxl` at -5.5px is the brand signature, not a stylistic accident.
- Use `accent-blue` only for hyperlinks, focus rings, and selected indicators. Never as a background or button fill.
- Drop one or two `gradient-spotlight-card` variants into a card grid; they are the brand's atmosphere device. Don't overdo it — three or more in the same viewport reads as a moodboard, not a system.
- Compose every CTA as a pill (`pill`); secondary actions live as charcoal pills, never as bordered ghost buttons.
- Keep body type Inter Variable with character variants `cv01`, `cv05`, `cv09`, `cv11`, `ss03`, `ss07` enabled — the brand voice depends on them.
- Use surface lift (canvas → surface-1 → surface-2) to mark hierarchy on dark, not opacity changes on white type.

### Don't

- Don't ship a light-mode marketing page. Framer's identity is dark.
- Don't introduce mid-tone gray text outside `ink-muted`. The hierarchy is binary: `ink` or `ink-muted`.
- Don't use `accent-blue` as a brand fill (e.g., a blue CTA pill). The blue is a signal color, not a surface.
- Don't square off CTAs. Pill (`pill`) or full circle is the brand vocabulary.
- Don't reduce the negative letter-spacing on display sizes "for accessibility". The compression is intrinsic to the brand voice; reduce the SIZE if needed, but keep the percentage.
- Don't apply gradient backgrounds to whole sections. Gradients are CARDS, not section grounds.
- Don't combine more than one chromatic accent. The palette is monochrome plus one blue plus the gradient family — not "blue, green, and red".



## hashicorp
An enterprise-infrastructure marketing canvas built around a near-black ground (#000000) and a system of per-product accent colors — Terraform purple, Vault yellow, Consul pink, Waypoint cyan, Vagrant blue — that act as identity tokens rather than decorative palette. Display type is hashicorpSans set in 600/700 with tight 1.17–1.21 line-heights; body type runs the same family at 500 weight with relaxed 1.50–1.71 line-heights. Cards live as charcoal surfaces with 1px translucent gray borders; product showcase cards lift into per-product chromatic gradients. The system reads as confident, technical, and intentionally multi-product — every section quietly signals which HashiCorp tool it represents.
Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#ffffff", "ink-muted": "#b2b6bd", "ink-subtle": "#656a76", "canvas": "#000000", "surface-1": "#15181e", "surface-2": "#1f232b", "surface-3": "#3b3d45", "hairline": "#3b3d45", "hairline-soft": "#252830", "inverse-canvas": "#ffffff", "inverse-ink": "#000000"}
Fonts: ['hashicorpSans']
Layout: 
- Max content width sits around 1280px with side gutters scaling from `xxl` on desktop down to `lg` on mobile.
- Product card grids are 3-up on desktop, 2-up at tablet, 1-up on mobile.
- Pricing tier grid is 3-up across desktop; comparison table beneath uses fixed-width left column.
- Resource directory (PDF library) uses 4-up dense thumbnail grid.

## Do's and Don'ts

### Do

- Reserve `canvas` (black) and `surface-1` (charcoal) as the system's two anchor surfaces. Every band of the page is one or the other.
- When introducing a section about a specific HashiCorp product, use that product's `product-*` token consistently — for the section pill, the CTA button, and (where appropriate) the showcase card background.
- Use `md` 8px on CTA buttons; HashiCorp's brand reads as engineered, not consumer.
- Pair tight display line-heights (1.17–1.21) with relaxed body line-heights (1.50–1.71). The contrast IS the brand voice.
- Use the eyebrow typography (`eyebrow`, uppercase, 0.6px tracking) above every meaningful section.
- Use surface lift (canvas → surface-1 → surface-2) to express hierarchy on dark.
- Reserve product-chromatic cards for product identity; keep generic feature cards on `surface-1`.

### Don't

- Don't ship a light-mode marketing page. HashiCorp's marketing brand IS dark.
- Don't introduce mid-tone gray text outside the documented `ink` / `ink-muted` / `ink-subtle` set.
- Don't square off CTA corners — use `md` 8px, not 0px.
- Don't use a product accent color for a CTA on a page that isn't about that product. Terraform purple on the Vault page is a brand violation.
- Don't combine multiple product accents in the same viewport — the system says "this section is about THIS tool", and mixing accents breaks that signal.
- Don't add drop shadows on dark; surface lift carries elevation.
- Don't replace `hashicorpSans` with a display-only sans for headlines and a different family for body. The brand is held together by one family across the full hierarchy.



## hp
An inspired interpretation of HP's design language — a white-paper enterprise-consumer system anchored by HP Electric Blue (`#024ad8`) as the lone signal CTA, near-black ink (`#1a1a1a`) for headlines, geometric Forma-DJR sans throughout, and angular blue-chevron decorations that nod to the HP wordmark's slashes. Cards round at 8–16px, photos sit in soft 16px frames, and dark navy slabs anchor the customer-story and "how can we help" closing bands.
Core tokens: {"primary": "#024ad8", "primary-bright": "#296ef9", "primary-deep": "#0e3191", "primary-soft": "#c9e0fc", "on-primary": "#ffffff", "ink": "#1a1a1a", "ink-deep": "#000000", "ink-soft": "#292929", "on-ink": "#ffffff", "canvas": "#ffffff", "hairline": "#e8e8e8", "hairline-strong": "#c2c2c2", "link": "#024ad8", "link-pressed": "#0e3191"}
Fonts: ['Forma DJR Micro']
Layout: 
- **Desktop max-width**: 1366px content container with full-bleed-on-canvas section backgrounds.
- **Hero**: a single full-width photo card (homepage and laptop-hub hero) with the headline overlay positioned upper-left or upper-right.
- **Product family grid**: 4 columns at >1200px, 3 at 1024–1199px, 2 at 768–1023px, 1 below 768px.
- **Pricing tiers**: 4 columns at >1024px, 2x2 grid at 768–1023px, single-column accordion below 768px.
- **Footer**: 5-column link grid at >1024px, collapsing to 2-column then accordion on mobile.

## Do's and Don'ts

### Do
- Reserve `primary` for the primary CTA, link color, and `chevron-decoration` motif — at most twice per viewport
- Set every headline in Forma DJR Micro at weight 500 with line-height 1.0 — resist the urge to bump weight at hero scale
- Use `xl` (16px) for cards and photo frames; `md` (4px) for buttons and inputs — keep the two-tier split sharp
- Pair white `canvas` body bands with `cloud` (`#f7f7f7`) alternating bands; let the gray do the breathing
- Close every page rhythm with a dark-navy `ink` slab — the "How can we help?" prelude + footer
- Set button labels in uppercase with `button-md` (0.7px tracking) — the only place the system tracks letters
- Use Soft Lift shadow exclusively for product cards and pricing tiers — leave section bands flat
- Frame product photography inside `xl` containers; never use full-bleed circular masks

### Don't
- Don't introduce secondary saturated colors outside `primary` family + the `bloom-coral` sale-tag and `storm` printer-plan accents
- Don't apply heavy material shadows — depth is via color contrast (cloud vs. white) and Soft Lift only
- Don't round buttons above `md` (4px); a soft 8px+ button reads as a different brand
- Don't run Forma DJR Micro below 12px — small caption at 11px is the floor
- Don't use the chevron decoration as inline noise; it is a hero-only architectural element tied to the wordmark
- Don't drop ink text opacity to create hierarchy — switch surface or shift to `charcoal` / `graphite` instead
- Don't replace the HP wordmark with a generic sans lockup; the wordmark is a custom mark with its own ratio



## ibm
An enterprise-marketing canvas faithful to Carbon Design System: white surfaces, charcoal type, IBM Blue (#0f62fe) as the single confident accent, and a deliberately flat-square aesthetic where corners stay at 0–4px. Type runs IBM Plex Sans at light weight 300 for display sizes (a brand signature) and 400/600 for body and emphasis. Cards live as thin-bordered tiles with no shadow; sections separate via subtle gray rows. The chrome is square, the typography is light, and the only color in the system is one assertive blue — the result reads as old-world enterprise gravitas reframed for the cloud era.
Core tokens: {"primary": "#0f62fe", "on-primary": "#ffffff", "ink": "#161616", "ink-muted": "#525252", "ink-subtle": "#8c8c8c", "canvas": "#ffffff", "surface-1": "#f4f4f4", "surface-2": "#e0e0e0", "inverse-canvas": "#161616", "inverse-surface-1": "#262626", "inverse-ink": "#ffffff", "inverse-ink-muted": "#c6c6c6", "hairline": "#e0e0e0", "hairline-strong": "#161616"}
Fonts: ['IBM Plex Sans']
Layout: 
- Carbon's 16-column grid at desktop, scaling to 8 / 4 columns at tablet / mobile.
- Max content width sits around 1584px (Carbon's max-grid breakpoint).
- Card grids are 4-up at desktop, 2-up at tablet, 1-up at mobile.
- The customer logo marquee uses fixed-width tiles in a flex row, scrolling horizontally on smaller viewports.

## Do's and Don'ts

### Do

- Use `none` 0px on every CTA, card, input, and container. The flat-square aesthetic is the brand.
- Pair Plex Sans weight 300 for display sizes (42px+) with weight 400 for body. Resist the urge to bold the headline.
- Reserve `primary` IBM Blue for primary CTAs, links, focused-input underlines, and CTA banner. Do not use it as a card background or eyebrow color.
- Apply `letter-spacing: 0.16px` to body sizes. It's a Carbon precision detail and part of the typographic voice.
- Use surface change (`canvas` → `surface-1`) and 1px hairlines for card hierarchy. Skip drop shadows.
- Stick to sentence case for eyebrows and section labels — Carbon resists all-caps tracking.
- Invert to `inverse-canvas` only at the footer; the rest of the page stays light.

### Don't

- Don't round corners on buttons, cards, or inputs. Even 4px rounded corners break the Carbon look.
- Don't bold display headlines. Plex Sans at weight 300 is the brand voice; weight 700 makes it look generic.
- Don't add atmospheric depth (gradient backdrops, drop shadows, atmospheric overlays) outside the documented soft-blue hero gradient.
- Don't introduce a second brand color. IBM Blue is the only chromatic accent; status semantics use the documented green / yellow / red.
- Don't replace IBM Plex Sans with Inter or Helvetica without preserving the `letter-spacing: 0.16px` and weight-300 display treatment.
- Don't use pill-shaped buttons. Carbon uses square corners; pills read as a different brand.
- Don't write all-caps tracked eyebrows. Carbon's eyebrows are sentence case at 14px.



## intercom
An editorial customer-service marketing canvas built around a soft cream-white ground, charcoal type set in Saans (Intercom's proprietary geometric sans), and a single confident Fin Orange (#ff5600) reserved for the Fin AI brand. Cards live as floating white tiles with thin hairline borders and minimal radii (8–16px). Display headlines run Saans at weight 500 with measured negative tracking. The system reads as a careful, product-led publication: product screenshots dominate, ornament is rare, and the only place chromatic energy enters is the Fin Orange CTA.
Core tokens: {"primary": "#111111", "on-primary": "#ffffff", "ink": "#111111", "ink-muted": "#626260", "ink-subtle": "#7b7b78", "ink-tertiary": "#9c9fa5", "canvas": "#f5f1ec", "surface-1": "#ffffff", "surface-2": "#ebe7e1", "inverse-canvas": "#000000", "inverse-surface-1": "#313130", "inverse-ink": "#ffffff", "inverse-ink-muted": "#9c9fa5", "hairline": "#d3cec6", "hairline-soft": "#ebe7e1", "report-pink": "#ff2067"}
Fonts: ['Saans', 'SaansMono']
Layout: 
- Max content width sits around 1280px.
- Card grids are 3-up at desktop, 2-up at tablet, 1-up at mobile.
- Pricing tier grid is 3-up; comparison strip below shows checkmarks per tier.
- Product mockup cards span full content width — they're the protagonist of every section.

## Do's and Don'ts

### Do

- Reserve `canvas` cream as the system's anchor surface — never replace with pure white.
- Lift cards from cream onto white (`surface-1`) for hierarchy.
- Use **`button-fin`** Fin Orange ONLY on Fin AI product CTAs and Fin badges.
- Pair Saans display at weight 500 with body at 400.
- Use product UI screenshots as the protagonist of every section.
- Use `lg` 12px for cards and `xl` 16px for product mockup tiles.
- Apply negative tracking proportionally to display sizes.

### Don't

- Don't use pure white as the canvas.
- Don't use Fin Orange as a section background or as a generic primary CTA.
- Don't add drop shadows to floating cards.
- Don't introduce a second display family.
- Don't pill-round CTAs.
- Don't write all-caps tracked eyebrows.
- Don't promote the report palette colors to brand-level surfaces.
- Don't combine charcoal CTAs and Fin Orange CTAs in the same viewport.



## jobright
An analysis of Jobright's design language — an AI job-hunting platform built on an energetic spring-mint green against black and white, with pale-mint section bands carrying the page rhythm. Bold condensed Titillium Web display headings pair with a clean Inter UI, and the CTA system runs on high-contrast pill buttons — black pills for primary actions, a mint-green pill for the signature accent. Rounded product-mockup cards, a scrolling black job ticker, and generous whitespace give it a friendly, high-energy startup feel.
Core tokens: {"primary": "#00f0a0", "on-primary": "#000000", "ink": "#000000", "canvas": "#ffffff", "canvas-mint": "#ecffe0", "muted": "#86909c", "hairline": "#e5e7eb", "surface-soft": "#f2f4f5"}
Fonts: ['Titillium Web', 'Inter']
Layout: Content is centered in a ~1200px container (the dominant breakpoint in a wide 1600→575px ladder). Feature blocks run as two-column rows — copy + CTA on one side, a product-mockup card on the other — alternating sides down the page and collapsing to stacked single column on narrow screens. Testimonials run 3-up; the footer job-search bar runs as a single horizontal control row.

## Do's and Don'ts

### Do
- Reserve `primary` for the logo, links, the signature green pill, and highlights — the one electric accent that carries the brand.
- Carry section rhythm on the pale-mint band (`canvas-mint`), alternating with white and full-black bands.
- Use black pills (`lg`) for primary CTAs and the mint-green pill (`pill`) for the one signature accent action.
- Pair heavy Titillium Web headlines (`display`) with light Inter body (`body-lg`) for confident-yet-quiet hierarchy.
- Float product-mockup cards (`card`) on soft shadows over the mint bands to demo AI features.
- Keep buttons pill-shaped and high-contrast — black-on-mint or white-on-black.

### Don't
- Don't introduce the product-UI tag/score palette (Ant-style pastels) as brand chrome — the marketing system is mint, black, and white only.
- Don't fill a primary CTA with `primary` green as the default — the everyday primary is the black pill; green is the one accent pill.
- Don't set body copy in Titillium Web or headlines in Inter — the display/UI font roles are fixed.
- Don't put heavy shadows on cards — elevation is a hairline or a whisper-soft float.
- Don't cool or blue-shift the mint bands — the section wash is warm spring-mint `canvas-mint`.
- Don't square off the pills or the mockup cards — the rounded pill + 40px card silhouette is core to the friendly feel.


## kraken
## 1. Visual Theme & Atmosphere

Kraken's website is a clean, trustworthy crypto exchange that uses purple as its commanding brand color. The design operates on white backgrounds with Kraken Purple (`#7132f5`, `#5741d8`, `#5b1ecf`) creating a distinctive, professional crypto identity. The proprietary Kraken-Brand font handles display headings with bold (700) weight and negative tracking, while Kraken-Product (with IBM Plex Sans fallback) serves as the UI workhorse.

**Key Characteristics:**
- Kraken Purple (`#7132f5`) as primary brand with darker variants (`#5741d8`, `#5b1ecf`)
- Kraken-Brand (display) + Kraken-Product (UI) dual font system
- Near-black (`#101114`) text with cool blue-gray neutral scale
- 12px radius buttons (rounded but not pill)
- Subtle shadows (`rgba(0,0,0,0.03) 0px 4px 24px`) — whisper-level
- Green accent (`#149e61`) for positive/success states


Core tokens: {}
Fonts: []

## 7. Do's and Don'ts

### Do
- Use Kraken Purple (#7132f5) for CTAs and links
- Apply 12px radius on all buttons
- Use Kraken-Brand for headings, Kraken-Product for body

### Don't
- Don't use pill buttons — 12px is the max radius for buttons
- Don't use other purples outside the defined scale



## lamborghini
## 1. Visual Theme & Atmosphere

Lamborghini's website is a cathedral of darkness — a digital stage where jet-black surfaces stretch infinitely and every element emerges from the void like a machine under a spotlight. The page is almost entirely black. Not dark gray, not near-black — true, uncompromising black (`#000000`) that saturates the viewport and refuses to yield. Into this abyss, white type and Lamborghini Gold (`#FFC000`) are deployed with surgical precision, creating a visual language that feels like walking through a nighttime motorsport event where every surface absorbs light except the things that matter.

The hero is a full-viewport video — dark, cinematic, immersive — showing event footage or vehicle reveals with the Lamborghini bull logo floating ethereally above. The navigation is minimal: a centered bull logo, a "MENU" hamburger on the left, and search/bookmark icons on the right, all rendered in white against the black canvas. There are no borders, no visible nav containers, no background color on the header — just white marks floating in darkness. The overall mood is nocturnal luxury: exclusive, theatrical, and deliberately intimidating. Each section transition is a scroll through darkness into the next revelation.

Typography is the voice of this darkness. LamboType — a custom Neo-Grotesk typeface created by Character Type and design agency Strichpunkt — is used for everything from 120px uppercase display headlines to 10px micro labels. Its distinctive 12° angled terminals are inspired by the aerodynamic lines of Lamborghini's super sports cars, and its proportions range from Normal to Ultracompressed width. Headlines SHOUT in uppercase at enormous scales with tight line-heights (0.92 at 120px), creating dense blocks of text that feel stamped from steel. The typeface carries hexagonal geometric DNA — constructed from hexagons, three-armed stars, and circles — that echoes throughout the interface in the hexagonal pause button and UI icons. Built on Bootstrap grid with 68 Element Plus/UI components, the technical infrastructure is substantial beneath the theatrical surface.

**Key Characteristics:**
- True black (`#000000`) dominant surfaces with white and gold as the only relief colors
- LamboType custom Neo-Grotesk font with 12° angled terminals inspired by aerodynamic car lines
- Lamborghini Gold (`#FFC000`) as the sole accent color — used exclusively for primary CTA buttons
- All-uppercase display typography at extreme scales (120px, 80px, 54px) with tight line-heights
- Full-viewport video heroes with cinematic event/vehicle content
- Zero border-radius on buttons — sharp, angular, uncompromising rectangles
- Hexagonal motifs in UI elements (pause button, icon system) echoing brand geometry
- Bootstrap grid system + Element Plus/UI 68 components underneath
- Transparent ghost buttons with white borders at 50% opacity as the secondary CTA pattern


Core tokens: {}
Fonts: []
Layout: - **Framework**: Bootstrap grid system (container + row + col)
- **Max width**: 1440px (largest breakpoint)
- **Columns**: Standard 12-column Bootstrap grid
- **Full-bleed**: Hero sections break out of grid to fill viewport edge-to-edge
- **Content areas**: Centered within 1200px max-width containers

## 7. Do's and Don'ts

### Do
- Use absolute black (`#000000`) as the primary background — never dark gray as a substitute
- Apply Lamborghini Gold (`#FFC000`) exclusively for primary CTA buttons — never for decorative purposes
- Set all display headings in uppercase with LamboType — the brand voice is always SHOUTING
- Use zero border-radius on buttons and cards — sharp angles are non-negotiable
- Maintain tight line-heights (0.92–1.19) on display type to create dense, architectural text blocks
- Use the transparent ghost button (white border, 50% opacity) as the secondary CTA on dark backgrounds
- Let full-viewport video/photography carry emotional weight — UI is infrastructure, not decoration
- Reserve hexagonal geometry for UI icons and the video control button
- Use weight 400 (regular) for headlines — the typeface is distinctive enough without bold emphasis
- Keep the gray palette achromatic — all neutrals are pure gray without color tinting

### Don't
- Introduce additional accent colors beyond gold — the monochrome-plus-gold system is sacred
- Apply border-radius to buttons or cards — curved edges contradict the angular vehicle aesthetic
- Use LamboType in italic or decorative styles — the brand is always upright and direct
- Add gradients to buttons or surfaces — depth comes from surface layering, not blending
- Use light backgrounds as the primary canvas — darkness is the default state, light is the exception
- Mix lowercase into display headings — the uppercase convention communicates authority and power
- Add hover animations with scale or translate — interactions should be color-only (background/opacity shifts)
- Use Open Sans for display text — LamboType must handle all visible typography
- Create busy layouts with many small elements — Lamborghini's design is about singular, bold statements
- Apply shadows to elements — on a black canvas, shadows are meaningless; use surface color shifts instead



## linear.app
A near-black product-focused marketing canvas built around #010102 (the deepest dark surface of any tool in this collection), light gray text (#f7f8f8), and the signature Linear lavender-blue (#5e6ad2) used as the single chromatic accent. The system reads as software-craft documentation: dense, technical, and quietly luxurious. Display type is set in the Linear custom sans (SF Pro Display fallback) at 500–700 with measured negative tracking. Cards live as charcoal panels (#0f1011) with hairline borders. The accent lavender appears on the brand mark, focus rings, and a few intentional CTAs — never decoratively. Page rhythm leans on product UI screenshots framed in dark panels rather than atmospheric color.
Core tokens: {"primary": "#5e6ad2", "on-primary": "#ffffff", "primary-hover": "#828fff", "primary-focus": "#5e69d1", "ink": "#f7f8f8", "ink-muted": "#d0d6e0", "ink-subtle": "#8a8f98", "ink-tertiary": "#62666d", "canvas": "#010102", "surface-1": "#0f1011", "surface-2": "#141516", "surface-3": "#18191a", "surface-4": "#191a1b", "hairline": "#23252a", "hairline-strong": "#34343a", "hairline-tertiary": "#3e3e44", "inverse-canvas": "#ffffff", "inverse-surface-1": "#f5f6f6", "inverse-surface-2": "#f6f7f7", "inverse-ink": "#000000"}
Fonts: ['Linear Display', 'Linear Text', 'Linear Mono']
Layout: 
- Max content width sits around 1280px.
- Card grids are 3-up at desktop, 2-up at tablet, 1-up at mobile.
- Pricing tier grid is 3-up; comparison strip below shows checkmarks per tier.
- Product screenshot panels span full content width — they're the protagonist.

## Do's and Don'ts

### Do

- Reserve `canvas` (#010102) as the system's anchor surface — the faint blue tint is intentional.
- Use `primary` lavender ONLY for: brand mark, primary CTA, focus ring, link emphasis.
- Use the four-step surface ladder for hierarchy. Avoid skipping levels.
- Pair display weight 600 with body weight 400 — Linear resists 700+ display weights.
- Apply negative letter-spacing aggressively on display.
- Use product UI screenshots as the protagonist of every section.
- Compose CTAs as `md` 8px corners.

### Don't

- Don't ship a light-mode marketing page.
- Don't use lavender as a section background or card fill.
- Don't introduce a second chromatic accent (orange, pink, green for marketing).
- Don't add atmospheric gradients or spotlight cards.
- Don't pill-round CTAs.
- Don't use `#000000` true black as the canvas.
- Don't combine multiple bright accents in product screenshot mockups.



## lovable
## 1. Visual Theme & Atmosphere

Lovable's website radiates warmth through restraint. The entire page sits on a creamy, parchment-toned background (`#f7f4ed`) that immediately separates it from the cold-white conventions of most developer tool sites. This isn't minimalism for minimalism's sake — it's a deliberate choice to feel approachable, almost analog, like a well-crafted notebook. The near-black text (`#1c1c1c`) against this warm cream creates a contrast ratio that's easy on the eyes while maintaining sharp readability.

The custom Camera Plain Variable typeface is the system's secret weapon. Unlike geometric sans-serifs that signal "tech company," Camera Plain has a humanist warmth — slightly rounded terminals, organic curves, and a comfortable reading rhythm. At display sizes (48px–60px), weight 600 with aggressive negative letter-spacing (-0.9px to -1.5px) compresses headlines into confident, editorial statements. The font uses `ui-sans-serif, system-ui` as fallbacks, acknowledging that the custom typeface carries the brand personality.

What makes Lovable's visual system distinctive is its opacity-driven depth model. Rather than using a traditional gray scale, the system modulates `#1c1c1c` at varying opacities (0.03, 0.04, 0.4, 0.82–0.83) to create a unified tonal range. Every shade of gray on the page is technically the same hue — just more or less transparent. This creates a visual coherence that's nearly impossible to achieve with arbitrary hex values. The border system follows suit: `1px solid #eceae4` for light divisions and `1px solid rgba(28, 28, 28, 0.4)` for stronger interactive boundaries.

**Key Characteristics:**
- Warm parchment background (`#f7f4ed`) — not white, not beige, a deliberate cream that feels hand-selected
- Camera Plain Variable typeface with humanist warmth and editorial letter-spacing at display sizes
- Opacity-driven color system: all grays derived from `#1c1c1c` at varying transparency levels
- Inset shadow technique on buttons: `rgba(255,255,255,0.2) 0px 0.5px 0px 0px inset, rgba(0,0,0,0.2) 0px 0px 0px 0.5px inset`
- Warm neutral border palette: `#eceae4` for subtle, `rgba(28,28,28,0.4)` for interactive elements
- Full-pill radius (`9999px`) used extensively for action buttons and icon containers
- Focus state uses `rgba(0,0,0,0.1) 0px 4px 12px` shadow for soft, warm emphasis
- shadcn/ui + Radix UI component primitives with Tailwind CSS utility styling


Core tokens: {}
Fonts: []
Layout: - Max content width: approximately 1200px (centered)
- Hero: centered single-column with massive vertical padding (96px+)
- Feature sections: 2–3 column grids
- Full-width footer with multi-column link layout
- Showcase sections with centered card grids

## 7. Do's and Don'ts

### Do
- Use the warm cream background (`#f7f4ed`) as the page foundation — it's the brand's signature warmth
- Use Camera Plain Variable at display sizes with negative letter-spacing (-0.9px to -1.5px)
- Derive all grays from `#1c1c1c` at varying opacity levels for tonal unity
- Use the inset shadow technique on dark buttons for tactile depth
- Use `#eceae4` borders instead of shadows for card containment
- Keep the weight system narrow: 400 for body/UI, 600 for headings
- Use full-pill radius (9999px) only for action pills and icon buttons
- Apply opacity 0.8 on active states for responsive tactile feedback

### Don't
- Don't use pure white (`#ffffff`) as a page background — the cream is intentional
- Don't use heavy box-shadows for cards — borders are the containment mechanism
- Don't introduce saturated accent colors — the palette is intentionally warm-neutral
- Don't use weight 700 (bold) — 600 is the maximum weight in the system
- Don't apply 9999px radius on rectangular buttons — pills are for icon/action toggles
- Don't use sharp focus outlines — the system uses soft shadow-based focus indicators
- Don't mix border styles — `#eceae4` for passive, `rgba(28,28,28,0.4)` for interactive
- Don't increase letter-spacing on headings — Camera Plain is designed to run tight at scale



## mastercard
## 1. Visual Theme & Atmosphere

Mastercard's experience reads like a warm, editorial magazine built from soft stone and signal orange. The canvas is a muted putty-cream (`#F3F0EE`) — not white, not gray, but a color that feels like the paper of a premium annual report. On top of that canvas, everything that matters is shaped like a stadium, a pill, or a perfect circle. The dominant visual gesture is the **oversized radius**: heroes carry 40-point corners, cards go fully pill-shaped, service images are cropped into circular orbits, and buttons either complete the pill or fit snugly at 20 points. There are almost no sharp corners anywhere on the page.

The second gesture is **orbit and trajectory**. Circular image masks don't sit still — they're connected by thin, hand-drawn-feeling orange arcs that span entire viewport widths, implying a constellation of services rather than a list. Each circle has a small attached "satellite" — a white micro-CTA holding an arrow icon — docked onto its perimeter like a moon. This is the most distinctive thing about Mastercard's current design language: the circles feel like they're in motion even though the page is still.

Typography is rendered entirely in **MarkForMC**, Mastercard's proprietary geometric sans. Headlines are set at a medium weight (500) with tight negative letter-spacing (-2%), giving them confidence without shouting. Body copy runs at the same family in a slightly lighter weight (450) — a weight you rarely see on the web, chosen because it reads softer than regular 400 without feeling thin. The whole system — warm cream surfaces, pill shapes, circular portraits, traced-orange orbits, black CTAs — feels simultaneously institutional (a 60-year-old payments network) and editorial (a modern brand magazine), which is exactly the tension Mastercard wants to hold.

**Key Characteristics:**
- Warm cream canvas (`#F3F0EE`) replaces traditional white — every surface is tinted, never sterile
- Extreme border-radius as design language: 40px, 99px, 1000px dominate; anything square is a cookie-banner third-party
- Circular image portraits with attached white satellite-CTAs and traced-orange orbital paths
- Ghost "watermark" headlines (cream-on-cream text at heading scale) layered behind circle portraits
- Black primary CTAs with 20px radius in the body — the cookie-banner orange is kept to consent flows
- Floating pill-shaped navigation that docks below the viewport top with rounded shoulders
- Eyebrow labels with a tiny accent dot + uppercase bold tracking — used as the section-category signal
- Dark warm-black footer (`#141413`) with four-column link layout and large conversational headline


Core tokens: {}
Fonts: []
Layout: - **Max content width**: ~1200–1280px centered, with ~48–100px horizontal gutter
- **Column pattern**: 12-column implied, but practical layouts use 2-up asymmetric (large headline left, supporting text right), 1-up full-bleed (hero, video), or staggered single-portrait placement (service cards sit in varying grid positions creating the "constellation" feel)
- **Footer grid**: 4 equal columns on desktop, collapses to single column accordion on mobile

## 7. Do's and Don'ts

### Do
- Use Canvas Cream (`#F3F0EE`) as the default body background — never pure white
- Mask service/feature imagery as perfect circles, not rectangles or rounded rectangles
- Attach a white satellite CTA to the bottom-right of each circular portrait
- Set headlines in MarkForMC weight 500 with -2% letter-spacing
- Use weight 450 (not 400) for body paragraphs
- Keep primary CTAs as Ink Black pills (20px radius) with cream text
- Use Signal Orange only on consent, legal, or compliance actions
- Float the nav as a rounded white pill below the viewport top, not flush at y=0
- Build page rhythm from three surface tones: canvas cream → lifted cream → ink footer
- Use thin Light Signal Orange arcs between service cards to imply connection

### Don't
- Don't use pure white as a page background — it breaks the warm editorial tone
- Don't round image frames at 8–16px — Mastercard either uses full-pill, 40px, or full-circle. In-between radii look generic
- Don't use Signal Orange for marketing CTAs — it reads as cookie-consent orange and dilutes the legal color signal
- Don't mix typefaces — no serif accent, no script, no secondary display font
- Don't crowd the nav with more than six top-level links — the pill is meant to feel airy
- Don't drop hard shadows — all elevation should use 48px+ spread and ≤10% opacity
- Don't use uppercase for anything larger than the 14px eyebrow label
- Don't omit the tiny accent dot before eyebrow labels — it's the identity
- Don't place circular portraits on a grid — their magic comes from asymmetric placement



## mercury
An analysis of Mercury's design language — a fintech system that moves between a deep ink-violet night world on the homepage and a pale, near-white light world on its product and pricing pages, held together by one confident indigo action pill, soft translucent secondary pills, gently rounded cards and a quiet custom sans set at unusually light weights.
Core tokens: {"primary": "#5266eb", "on-primary": "#ffffff", "periwinkle": "#9cb4e8", "canvas": "#fbfcfd", "surface": "#ffffff", "surface-tint": "#fbfbff", "ink": "#28253b", "ink-secondary": "#554e7b"}
Fonts: ['arcadiaDisplay', 'arcadia']
Layout: - Content is centered in a column of roughly 1100–1200px. Headlines are narrower (~600px) and centered.
- Feature cards run in 2- and 3-up grids. The pricing card is a 3-column comparison table about 900px wide.
- Split sections pair a text column with a product mockup.

## Do's and Don'ts

### Do
- Use `primary` for the single most important action on a view, usually "Open account".
- Make secondary actions translucent pills (`pill`): lavender-grey or periwinkle on dark, indigo or grey-violet tints on light.
- Frame light pages with the `night` nav and footer.
- Keep type light: `body-lg` at 360, UI at 420, headlines at 480.
- Separate cards from the canvas with fill (`lavender`, `night-raised`) rather than borders or heavy shadows.
- Center section headlines and give sections `section` or more of vertical space.

### Don't
- Don't use more than one solid `primary` button in a group. Everything else stays translucent.
- Don't set text in heavy bold weights. The brand never goes above 500.
- Don't use hard outlined buttons or square corners on actions.
- Don't put light-world ink (`ink`) on night surfaces or `on-dark` on the light canvas.
- Don't add strong drop shadows. Elevation is tonal.
- Don't introduce status greens or oranges into the chrome. They belong to product mockups, not the interface.


## meta
Meta's design system spans hardware commerce (Quest VR, Ray-Ban Meta AI glasses) and brand surfaces with a confident product-merchandising voice. The system pairs a stark white canvas with full-bleed photographic product cards, a confident Optimistic VF wordmark/headline face, dual-CTA hero patterns (black primary + outlined secondary), and a saturated cobalt blue (#0064E0) for in-product purchase actions. Pill-shaped 100px-radius buttons, generous 24-32px card rounding, and tight three-tier text hierarchy carry across homepage, product detail (PDP), buy-now configurator, and accessory subpages.
Core tokens: {"primary": "#0064e0", "primary-deep": "#0457cb", "primary-soft": "#0091ff", "on-primary": "#ffffff", "ink-button": "#000000", "on-ink-button": "#ffffff", "meta-link": "#385898", "canvas": "#ffffff", "surface-soft": "#f1f4f7", "ink-deep": "#0a1317", "ink": "#1c1e21", "hairline": "#ced0d4", "hairline-soft": "#dee3e9"}
Fonts: ['Optimistic VF']
Layout: - Marketing page max-width sits around 1280px with 32–48px gutters.
- The PDP layout uses a 2-column split: hero gallery (~58% width) + sticky purchase rail (~42%, with `max-width: 380px` on the rail).
- Three-up feature grids ("Why buy from Meta") use a 24px column gap; six-up product thumbnail rows (color/SKU pickers) use a 12px gap.

## Do's and Don'ts

### Do
- Reserve `primary` (cobalt) for buy-now CTAs only — its visual weight is meaningful precisely because it doesn't appear on marketing pages.
- Use `ink-button` (black) for marketing-surface primary CTAs. Pair with `button-secondary` ghost outline for the secondary action.
- Apply `full` to every button, every category pill, every badge, every chip — buttons are NEVER squared in Meta's system.
- Apply `xxxl` to photographic product cards and `xl` to icon-feature tiles to maintain the visible card-hierarchy contrast.
- Switch on `ss01, ss02` together for any Optimistic VF heading. Never one stylistic set without the other.
- Use the 300-weight `heading-md` for editorial subheads — it creates the brand's signature visual rhythm against the 500-weight displays.

### Don't
- Don't use `primary` (cobalt) for marketing-surface primary buttons — it conflicts with Meta's brand-history positioning of black-CTA-on-white-canvas marketing.
- Don't introduce additional accent colors beyond cobalt + Oculus purple. The hardware brand is deliberately monochromatic outside its product photography.
- Don't soften the corners of pill buttons below `full`. The pill is a brand signature.
- Don't run feature cards without rounding — `xxxl` is the minimum for any photographic surface.
- Don't reduce `body-md` line-height below 1.50 — the negative letter-spacing already tightens the metric and any further compression breaks legibility.
- Don't apply heavy shadows to marketing cards. Elevation is a commerce-flow signal, not a marketing flourish.



## minimax
MiniMax presents itself as a premium AI infrastructure brand through a striking duality — bold black-pill CTAs and stark white canvas for marketing, paired with vibrant gradient product cards (orange-red, magenta-pink, purple, blue) that turn each model release into a distinctive visual identity. The system uses DM Sans across all surfaces, employs an oversized 80px hero display, anchors major actions in deep near-black pills, and layers content density via a 3-column documentation grid with sidebar nav, prose body, and TOC. Coverage spans the marketing homepage, model showcase pages, developer documentation, and platform pricing surfaces.
Core tokens: {"primary": "#0a0a0a", "on-primary": "#ffffff", "primary-soft": "#181e25", "canvas": "#ffffff", "surface": "#f7f8fa", "surface-soft": "#f2f3f5", "hairline": "#e5e7eb", "hairline-soft": "#eaecf0", "ink": "#0a0a0a", "ink-strong": "#000000", "muted": "#a8aab2"}
Fonts: ['DM Sans']
Layout: - Marketing pages use a 1280px max-width with 32px gutters.
- Homepage product matrix renders as a 4-column row of 32px-rounded gradient cards, each ~280–320px wide.
- AI Product Matrix below uses a 4-column grid with 16px-rounded white cards.
- Documentation surfaces use a 3-column layout: left sidebar nav (~220px), center prose body (~720px max-width), right TOC (~180px). Sidebar persists on desktop; collapses to drawer below 1024px.
- Token Plan / pricing pages use 2-column tabs above a 3-column tier card grid.

## Do's and Don'ts

### Do
- Use `primary` (black) as the dominant CTA — it's the brand's most recognizable interactive element.
- Reserve product brand colors (`brand-coral`, `brand-magenta`, `brand-blue`, `brand-purple`) ONLY for product-identity moments — never for general buttons or text.
- Pair `hero` (32px) gradient cards with `xl` (16px) white cards in the same viewport — the radius contrast is the visual signature.
- Apply `full` to every button, every pill tab, every badge.
- Use `hero-display` (80px) with -2px letter-spacing for hero displays — never compromise the leading or letter-spacing.
- Treat each model/product line as a distinct color identity. M2.7 is coral, Music is magenta, Hailuo is blue. These are brand assignments, not free choices.

### Don't
- Don't use brand-coral or brand-magenta on body text or large surfaces — they lose meaning when overused.
- Don't soften corners on buttons (anything less than `full`); the pill is a brand signature.
- Don't introduce a second display typeface; DM Sans handles every role.
- Don't reduce hero leading below 1.10 — the brand needs that breathing room on the 80px display.
- Don't apply heavy shadows on white cards; flat-with-borders is the documentation default.
- Don't put gradient backgrounds on standard buttons; gradients are reserved for product-card identity moments.



## mintlify
Mintlify presents documentation infrastructure with a dual-mode aesthetic — atmospheric sky-gradient marketing heroes (cloud illustration backdrops, soft cream-to-blue washes) paired with dense developer-grade documentation surfaces. The system uses Inter for UI prose, Geist Mono for code, and a signature Mintlify green (brand-green) reserved for accent CTAs and active states. Black-pill primary buttons dominate marketing, white-on-dark inversions appear on dark hero bands, and a 3-column documentation layout (sidebar / prose / TOC) anchors the developer experience. Coverage spans homepage, startups program, pricing comparison, and the live tabs documentation page.
Core tokens: {"primary": "#0a0a0a", "on-primary": "#ffffff", "canvas": "#ffffff", "canvas-dark": "#0a0a0a", "surface": "#f7f7f7", "surface-soft": "#fafafa", "surface-code": "#1c1c1e", "hairline": "#e5e5e5", "hairline-soft": "#ededed", "hairline-dark": "#1f1f1f", "ink": "#0a0a0a", "muted": "#a8a8aa", "on-dark-muted": "#b3b3b3"}
Fonts: ['Inter', 'Geist Mono']
Layout: - Marketing pages use a 1280px max-width with 32px gutters
- Hero and feature bands often use 2-column splits (text left, illustration/mockup right)
- Pricing page renders 3 tier cards in a row at desktop (FREE / Lift Off / Custom), then a comprehensive feature comparison table below
- Documentation pages use a strict 3-column grid: left sidebar nav (~240px), center prose (~720px max-width), right TOC (~200px)
- Logo walls use 6-up rows of customer logos at 80–100px height each

## Do's and Don'ts

### Do
- Reserve `brand-green` (Mintlify mint) for accent CTAs and active state indicators only — even one accent button per viewport carries weight
- Use `primary` (black) as the dominant CTA on light backgrounds; switch to `button-on-dark` (white pill) on dark hero bands
- Apply `full` to every button and pill; never soften pill corners
- Pair Inter (UI prose) with Geist Mono (code) — never introduce a third typeface
- Use atmospheric gradient hero bands sparingly (only the homepage and startups page); keep deeper surfaces flat and dense
- Apply `lg` (12px) consistently on cards; use `md` (8px) only on compact UI like search pills and code blocks
- Keep documentation prose at `body-md` (16px) with 1.50 line-height — never compress

### Don't
- Don't use `brand-green` on body text or large surfaces — it loses signal
- Don't introduce additional accent colors beyond mint, tag-blue, error-red, and the testimonial orange
- Don't apply heavy shadows on flat documentation cards; reserve elevation for the hero product mockup
- Don't reduce documentation line-height below 1.50 — long-form readability suffers
- Don't combine atmospheric gradients with multiple competing color accents in the same hero — the sky/dark gradient is the brand mood; let it breathe
- Don't use Inter for code or Geist Mono for prose — the typeface assignment IS the brand voice



## miro
Miro presents itself as the AI-powered visual workspace through a confident, almost playful brand voice — anchored by its signature canary yellow (brand-yellow) wordmark over white canvas, broken open by colorful pastel feature tints (rose, teal, coral, orange, mint) that echo the actual sticky-note color palette used on the live whiteboard. Black-pill primary buttons dominate marketing, real Miro-board mockups serve as feature illustrations, and a 4-tier pricing grid leads into a dense comparison table. Roobert PRO carries display headlines; the system supports homepage, pricing, AI Workflows product page, agile vertical, and customer stories surfaces.
Core tokens: {"primary": "#1c1c1e", "on-primary": "#ffffff", "brand-pink": "#fde0f0", "canvas": "#ffffff", "surface": "#f7f8fa", "surface-soft": "#fafbfc", "surface-yellow": "#fff8e0", "surface-pricing-featured": "#f5f3ff", "hairline": "#e0e2e8", "hairline-soft": "#eef0f3", "hairline-strong": "#c7cad5", "ink-deep": "#050038", "ink": "#1c1c1e", "muted": "#a5a8b5", "on-dark-muted": "#a5a8b5"}
Fonts: ['Roobert PRO']
Layout: - Marketing pages use 1280px max-width with 32px gutters
- Pricing page renders 4-tier card row at desktop (Free / Starter / Business / Enterprise)
- Customer stories page uses 2-column grid with filter dropdowns
- AI Workflows page uses 2-column hero, then 3-up feature grid

## Do's and Don'ts

### Do
- Reserve `brand-yellow` for the wordmark, top promo banner, and "yellow tag" chips
- Use `primary` (black) as the dominant CTA on all surfaces
- Pair pastel feature cards (yellow, rose, coral, teal) with white feature cards in the same viewport
- Apply `full` to every button, every pill tab, every status badge
- Apply `xxxl` (28px) to pastel feature cards
- Use real Miro-board mockups as feature illustrations
- Maintain Roobert PRO across every UI surface

### Don't
- Don't use `brand-yellow` on standard CTAs or large background surfaces
- Don't introduce additional accent colors beyond yellow + brand pastels
- Don't soften corners on buttons; the pill is a brand signature
- Don't reduce hero leading below 1.05
- Don't apply heavy shadows on flat documentation cards; reserve elevation for whiteboard mockups
- Don't use stock photography — show the live product board UI



## mistral.ai
Mistral AI brands itself with a singular signature — atmospheric sunset gradients (mustard, orange, deep red) layered over photography of mountains, plus a horizontal "sunset stripe" bar that closes every page. The system pairs warm cream-yellow surfaces (cream) with a saturated orange primary CTA (primary) and uses an elegant near-serif voice for hero displays. Coverage spans homepage (Frontier AI hero), Le Studio product page, Coding solutions, news article surfaces, contact form, and services tier page — all anchored by the signature gradient closing band.
Core tokens: {"primary": "#fa520f", "primary-deep": "#cc3a05", "on-primary": "#ffffff", "ink": "#1f1f1f", "ink-tint": "#3d3d3d", "muted": "#a8a8a8", "hairline": "#e5e5e5", "hairline-soft": "#ededed", "hairline-strong": "#c7c7c7", "canvas": "#ffffff", "surface": "#fafafa", "surface-cream": "#fff8e0", "surface-cream-soft": "#fffaeb", "surface-code": "#1c1c1e", "on-dark-muted": "#a8a8a8", "link": "#fa520f"}
Fonts: ['PP Editorial Old', 'Inter', 'JetBrains Mono']
Layout: - Marketing pages use 1280px max-width with 32px gutters
- Hero band uses 2-column split (text left, sunset photography right) on desktop
- Le Studio product page uses 3-up feature grid below the hero
- Contact page uses 1-column layout with cream form panel centered (~520px max-width)
- Services page uses 4-tier card layout with cream feature panel separator strip

## Do's and Don'ts

### Do
- Reserve `primary` (saturated orange) for primary CTAs and active states only
- Use the **sunset stripe band** at the foot of every page — it's the brand's most recognizable signature
- Pair PP Editorial Old (display) with Inter (UI) — never substitute either with a generic alternative
- Apply `md` (8px) to buttons and `lg` (12px) to cards consistently
- Use cream-yellow surfaces (cream) for form panels, feature cards, and footer
- Anchor heroes with photographic mountain-sunset imagery (or its visual equivalent — atmospheric gradient sky)
- Use stat-display token (PP Editorial 56px) for stat callouts to maintain editorial character

### Don't
- Don't use pill-shaped buttons (`full`) — Mistral's geometry is sober and editorial, not playful
- Don't introduce additional accent colors beyond the orange/yellow/cream sunset palette
- Don't reduce hero leading below 1.05 — the editorial display needs that magazine-grade tightness
- Don't replace PP Editorial Old hero displays with Inter — the editorial / sans contrast IS the brand
- Don't apply heavy shadows on flat documentation cards; reserve elevation for IDE mockups
- Don't drop the sunset stripe band from any page bottom — it's the brand's continuity element



## mongodb
MongoDB carries a strong dual-mode visual identity — dark deep-teal hero bands with bright MongoDB green (brand-green) CTAs paired with stark white documentation surfaces. The signature green pill button is unmistakable across product, pricing, learning, and AI use-case surfaces. The system uses Euclid Circular A as its display face, anchors a 3-tier pricing comparison (Free / Flex / Dedicated), and presents extensive course catalogs in card grids with colored category tags. Coverage spans homepage, Atlas product page, Community Edition, MongoDB University, AI use cases, and pricing.
Core tokens: {"primary": "#00ed64", "primary-deep": "#00b545", "primary-pressed": "#008c34", "on-primary": "#001e2b", "accent-pink": "#f06bb8", "canvas": "#ffffff", "canvas-dark": "#001e2b", "surface": "#f9fbfa", "surface-soft": "#f4f7f6", "surface-feature": "#e3fcef", "hairline": "#e1e5e8", "hairline-soft": "#eceff1", "hairline-strong": "#c1ccd6", "hairline-dark": "#1c2d38", "ink": "#001e2b", "muted": "#a8b3bc", "on-dark-muted": "#a8b3bc"}
Fonts: ['Euclid Circular A', 'Source Code Pro']
Layout: - 1280px max-width with 32px gutters
- Pricing: 3-tier card row, dense feature comparison table below
- Learn catalog: 3-up course tile grid, 4-up certification grid
- AI use cases: 2-column hero with atmospheric illustration

## Do's and Don'ts

### Do
- Use `brand-green` (bright MongoDB green) for primary CTAs everywhere
- Pair dark-teal hero bands with bright green CTA pills
- Apply `full` to every button, every status badge
- Apply `lg` (12px) to cards consistently
- Use category accent colors (purple, orange, green, teal) ONLY for course tags
- Maintain Euclid Circular A across every UI surface
- Use code mockup cards with terminal-aesthetic content for product showcases

### Don't
- Don't use the bright green for body text or large surfaces
- Don't introduce additional accent colors beyond the brand green and category-encoding palette
- Don't soften corners on buttons; the pill is a brand signature
- Don't replace deep teal hero bands with white hero bands
- Don't apply heavy shadows on flat documentation cards; reserve elevation for code mockups
- Don't use Source Code Pro for prose



## mydealz
An analysis of mydealz's design language — a high-density German deals-community system built on a confident brand green, where a stacked white-card feed carries thousands of deals and every card wears the signature hot/cold temperature control that turns pricing into a crowd vote. Fully-round 540px pill buttons, Averta CY at two weights, cool-gray page canvas, and a compact red/blue/orange status vocabulary keep the information-dense feed scannable and playful at once.
Core tokens: {"primary": "#30a83c", "on-primary": "#ffffff", "discount-surface": "#defde4", "canvas": "#f3f5f7", "surface": "#ffffff", "ink": "#000000", "muted": "#a7a9ac", "hairline": "#dfe1e4", "warning-surface": "#faf9ca"}
Fonts: ['Averta CY', 'monospace']
Layout: A two-column shell above ~768px: the main deal feed (single stacked column of full-width cards) plus a right sidebar of coupon, news, and discussion cards. Below the breakpoint the sidebar drops and the feed goes full-width. The container is wide and content-dense rather than a narrow reading column.

## Do's and Don'ts

### Do
- Reserve `primary` green for actions and prices — it is the single thread tying the feed together.
- Keep the `temperature-control` pairing intact: `cold` down, `hot` up and temperature — it's the brand's signature.
- Pill every button, chip, search, and the temperature control to `full`; keep content cards at `md`.
- Put savings in the `discount-surface` mint badge beside the green price.
- Hold typography to Averta CY 500 / 700; bold every price and temperature.
- Separate cards with `hairline` borders and the `canvas` gutter, not heavy shadows.

### Don't
- Don't recolor prices or primary actions away from `primary` green.
- Don't split the temperature pairing or recolor the vote arrows — cold is blue, hot is red, always.
- Don't introduce shadows on resting feed cards; the soft 4–12px shadow is for elements that lift.
- Don't use a third or fourth type weight — the system is 500 and 700 only.
- Don't let `warm` orange or `premium` violet drift into decorative use; they are functional status colors.
- Don't square off the pills — the fully-round `full` button is the brand's shape signature.


## nerdwallet
An analysis of NerdWallet's design language — a personal-finance comparison platform built almost entirely from one deep green and a ladder of mints beneath it. Editorial pages open on a green gradient band, then drop to near-white where dense comparison tables do the real work. Corners are almost square, shadows are nearly absent, and the whole system separates content with hairlines and pale mint washes rather than elevation.
Core tokens: {"primary": "#008254", "primary-deep": "#006642", "on-primary": "#ffffff", "canvas": "#ffffff", "canvas-soft": "#f7f7f7", "hairline": "#ebebec", "hairline-strong": "#d8d9da", "ink": "#000000", "muted": "#64666a", "link": "#005fb9"}
Fonts: ['Gotham', 'GothamDisplay']
Layout: 
Content centres in a container of roughly 1200px inside the 1280px viewport. The homepage runs a 5-up category tile grid that steps down to 4-up and 2-up. Editorial pages use a single wide column for the hero band and then a full-width comparison table with five semantic columns — institution, rating, headline rate, bonus, and action. Product cards on the credit-cards page are full-width blocks stacked vertically, each subdivided into a spec grid of three to four cells.

## Do's and Don'ts

### Do

- Spend `primary` on actions and active states only — buttons, rating stars, active tabs, in-body links.
- Reach for the mint ladder (`mint-50` → `mint-200`) when a section needs separation; it is the system's substitute for elevation.
- Keep controls at `xs` and cards at `lg`; save `xxxl` for decorative panels and photo frames.
- Separate table rows with a single `hairline` rule and no vertical dividers.
- Use the lime family for emphasis that has to survive on a green ground, where `primary` would disappear.
- Set headings in `ink` pure black and body copy at weight 300 — the weight gap is the hierarchy.
- Give every comparison figure a `caption` label above it in `body`, never inline.
- Open editorial pages with `{hero-band}` and then drop immediately to a light canvas; do not carry the green further down.

### Don't

- Don't round the filled buttons. `xs` is a deliberate choice against the softness of the illustration style.
- Don't add drop shadows to cards — use the `hairline-strong` border instead. The system's only shadows sit at 4–5% opacity.
- Don't use `link` blue and `primary` green interchangeably; blue is a supporting reference, green is navigation the reader is meant to follow.
- Don't extend `{hero-band}` green into body sections or use it as a card fill.
- Don't introduce a warm accent. The palette runs green through mint with blue as the only outside hue.
- Don't set body copy above weight 300 or headings below 700 — collapsing the gap flattens the hierarchy.
- Don't place `lime-panel` on white as a text colour; the lime tier only works as a fill on white or as type on green.
- Don't give `{text-input}` a radius or a border of its own; the containing chrome supplies both.


## nike
A photography-first commerce system built on extreme typographic contrast — towering uppercase Futura display lockups burned into editorial campaign imagery, sitting above a dense, neutral, near-monochrome retail chrome of pill-shaped black CTAs, gray search and tag pills, and tight 8px-grid product cards. The brand's voice is athletic, kinetic, and absolute: pure black, pure white, a single soft surface gray, and a deliberately small set of semantic accents (sale red, success green, restrained category tints) — every chromatic moment is reserved for editorial photography or pricing signal, never decorative chrome.

Core tokens: {"primary": "#111111", "on-primary": "#ffffff", "canvas": "#ffffff", "ink": "#111111", "hairline": "#cacacb", "hairline-soft": "#e5e5e5", "accent-pink": "#ed1aa0", "accent-pink-soft": "#ffb0dd", "accent-pink-deep": "#4c012d"}
Fonts: ['Nike Futura ND', 'Helvetica Now Display Medium', 'Helvetica Now Text', 'Helvetica Now Text Medium', 'Helvetica Neue']
Layout: - **Max width:** ~1440px content area with edge gutters that grow to ~80px at 1920px (the system lets very wide viewports breathe rather than stretch).
- **Column patterns:** PLP listing uses 3-up at desktop, collapsing to 2-up at 1023px and 1-up at 599px. The men's home `/men` mixes a 2-up campaign hero row, a 3- or 4-up "Trending Now" row, a horizontal-scroll "Shop by Sport" rail, and a 4-up "Latest in Clothing" thumbnail grid.
- **Filter sidebar:** ~220px fixed-width left rail on PLP at desktop, collapsing into a `Hide Filters` toggle button at narrow widths.

## Do's and Don'ts

### Do
- Reserve `display-campaign` exclusively for editorial campaign hero lockups — never use 96px Futura for section headers or product titles.
- Use `button-primary` (`ink` pill) as the single primary action per viewport. Pair it at most with `button-secondary` (`soft-cloud` pill) for a soft alternative.
- Stage every product photograph on `soft-cloud` — the gray is the system's "studio."
- Keep all CTAs pill-shaped at `lg` (30px). Never introduce a square or `sm` button.
- Use `sale` only on price rows — never on backgrounds, badges, or chrome.
- Stack content sections at `section` (48px) rhythm with no decorative dividers between them; the photography's bleed-edge is the divider.
- Anchor on-image CTAs with `button-outline-on-image` (white pill) at bottom-left — the system's universal "shop this image" position.

### Don't
- Don't introduce drop shadows or card elevation. Cards sit flat on the page; the only depth cue is the 1px inset hairline on sticky bars.
- Don't use any of the category accent colors (`accent-pink`, `accent-purple-soft`, `accent-teal`) for primary chrome — they belong to swatch dots, soft tile fills, and editorial moments only.
- Don't replace `ink` with a near-black gray like `charcoal` for a CTA — Nike's primary pill is true `#111111`.
- Don't pad inside product cards. The image is full-bleed; metadata sits directly below with `sm` (8px) between rows.
- Don't put two campaign-tile lockups in the same row at the same scale — Nike alternates a single full-bleed editorial tile with a 2-up or 4-up product/category grid.
- Don't underline anything other than `link-md` inline links and the active primary-nav indicator. Buttons, headings, and prices stay un-underlined.
- Don't introduce a third button shape. Pill or icon-circular — that's the entire button shape vocabulary.



## nintendo-2001
An analysis of Nintendo.com's 2001 design language — a brushed-periwinkle "console chrome" interface where every panel is a beveled metal plate, navigation glows amber over a halftone-dotted carbon bar, and bold outlined display type sits on circuit-board hero fields. A Y2K hardware aesthetic that treats the web page like the faceplate of a game system.
Core tokens: {"primary": "#e60012", "canvas": "#7a8aba", "canvas-soft": "#9fbee7", "periwinkle": "#8ba1d4", "muted-indigo": "#60619c", "surface": "#ffffff", "hairline": "#5a5f8c", "ink": "#21242e", "ink-soft": "#3d4f97", "on-primary": "#ffffff"}
Fonts: ['Arial', 'Arial Black']
Layout: - **Fixed-width canvas** ~780–830px wide (a desktop-era fixed table layout, centered). No fluid scaling — the interface is sized to a single target window like an application.
- **Masthead row**: Mario mascot + speech bubble (left) and search module (right) float above the chrome.
- **Dual nav bars**: a carbon primary bar (logo + 5 section words + Code Bank / Game Finder utility chips) stacked over a periwinkle secondary strip (Parents, Customer Service, Corporate, Global, Privacy, Store, Contact).
- **Body**: a full-width hero panel, then a **two-column split** — a ~two-thirds content column of stacked panels (Official News list, Featured Sites 2×2 grid, etc.) beside a ~one-third **right action rail** (Login / Subscribe / Newsletter / Help buttons, an info box, a side promo card).
- **Left rail**: a thin vertical strip of rotated tabs (Top Ten, Top Rentals, Player's Choice, ESRB Ratings) clipped to the chrome edge.

## Do's and Don'ts

### Do
- Build every region as a **beveled plate**: a `canvas` body with a brighter top edge and a `chrome-indigo` shadow line beneath. The "assembled machine" feel depends on it.
- Reserve warm color for **wayfinding only** — `nav-gold` for nav words, `amber` for utility/badges, `signal` for forward/Submit. Cool chrome never carries action color.
- Keep structural labels **uppercase Arial Bold with 0.5px tracking** (`ui-label`) — it is the silkscreen-legend voice of the whole system.
- Render hero wordmarks as **outlined + drop-shadowed `display`** over full-bleed photographic fields tinted per page.
- Use `carbon` with halftone texture for the **command layer** (nav, right rail, footer) to separate "system controls" from "content."
- Let panels **butt together** with thin bevel seams; density is the intended texture.
- Default corners to **sharp/chamfered** (`none`); spend roundness only on the logo pill, radio dots, and circle-arrow badges.

### Don't
- Don't soften every corner — turning the sharp chrome into a uniformly rounded card system erases the manufactured-faceplate identity.
- Don't introduce a **soft blurred drop-shadow** elevation language; depth here is hard bevels and pictorial photography, not Material elevation.
- Don't let `signal` and `amber` bleed into decorative use — warm color must always mean "act here."
- Don't add accent colors outside the page-tint heroes (`systems-teal`, `games-red`); the steady-state chrome is strictly cool periwinkle + carbon.
- Don't widen body copy or whitespace into an airy modern layout; the packed, fixed-canvas density is the brand.
- Don't flatten the dual-nav structure (gold primary words over the pale secondary strip) into one bar — the layered command hierarchy is signature.
- Don't render hero or system wordmarks as flat text; without the outline + shadow they lose the box-art reference entirely.


## notion
Notion presents itself as the all-in-one workspace through a confident, illustration-rich brand voice — anchored by a deep navy hero band (brand-navy) decorated with brand-colored sticky-note dots and mesh wire illustrations, a signature purple pill primary CTA (primary), and a rich palette of pastel-tinted feature cards that echo the colorful database properties of the live product. The system uses a Notion-Sans (Inter-based) typeface across every UI surface, anchors a 4-tier pricing comparison (Free / Plus / Business / Enterprise), and presents the live workspace UI mockup directly inside the hero band. Coverage spans homepage, Enterprise, Product AI, Product Agents, Startups, and Pricing surfaces.
Core tokens: {"primary": "#5645d4", "primary-pressed": "#4534b3", "primary-deep": "#3a2a99", "on-primary": "#ffffff", "link-blue": "#0075de", "link-blue-pressed": "#005bab", "brand-pink": "#ff64c8", "brand-pink-deep": "#a02e6d", "canvas": "#ffffff", "surface": "#f6f5f4", "surface-soft": "#fafaf9", "hairline": "#e5e3df", "hairline-soft": "#ede9e4", "hairline-strong": "#c8c4be", "ink-deep": "#000000", "ink": "#1a1a1a", "muted": "#bbb8b1", "on-dark-muted": "#a4a097"}
Fonts: ['Notion Sans']
Layout: - 1280px max-width with 32px gutters
- Pricing: 4-tier card row at desktop with dense comparison table
- Homepage: centered hero with workspace mockup below buttons; alternating colorful feature card sections

## Do's and Don'ts

### Do
- Use `primary` (purple) as the dominant CTA across all surfaces — it's the brand's recognizable signal
- Pair deep navy hero bands (brand-navy) with the purple button + decorative sticky-note dots
- Use pastel feature card tints (peach, rose, mint, lavender, sky, yellow) generously
- Use `card-tint-yellow-bold` for high-emphasis "Ask the assistant"-style banner cards
- Apply `md` (8px) to buttons consistently — Notion uses rectangles, not pills
- Apply `lg` (12px) to all card families
- Maintain Notion-Sans across every UI surface
- Use the workspace mockup card on hero bands to show actual product UI

### Don't
- Don't use the purple for body text or large background surfaces
- Don't use pill-shaped buttons; Notion's geometry is rectangular-sober
- Don't mix link-blue (link-blue) with primary-purple (primary) — they have distinct roles
- Don't apply heavy shadows on flat documentation cards
- Don't replace Notion-Sans with a generic Inter



## nvidia
An engineering-grade marketing system organized around two surface modes — a deep black canvas for hero and footer chapters and a flat paper-white canvas for body content — connected by a single, almost violently saturated NVIDIA Green accent that carries every CTA, every active tab, and the small decorative corner squares that mark out cards. The system is unapologetically angular: 2px radius across every surface, tight bold sans-serif typography in NVIDIA's proprietary EMEA cut, and a hairline gray rule that separates dense multi-column technical content. There is no decorative gradient, no atmospheric mesh, no soft drop shadow — just black, white, gray, and green stacked into a structured editorial grid that scales from product cards to massive industry landing pages without bending its rules.

Core tokens: {"primary": "#76b900", "on-primary": "#000000", "primary-dark": "#5a8d00", "ink": "#000000", "canvas": "#ffffff", "surface-dark": "#000000", "surface-soft": "#f7f7f7", "surface-elevated": "#1a1a1a", "hairline": "#cccccc", "hairline-strong": "#5e5e5e", "link-blue": "#0046a4"}
Fonts: ['NVIDIA-EMEA']
Layout: - **Max width:** ~1280px content area at desktop, with 24px gutters that grow to ~48px at ultrawide.
- **Column patterns:**
  - Card grids: 4-up at desktop, 3-up at 1024px, 2-up at 768px, 1-up at 480px.
  - Long-form text: 2-column 60/40 split (body + sidebar) at desktop, single-column at < 960px.
  - Footer: 6-up link columns at desktop, collapsing to 2-up on tablet, full accordion on mobile.
- **Card aspect:** product cards lean to 1:1 or 4:3 with 16:9 imagery on top + 1–2 lines of metadata below. Resource cards are 3:2 imagery with a longer description block.

## Do's and Don'ts

### Do
- Reserve `primary` for primary CTAs, active states, decorative corner squares, and the NVIDIA wordmark itself. Treat it as a precious resource.
- Stack hero/footer chapters in `surface-dark` and body sections in `canvas` — alternate them in a predictable rhythm down the page.
- Anchor a `corner-square` to one corner of every reusable card. It is the system's identity tag.
- Use `sm` (2px) on every interactive element. Never go to 0, never go past 4.
- Build hierarchy from font weight (400 vs 700) and size, not from color tinting. Body text stays `ink` or `body` regardless of context.
- Stack content sections at `section` (64px) rhythm with no decorative dividers between them.
- Pair `button-primary` (green fill) with `button-outline` (green border) for primary + secondary action pairs.

### Don't
- Don't introduce drop shadows on cards or content surfaces. The only allowed shadow is the 5px ambient on sticky chrome.
- Don't substitute `success-deep`, `accent-green-pale`, or any other green for `primary` in CTAs. The brand green is precise.
- Don't use `link-blue` outside of inline body-prose links. It is not a button color, not a chrome color.
- Don't soften the geometry. No pill buttons, no rounded cards, no `lg` or higher anywhere except avatars and social icons.
- Don't pad the hero `hero-card-dark` symmetrically. Copy hugs the left third; imagery fills the right.
- Don't add a second accent color for variety. The system is intentionally one-color.
- Don't put `button-primary` on a `canvas` background where green-on-white would clash with photo content — use `button-outline` instead and reserve fill for dark surfaces.



## ollama
An almost defiantly minimal documentation-first system that treats the home page like a Markdown README — paper-white canvas, 36px center-aligned heading, a single black pill CTA, an inline terminal install snippet, and a hand-drawn llama mascot as the only ornamental element. No gradient, no hero photography, no marketing pyrotechnics. The chrome is a tiny utility palette of pure black, pure white, and three neutral grays; every interactive element is fully rounded into a pill (`full`); typography is SF Pro Rounded for headings paired with system sans for body and ui-monospace for code. Pricing tiers, FAQs, and "your data stays yours" guarantees all sit on the same flat canvas inside thin-border cards — the system is the documentation, and the documentation is the system.

Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#000000", "ink-deep": "#090909", "canvas": "#ffffff", "surface-soft": "#fafafa", "surface-card": "#ffffff", "hairline": "#e5e5e5", "hairline-strong": "#d4d4d4", "surface-dark": "#171717", "link": "#000000", "link-mute": "#737373"}
Fonts: ['SF Pro Rounded', 'ui-sans-serif', 'ui-monospace']
Layout: - **Max width:** ~720px content column on the home page (the whole page is laid out as a single narrow reading column with optional 2-column splits inside specific sections).
- **Pricing grid:** 3-up cards at desktop with a max content width of ~960px; collapses to 1-up below 768px.
- **Automate-your-work split:** desktop 50/50 left-text/right-terminal-mockup; mobile stacks vertical with the terminal below the text.
- **FAQ:** single-column stacked rows, full-width within the 720px content column.
- **Footer:** single-row of small body-sm links, center-aligned at desktop, wrapping to two rows on narrow screens.

## Do's and Don'ts

### Do
- Treat the page like a Markdown document: single reading column, plenty of `section` air between sections, no decorative dividers.
- Use `button-primary` (black pill) for every primary action. There is no green, no blue, no brand-tinted CTA.
- Default to `full` for any interactive element. Cards get `lg` (12px) and that is the only exception.
- Use `display-xl` SF Pro Rounded for the hero headline and `body-md` system sans for everything else. Avoid intermediate display sizes.
- Reserve `pricing-card-dark` (the inverted dark surface) for exactly one "look here" moment per page — never use it twice.
- Render install commands and CLI examples inside `install-snippet` or `terminal-card` with `code-md` / `code-sm`. Code is a first-class component.
- Keep the llama mascot the only illustration in the system. It is the brand.

### Don't
- Don't introduce gradients, drop shadows, or atmospheric backgrounds. The canvas is pure `canvas`.
- Don't add brand colors. The system is `primary` (black) on `canvas` (white) with `body` (gray) text. That is it.
- Don't soften pills or sharpen cards — pills stay `full`, cards stay `lg`. Don't introduce `md` for buttons or `full` for cards.
- Don't lift cards with shadows. Use a 1px `hairline` border or invert to `surface-dark` — those are the only two card treatments.
- Don't replace `ui-sans-serif` with a branded display body face. The system relies on `system-ui` rendering to feel native.
- Don't fill long-form pages with marketing chrome. FAQ answers stay in `body` body-md prose with no decorative containers.



## opencode.ai
A terminal-native marketing system rendered entirely in Berkeley Mono — every word on the page, from the hero headline down to the footer fine print, is monospaced. The page itself reads like a manpage or a static-site README: warm cream canvas (`#fdfcfc`), nearly-black ink (`#201d1d`), 4px-radius rectangles for the few interactive elements, and bracketed `[+]`/`[-]` ASCII markers used as bullets. The brand's only "visual moment" is a single dark hero card that mocks up the OpenCode TUI itself — black background, monospaced terminal output, ASCII pipe characters, and a wordmark rendered as block-pixel ASCII. Every section sits as a hairline-bordered text block on the cream canvas with no shadows, no gradients, no decorative imagery, and no non-monospaced character anywhere in the system.

Core tokens: {"primary": "#201d1d", "on-primary": "#fdfcfc", "ink": "#201d1d", "ink-deep": "#0f0000", "canvas": "#fdfcfc", "surface-soft": "#f8f7f7", "surface-card": "#f1eeee", "surface-dark": "#201d1d", "surface-dark-elevated": "#302c2c", "hairline": "rgba(15,0,0,0.12)", "hairline-strong": "#646262"}
Fonts: ['Berkeley Mono']
Layout: - **Max width:** ~960px content column for body sections; the dark hero TUI mockup is full-bleed within an outer ~1100px content frame.
- **Two-column split:** `/enterprise` pairs a left text block (~360px wide) with a right-aligned form column (~480px wide). The home page is single-column reading.
- **Footer:** 5-up horizontal link row (GitHub / Docs / Changelog / Discord / X) at desktop, collapsing to 2-up at tablet and 1-up at mobile.

## Do's and Don'ts

### Do
- Render every text role in Berkeley Mono. The single-font decision is the entire identity.
- Keep `canvas` (`#fdfcfc`) as the only body background. Don't introduce gray section bands.
- Use ASCII bracket markers (`[+]`, `[-]`, `[x]`, `+`, `−`) as bullets, toggles, and section glyphs. They are the brand's only iconography.
- Anchor the dark `hero-tui-mockup` exactly once per landing page as the hero centerpiece. Never use the dark surface for body content.
- Reserve `accent` (Apple Blue) and the rest of the semantic ramp for in-TUI states; marketing chrome stays monochrome.
- Use `sm` (4px) on every interactive element and `none` (0px) on every container.
- Stack content sections at `section` (96px) rhythm with only 1px `hairline` rules between them.

### Don't
- Don't introduce a sans-serif body font, a display face, or an italic style. Berkeley Mono carries everything.
- Don't add drop shadows, gradients, or atmospheric backgrounds. The system is flat-on-cream.
- Don't replace the ASCII bracket markers with SVG icons. The brackets are the icons.
- Don't use the semantic accent ramp (`accent`, `warning`, `danger`, `success`) on marketing CTAs. They belong to the in-product TUI.
- Don't pad cards with 24px+ internal padding. List rows sit at 8px vertical; FAQ rows at 12px.
- Don't render the OpenCode wordmark as a vector logo. It is always block-pixel ASCII.
- Don't fill the hero TUI mockup with photography or illustration. It is text-only and always shows a faux terminal command line.



## oracle
An analysis of Oracle's design language — an enterprise system built on a warm neutral ladder rather than a colour palette. Six numbered greys carry almost every surface, a single dark charcoal carries every action, and the famous red is held back for the wordmark alone. Two display registers coexist, being a very light sans on the corporate index and a Georgia serif across the product pages, and the only chromatic moments are a thin gold rule under a headline and the occasional full-width band of teal or forest green.
Core tokens: {"primary": "#312d2a", "primary-pressed": "#47423e", "on-primary": "#ffffff", "ink": "#161513", "ink-deep": "#211e1c", "canvas": "#ffffff", "canvas-soft": "#fbf9f8", "canvas-tint": "#f5f4f2", "canvas-warm": "#f1efed", "hairline": "#e4e1dd", "link": "#006b8f", "disabled-ink": "#aea8a2"}
Fonts: ['Georgia', 'Oracle Sans']
Layout: - **Outer container**: 1744px maximum, with a 72px side gutter.
- **Context container**: 1600px maximum for content that sits inside a band.
- **Minimum container**: 272px, which is the floor the layout collapses toward on the narrowest phones.
- **Grid gap**: 32px between columns, used by the corporate index tile row, the channel columns and the product card grids.
- **Masthead**: 85px tall, full width, white. **Product sub-navigation**: 64px, full width, sticky. **Footer**: 105px, full width, white.
- Sections are full-bleed and square-cornered; the container only constrains the content inside them, never the band itself.

## Do's and Don'ts

### Do
- Build page structure from the neutral ladder. Moving a section one rung is the system's way of saying "new region".
- Keep `brand-mark` on the wordmark and nowhere else. Its scarcity is what gives it weight.
- Run every action through `primary` at `xs` with `10px 16px` padding, whatever the context.
- Flip polarity rather than changing colour when an action lands on a dark band — use `{components.button-primary-inverse}`.
- Hold `section` at 48px on every full-width band; the uniform rhythm is what makes the small tonal steps legible.
- Let weight carry hierarchy. The 400-to-800 jump between body and heading is the system's main structural signal.
- Keep letter-spacing at zero on every role, at every size.
- Deploy chromatic colour only at whole-band scale, as `{components.section-band-teal}` or `{components.section-band-forest}`.

### Don't
- Don't add shadows. The system has none, and elevation is expressed by position on the neutral ladder.
- Don't use pure black. `ink` is warm and deliberately a few points off it.
- Don't round a band, a section, a masthead or a footer — `none` on full-width chrome is the rule.
- Don't mix the two card radii. `xl` belongs to the corporate index and `md` to the product pages; using both on one page breaks the template read.
- Don't set a headline in Oracle Sans on a product page or in Georgia on the corporate index — the two registers do not cross templates.
- Don't underline `{components.link-inline}`; `link` alone carries the affordance.
- Don't add a fourth or fifth tint between the ladder rungs. They are already close enough that another step would be invisible.
- Don't give `{components.hero-eyebrow-rule}` a second colour or a second instance per page; one 40 × 4px gold bar is the whole ornament budget.


## oura
An analysis of Oura's design language — a warm-paper wellness system that pairs a high-contrast Editorial serif with a quiet grotesque sans, wraps every surface in a cream-and-earth palette drawn from mustard, clay and olive, and drives conversion with a single decisive action blue against otherwise calm, photography-led layouts.
Core tokens: {"primary": "#2a72de", "on-primary": "#ffffff", "canvas": "#f7f1e8", "surface": "#ffffff", "surface-grey": "#ececec", "ink-band": "#000000", "ink-band-soft": "#19191c", "ink": "#1c1b1a", "hairline": "#e1dcd3"}
Fonts: ['Editorial New', 'AkkuratLL']
Layout: - Content is center-constrained within a wide max-width, with full-bleed photography breaking out to the viewport edges.
- Card grids run 3-up (person cards, benefit trios) and 4-up (news / expert carousels), collapsing toward 1-up on narrow screens.
- The product page alternates centered single-column showcases with edge-to-edge media.

## Do's and Don'ts

### Do
- Reserve `primary` strictly for the primary conversion CTA — one blue moment per view, maximum.
- Default every surface to `canvas` (warm paper), not white. White (`surface`) is for elevated cards and inputs, not backgrounds.
- Use `stone` for the wordmark, secondary pills, outlines, form fills, and links — it is the workhorse neutral.
- Pair `display` (thin serif) at large sizes with `body` (grotesque) for reading; let scale create hierarchy.
- Keep pills fully rounded (`full`) and cards softly rounded (`lg`); use `xl` only for large product imagery.
- Let the earth-tone ramps (gold, clay, olive) live in bands, illustration, and data-viz — as color-blocked sections that pace the scroll.
- Give sections large vertical breathing room; treat empty cream as structure.

### Don't
- Don't use `primary` for links, accents, icons, or decorative fills — it must stay unique to the primary CTA.
- Don't put the mustard/olive accent colors on buttons — they are surfaces and illustration, never actions.
- Don't set body copy in `display`; the thin serif is display-only and gets illegible at small sizes.
- Don't default backgrounds to white — it breaks the warm-paper identity.
- Don't add heavy or hard-edged shadows; elevation here is soft, warm, and low-opacity.
- Don't crowd sections — compressing the vertical rhythm collapses the calm, editorial pacing that defines the brand.


## pinterest
A photography-first discovery system organized around the Pinterest Red CTA, the masonry pin grid, and a soft warm-cream chrome that gets out of the imagery's way. The home page is a content-discovery tool wearing the chrome of a magazine publisher: 70px display headlines, friendly Pin Sans typography, fully-rounded pill buttons (16px) on a cream-tinted neutral palette, and a sticky red "Sign up" CTA that anchors every viewport. Pin imagery is the system's load-bearing visual element — square, portrait, and landscape pins tile in a column-based masonry grid where each tile is a fully-rounded 16px-radius card, separated by tight 8px gutters. The chrome is otherwise quiet: warm grays, true whites, and a single saturated red — no decorative gradients, no atmospheric backgrounds, no shadows beyond a soft modal scrim.

Core tokens: {"primary": "#e60023", "on-primary": "#ffffff", "primary-pressed": "#cc001f", "ink": "#000000", "ink-soft": "#211922", "hairline": "#dadad3", "hairline-soft": "#e5e5e0", "canvas": "#ffffff", "surface-soft": "#fbfbf9", "surface-card": "#f6f6f3", "surface-elevated": "#ffffff", "surface-dark": "#262622"}
Fonts: ['Pin Sans']
Layout: - **Max width:** ~1280px content area at desktop with 24px gutters (~48px at ultrawide).
- **Pin masonry grid:** auto-fitting column-based layout — 5–6 columns at ultrawide, 4 columns at desktop, 3 at tablet, 2 at mobile-landscape, 1 at mobile. Each tile preserves its natural aspect ratio (square / 2:3 / 3:4 / 4:5 portrait — never landscape because pins are vertically-oriented). Gutters are `sm` (8px) horizontal and vertical.
- **Home hero feature row:** asymmetric 2-column split where text and imagery alternate left/right down the page (text-left + image-right, then image-left + text-right, etc.).
- **Footer:** 4-column link grid at desktop, collapsing to 2-up at tablet, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (Pinterest Red) for primary CTAs, the active-tab indicator, and the brand wordmark only. It is never decorative.
- Use `md` (16px) on every interactive element and standard card; reserve `lg` (32px) for large pin cards and modals; reserve `full` for circular elements (search bar, chips, avatars).
- Stage every pin image inside a `pin-card` with no internal padding — the photograph IS the card.
- Stack content sections at `section` (64px) rhythm; tighten pin grids to `sm` (8px) gutters so imagery effectively touches.
- Use `pin-overlay-pill` to anchor a search-term tag in the corner of a category-tile pin photograph — the system's signature decorative gesture.
- Build hierarchy from font weight (400 → 600 → 700) and size, not from color tinting. Body stays `body` regardless of section context.
- Apply -1.2px letter-spacing on `display-xl` and `heading-xl`. The negative tracking is part of the brand voice.

### Don't
- Don't use sharp-cornered buttons or cards. There are no `none` interactive elements in the system.
- Don't introduce drop shadows on cards. The only shadow in the system is the 16px ambient under `modal-card`.
- Don't pad `pin-card` internally. The image is full-bleed; metadata sits over the image as an overlay pill, not below it.
- Don't replace `primary` with another red. The brand red is precise — `#e60023`.
- Don't use `ink-soft` (the body-prose link tint) outside of inline body anchor links. It is not a chrome color.
- Don't introduce a third radius value between 16px and 32px. The system jumps directly from md to lg with nothing in between.



## playstation
A three-surface marketing system organized around alternating black, white, and PlayStation Blue chapters that scroll past the viewer like a console launch trailer. Each section has a single editorial purpose — hero photography, console product render, PS Plus tier callout, news strip — and each owns one of three full-bleed canvas modes. The chrome is unusually quiet for a gaming brand: bright PlayStation Blue (`#0070d1`) carries every primary CTA as a fully-rounded pill, the proprietary SST face renders display copy at a signature weight 300 (light) for an airy, premium feel, and a crisp 8px-radius secondary card system carries product info on either canvas mode. The system never decorates — no gradient backgrounds on chrome, no atmospheric mesh, no drop shadows beyond a faint section-divide. Imagery does all the heavy lifting: console glamour shots, game key art, and PS Plus tier illustrations occupy 60-90% of every section, with copy compressed into a small editorial slot.

Core tokens: {"primary": "#0070d1", "primary-pressed": "#0064b7", "primary-active": "#004d8d", "on-primary": "#ffffff", "link-light": "#0064b7", "link-dark": "#53b1ff", "commerce-link-base": "#d63d00", "ink": "#000000", "ink-deep": "#121314", "ink-elevated": "#181818", "canvas-light": "#ffffff", "surface-soft": "#f3f3f3", "surface-card": "#f5f7fa", "surface-filter": "rgba(245,247,250,0.3)", "canvas-dark": "#000000", "surface-dark-elevated": "#121314", "surface-dark-card": "#181818", "hairline-light": "#f3f3f3", "hairline-dark": "rgba(229,229,229,0.2)"}
Fonts: ['PlayStation SST']
Layout: - **Max width:** ~1280px content area for body text on desktop with 24px gutters that expand to ~48px at ultrawide. Hero bands and game-tile rails go full-bleed with no max-width constraint on imagery.
- **Game tile carousel:** 4-up at desktop with horizontal scroll on the same row, collapsing to 3-up at 1024px and 2-up at 768px. Each tile uses 16:9 cover art at `md`.
- **Console showcase grid:** desktop 5-column thumbnail strip below the main hero render, collapsing to 3-up + horizontal scroll at tablet.
- **Support page:** desktop 2-column 30/70 split (sidebar nav + article body), collapsing to single-column with the sidebar promoted to a top accordion at mobile.
- **News strip:** 3-up card grid at desktop, 2-up at tablet, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (PlayStation Blue) for primary CTAs and the footer surface only. The blue band is precious — at most one full-bleed blue band per page.
- Reserve `commerce` (orange) for store/buy/pre-order CTAs only. It is never used on marketing chrome or hero pills.
- Use PlayStation SST at weight 300 for display headings (54 / 44 / 35 / 28 / 22). The light weight is the brand voice.
- Stack content sections at `section` (96px) rhythm with the next band's surface color taking over the page edge-to-edge — no decorative dividers between bands.
- Use `full` (9999px) on every CTA pill and `md` (8px) on every product card. The two-radius vocabulary is the entire shape system aside from inputs.
- Pair full-bleed game key art and console renders inside dark or light bands; let imagery occupy 60-90% of the band's vertical height.
- Use `ps-plus-banner` with the gold gradient exclusively for the PlayStation Plus tier callout — never decorate other components with the gold.

### Don't
- Don't introduce drop shadows on resting cards. The system is flat-on-canvas; cards lift only on press.
- Don't replace `primary` with another shade of blue. The brand blue is precise — `#0070d1` for default and `#0064b7` for pressed.
- Don't use `commerce` (orange) on marketing/hero CTAs. It's reserved exclusively for store actions.
- Don't introduce a sans-serif body font, italic, or monospace style. PlayStation SST carries every text role.
- Don't soften pill geometry. CTAs are always `full` — no medium-radius buttons.
- Don't use the gold PS Plus gradient on anything that isn't the PS Plus banner. It is a tier-specific brand asset.
- Don't put a gradient on chrome. The only allowed gradient is the gold PS Plus accent and the soft top-to-bottom darkening of the "ON PLAYSTATION" band.



## posthog
A playful developer-tools system rendered on a warm cream canvas with hand-drawn hedgehog mascots dotted across every page like marginalia in a sketchbook. The chrome reads like a friendly engineering blog: olive-gray ink (#4d4f46) for body, deep olive-charcoal (#23251d) for headlines, IBM Plex Sans Variable typography in tight 1.43-line-height paragraphs, and a single saturated yellow-orange CTA pill (#f7a501) carrying every primary action. The system actively rejects the genre's typical somber dark-tech aesthetic in favor of a creamy, textbook-illustration sensibility — bordered cards stack on the cream canvas with 4–6px radii, doc sidebars use rounded outline-icon mini-illustrations, and the home page leans on cartoon characters (hedgehogs in lab coats, hedgehogs at terminals, hedgehogs in lounge chairs) as its signature decoration. Code samples and product analytics charts live inside white-on-cream cards with thin olive borders; the contrast between the playful illustration and the data-dense product imagery is the brand's signature voice.

Core tokens: {"primary": "#f7a501", "primary-pressed": "#dd9001", "primary-active": "#b17816", "on-primary": "#23251d", "ink": "#23251d", "hairline": "#bfc1b7", "hairline-soft": "#dcdfd2", "canvas": "#eeefe9", "surface-soft": "#e5e7e0", "surface-card": "#ffffff", "surface-doc": "#fcfcfa", "surface-dark": "#23251d", "link-blue": "#1d4ed8", "link-teal": "#1078a3"}
Fonts: ['IBM Plex Sans Variable', 'ui-monospace', 'Source Code Pro']
Layout: - **Max width:** ~1280px content area at desktop with 24px gutters (~48px at ultrawide). Doc article body sits at ~720px max width with the 240px sidebar pushing the article column right of center.
- **Marketing card grid:** 4-up at desktop, 3-up at 1024px, 2-up at 768px, 1-up at 480px. Cards preserve a fixed 1:1 or 4:3 ratio.
- **Pricing tier grid:** 3-up at desktop with a left rail of plan info, collapsing to 2-up + 1 at tablet and 1-up at mobile.
- **Doc layout:** desktop 240px sticky left sidebar + ~720px article body + (optional) 200px right TOC rail = ~1160px content width.
- **Footer:** 6-column horizontal link grid at desktop, 3-up at tablet, 2-up at mobile.

## Do's and Don'ts

### Do
- Use `canvas` (cream — `#eeefe9`) as the page body. Never substitute pure white as the canvas.
- Reserve `primary` (yellow-orange) for the primary CTA pill only. The "Get started — free" treatment is the brand's anchor.
- Render the brand wordmark with the hedgehog illustration alongside it, not as a stand-alone wordmark. The hedgehog IS the brand identity.
- Use IBM Plex Sans Variable across every text role — body 400, emphasis 600/700, display 800.
- Stack content sections at `section` (80px) rhythm with no decorative dividers between them; let the cream canvas continue uninterrupted.
- Use `banner-tip-blue` / `-green` / `-red` / `-purple` only inside doc article body for tip/warning/note panels — keep marketing chrome out of the four-color callout family.
- Pair every code sample with the dark `code-block` surface; inline `<code>` chips use `inline-code` (cream surface-soft chip).
- Anchor a hedgehog mascot illustration in feature tile margins on home and workflows pages — the system's signature decoration.

### Don't
- Don't introduce drop shadows on cards. Cards sit flat on cream with thin olive borders only.
- Don't add a second saturated chromatic CTA. Yellow-orange is the only loud color in the system.
- Don't replace the cream canvas with pure white or full-bleed dark hero bands. The cream is the brand.
- Don't use the four-color callout banner pastels (`accent-blue-soft`, `-green`, `-red`, `-purple`) as marketing-card backgrounds. They belong to inline doc content only.
- Don't substitute the hedgehog illustration with a generic icon set. The character system is the brand.
- Don't use uppercase transform outside of `heading-sm`, `utility-xs`, and `caption-xs`. Uppercase is reserved for eyebrows and footer category headers.
- Don't pad cards with 32px+ on all sides except for `pricing-tier-card`. Standard cards sit at 24px internal padding.



## raycast

Core tokens: {}
Fonts: []
Layout: - **Max width:** ~1240px content area at desktop with 24px gutters (~48px at ultrawide). Hero command-palette mockups run wider (~1080px) with the page background extending to full bleed.
- **Store extension grid:** 2-up at desktop with rows of 2 cards stacked, collapsing to 1-up at mobile. Each card is a horizontal layout with a large square app icon at the left and copy + Install button at the right.
- **Pricing tier grid:** 3-up at desktop (Free / Pro / Pro+Advanced AI), collapsing to 1-up stacked at mobile.
- **Featured extension card grid:** 3-up at desktop in the "Featured" row at the top of the store page.
- **Comparison table:** full-width on the pricing page below the tier cards — 5-column table (Free / Pro / Advanced AI / Custom for Teams / Enterprise) with feature rows.
- **Footer:** 6-column horizontal link grid at desktop, collapsing to 2-up at tablet and 1-up at mobile.

## Do's and Don'ts

### Do
- Render the entire site in one continuous dark mode. There is no light variant in the system.
- Use `primary` (white pill) for every primary CTA. There is no second primary color — white IS the brand action.
- Build elevation from the surface-color ladder (`canvas` → `surface` → `surface-elevated` → `surface-card`), never from drop shadows.
- Enable `font-feature-settings: "calt", "kern", "liga", "ss03"` on the body element. The ss03 alternate `g` is part of the brand identity.
- Anchor a `command-palette-card` mockup as the hero's load-bearing visual. Real Raycast UI is the brand.
- Use `keycap` glyphs inline to indicate keyboard shortcuts. Subtle key-bg gradient (`key-bg-start` → `key-bg-end`) is the brand's only "depth" decoration.
- Reserve `hero-stripe-start` → `hero-stripe-end` red gradient for the hero band exactly once per page. Never repeat the stripe gradient deeper in the page.
- Use saturated category accents (`accent-yellow`, `accent-red`, `accent-green`, `accent-blue`) only inside extension and feature illustrations — never on chrome buttons or text.

### Don't
- Don't introduce a light mode. The system is dark-only by design.
- Don't add drop shadows on cards. Elevation is built from the surface ladder, not from shadows.
- Don't replace `primary` (white) with a tinted accent for the primary CTA. Pure white is the brand action color.
- Don't use the saturated accent colors (`accent-yellow`, `accent-red`, `accent-green`, `accent-blue`) on text, buttons, or chrome surfaces. They belong inside extension illustrations.
- Don't repeat the hero stripe gradient outside the top hero band. The one-band rule is the system's restraint.
- Don't use Inter without the `ss03` feature flag enabled. The chrome will lose its signature voice.
- Don't pad cards with 32px+ on all sides. The system runs tight at 16–24px in-card padding.



## renault
Renault's web presence pairs the freshly-modernised Renault diamond
(the 2021 flat-line rhombus mark) with a stark black-and-white canvas, a
signature Sunlight Yellow accent, and the proprietary NouvelR display
typeface. The system reads as confident, photography-first automotive — large
hero cars on neutral or atmospheric backdrops, square-edged or barely-rounded
containers, and a small disciplined palette where every coloured element is
intentional. Tile grids, full-bleed banners, and a recurring "configurator"
surface (white card, yellow accent dots, neutral product chrome) carry the
mass-market dealership tone without crossing into luxury.

Core tokens: {"primary": "#ffed00", "primary-deep": "#e6d200", "on-primary": "#000000", "ink": "#000000", "canvas": "#ffffff", "surface-soft": "#f7f7f7", "surface-card": "#ffffff", "surface-dark": "#000000", "surface-deep": "#111111", "hairline": "#f2f2f2", "hairline-strong": "#000000", "link": "#0000ee"}
Fonts: ['NouvelR']
Layout: - **Max content width** ≈ 1440px. Beyond that, content remains centred and the dark/light bands extend full-bleed.
- **Promo grid** on the homepage: a 2-column tile grid on desktop, dropping to 1-up on mobile. Each tile is square-cornered (`none`) with the photography or solid colour as the background.
- **Vehicle range grids**: 3 to 4 cars per row at desktop, collapsing 2-up at tablet and 1-up at small mobile.
- **Configurator** uses a fixed left visualisation pane (~60% width) with a right-hand scrolling option list (~40% width) on desktop.

## Do's and Don'ts

### Do
- Reserve `primary` exclusively for primary CTAs, "yeni"/"NEW" badges, and at most one accent promo tile per band — `promo-tile-yellow` is intentionally rare.
- Pair `primary` only with `on-primary` text. Yellow + white is forbidden.
- Set everything in **NouvelR** — no secondary serif, no script, no decorative italic.
- Hold display headlines at `display-xl` weight 700 with `lineHeight: 0.95` so they stack tightly on multi-line wraps.
- Use `xs` (2px) on every standard button — the near-flat corner is part of the brand.
- Switch full bands between `canvas` and `surface-dark` for storytelling rhythm. Avoid mid-greys as section backgrounds.
- Show vehicle photography full-bleed inside `vehicle-card` with copy stacked beneath, never overlaid.
- Use `sub-nav-pill` (`pill`) only for sub-nav and small filter rows — never for primary CTAs.

### Don't
- Don't introduce a secondary accent colour. Yellow is the only brand accent; semantic colours (`error`, `success`, `warning`) are functional, not decorative.
- Don't round vehicle cards or promo tiles. Square-cornered photography is core to the brand expression.
- Don't soften body weights to 500 or 600 — the system relies on the 400 / 700 contrast.
- Don't apply `primary` to body text or large surfaces beyond the single accent tile per band.
- Don't add atmospheric gradient washes outside the dedicated R5 / E-TECH hero contexts.
- Don't pair light grey text on white. Body text steps through `body`, `charcoal`, `mute` — `ash` and `stone` are reserved for placeholders and disabled states.
- Don't add drop shadows to vehicle cards or promo tiles — the system is shadow-free at the catalogue level.



## replicate
Replicate's marketing surfaces pair the warm-cream developer-tools aesthetic
of an indie ML playground with a confident hot-orange brand accent and a
signature display typeface (rb-freigeist-neue) sized aggressively large at
72px+. The system reads as "AI lab notebook crossed with print magazine":
cream and bone surfaces, dark ink type, monospace code wells, irregular
hand-drawn-feeling diagrams, and a rich orange used scarcely on the most
consequential CTA. Photography of contributors and example outputs is
square-ish with mid-radius corners; everything else is borderless or hairline.

Core tokens: {"primary": "#ea2804", "primary-deep": "#c01f00", "on-primary": "#ffffff", "ink": "#202020", "canvas": "#f9f7f3", "surface-bone": "#f3f0e8", "surface-card": "#ffffff", "surface-dark": "#202020", "surface-deep": "#000000", "hairline": "rgba(32,32,32,0.12)", "hairline-strong": "#202020", "hero-pink": "#f4a8a0", "link": "#ea2804"}
Fonts: ['rb-freigeist-neue', 'basier-square', 'jetbrains-mono']
Layout: - **Max content width** ≈ 1280px on body sections, 1440px on hero bands which run full-bleed.
- **Model grid** on collections: 4 columns at desktop, 3 at tablet large, 2 at tablet, 1 at mobile.
- **Pricing**: 3-tier grid centred at desktop, stacking vertically below 1024px; the centre tier flips to `pricing-tier-featured` (dark inversion) as the recommended option.
- **Code-story sections**: a 2-up split — narrative copy left, code well right — collapsing to stacked at < 1024px.

## Do's and Don'ts

### Do
- Use `canvas` (cream) as the default page background. White (`surface-card`) appears only on individual cards, inputs, and the hero illustration backdrop.
- Reserve `primary` for the primary CTA, the home hero band, and inline links — three roles, nothing else.
- Set every interactive element to `full` — buttons, inputs, badges, avatars, pills.
- Step content cards up to `md` (10px) or `lg` (16px) — never sharp corners.
- Open hero bands with `display-xxl` (128px) and `display-xl` (72px) at `lineHeight: 1.0` with negative letter-spacing.
- Use `rb-freigeist-neue` for all display, `basier-square` for UI/body, `jetbrains-mono` for code. Keep the lanes strict.
- Render code in `code-block` with a `surface-dark` background — code is print, not an inline grey box.
- Pair photography with `md` corners and full-bleed crop inside cards.

### Don't
- Don't replace cream with pure white at the page level. The brand temperature comes from `canvas`.
- Don't introduce a secondary brand colour. Orange is the only accent; semantic green and focus blue are functional, not decorative.
- Don't loosen display `lineHeight` past 1.0. Tight stacking is structural.
- Don't bump body weight to 500 for emphasis — change family (`basier-square` → `rb-freigeist-neue`) instead.
- Don't apply `full` to content cards. Pill-shaped cards break the rhythm.
- Don't put code in a light grey box. Code wells are always `surface-dark` or `surface-deep`.
- Don't use orange on body text or large surfaces — it loses its stamp quality immediately.
- Don't add drop shadows on cream surfaces. Elevation is colour-blocking; shadows are reserved for floating thumbnails.



## resend
Resend's marketing surfaces sit on a near-pure black canvas with off-white
text and a single signature color — the deep editorial-serif Domaine
Display headline mark — that gives an otherwise utilitarian developer-tool
brand its print-magazine confidence. The system pairs Domaine Display
(oversized 76px–96px serif, ss01/ss04/ss11 features on) with ABC Favorit
for body and Inter for UI. Surfaces rely on subtle 6–9% opacity gradient
glows, hairline 1px borders made from translucent white, and a strict
rounded-12px container vocabulary. There is no decorative chrome — just
type, code, and atmospheric depth.

Core tokens: {"primary": "#fcfdff", "primary-on": "#000000", "ink": "#fcfdff", "canvas": "#000000", "surface-card": "#0a0a0c", "surface-elevated": "#101012", "surface-deep": "#06060a", "hairline": "rgba(255,255,255,0.06)", "hairline-strong": "rgba(255,255,255,0.14)", "link": "#3b9eff", "surface-light": "#f1f7fe"}
Fonts: ['Domaine Display', 'ABC Favorit', 'Inter', 'Helvetica', 'Geist Mono']
Layout: - **Max content width** ≈ 1200px on body sections.
- **Feature grid**: 3 columns at desktop, 2 at tablet, 1 at mobile.
- **Pricing**: 3-tier grid centred at desktop; centre tier promotes to `pricing-tier-featured` (one-step-elevated surface).
- **Code-story splits**: a 2-up split — narrative copy left, `code-window` right — collapsing to stacked at < 1024px.
- **Email mockup band**: a single white card (640px max width) centred in the dark canvas with generous vertical padding to read like a print magazine inset.

## Do's and Don'ts

### Do
- Use `canvas` (true black) as the default page background. Every public page lives here.
- Reserve `button-primary` (white pill) as the only solid bright surface. One per viewport at most.
- Set hero headlines in **Domaine Display** at 76–96px with `lineHeight: 1.0` and `ss01 / ss04 / ss11` features engaged.
- Use **ABC Favorit** for marketing body, **Inter** for UI labels, **Geist Mono** for code. Keep the lanes strict.
- Build elevation from translucent-white hairlines, not drop shadows.
- Use `accent-*-glow` tokens as low-opacity radial atmospheric washes — never as solid surfaces.
- Set buttons and inputs to `md` (8px); cards and code wells to `lg` (12px); pills and avatars to `full`.
- Use the white email-mockup inset sparingly — it's the only deliberately-light surface and should feel like a print pull-quote.

### Don't
- Don't use a near-black canvas. The brand sits on `#000000`, not `#0a0a0a`.
- Don't apply solid colour to atmospheric accent tokens. `accent-orange` is for inline highlights only — its glow form is for backdrops.
- Don't add drop shadows to feature cards or code wells. Translucent white borders carry depth on this canvas.
- Don't bump body weight to 600 for emphasis. Use family change (Inter → ABC Favorit → Domaine Display) instead.
- Don't render code outside `code-window` — even small inline code uses Geist Mono and a `surface-card` background.
- Don't loosen Domaine Display `lineHeight` past 1.0. Tight stacking is structural to the brand.
- Don't introduce a secondary brand accent. White is the brand on black — accents are atmospheric only.
- Don't bring photography front-and-centre. The brand reads as type-and-code, not photography-led.



## revolut
Revolut's marketing surfaces pair a stark black canvas with the brand's
cobalt-violet (`#494fdf`) and a wide accent palette of deep, fully-saturated
product colours — teal, light-blue, deep pink, light-green, warning orange.
The system reads as fintech-meets-product-brochure: oversized 80px–136px
Aeonik Pro display headlines, generous whitespace, photography-led hero
bands, and full-width product mockups (cards, phones, terminals) shown as
hero objects inside near-black sections. Most surfaces are either black or
off-white; pill-shaped buttons and rounded-12/20px content cards carry the
consumer-financial-app feel without crossing into playful territory.

Core tokens: {"primary": "#494fdf", "primary-bright": "#4f55f1", "primary-deep": "#3a40c4", "on-primary": "#ffffff", "ink": "#191c1f", "canvas-light": "#ffffff", "canvas-dark": "#000000", "surface-soft": "#f4f4f4", "surface-card": "#ffffff", "surface-deep": "#0a0a0a", "surface-elevated": "#16181a", "hairline-light": "#e2e2e7", "hairline-dark": "rgba(255,255,255,0.12)", "hairline-strong": "#191c1f", "accent-blue-link": "#376cd5", "accent-pink": "#e61e49", "link": "#376cd5"}
Fonts: ['Aeonik Pro', 'Inter']
Layout: - **Max content width** ≈ 1200px on body sections; hero bands run full-bleed.
- **Plan grid**: 4-up plan cards on the home page, stacking 2-up at tablet and 1-up at small mobile.
- **Feature grid**: 3-up at desktop, 2-up at tablet, 1-up at mobile.
- **Product mockup bands**: a single full-width hero photo of a phone or card mockup, no surrounding chrome — the asset itself is the section.

## Do's and Don'ts

### Do
- Switch full bands between `canvas-dark` (storytelling) and `canvas-light` (catalogue). The two-mode rhythm is core.
- Use `button-primary` (white pill on dark) as the primary CTA on every dark hero band. It's the brand's loudest action.
- Reserve `primary` for the featured plan card and the brand wordmark — the cobalt should feel like a deliberate stamp, not a colour theme.
- Set hero headlines in **Aeonik Pro 500** at 80–136px with `lineHeight: 1.0` and large negative letter-spacing.
- Use **Inter** for body, button labels, captions — never substitute Aeonik Pro for body type.
- Apply `full` to every button and pill; `lg` (20px) to feature and plan cards; `md` (12px) to inputs.
- Show product mockups full-bleed inside dark sections — the asset IS the section.
- Use the wide accent palette (`accent-teal`, `accent-pink`, `accent-light-green`, etc.) inside product illustrations and iconography only.

### Don't
- Don't use accent colours (`accent-teal`, `accent-pink`, etc.) as button surfaces. They live inside illustrations only.
- Don't use a near-black canvas. The brand is `#000000`, not `#0a0a0a`.
- Don't pair white text with cobalt violet inside body content — `primary` is for the featured plan card surface, not large prose.
- Don't add drop shadows on cards. Elevation is canvas + surface-luminance shifts.
- Don't introduce a secondary brand colour. Cobalt violet is the only brand stamp.
- Don't loosen Aeonik Pro `lineHeight` past 1.0 on display sizes. Tight stacking is structural.
- Don't bump body Inter to weight 500. Use 400 (default) or 600 (emphatic) — never the in-between.
- Don't pair `canvas-dark` with another dark surface beyond `surface-elevated`. The surface ladder has only two dark steps.



## runwayml
## 1. Visual Theme & Atmosphere

Runway's interface is a cinematic reel brought to life as a website — a dark, editorial, film-production-grade design where full-bleed photography and video ARE the primary UI elements. This is not a typical tech product page; it's a visual manifesto for AI-powered creativity. Every section feels like a frame from a film: dramatic lighting, sweeping landscapes, and intimate human moments captured in high-quality imagery that dominates the viewport.

The design language is built on a single typeface — abcNormal — a clean, geometric sans-serif that handles everything from 48px display headlines to 11px uppercase labels. This single-font commitment creates an extreme typographic uniformity that lets the visual content speak louder than the text. Headlines use tight line-heights (1.0) with negative letter-spacing (-0.9px to -1.2px), creating compressed text blocks that feel like film titles rather than marketing copy.

What makes Runway distinctive is its complete commitment to visual content as design. Rather than illustrating features with icons or diagrams, Runway shows actual AI-generated and AI-enhanced imagery — cars driving through cinematic landscapes, artistic portraits, architectural renders. The interface itself retreats into near-invisibility: minimal borders, zero shadows, subtle cool-gray text, and a dark palette that puts maximum focus on the photography.

**Key Characteristics:**
- Cinematic full-bleed photography and video as primary UI elements
- Single typeface system: abcNormal for everything from display to micro labels
- Dark-dominant palette with cool-toned neutrals (#767d88, #7d848e)
- Zero shadows, minimal borders — the interface is intentionally invisible
- Tight display typography (line-height 1.0) with negative tracking (-0.9px to -1.2px)
- Uppercase labels with positive letter-spacing for navigational structure
- Weight 450 (unusual intermediate) for small uppercase text — precision craft
- Editorial magazine layout with mixed-size image grids


Core tokens: {}
Fonts: []
Layout: - Max container width: up to 1600px (cinema-wide)
- Hero: full-viewport, edge-to-edge
- Content sections: centered with generous margins
- Image grids: asymmetric, magazine-style mixed sizes
- Footer: full-width dark section

## 7. Do's and Don'ts

### Do
- Use full-bleed cinematic photography as the primary visual element
- Use abcNormal for all text — maintain the single-typeface commitment
- Keep display line-heights at 1.0 with negative letter-spacing for film-title density
- Use the cool-gray neutral palette (#767d88, #7d848e) for secondary text
- Maintain zero shadows — depth comes from photography and section backgrounds
- Use uppercase with letter-spacing for navigational labels (14px, 0.35px spacing)
- Apply small border-radius (4–8px) — the design is NOT pill-shaped
- Let visual content (photos, videos) dominate — the UI should be invisible
- Use weight 450 for micro labels — the precision matters

### Don't
- Don't add decorative colors to the interface — the only color comes from photography
- Don't use heavy borders or shadows — the interface must be nearly invisible
- Don't use pill-shaped radius — Runway's geometry is subtly rounded, not circular
- Don't use bold (700+) weight — 400–600 is the full range, with 450 as a precision tool
- Don't compete with the visual content — text overlays should be minimal and restrained
- Don't use gradient backgrounds in the interface — gradients exist only in photography
- Don't use more than one typeface — abcNormal handles everything
- Don't use body line-height above 1.50 — the tight, editorial feel is core
- Don't reduce image quality — cinematic photography IS the design



## sanity
## 1. Visual Theme & Atmosphere

Sanity's website is a developer-content platform rendered as a nocturnal command center -- dark, precise, and deeply structured. The entire experience sits on a near-black canvas (`#0b0b0b`) that reads less like a "dark mode toggle" and more like the natural state of a tool built for people who live in terminals. Where most CMS marketing pages reach for friendly pastels and soft illustration, Sanity leans into the gravity of its own product: structured content deserves a structured stage.

The signature typographic voice is waldenburgNormal -- a distinctive, slightly geometric sans-serif with tight negative letter-spacing (-0.32px to -4.48px at display sizes) that gives headlines a compressed, engineered quality. At 112px hero scale with -4.48px tracking, the type feels almost machined -- like precision-cut steel letterforms. This is paired with IBM Plex Mono for code and technical labels, creating a dual-register voice: editorial authority meets developer credibility.

What makes Sanity distinctive is the interplay between its monochromatic dark palette and vivid, saturated accent punctuation. The neutral scale runs from pure black through a tightly controlled gray ramp (`#0b0b0b` -> `#212121` -> `#353535` -> `#797979` -> `#b9b9b9` -> `#ededed` -> `#ffffff`) with no warm or cool bias -- just pure, achromatic precision. Against this disciplined backdrop, a neon green accent (display-p3 green) and electric blue (`#0052ef`) land with the impact of signal lights in a dark control room. The orange-red CTA (`#f36458`) provides the only warm touch in an otherwise cool system.

**Key Characteristics:**
- Near-black canvas (`#0b0b0b`) as the default, natural environment -- not a dark "mode" but the primary identity
- waldenburgNormal with extreme negative tracking at display sizes, creating a precision-engineered typographic voice
- Pure achromatic gray scale -- no warm or cool undertones, pure neutral discipline
- Vivid accent punctuation: neon green, electric blue (`#0052ef`), and coral-red (`#f36458`) against the dark field
- Pill-shaped primary buttons (99999px radius) contrasting with subtle rounded rectangles (3-6px) for secondary actions
- IBM Plex Mono as the technical counterweight to the editorial display face
- Full-bleed dark sections with content contained in measured max-width containers
- Hover states that shift to electric blue (`#0052ef`) across all interactive elements -- a consistent "activation" signal


Core tokens: {}
Fonts: []
Layout: - Max content width: ~1440px (inferred from breakpoints)
- Page gutter: 32px on desktop, 16px on mobile
- Content sections use full-bleed backgrounds with centered, max-width content
- Multi-column layouts: 2-3 columns on desktop, single column on mobile
- Card grids: CSS Grid with consistent gaps (16-24px)

## 7. Do's and Don'ts

### Do
- Use the achromatic gray scale as the foundation -- maintain pure neutral discipline with no warm/cool tinting
- Apply Electric Blue (`#0052ef`) consistently as the universal hover/active state across all interactive elements
- Use extreme negative letter-spacing (-2px to -4.48px) on display headings 48px and above
- Keep primary CTAs as full-pill shapes (99999px radius) with the coral-red (`#f36458`)
- Use IBM Plex Mono uppercase for technical labels, tags, and system metadata
- Communicate depth through surface color (dark-to-light) rather than shadows
- Maintain generous vertical section spacing (64-120px) on the dark canvas
- Use `"cv01", "cv11", "cv12", "cv13", "ss07"` OpenType features for display typography

### Don't
- Don't introduce warm or cool color tints to the neutral scale -- Sanity's grays are pure achromatic
- Don't use drop shadows for elevation -- dark interfaces demand colorimetric depth
- Don't apply border-radius between 13px and 99998px -- the system jumps from 12px (large card) directly to pill (99999px)
- Don't mix the coral-red CTA with the electric blue interactive color in the same element
- Don't use heavy font weights (700+) -- the system maxes out at 600 and only for 11px uppercase labels
- Don't place light text on light surfaces or dark text on dark surfaces without checking the gray-on-gray contrast ratio
- Don't use traditional offset box-shadows -- ring shadows (0 0 0 Npx) or border-based containment only
- Don't break the tight line-height on headings -- 1.00-1.24 is the range, never go to 1.5+ for display text



## sap
An analysis of SAP's design language — an enterprise system that keeps almost everything on white and spends its structure on two greys and one blue. The chrome is deliberately quiet, a 60px light-grey bar over a product tab rail, so the page reads as an application frame rather than a marketing surface. Depth comes from broad flat bands rather than shadow, corners stay at 8px on controls and 12px on media, and the brand's own variable typeface carries a 350-to-700 weight range that lets a 15px list item and a 15px nav link read as different classes of text at the same size.
Core tokens: {"primary": "#0057d2", "primary-deep": "#0040b0", "on-primary": "#ffffff", "canvas": "#ffffff", "ink": "#000000", "ink-lead": "#3c3c3c", "ink-body": "#223548", "ink-list": "#354a5f", "ink-meta": "#475e75", "ink-nav": "#545454", "hairline": "#475e75"}
Fonts: ['72 Brand Variable']
Layout: The content column is centred and capped, with the chrome running full-bleed above it. Product pages centre their hero — headline, subcopy and a single button stacked on the axis — while the services hero splits left-text against a right-hand image. Feature content resolves into two columns; the services page runs a 2×2 grid separated by hairlines rather than by card edges. The footer divides into link columns above a legal strip.

Hero treatment is the clearest per-template difference. The home page runs a full-bleed navy gradient, the services page a flat `primary-deep` band at 450px, and the product page no band at all — just centred type on `canvas` above an illustration. Three templates, three hero strategies, one chrome.

## Do's and Don'ts

### Do
- Keep `primary` for things that act — buttons, inline links, the active tab — and let everything else stay neutral.
- Separate sections with a full-width band rather than a border or a shadow. The bands are this layout's punctuation.
- Run every band square. `none` at full width is what makes a zone read as a zone.
- Use the weight axis at small sizes. `list-item` at 350 and `nav-link` at 400 are the same size on purpose.
- Set headings in true `ink` black and step body copy down into `ink-body` slate. The hue shift carries the hierarchy.
- Keep the chrome in `ink-nav` grey so navigation stays visually distinct from content text.
- Cap controls at `md` and media at `lg`.
- Let the product illustrations carry the shadows. Floating UI cards inside an image are depicting an interface, not decorating a section.

### Don't
- Don't elevate a button or a card. Depth in this system is band and gradient, not shadow.
- Don't round a full-width region. It becomes a card and the banded rhythm collapses.
- Don't introduce a second accent hue. `sky` and `navy` are scoped to specific surfaces and are not general-purpose.
- Don't set body copy in `ink-nav`. That grey belongs to the chrome; content uses the slate tiers.
- Don't flatten the weight range to 400 and 700. Losing 350 and 500 collapses three distinct roles in the 14–16px band.
- Don't add letter-spacing. The typeface is metrically tuned for these sizes and needs no correction.
- Don't crop the product illustrations to a uniform ratio. Each composition is sized to what it explains.
- Don't let a hero band and a content band sit adjacent without a white interval. The rhythm depends on white returning between coloured zones.


## sentry
An inspired interpretation of Sentri's design language — a developer-tools brand built on a deep purple-violet midnight canvas, electric lime accents, and a slightly subversive illustrated personality. The system pairs a custom display sans (chunky, playful, near-condensed) with the open Rubik family for UI copy and Monaco for code, then leans on dark-on-light pricing surfaces, sticker-style mascots, and a single-color CTA hierarchy where black-violet buttons read as the primary action against either polarity.
Core tokens: {"primary": "#150f23", "ink-deep": "#1f1633", "on-primary": "#ffffff", "accent-pink": "#fa7faa", "surface-canvas-dark": "#1f1633", "surface-canvas-light": "#ffffff", "surface-night": "#150f23", "surface-press-light": "#f0f0f0", "surface-press-stronger": "#efefef", "hairline-violet": "#362d59", "hairline-cool": "#cfcfdb", "hairline-cloud": "#e5e7eb", "ink": "#1f1633", "ink-press": "#1a1a1a", "on-dark-muted": "#bdb8c0"}
Fonts: ['Sentri Display, Rubik, system-ui, sans-serif', 'Rubik, -apple-system, system-ui, Segoe UI, Helvetica, Arial, sans-serif', 'Rubik, -apple-system, system-ui, sans-serif', 'Monaco, Menlo, Ubuntu Mono, monospace']
Layout: - Marketing pages use a wide centered container with generous outer gutters; max width sits around 1152px (one of the extracted breakpoints), with content inside flexing across 12 conceptual columns.
- Pricing splits into a 4-tier card row at desktop, collapsing to 2-up at mid widths and 1-up on mobile.
- The contact form uses a 2-column field layout (first/last name side-by-side) inside a single light-canvas panel.
- Breakpoints stair-step at 1440 → 1152 → 992 → 768 → 640 → 576 — see Responsive Behavior.

## Do's and Don'ts

### Do
- Reserve `accent-lime` for keyword-highlight chips inside display headlines and the footer squiggle divider — never use it as a button background, never as body text.
- Pair every `button-primary` with `button-cap` in uppercase with 0.2px tracking — the cadence is part of the brand, not a stylistic option.
- Treat the dark canvas (`surface-canvas-dark`) and light canvas (`surface-canvas-light`) as two complete worlds — let one own marketing/feature pages and the other own transactional pages, with no half-measures.
- Use sticker mascots to break section boundaries — let them overlap, tilt, and float; constraining them inside cards drains their personality.
- Use `card-pricing-featured` (dark inverted tier) instead of an accent-bordered light tier for the featured pricing column.
- Default body line-height to 1.5 on functional UI surfaces and 2.0 on marketing surfaces — the difference is intentional.

### Don't
- Don't introduce additional accent colors beyond `accent-lime` and `accent-pink` — adding teal, orange, or yellow dilutes the violet-and-lime signature.
- Don't apply drop shadows to cards on dark canvas — depth comes from texture and illustration, not from light-on-dark shadows that would muddy the violet.
- Don't use `display-hero` (88px) for anything except the marketing hero — even sub-pages cap at `display-large` (60px).
- Don't put body text in `accent-lime` — it's a chip color, not a type color, and breaks contrast at body sizes.
- Don't soften the `primary` button to a brand-violet — the near-black is the point; it reads as the most authoritative action regardless of canvas polarity.
- Don't put illustrated mascots inside cards or constrained containers — their job is to break grid, not occupy it.



## shopify
An inspired interpretation of Shopifi's design language — a cinematic commerce platform that runs two parallel design tracks. The marketing-hero and product-narrative pages live on near-black canvases with full-bleed photography of merchants, giant Neue Haas Grotesk display type at thin weights, and a single black-pill CTA stroked in white. The transactional pages (pricing, signup, dashboards) flip to a cream-mint canvas with pastel aloe and pistachio greens, the same pill button vocabulary, and Inter for UI body. The two tracks share typographic DNA but diverge sharply in canvas polarity — and that choice is the brand.
Core tokens: {"primary": "#000000", "ink": "#000000", "on-primary": "#ffffff", "canvas-night": "#000000", "canvas-night-elevated": "#0a0a0a", "canvas-light": "#ffffff", "canvas-cream": "#fbfbf5", "surface-elevated-dark": "#1e2c31", "hairline-light": "#e4e4e7", "hairline-dark": "#1e2c31", "link-cool-1": "#9dabad", "link-cool-2": "#9797a2", "link-cool-3": "#bdbdca", "link-mint": "#99b3ad"}
Fonts: ['NeueHaasGrotesk Display, Helvetica, Arial, sans-serif', 'Inter Variable, Inter, Helvetica, Arial, sans-serif', 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace']
Layout: - Cinematic hero pages use a wide max-width container (~1440–1600px) with edge-bleeding photography that escapes the container.
- Pricing collapses through 4-up → 2-up → 1-up tiers based on viewport.
- Body content centers in a ~720–840px reading column on long-form pages.

## Do's and Don'ts

### Do
- Reserve `aloe-10` and `pistachio-10` for the light track only — they don't appear on cinematic black pages.
- Always use `pill` for buttons; never `md` or `lg`.
- Render display tiers at weight 330; bumping to 400 or 500 breaks the brand's thin-display signature.
- Use full-bleed photography on cinematic pages — let it escape the container.
- Apply `font-feature-settings: "ss03"` globally; the stylistic set is the brand's typographic signature.
- Pair black canvas with white type and white-stroked outline pills; pair light canvas with black type and filled-black pills.

### Don't
- Don't introduce a third canvas color — stick to black or light/cream. Greys, beiges, and blues are not in the system.
- Don't add drop shadows on cinematic dark cards beyond the subtle inset top-highlight; the cinematic track wants flat blackness.
- Don't shrink display tiers below `display-md` (48px) on hero surfaces; below that they read as section heads, not display.
- Don't put aloe / pistachio greens behind type — they're surface fills, not text colors.
- Don't replace the pill shape with a rounded-rectangle button anywhere.



## slack
An inspired interpretation of Slacc's design language — a workplace messaging brand built on a deep aubergine primary, with cream-lavender hero gradients, blue inline links, and pill CTAs. The system pairs a proprietary humanist sans for display with a separate utility sans for body, and stages product UI mockups inside soft pastel-mesh hero composites that act as both decoration and feature explanation.
Core tokens: {"primary": "#4a154b", "primary-deep": "#481a54", "primary-press": "#611f69", "primary-tint": "#592466", "on-primary": "#ffffff", "ink": "#1d1d1d", "ink-mute": "#696969", "link-blue": "#1264a3", "link-hover": "#3860be", "canvas": "#ffffff", "canvas-cream": "#f4ede4", "canvas-lavender": "#f9f0ff", "surface-elev": "#ffffff", "surface-aubergine": "#4a154b", "hairline": "#e6e6e6", "hairline-strong": "#000000"}
Fonts: ['Salesforce-Avant-Garde, system-ui, -apple-system, BlinkMacSystemFont, sans-serif', 'Salesforce-Sans, system-ui, -apple-system, sans-serif']
Layout: - Marketing pages center in a ~1240px container with edge-bleeding pastel-mesh gradients escaping the container.
- Pricing collapses 4-up → 2-up → 1-up at 992 / 768 breakpoints.
- Statistics row: 3-column grid with massive 50px aubergine display numerals.

## Do's and Don'ts

### Do
- Reserve `primary` aubergine for filled CTAs, the featured pricing tier, and the closing aubergine band — it's the brand's chromatic monotheism.
- Use `pill` (90px) for every button across the system — never a rounded-rectangle button.
- Pair display tiers with negative letter-spacing (`-0.768px` at 64px); the proprietary face needs the tracking pull.
- Compose hero bands with pastel-mesh gradient backdrop + floating product UI mockup; the gradient is the depth.
- Use `link-blue` for inline links — it's the only chromatic departure from aubergine and is part of the brand voice.

### Don't
- Don't add a third accent color to the system — the aubergine + blue link combination is exhaustive.
- Don't shrink button padding below `14px 28px` — the over-padded pill is part of the brand feel.
- Don't render display tiers at default tracking (0) — without negative letter-spacing the headlines read loose and unedited.
- Don't put product UI screenshots inside cards — they sit ABOVE the pastel-mesh gradient, never inside chrome.
- Don't use aubergine for body text — it's a surface and CTA color, not a type color at body sizes.
- Don't replace the pill shape with a square button anywhere.



## spacex
An inspired interpretation of Spasex's design language — a mission-oriented aerospace brand built on pure black canvas, full-bleed photographic and video heroes of rockets and Mars landscapes, and uppercase D-DIN display type set in tight vertical leading. UI chrome is intentionally minimal a single ghost outlined pill button per band, all-caps eyebrow microtext, and a fixed top nav over photography. The system is unapologetically austere — black, white, and the imagery itself.
Core tokens: {"primary": "#000000", "ink": "#000000", "on-primary": "#ffffff", "on-primary-mute": "#f0f0fa", "canvas-night": "#000000", "canvas-night-soft": "#0a0a0a", "canvas-light": "#ffffff", "canvas-cool": "#f0f0fa", "hairline-on-dark": "#3a3a3f", "hairline-on-light": "#e0e0e8", "link-on-dark": "#ffffff", "link-blue-fallback": "#0000ee", "ink-mute": "#5a5a5f"}
Fonts: ['D-DIN-Bold, Arial Narrow, Arial, Verdana, sans-serif', 'D-DIN, Arial, Verdana, sans-serif']
Layout: - Marketing pages have no container — every band is full-viewport-width, full-viewport-height (or close to it) with photography filling the entire frame.
- Shop product grid: 4-up at desktop, 2-up at tablet, 1-up at mobile.
- Type sits inside an inner ~1200px reading column centered horizontally over the full-bleed photograph.

## Do's and Don'ts

### Do
- Use full-bleed photography or autoplaying video as the dominant decorative element on every marketing band.
- Render display tiers in uppercase D-DIN-Bold with positive 0.96–1.6px letter-spacing — the wide tracking is the signature.
- Use a single `{button-ghost-on-dark}` per band — the brand does NOT show two CTAs side by side on marketing surfaces.
- Pair every photograph with type that respects the imagery — no scrims, no gradients, no overlays. Grade the photo, not the canvas.
- Keep nav overlay-style (transparent, white-on-image) on marketing pages.

### Don't
- Don't introduce brand accent colors — black, white, and photography are the entire palette.
- Don't use drop shadows or gradient overlays on dark canvas — they fight the photography.
- Don't render display tiers in sentence-case or title-case — uppercase is the brand.
- Don't put filled buttons on marketing surfaces — the ghost outlined pill is the only marketing CTA.
- Don't use serif or humanist sans alternatives — the condensed industrial DIN cut is non-negotiable.



## spotify
## 1. Visual Theme & Atmosphere

Spotify's web interface is a dark, immersive music player that wraps listeners in a near-black cocoon (`#121212`, `#181818`, `#1f1f1f`) where album art and content become the primary source of color. The design philosophy is "content-first darkness" — the UI recedes into shadow so that music, podcasts, and playlists can glow. Every surface is a shade of charcoal, creating a theater-like environment where the only true color comes from the iconic Spotify Green (`#1ed760`) and the album artwork itself.

The typography uses SpotifyMixUI and SpotifyMixUITitle — proprietary fonts from the CircularSp family (Circular by Lineto, customized for Spotify) with an extensive fallback stack that includes Arabic, Hebrew, Cyrillic, Greek, Devanagari, and CJK fonts, reflecting Spotify's global reach. The type system is compact and functional: 700 (bold) for emphasis and navigation, 600 (semibold) for secondary emphasis, and 400 (regular) for body. Buttons use uppercase with positive letter-spacing (1.4px–2px) for a systematic, label-like quality.

What distinguishes Spotify is its pill-and-circle geometry. Primary buttons use 500px–9999px radius (full pill), circular play buttons use 50% radius, and search inputs are 500px pills. Combined with heavy shadows (`rgba(0,0,0,0.5) 0px 8px 24px`) on elevated elements and a unique inset border-shadow combo (`rgb(18,18,18) 0px 1px 0px, rgb(124,124,124) 0px 0px 0px 1px inset`), the result is an interface that feels like a premium audio device — tactile, rounded, and built for touch.

**Key Characteristics:**
- Near-black immersive dark theme (`#121212`–`#1f1f1f`) — UI disappears behind content
- Spotify Green (`#1ed760`) as singular brand accent — never decorative, always functional
- SpotifyMixUI/CircularSp font family with global script support
- Pill buttons (500px–9999px) and circular controls (50%) — rounded, touch-optimized
- Uppercase button labels with wide letter-spacing (1.4px–2px)
- Heavy shadows on elevated elements (`rgba(0,0,0,0.5) 0px 8px 24px`)
- Semantic colors: negative red (`#f3727f`), warning orange (`#ffa42b`), announcement blue (`#539df5`)
- Album art as the primary color source — the UI is achromatic by design


Core tokens: {}
Fonts: []
Layout: - Sidebar (fixed) + main content area
- Grid-based album/playlist cards
- Full-width now-playing bar at bottom
- Responsive content area fills remaining space

## 7. Do's and Don'ts

### Do
- Use near-black backgrounds (`#121212`–`#1f1f1f`) — depth through shade variation
- Apply Spotify Green (`#1ed760`) only for play controls, active states, and primary CTAs
- Use pill shape (500px–9999px) for all buttons — circular (50%) for play controls
- Apply uppercase + wide letter-spacing (1.4px–2px) on button labels
- Keep typography compact (10px–24px range) — this is an app, not a magazine
- Use heavy shadows (`0.3–0.5 opacity`) for elevated elements on dark backgrounds
- Let album art provide color — the UI itself is achromatic

### Don't
- Don't use Spotify Green decoratively or on backgrounds — it's functional only
- Don't use light backgrounds for primary surfaces — the dark immersion is core
- Don't skip the pill/circle geometry on buttons — square buttons break the identity
- Don't use thin/subtle shadows — on dark backgrounds, shadows need to be heavy to be visible
- Don't add additional brand colors — green + achromatic grays is the complete palette
- Don't use relaxed line-heights — Spotify's typography is compact and dense
- Don't expose raw gray borders — use shadow-based or inset borders instead



## starbucks
## 1. Visual Theme & Atmosphere

Starbucks' design system is a **warm, confident retail flagship** wearing the green of their storefront apron across every surface. The canvas alternates between a neutral-warm cream (`#f2f0eb`) and a ceramic off-white (`#edebe9`) — colors that reference actual store materials: the paper napkins, the café walls, the wood finishes — while the signature **Starbucks Green** (`#006241`) anchors the brand moment on hero bands, CTAs, and the Rewards experience. The greens come in four calibrated shades (Starbucks, Accent, House, Uplift) each mapped to a specific surface role, and gold (`#cba258`) appears only around Rewards-status ceremony — not as a general accent.

Typography carries most of the brand voice. The proprietary **SoDoSans** typeface (custom to Starbucks) sits across nearly every surface with a tight `-0.16px` letter-spacing — it reads confident and friendly rather than fashion-magazine severe. What's unusual: the Rewards page switches to a warm serif (`"Lander Tall", "Iowan Old Style", Georgia`) for specific headline moments, subtly echoing the nostalgic feel of a coffeehouse chalkboard. And the Careers pages use a handwritten script (`"Kalam", "Comic Sans MS", cursive`) for personal cup-name touches. Three typefaces, three contexts — the system is disciplined about when each appears.

The surfaces breathe through rounded geometry. Every button is a 50px full-pill. Cards take a 12px rounded-rectangle. The "Frap" floating CTA — a 56px circular order button in Green Accent (`#00754A`) — is the product's signature depth move: it floats bottom-right with a layered shadow stack (`0 0 6px rgba(0,0,0,0.24)` base + `0 8px 12px rgba(0,0,0,0.14)` ambient) and compresses via `scale(0.95)` on press. Elevations are otherwise restrained — card shadows stay at a whispered `0.14/0.24` alpha, global nav gets a quiet three-layer shadow stack. The whole system feels like clean café signage: legible, warm, and never shouting.

**Key Characteristics:**
- Four-tier green brand system (Starbucks / Accent / House / Uplift) each mapped to a distinct surface role — not a single "brand green"
- Gold reserved for Rewards-status moments only; never a general-purpose accent
- Warm-neutral canvas (`#f2f0eb` / `#edebe9`) instead of cold white — references café materials
- Custom proprietary typeface (SoDoSans) with tight `-0.16px` letter-spacing as the universal voice
- Context-specific type switches: serif (Lander Tall) for Rewards, script (Kalam) for Careers cup-names
- Full-pill buttons (`50px` radius) universal, `scale(0.95)` active press the signature micro-interaction
- Floating "Frap" circular CTA (`56px`, Green Accent fill, layered shadow stack) — the product's signature elevation element
- Gift-card surfaces designed as **photographed physical product** — every card is a distinct illustrated photograph rather than a generated graphic
- 12px card radius + whisper-soft shadows keep content cards flat-plus-hint-of-lift
- Rem-based spacing scale anchored at 1.6rem (~16px) = `--space-3`, stepping to 6.4rem (~64px)

**Color-block page rhythm:** Cream hero → White content sections → Dark-green (`#1E3932`) feature band with white text → Cream utility zone → Dark-green (`#1E3932`) footer with gold / white text — an espresso-dark bookend around the bright body.


Core tokens: {}
Fonts: []
Layout: 
- Column width scale: `--columnWidthSmall: 343px` / `Medium: 500px` / `Large: 720px` / `XLarge: 1440px`
- Gift-card grid uses a 3-5-up responsive grid of `~343px` tiles
- Rewards status section: 3-up dark-green panels at `lg+` breakpoints
- Hero: asymmetric split 40% (image) / 60% (content) via `--headerCrateProportion` / `--contentCrateProportion`

## 7. Do's and Don'ts

### Do
- Use Neutral Warm (`#f2f0eb`) or Ceramic (`#edebe9`) as page canvas instead of pure white — the warm cream is the signature
- Map the green tiers to their intended surface role — Starbucks Green for headings, Green Accent for CTAs, House Green for deep bands, Uplift for decorative
- Keep tracking tight at `-0.01em` / `-0.16px` on SoDoSans across the whole system
- Use 50px full-pill radius on every button without exception
- Apply `transform: scale(0.95)` as the universal button active state
- Reserve Gold for Rewards-status ceremony moments only
- Use SoDoSans for nearly everything; switch to Lander Tall serif only for Rewards editorial headlines; reserve Kalam script for Careers "cup name" moments
- Layer 2–3 low-alpha shadows instead of one heavier drop shadow for elevation
- Use the Frap circular CTA as the persistent floating order entry on every shopping surface
- Let the cream canvas breathe between content cards — use whitespace, not dividers

### Don't
- Don't use pure white as the page canvas — the warm cream temperature is load-bearing
- Don't pick "one brand green" — the four-green system is intentional; using only `#006241` everywhere flattens the brand
- Don't use Gold as a general-purpose accent — it's a Rewards signal only
- Don't square the corners on buttons — the 50px pill is universal
- Don't introduce gradient fills — the system is color-block throughout
- Don't weight-contrast h1 and h2 by size — the hierarchy comes from weight + color (600 Starbucks-Green vs 400 Text Black)
- Don't use pure black for body text — `rgba(0,0,0,0.87)` matches the warm canvas
- Don't skip the `scale(0.95)` active feedback on buttons — it's a signature micro-interaction
- Don't stack single heavy shadows; always layer 2–3 low-alpha ones
- Don't introduce serifs or scripts into the main shopping flow — they belong to Rewards and Careers contexts respectively



## stripe
An inspired interpretation of Stripi's design language — a financial-infrastructure brand built on a deep navy ink, an electric indigo primary, and a recurring atmospheric gradient mesh that occupies the upper third of nearly every marketing page. The system pairs the proprietary Sohne family at thin (300) weights with negative letter-spacing for editorial-density display headlines, and uses tabular-figure body type where money and numerics matter. Buttons are tight-radius pills, cards live on near-white surfaces, and the dashboard track flips polarity to a familiar dark-app shell.
Core tokens: {"primary": "#533afd", "primary-deep": "#4434d4", "primary-press": "#2e2b8c", "primary-soft": "#665efd", "primary-bg-subdued-hover": "#b9b9f9", "ink": "#0d253d", "ink-secondary": "#273951", "ink-mute": "#64748d", "ink-mute-2": "#61718a", "on-primary": "#ffffff", "canvas": "#ffffff", "canvas-soft": "#f6f9fc", "canvas-cream": "#f5e9d4", "hairline": "#e3e8ee", "hairline-input": "#a8c3de"}
Fonts: ["sohne-var, 'SF Pro Display', system-ui, -apple-system, sans-serif"]
Layout: - Marketing pages center in a ~1200px container with the gradient mesh extending edge-to-edge above.
- Pricing collapses 4-up → 2-up → 1-up at 1024 / 768 breakpoints.
- Dashboard product mockups use their own internal grids (12-col tables, 3-col card grids) rendered as static composites.

## Do's and Don'ts

### Do
- Reserve `primary` for filled CTAs and inline link emphasis — it should appear sparingly, one filled button per band.
- Apply the gradient mesh to every marketing hero; bare-canvas heroes feel off-brand.
- Render display tiers at weight 300 with negative letter-spacing — the thin tracking is the typographic signature.
- Use `font-feature-settings: "tnum"` on every money / numeric cell.
- Apply `font-feature-settings: "ss01"` globally on the body element.
- Pair every feature explanation with a composited product UI mockup; the brand's argument is "look at the actual product."

### Don't
- Don't bump display weight above 300 — at 400 the brand's editorial air collapses.
- Don't add new accent colors outside the documented gradient stops (cream / orange / lavender / indigo / ruby / magenta).
- Don't use the indigo `primary` as a body-text color — it's a CTA and link color, not a type color at body size.
- Don't shrink button padding below `8px 16px` — the tight pill is part of the brand's transactional feel.
- Don't render money cells without `tnum` — it breaks the quiet financial-data signature.
- Don't replace the pill shape with rounded-rectangles for buttons.



## supabase

Core tokens: {}
Fonts: []
Layout: - Marketing pages center in a ~1280px container with no edge-bleed; the brand keeps content inside the box.
- Pricing collapses 4-up → 2-up → 1-up at 1024 / 768 breakpoints.
- Product UI mockups stack 2-up or render as overlapping panes inside the same container.

## Do's and Don'ts

### Do
- Reserve `primary` emerald for filled CTAs and the wordmark accent — it should appear sparingly.
- Render display tiers at weight 500 with negative letter-spacing — the engineered tightness is part of the brand.
- Use `sm` 6px for buttons — square-ish radii, never pill-shaped.
- Composite product UI mockups inside `lg` containers with subtle Level 2 shadows.
- Use near-black `ink` on the emerald button (not white) — the green reads as "lit" with dark type, which is the brand's idiosyncratic choice.
- Apply system mono for every code block.

### Don't
- Don't introduce additional accent colors as system colors — purples, yellows, and pinks belong inside chart points and integration logos only.
- Don't bump display weight above 500 — the brand's calibrated mid-weight breaks at 600+.
- Don't use pill-shaped buttons; the brand's button radius is square-ish 6px.
- Don't use white text on the emerald button — the brand specifically uses near-black on green.
- Don't add atmospheric gradients to hero bands — the white canvas is the design.



## superhuman
An inspired interpretation of Superhumon's design language — a fast-email productivity brand split between an editorial dark hero (deep indigo navy with violet-sky atmospheric backdrop and a portrait subject) and a quiet white content body with off-warm-grey ink. The system uses a single proprietary variable display sans, heavy weight 460–540 with tight tracking, and a deep-teal closing CTA band that breaks the indigo/white rhythm with a warm dark interlude. Buttons are tight rounded rectangles, pricing is sober and dense, and the brand reads more like a high-end newsletter than a SaaS app.
Core tokens: {"primary": "#1b1938", "primary-deep": "#0e0c1f", "on-primary": "#ffffff", "ink": "#292827", "ink-mute": "#73706d", "ink-faint": "#9a9794", "canvas": "#ffffff", "canvas-soft": "#fafaf8", "surface-violet-soft": "#c9b4fa", "surface-teal-deep": "#0e3030", "surface-teal-mid": "#155555", "hairline": "#e8e4dd", "hairline-dark": "#3f3a52"}
Fonts: ["'Super Sans VF', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif"]
Layout: - Hero spans full viewport width with the violet-sky backdrop edge-to-edge; content centers in a ~960px column.
- Body content centers in ~960–1100px.
- Pricing collapses 3-up → 2-up → 1-up at 1024 / 768 breakpoints.

## Do's and Don'ts

### Do
- Pair every hero with the violet-sky atmospheric backdrop and a half-bleed portrait subject when possible.
- Render display tiers at sub-default weights (460 / 540) — the warmth is the typographic signature.
- Use rounded-rectangle CTAs at 8px radius everywhere except the hero (where pill-shaped is the rule).
- Close every marketing page with a deep-teal CTA band.
- Use warm dark grey `ink` for body text — never pure black.
- Apply tight 0.96 line-height on display sizes; the editorial compression is the brand.

### Don't
- Don't use pill-shaped buttons in the body of the page; the pill is hero-only.
- Don't bump display weight above 540 unless using `body-strong` (700) for emphasized inline body.
- Don't render body text in pure black — the warm grey `#292827` is part of the brand.
- Don't omit the closing teal band — every marketing page closes with it.
- Don't introduce additional accent colors beyond indigo, violet-soft, teal, and the off-warm-greys.



## tesla
## 1. Visual Theme & Atmosphere

Tesla's website is an exercise in radical subtraction — a digital showroom where the product is everything and the interface is almost nothing. The page opens with a full-viewport hero that fills the entire screen with cinematic car photography: three vehicles arranged on polished concrete against a hazy cityscape sky, with a single model name floating above in translucent white type. There are no decorative borders, no gradients, no patterns, no shadows. The UI exists only to provide just enough navigational structure to get out of the way. Every pixel that isn't product imagery is white space, and that restraint is the design system's most powerful statement.

The color philosophy is almost ascetic: a single blue (`#3E6AE1`) for primary calls to action, three shades of dark gray for text hierarchy, and white for everything else. The entire emotional weight is carried by photography — sprawling landscape shots, studio-lit vehicle profiles, and atmospheric environmental compositions that stretch edge-to-edge across each viewport-height section. The UI chrome dissolves into the imagery. The navigation bar floats above the hero with no visible background, border, or shadow — the TESLA wordmark and five navigation labels simply exist in the space, trusting the content beneath them to provide sufficient contrast.

Typography recently transitioned from Gotham to Universal Sans — a custom family split into "Display" for headlines and "Text" for body/UI elements — unifying the website, mobile app, and in-car software into a single typographic voice. The Display variant renders hero titles at 40px weight 500, while the Text variant handles everything from navigation (14px/500) to body copy (14px/400). The font carries a geometric precision with slightly humanist terminals that feels engineered rather than designed — exactly matching Tesla's brand identity of technology that doesn't need to announce itself. There are no text shadows, no text gradients, no decorative type treatments. Every letterform earns its place through clarity alone.

**Key Characteristics:**
- Full-viewport hero sections (100vh) dominated by cinematic car photography with minimal overlay UI
- Near-zero UI decoration: no shadows, no gradients, no borders, no patterns anywhere on the page
- Single accent color — Electric Blue (`#3E6AE1`) — used exclusively for primary CTA buttons
- Universal Sans font family (Display + Text) unifying web, app, and in-car interfaces
- Photography-first presentation where product imagery carries all emotional weight
- Frosted-glass navigation concept with transparent/white nav that floats over hero content
- 0.33s cubic-bezier transitions as the universal timing for all interactive state changes
- Carousel-driven hero with dot indicators and edge arrow navigation for multiple vehicle showcases
- "Ask a Question" persistent chatbot bar anchored to the viewport bottom


Core tokens: {}
Fonts: []
Layout: - **Max width**: approximately 1383px (full viewport width used for most content)
- **Hero**: Full-bleed, edge-to-edge, 100vh sections
- **Navigation panel**: 3-column grid for vehicle cards with right-aligned text sidebar (~70/30 split)
- **Category cards**: 2-up horizontal layout (large left card + smaller right card)

## 7. Do's and Don'ts

### Do
- Let photography dominate every screen — the product IS the design
- Use Electric Blue (`#3E6AE1`) exclusively for primary CTAs — never for decorative purposes
- Maintain viewport-height sections for major content blocks — one message per screen
- Keep typography at weight 400-500 only — no bold, no light, no extremes
- Use 4px border-radius for all interactive elements — precision over playfulness
- Trust whitespace as a luxury signal — never fill available space just because it's empty
- Keep all transitions at 0.33s — consistency in motion is as important as consistency in color
- Use transparent PNG vehicle imagery on white backgrounds for product showcases
- Center CTAs horizontally below model names — the vertical rhythm is model → subtitle → buttons
- Maintain the Display/Text font split — Display for hero-scale text only, Text for everything else

### Don't
- Add shadows to any element — elevation through shadow contradicts the flat, gallery aesthetic
- Use more than one chromatic color besides the blue CTA — the palette is intentionally monochrome-plus-one
- Apply gradients, patterns, or decorative backgrounds to surfaces — white and photography are the only backgrounds
- Use text larger than 40px on the web — the typography is deliberately restrained even at hero scale
- Add borders to cards or containers — separation is achieved through spacing, not lines
- Use uppercase text transforms — Tesla's confidence is expressed through lowercase calm
- Introduce rounded-pill buttons or large border-radii — the 4px radius is deliberate and precise
- Override the Universal Sans family with other typefaces — cross-platform consistency is a core brand value
- Add hover animations with scale/translate transforms — Tesla's interactions are color-only (background and border transitions)
- Clutter the viewport with multiple CTAs — every screen should have at most two action buttons



## theverge
## 1. Visual Theme & Atmosphere

The Verge's 2024 redesign feels like somebody wired a Condé Nast magazine to a chiptune soundboard. The canvas is almost-black (`#131313`), the headlines are built from a brutally heavy display face (Manuka) that runs up to 107px, and the whole page is peppered with acid-mint `#3cffd0` and ultraviolet `#5200ff` that behave less like brand colors and more like hazard tape. Story tiles are not quiet gray cards — they're saturated, full-bleed color blocks (yellow, pink, orange, blue, purple) that feel like pasted-up rave flyers arranged into a timeline. The mood is "developer console meets club night meets tech tabloid": serious enough to cover a congressional hearing, loud enough to review a synthesizer.

What makes this system unmistakable is the **StoryStream** timeline: a vertical feed where every post is a rounded rectangle — often 20–40px radius — filled edge-to-edge with color, framed by a thin border, and marked by a mono-uppercase timestamp on its left rail. Stories don't float on a grid; they stack on a dashed vertical rule like commits in a git log. Above that, a massive **"The Verge" wordmark** dominates the masthead in Manuka at hero scale, letting the reader know before any headline loads that this is editorial territory, not a template.

There is no "light mode" on the homepage — the dark canvas is the product, and the only time the palette inverts is when a single story tile takes a mint or yellow fill. The depth is almost entirely flat: **hairline 1px borders** (`#ffffff`, `#3cffd0`, or `#5200ff`) do the work that shadows would do on a Material-flavored site. Every container is either `#131313` with a 1px outline, a fully saturated accent block, or a slate-gray `#2d2d2d` secondary surface.

**Key Characteristics:**
- Near-black editorial canvas (`#131313`) as the default surface — no light mode on the homepage
- Acid-mint `#3cffd0` + ultraviolet `#5200ff` as hazard-tape accents, never quiet background wash
- Massive Manuka display headlines up to 107px — the single loudest type move in mainstream tech media
- Rounded pill-card everything: 20/24/30/40px corner radii, never square
- Fully saturated color-block story tiles (mint, purple, yellow, pink, orange, electric blue) on a dark page
- Timeline "StoryStream" feed with mono uppercase timestamps rather than a traditional magazine grid
- Flat depth — 1px borders in white, mint, purple do the work that shadows would do elsewhere


Core tokens: {}
Fonts: []
Layout: - **Max width**: ~1280–1300px (dembrandt detected breakpoints at 1200/1280/1300).
- **Column patterns**: a 12-column underlying grid that resolves into 3-column hero + 1-column StoryStream rail + feature panels. The homepage feels freeform because color-block tiles frequently span 2–3 columns on a whim.
- **Container padding**: 24px mobile / 48px desktop on the outer edges.
- **Gutters**: 16–24px between columns, tighter (8–12px) inside StoryStream items.

## 7. Do's and Don'ts

### Do
- **Do** use `#131313` as the canvas for every view. There is no light mode.
- **Do** use Jelly Mint (`#3cffd0`) and Verge Ultraviolet (`#5200ff`) as hazard accents — buttons, borders, active states, and saturated color-block tiles.
- **Do** use Manuka exclusively at 60px+ for hero headlines. Treat anything smaller as a bug.
- **Do** round everything: 20px for cards, 24px for feature cards, 30–40px for pill buttons.
- **Do** use PolySans Mono for UPPERCASE labels, timestamps, kickers, and button text. Lowercase mono doesn't exist here.
- **Do** apply 1.5–1.9px letter-spacing to every ALL-CAPS label — this is a Verge signature.
- **Do** use saturated color-block tiles (mint, purple, yellow, pink, orange, white) to elevate a story — never a drop shadow.
- **Do** use `#3860be` (deep link blue) as the hover color on every link, regardless of base color.
- **Do** apply the StoryStream timeline rail (1px dashed/solid `#3d00bf` or white) on feed views.
- **Do** use thin-weight (300) PolySans at 19–20px with 1.9px tracking for "fashion-whisper" capitalized eyebrows — the contrast with the 107px Manuka shout is the whole voice.

### Don't
- **Don't** use a light background. The dark canvas is the product.
- **Don't** add `box-shadow` for elevation. Use 1px borders or saturated accent fills instead.
- **Don't** use square corners. Every interactive and content container is rounded.
- **Don't** use Manuka for UI, buttons, or body copy. It's strictly display.
- **Don't** use lowercase mono. PolySans Mono is always UPPERCASE.
- **Don't** let mint and ultraviolet appear as background washes — they're hazard accents, not canvas tints.
- **Don't** use gradients anywhere. The system is solid color blocks only.
- **Don't** introduce new accent colors outside the declared mint / purple / yellow / pink / orange tile palette.
- **Don't** pair Manuka with FK Roman Standard in the same headline cluster — Manuka is the only display shout, serif pulls are reserved for body moments.
- **Don't** use `#3cffd0` text on a `#131313` background at under 16px — the contrast vibrates at small sizes.



## together.ai
An inspired interpretation of Together AI's design language — an AI infrastructure platform whose surface alternates between near-black hero bands (with a three-color orange-magenta-periwinkle gradient as the single piece of brand chrome) and bright white research / pricing / docs bands, knit together by a custom display sans and an uppercase mono eyebrow face.
Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#000000", "hairline": "#959494", "canvas": "#ffffff", "canvas-dark": "#010120", "surface-dark-soft": "#313641", "accent-periwinkle": "#bdbbff"}
Fonts: ['The Future, Inter, Helvetica Neue, Arial, sans-serif', 'PP Neue Montreal Mono, ui-monospace, SF Mono, Menlo, monospace']
Layout: - **Max width**: ~1280 px desktop container; nothing rendered above that. Content centres with horizontal gutters of `3xl` 32 px on desktop, `lg` 16 px on mobile.
- **Column patterns**:
  - Research / testimonial grids: 3-up at desktop, 1-up at mobile.
  - Stats tile grid: 3-up at desktop, 1-up at mobile.
  - Article-card grid: 2-up at desktop, 1-up at mobile.
  - Pricing data table: full-width, model rows stack on mobile.
  - Hero: 50 / 50 split (headline left, ribbon graphic right) at desktop; stacked at mobile with graphic above.

## Do's and Don'ts

### Do
- Reserve `primary` (`#000000`) for every primary CTA. One black pill per visible viewport — that consistency is the brand's whole conversion story.
- Set every section eyebrow and button label in `mono-caps-button` / `mono-caps-eyebrow` — uppercase mono, positive tracking.
- Pair the brand gradient (`accent-orange` → `accent-magenta` → `accent-periwinkle`) at hero scale only. The gradient is the brand chrome; never shrink to icon size.
- Cycle page surfaces in the `canvas-dark` → `canvas` → `canvas-dark` rhythm; the dark-light contrast carries elevation more than any shadow.
- Use `sm` 4 px as the canonical card / button radius across the system; reserve `full` for the single floating chat-launcher orb.
- Render the giant `together.ai` wordmark banner at the bottom of every long page in `display-xxl`, tinted toward `hairline` so it reads as a stencil — not as a heavy footer title.

### Don't
- Don't introduce a fifth accent colour. The three-stop gradient + mint pill is the entire decorative palette; new accents flatten the brand.
- Don't set body paragraphs in the mono face. The mono is for labels only; long-form mono reads as a console log, not as marketing copy.
- Don't centre-align body paragraphs under a left-aligned display headline. The brand keeps text-block alignment consistent within a copy stack.
- Don't drop a soft drop-shadow on light-surface cards. The brand uses hairlines and surface contrast for elevation; soft shadows belong only on the floating chat-launcher orb.
- Don't reduce the brand gradient to a single-colour fill, reorder its stops, or add a fourth stop. The gradient is a fixed object.
- Don't switch the primary button shape to a full pill `full`. The brand's CTA shape is a slightly-rounded rectangle, never a full pill.
- Don't set headlines in the all-caps mono. Every all-caps moment belongs to the mono face; every headline belongs to the display sans in sentence case.


## uber
An inspired interpretation of Uber's design language — a transportation-and-delivery super-app brand whose web surface is a black-and-white duet, framed by a custom geometric display sans, accented by a single signature pill shape (radius 999px) on every interactive element, and decorated only by editorial 4:3 illustrations of riders, drivers, and city objects.
Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#000000", "hairline-mid": "#4b4b4b", "canvas": "#ffffff", "canvas-soft": "#efefef", "canvas-softer": "#f3f3f3", "surface-pressed": "#e2e2e2", "link": "#0000ee"}
Fonts: ['UberMove, UberMoveText, system-ui, Helvetica Neue, Arial, sans-serif', 'UberMoveText, system-ui, Helvetica Neue, Arial, sans-serif']
Layout: - **Max width**: ~1200 px container; centred with horizontal gutters of `3xl` 32 px on desktop, `lg` 16 px on mobile.
- **Column patterns**:
  - Promo-card rows: 2-up at desktop (image left + content right, alternating sides), 1-up at mobile.
  - Category chips: horizontal flex with wrap.
  - FAQ rows: full-width single-column.
  - App-download pills: 2-up at desktop (Rider + Driver), 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (`#000000`) for every primary CTA pill. One black pill per visible viewport is the brand's whole conversion story.
- Use `pill` 999 px on every interactive element (buttons, chips, app pills). The pill IS the brand's geometric signature.
- Render cards in `xl` 16 px — promo cards, content cards, the ride-request form card, the annual-showcase card all share this radius.
- Set every headline in `display-*` weight 700 in sentence-case. The display face never carries body copy.
- Use polarity-flipped black promo bands mid-page to break up white-on-white rhythm. The polarity shift IS the depth cue.
- Anchor every promo card with a 4:3 editorial illustration; never use generic stock imagery.

### Don't
- Don't introduce a second brand accent colour (orange, blue, green). The brand's entire UI is black-and-white plus grayscale; new accents flatten the system.
- Don't render the primary CTA as a `xl` rectangle except inside the larger ride-request flow (where `button-large-rounded` is the documented exception).
- Don't use all-caps display headlines. Sentence-case is the voice; uppercase is restricted to rare eyebrow tags.
- Don't drop a soft drop-shadow on every card. The brand uses Level 0 flat as the default; shadow is reserved for the floating pill and the ride-request form.
- Don't reduce the brand to its illustration system alone. The pill geometry + black/white duet carries the brand even without illustrations.
- Don't tighten or loosen letter-spacing on the display face. The brand never letter-spaces; default tracking is part of the voice.
- Don't use `full` 9999 px for square cards — the pill 999 px and full 9999 px effects are identical for interactive elements, but cards stay at `xl` 16 px.


## vercel
An inspired interpretation of Vercel's design language — a developer-platform brand whose surface is a stark black-and-ink duet on near-white canvas, broken at hero scale by a multi-color mesh gradient (cyan / blue / magenta / amber) that acts as the entire decorative system, paired with a custom geometric sans for headlines and a monospaced caption face for technical labels.
Core tokens: {"primary": "#171717", "on-primary": "#ffffff", "ink": "#171717", "hairline": "#ebebeb", "hairline-strong": "#a1a1a1", "canvas": "#ffffff", "canvas-soft": "#fafafa", "canvas-soft-2": "#f5f5f5", "link": "#0070f3", "link-deep": "#0761d1", "link-bg-soft": "#d3e5ff", "highlight-pink": "#ff0080"}
Fonts: ['Geist, Inter, system-ui, -apple-system, sans-serif', 'Geist Mono, ui-monospace, SFMono-Regular, Menlo, Monaco, monospace']
Layout: - **Max width**: ~1400 px (`--ds-page-width`); the legacy `--geist-page-width` is 1200 px and still appears on some marketing surfaces. Content centres with horizontal gutters of `lg` 24 px on desktop, `md` 16 px on mobile.
- **Column patterns**:
  - Three-feature row: 3-up at desktop, 1-up at mobile (rows like "Web Apps / Composable Commerce / Multi-tenant Platforms").
  - Tab pill row: 5-up centred row of `tab-ghost` pills.
  - Template-grid cluster: 5-up at desktop, scaling to 1-up at mobile.
  - Pricing tier grid: 3-up at desktop with the middle tier polarity-flipped.
  - Logo strip: ~5 logos wide, single row.

## Do's and Don'ts

### Do
- Reserve `primary` (`#171717`) for primary CTAs across the page. Black ink IS the conversion target.
- Use `pill` 100 px for every marketing-scale CTA and `sm` 6 px for nav-scale buttons. The two pill scales coexist deliberately.
- Set every headline in `display-*` weight 600, sentence-case, often period-terminated. Aggressive negative tracking is part of the voice.
- Use the brand mesh gradient as atmospheric decoration at hero scale only — never miniaturise it to an icon, never reduce to a single colour.
- Layer stacked shadows (multiple small offsets with inset hairline) rather than single heavy drops. The brand's elevation is calmer than Material.
- Cycle page surfaces in `canvas-soft` → `canvas` → `primary` polarity-flipped bands; the dark band IS the depth cue.
- Set every code block and technical eyebrow in `code` / `caption-mono`. Mono is the voice of the platform.

### Don't
- Don't introduce a sixth accent colour. The brand operates with ink + gray + the four-pair gradient palette; new accents flatten the voice.
- Don't render headlines in all-caps. Sentence-case + negative tracking is non-negotiable.
- Don't drop a single heavy drop-shadow on cards. The brand's elevation is built from stacked small offsets + inset hairline rings.
- Don't render the brand gradient at icon scale or in a single-colour reduced form. The gradient lives at hero scale only.
- Don't promote the geometric sans to weight 700. The brand's display ceiling is 600.
- Don't pair the marketing 100-px pill CTA shape with the 6-px nav radius on the same screen — pick a scale and stay there.
- Don't set body paragraphs in the mono face. The mono is for code + technical labels only.


## vodafone
An inspired interpretation of Vodafone's design language — a telecom super-brand whose web surface alternates between editorial photography hero bands with massive uppercase display headlines and clean white content bands, anchored by the company's signature scarlet red CTA and the proprietary Vodafone display sans set at impossibly heavy 800 weight.
Core tokens: {"primary": "#e60000", "on-primary": "#ffffff", "ink": "#25282b", "canvas": "#ffffff", "canvas-soft": "#f2f2f2"}
Fonts: ['Vodafone, Vodafone Rg, Helvetica Neue, Arial, sans-serif']
Layout: - Marketing content uses a wide container (effectively edge-to-edge with `3xl` gutters on desktop, shrinking on mobile).
- Story-card grids: 2-up at desktop, 1-up at mobile.
- Hero photography fills the viewport; the headline overlays at the top-left.

## Do's and Don'ts

### Do
- Reserve `primary` Vodafone Red for primary CTAs and the `speechmark-logo-orb`. Every conversion target uses the red pill.
- Set hero headlines in `display-hero` weight 800 UPPERCASE with tight `-1px` tracking. That stencil look IS the brand voice.
- Use `pill-lg` 60 px on every interactive pill. The brand never uses square corners on CTAs.
- Cycle page surfaces in `ink` dark hero → `canvas` light content → `ink` footer. Surface contrast is the depth cue.
- Pair editorial portrait photography with the massive display headline overlay — that combination IS the brand's signature.
- Render the speechmark logo orb at consistent size relative to surrounding content — it's the brand's centre of gravity on every page.

### Don't
- Don't introduce a second accent colour. The brand operates with red + ink + grayscale only.
- Don't render headlines in sentence case at hero scale. Hero display IS uppercase weight 800.
- Don't render the primary CTA as a square rectangle. The 60 px pill is non-negotiable.
- Don't drop a soft drop-shadow on cards. The brand relies on surface-colour contrast, not shadow.
- Don't substitute the speechmark logo orb with a wordmark or a different shape. The orb is the iconic mark.
- Don't pair the weight 800 display face with letter-spacing 0 at 144 px — the `-1px` tracking is part of the brand's calibration.


## voltagent
An inspired interpretation of Voltagent's design language — a developer-focused AI agent engineering platform whose surface is an unrelenting near-black canvas broken only by a single electric-green brand accent, code-editor mockups inside the hero, and a precise grid of dark feature cards that read like a documentation site dressed as marketing.
Core tokens: {"primary": "#00d992", "primary-soft": "#2fd6a1", "primary-deep": "#10b981", "on-primary": "#101010", "ink": "#f2f2f2", "ink-strong": "#ffffff", "hairline": "#3d3a39", "hairline-soft": "#b8b3b0", "canvas": "#101010", "canvas-soft": "#1a1a1a", "canvas-text-soft": "#f5f6f7"}
Fonts: ['Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif', 'Inter, system-ui, -apple-system, sans-serif', 'SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace', 'SFMono-Regular, Menlo, Monaco, Consolas, monospace']
Layout: - Marketing container centres at roughly 1200 – 1400 px; content stays edge-to-edge in colour with horizontal gutters of `3xl` on desktop.
- Feature-card grids: 2-up to 3-up at desktop, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (`#00d992`) for every primary CTA, the lightning logo glyph, and live-status indicators. The green is the brand's centre of gravity.
- Use the dark `canvas` (`#101010`) as the only page surface. There is no light-mode rhythm.
- Build cards with 1 px `hairline` borders, not shadows. Hairlines on dark IS the brand's elevation system.
- Pair Inter (sentence-case) with SF Mono (inline code, command snippets). Every uppercase moment uses Inter at weight 600 with `2.52 px` tracking — not a separate mono.
- Use `sm` 6 px for buttons, `md` 8 px for cards, `pill` 9999 px only for inline status tags.

### Don't
- Don't introduce a light-mode counterpart. The brand is dark-canvas only.
- Don't use the primary green as a body-text fill. It's CTA-only.
- Don't drop a soft drop-shadow on cards. The brand uses hairlines + occasional glow, never material shadows.
- Don't render the hero headline in heavy weight (700+). The brand's display is intentionally calm at weight 400.
- Don't replace Inter or SF Mono with a different family — both faces are part of the brand's voice and pairing.


## warp
An inspired interpretation of Warp's design language — an agentic terminal-and-development-environment brand whose surface is a warm near-charcoal canvas (a tint warmer than pure black), broken only by clean Inter typography, the occasional Instrument Serif italic moment, and dense terminal-mockup imagery; CTAs are unusually understated, with shape geometry running tighter than most marketing sites.
Core tokens: {"primary": "#f7f5f0", "on-primary": "#2b2622", "ink": "#f7f5f0", "canvas": "#2b2622", "canvas-soft": "#383330", "hairline": "#3f3a36"}
Fonts: ['Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif', 'Inter, system-ui, -apple-system, sans-serif', 'Instrument Serif, Georgia, "Times New Roman", serif', 'DM Mono, ui-monospace, SFMono-Regular, Menlo, monospace']
Layout: - Marketing content centres at roughly 1200 px width.
- Hero: 2-column at desktop (split between two terminal screenshots), stacks at mobile.
- Partner logos: 5-up wrapping flex row.
- Download tiles: 3-up at desktop (Mac / Linux / Windows), 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` off-white for primary CTA pills and default text. There is no chromatic accent.
- Use tight `sm` 3 px or `md` 4 px button radii. The brand never uses generous pills for CTAs.
- Set hero headlines in Inter weight 400 with `-1.6 px` tracking. The brand reads as quietly confident.
- Pair Inter (sentence-case) with DM Mono (code blocks, terminal mockups).
- Keep the warm-dark canvas tone — pure black breaks the brand's identity.

### Don't
- Don't introduce a chromatic brand accent. The off-white-on-warm-dark IS the brand's voice.
- Don't render the hero headline in heavy weight (700+). The brand's display is intentionally light.
- Don't use generous pill CTAs. The brand's button radius is 3-4 px, almost rectangular.
- Don't replace the warm dark canvas with neutral gray or pure black. The warmth IS the brand.
- Don't drop a soft drop-shadow on cards. Hairlines + surface contrast carry elevation.


## webflow
An inspired interpretation of Webflow's design language — a visual web development platform whose surface contrasts a deep near-black `#080808` primary against a generous white canvas, broken by a five-stop chromatic accent system (purple / pink / blue / orange / green) that maps to the brand's product categories, and anchored by the proprietary WF Visual Sans family used at restrained 500 / 600 weights with negative tracking.
Core tokens: {"primary": "#080808", "on-primary": "#ffffff", "ink": "#080808", "ink-strong": "#222222", "hairline": "#d8d8d8", "canvas": "#ffffff", "accent-pink": "#ed52cb"}
Fonts: ['WF Visual Sans Variable, Inter, system-ui, -apple-system, sans-serif', 'WF Visual Sans Variable, Inter, system-ui, sans-serif', 'WFVisualSans-Mono, Inconsolata, ui-monospace, SFMono-Regular, Menlo, monospace']
Layout: - Marketing container is wide (effectively edge-to-edge with `3xl` gutters).
- Category card grid: 2 / 3-up at desktop with mixed sizing (some larger feature cards span 2 columns).
- Pricing tier grid: 3-up at desktop, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `primary` (`#080808`) for every primary CTA, every heading, and every wordmark. Near-black is the conversion colour.
- Use the five chromatic accents (purple / pink / blue / orange / green) as full-fill category cards, NOT as button backgrounds.
- Set hero headlines in `display-xxl` weight 600 with `-0.8 px` tracking.
- Pair the proprietary WF Visual Sans family across every typographic role.
- Use `sm` 4 px for buttons, `md` 8 px for cards. The brand never uses pill CTAs.
- Use layered multi-stop drop-shadows on featured cards — the brand's distinctive elevation recipe.

### Don't
- Don't promote button-medium weight to 700+. The brand's weight ceiling is 600.
- Don't use chromatic accents as button backgrounds. They're surface fills, not actions.
- Don't render CTAs as pills. The brand's button geometry is tight 4 px rectangle.
- Don't introduce a sixth accent colour. The 5-stop palette is the system.


## wired
An inspired interpretation of Wired's design language — a flagship technology-magazine brand whose surface is a strict editorial duet of stark black wordmark on white canvas, anchored by a tall narrow custom display serif for hero headlines, a humanist serif body face for long-form reading, and a clean sans face for metadata; layout reads like a printed magazine ported to the web with very little marketing chrome.
Core tokens: {"primary": "#000000", "on-primary": "#ffffff", "ink": "#000000", "ink-soft": "#1a1a1a", "hairline": "#e0e0e0", "canvas": "#ffffff", "canvas-soft": "#f5f5f5", "link": "#057dbc"}
Fonts: ['WiredDisplay, "Times New Roman", Georgia, serif', 'Apercu, "Helvetica Neue", Helvetica, Arial, sans-serif', 'BreveText, Georgia, "Times New Roman", serif']
Layout: - Marketing content uses a wide container (~1400 px max).
- Cover-story grid: 1 large hero + 2-up secondary stories + vertical stack.
- Story-row stack: full-width single column with hairline dividers.

## Do's and Don'ts

### Do
- Reserve `primary` black for the wordmark, every CTA, and the footer fill. The brand IS the strict black-on-white duet.
- Set hero headlines in `display-hero` (WiredDisplay 64 px weight 400). The proprietary serif IS the brand's typographic signature.
- Use `none` 0 px on every button and form input. The brand reads as a printed magazine — square corners are non-negotiable.
- Pair WiredDisplay (serif display) with BreveText (serif body) and Apercu (sans labels). Three faces, three roles.
- Render story rows with `hairline` 1 px dividers — the brand's only elevation cue.

### Don't
- Don't introduce a chromatic brand accent. The link blue is reserved for inline body links inside articles only.
- Don't round button corners. The brand never softens its rectangular geometry.
- Don't drop a soft drop-shadow on cards. Surface contrast and hairlines carry elevation.
- Don't substitute the proprietary serif faces with a generic sans for display. The serif voice is the brand.
- Don't promote display weight beyond 400. The brand's elegance is in the typeface design, not bold weight.


## wise
An inspired interpretation of Wise's design language — a global money-transfer brand whose surface combines an unusually heavy near-black display sans (weight 900 at 64–126 px) with a vivid lime-green brand accent, sage-tinted surface neutrals, and rounded white cards on a pale green-tinted canvas; the whole system reads more like a Scandinavian fintech magazine than a bank.
Core tokens: {"primary": "#9fe870", "on-primary": "#0e0f0c", "primary-active": "#cdffad", "primary-neutral": "#c5edab", "primary-pale": "#e2f6d5", "ink": "#0e0f0c", "ink-deep": "#163300", "canvas": "#ffffff", "canvas-soft": "#e8ebe6"}
Fonts: ['Wise Sans, Inter, system-ui, -apple-system, sans-serif', 'Wise Sans, Inter, system-ui, sans-serif', 'Inter, system-ui, sans-serif']
Layout: - Marketing container centres at ~1200 px.
- Hero: split layout (headline left, currency-converter card right) at desktop; stacked at mobile.
- Feature grids: 2-up / 3-up at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` Wise green for every primary CTA. The lime-green pill IS the brand's conversion signature.
- Set hero headlines in `display-mega` / `display-xl` Wise Sans weight 900. Never lighter.
- Use `xl` 24 px for buttons and cards. The generous radius is the brand's friendliness signature.
- Cycle page surfaces in `canvas-soft` sage canvas → `canvas` white cards. Surface contrast carries elevation.
- Use the full semantic palette (positive / warning / negative) for in-product status — never repurpose Wise green as success indicator since it IS the brand CTA.

### Don't
- Don't introduce a second brand accent. Wise green is the sole identity colour.
- Don't render the hero in weight 700 or lighter. The brand's display weight is 900.
- Don't render CTAs as sharp rectangles. The 24 px pill geometry is non-negotiable.
- Don't pair the green CTA with a green background. The brand always sits Wise green on neutral surfaces (sage / white / ink).
- Don't replace Wise Sans with a generic geometric sans for hero typography — the proprietary face IS the brand's voice.


## x.ai
An inspired interpretation of xAI's design language — Elon Musk's frontier-AI company whose web surface is a strict near-black canvas broken only by white pill outlines, occasional warm sunset / dusk gradient accents, a custom geometric sans (Universal Sans) for display, and an uppercase tracked monospace caption face; the whole system reads as engineered-cosmic, unmarketed.
Core tokens: {"primary": "#ffffff", "on-primary": "#0a0a0a", "ink": "#ffffff", "ink-hover": "#fafaf7", "hairline": "#212327", "canvas": "#0a0a0a", "canvas-soft": "#1a1c20", "canvas-card": "#191919", "canvas-mid": "#363a3f"}
Fonts: ['universalSans, Inter, system-ui, -apple-system, sans-serif', 'universalSans, Inter, system-ui, sans-serif', 'GeistMono, ui-monospace, SFMono-Regular, Menlo, Monaco, monospace', 'GeistMono, ui-monospace, SFMono-Regular, Menlo, monospace']
Layout: - Marketing content centres at ~1200 px.
- Product / announcement card grid: 2-up at desktop, 1-up at mobile.

## Do's and Don'ts

### Do
- Reserve `canvas` (`#0a0a0a`) as the only page surface. The brand is dark-canvas only.
- Set hero headlines in `display-xl` Universal Sans weight 400 with `-2.4 px` tracking. The precision IS the voice.
- Use `pill` 9999 px on every interactive element. The pill is the brand.
- Pair Universal Sans (sentence-case) with GeistMono UPPERCASE (eyebrows, labels, metric counters).
- Use white-translucent borders for outline buttons — the brand never uses solid white borders on its outline pill.

### Don't
- Don't introduce a light-mode counterpart. xAI is dark-canvas only.
- Don't bold display headlines. Weight 400 is the entire scale.
- Don't use filled buttons broadly. The brand uses outline pills almost exclusively; one Sign Up white-filled pill is the rare exception.
- Don't drop a drop-shadow on cards. Hairline borders carry elevation.
- Don't substitute Universal Sans with a generic geometric sans without adjusting letter-spacing. The negative tracking is part of the brand.


## zapier
An inspired interpretation of Zapier's design language — a workflow-automation platform whose surface combines warm-cream neutrals (`#fffefb` canvas, `#f8f4f0` soft cream) with deep coffee ink (`#201515`) and a single saturated orange CTA accent (`#ff4f00`); typography pairs the proprietary Degular Display family at hero scale with Inter for sub-displays and body, giving the brand a confident-warm rather than cool-tech voice.
Core tokens: {"primary": "#ff4f00", "on-primary": "#fffefb", "ink": "#201515", "ink-soft": "#2f2a26", "ink-mid": "#36342e", "canvas": "#fffefb", "canvas-soft": "#f8f4f0"}
Fonts: ['Degular Display, Inter, system-ui, -apple-system, sans-serif', 'Degular Display, Inter, system-ui, sans-serif', 'Inter, system-ui, sans-serif']
Layout: - Marketing container ~1280 px wide; centred with gutters.
- Hero: split at desktop (headline left, illustration right); stacked at mobile.
- Pricing tier grid: 3 / 4-up at desktop.

## Do's and Don'ts

### Do
- Reserve `primary` Zapier orange for every primary CTA. The saturated orange IS the conversion signature.
- Keep canvas WARM — `canvas` `#fffefb` cream, not pure white. The temperature is the brand voice.
- Set hero headlines in `display-xl` Degular Display weight 500. Sentence-case, no uppercase.
- Pair Degular Display (hero, eyebrow) with Inter (everything else). Two faces, two roles.
- Use `md` 12 px for buttons + cards. The middle radius is the brand's signature.
- Pair orange CTA with ink-dark text on cream backgrounds — the three-token rhythm is the brand's whole conversion story.

### Don't
- Don't replace cream canvas with pure white. The warmth is the brand.
- Don't use pure black ink. The coffee-warmth in `#201515` carries through every text color.
- Don't render CTAs as pills. The brand's button is 12 px rounded rectangle.
- Don't introduce a second chromatic accent. Orange + cream + coffee is the entire palette.
- Don't substitute Degular Display with a cool geometric sans (e.g., generic Helvetica) — the brand's display face has warm proportions that the substitute doesn't capture.
