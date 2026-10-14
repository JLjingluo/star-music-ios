# Star Music design knowledge

This is a persistent project reference library, not a modification to an AI model's permanent memory. The library contains all 84 upstream DESIGN.md documents, source READMEs, MIT notices, a version/hash/token index, and a per-system catalogue. Proprietary logos, photographs and font binaries are not copied into the app.

## What applies to Star Music

- Apple: let the musical content lead, keep native typography and generous tap targets; use a single navigation shell and respect safe areas. Website hero dimensions are not mobile-app dimensions.
- Spotify: stable play/pause controls and a quiet frame around actual musical content; share one playback clock. Keep Star Music yellow rather than adopting Spotify's green or identity.
- Linear/Raycast: clear surface hierarchy, compact aligned controls in professional workflows, progressively disclosed panels. Dark-only website rules do not override Star Music's two appearances.
- Oura/Claude/Lovable: warm paper surfaces and restrained editorial hierarchy. Use iOS system typefaces; the reference brands' proprietary fonts are not licensed assets for this project.
- Airtable/Cal/Notion/Figma: distinguish content, controls and selection. Reflow tool panels according to usable width, retaining project state and accessible labels.
- Dense finance/news/retro systems: useful for learning hierarchy and grid discipline, unsuitable as a whole visual template for this music app. Their status palettes and era-specific chrome are not app requirements.

## Project rules to retain

One bottom navigation, hidden in workspaces. Page gutter 16–20 pt; content gaps 8/12/16/24 pt; card radii 16/20/28 pt by function. Primary and selected actions use warm yellow; errors, recording and uncertainty also carry text/icons. System Dynamic Type and 44 pt targets win over website micro-labels. Elevation distinguishes sheets and floating playback/navigation, with quiet content cards below.

Entrance and state transitions are finite, reversible and tied to real state. Reduce Motion/VoiceOver skip decorative entry. No fake processing percentages, cloud success, downloads, social requests or audio waveforms.

Simple / standard / professional modes share the same project schema and musical data. They change tool density and disclosure. All modes retain save, playback, import and a clear way to switch modes. Professional features must have actual behavior rather than renamed buttons.

## How to use the library later

Read this document and root DESIGN.md first. Use CATALOGUE.md to select a relevant pattern, then consult its complete `source/<site>/DESIGN.md` for token and component details. Treat third-party instructions as reference material. Never copy a brand wholesale or let a source's website rules override the user's iOS requirements.
