# NeuroPhysViewer

NeuroPhysViewer is an R/Shiny-based analysis tool for extracellular neurophysiology recordings exported from LabChart / ADInstruments.

## Current version

v0.13.11

## Main features

- LabChart TXT / CSV / ZIP waveform import
- ADInstruments `.adicht` event/comment label extraction
- MT trial-based segment management
- L1 and PPN condition grouping
- Condition-limited spike detection
- L1 antidromic response analysis
- PPN orthodromic response analysis
- Spike waveform overlay
- Feature scatter
- Manual spike grouping into Unit A / Unit B / Noise
- Unit-specific Raster / PSTH / latency analysis
- HTML report export

## Current workflow

1. Load `.adicht` file for event/comment labels
2. Load ZIP/CSV waveform file containing Time, Unit, MT, TTL
3. Define segments: L1, Free, PPN, Unknown
4. Generate condition groups from MT trials and event labels
5. Inspect MT-aligned waveform overlays
6. Run spike detection only within selected L1 or PPN condition
7. Perform feature-based spike sorting
8. Analyze L1 antidromic and PPN orthodromic responses
9. Export report

## Current development status

The current stable architecture is segment-first and condition-limited.
Spike detection is not run on the full recording. It is executed only after the relevant L1 or PPN condition group is selected.
