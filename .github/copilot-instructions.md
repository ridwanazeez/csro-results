# CSRO Results Generator - AI Coding Agent Instructions

## Project Overview

Single-page Vue 3 application for formatting Assetto Corsa racing server results (JSON) into readable tables and championship standings for CSRO (Caribbean Sim Racing Organization) admins. Built with Vue 3 Options API, TailwindCSS, VueUse, html2canvas, and Vite. Deployed to GitHub Pages at `/csro-results/` base path.

## Architecture & Data Flow

### Core Components (4-component system)

- **App.vue**: Root component handling file upload, multi-result management, view switching (table/standings), and localStorage orchestration
- **ResultsTable.vue**: Single result display with contenteditable cells for inline editing, custom time calculation, drag-and-drop reordering, and screenshot functionality
- **StandingsView.vue**: Championship standings aggregator showing qualifying/race history, driver/team/country standings calculated from all saved RACE results
- **SideNav.vue**: Settings sidebar for series branding (title/logo), result management (save/load/delete), and view navigation

### Data Persistence Pattern

Uses localStorage exclusively (no backend):

- `CSRO_RESULT`: Current active result JSON from Assetto Corsa
- `CSRO_SAVED_RESULTS`: Array of saved results with metadata (id, name, timestamp, data)
- Data flows: Upload → App.vue → localStorage → ResultsTable/StandingsView
- Settings (title/logo) flow through reactive props, triggering re-renders via `resultsTableKey` increment

### State Management

No Vuex/Pinia. State managed via:

- Parent-child props (`raceData`, `savedResults`, `settings` from App → child components)
- Custom events (`@settings`, `@save-result`, `@load-result`, `@delete-result`, `@view-standings`)
- localStorage for multi-session persistence
- Force re-render pattern: `resultsTableKey` incremented to refresh components after state changes
- View switching: `currentView` state toggles between 'table' and 'standings'

## Critical Domain Logic

### Time Calculation (ResultsTable.vue)

`calculateBestLap(x, penalty)` converts milliseconds from Assetto Corsa JSON to `M:SS.mmm` format:

- Input: milliseconds as integer (e.g., 71234 = 1:11.234)
- Logic handles edge cases: <10s, <100ms, <10ms padding with zeros
- Used for TotalTime, BestLap, and gap calculations
- DO NOT refactor to use Date objects - manual calculation required for game-specific format

### Race Gap Calculation

`calculateRaceGap(results)` computes time differences relative to P1's best lap (qualifying mode only):

- Gap = Current driver BestLap - P1 BestLap
- Returns formatted time strings in array indexed by position

### Points System

`calculatePoints(position)` implements F1-style points: [25, 18, 15, 12, 10, 8, 6, 4, 2, 1] for positions 1-10, 0 for 11+

- Used by default in RACE results, customizable via contenteditable cells
- Points from RACE results (not QUALIFY) aggregate into championship standings
- Custom points stored as `customPoints` property on result objects

### Inline Editing System

All table cells in ResultsTable are `contenteditable="true"` with `@blur="handleCellEdit"`:

- Edits captured via data attributes: `data-field`, `data-index`
- Custom values stored with `custom` prefix: `customPoints`, `customBestLap`, `customGap`, `customLaps`
- Original calculated values preserved, custom overrides take display priority
- Drag-and-drop reordering available for result rows

### Championship Standings (StandingsView.vue)

Aggregates all saved results to compute:

- **Driver Standings**: Sum of points across all RACE results, sorted descending
- **Team Standings**: Points grouped by `Driver.Team` from Cars array
- **Country Standings**: Points grouped by `Driver.Nation` with country code lookup
- Only RACE type results count for standings; QUALIFY results displayed separately

## Development Workflows

### Build & Dev

```bash
npm run dev        # Vite dev server (default: http://localhost:5173)
npm run build      # Production build for /csro-results/ base path
npm run preview    # Preview production build
```

### Code Quality

```bash
npm run lint       # ESLint with auto-fix (Vue 3 + Prettier config)
npm run format     # Prettier on src/ directory
```

### Deployment

GitHub Pages deployment assumes:

- Base path: `/csro-results/` (set in vite.config.js)
- Static files in `public/images/` (csro-logo.png referenced)

## Key Conventions

### Styling

- **TailwindCSS only** - no scoped styles or custom CSS
- Dark mode: `class` strategy with `dark:` prefixes (see tailwind.config.js)
  - Toggle managed by VueUse's `useDark()` composable in SideNav.vue
  - Persists preference to localStorage automatically via VueUse
  - Button placed above footer in SideNav
- Inter var font from CDN (index.html), extended in Tailwind config
- `@tailwindcss/forms` plugin for select/input styling

### File Structure

- Components: Single-file Vue components (.vue) in `src/components/`
- Assets: `public/images/` for static images (deployed as-is)
- Path alias: `@` → `src/` (vite.config.js)

### Vue Patterns

- **Options API exclusively** - no `<script setup>` or Composition API
- Exception: `setup()` method used in SideNav.vue for VueUse composables (`useDark`, `useToggle`)
- Props: Always define with `type` and `default`
- Reactivity: Standard data() return objects, avoid refs
- Conditional rendering: v-if for feature toggles (e.g., uploaded state, qualifying vs race)

## Integration Points

### External Dependencies

- **Assetto Corsa JSON format**: Expects specific structure:
  - `Type`: "QUALIFY" or "RACE"
  - `Result[]`: Array with `DriverName`, `BestLap`, `TotalTime`
  - `Laps[]`: Array with `DriverName` for lap counting
  - `Cars[]`: Array with `Driver.Name`, `Driver.Team`, `Driver.Nation` for team/country lookup
  - `Date`: ISO date string
- **localStorage API**: Must be available (no SSR compatibility)
- **FileReader API**: For JSON and image file uploads
- **html2canvas**: Screenshot functionality for both ResultsTable and StandingsView
  - Triggered via SideNav "Save Screenshot" button
  - Captures `#resultsTable` or `#standingsTable` element
  - Downloads as PNG with filename based on result type and date

### Image Handling

- Series logos converted to base64 data URLs via FileReader
- Stored in component state, passed through props
- Default fallback: `/images/csro-logo.png`

## Common Gotchas

1. **Time formatting precision**: Must preserve 3-digit milliseconds with leading zeros
2. **GitHub Pages base path**: All asset references must work with `/csro-results/` prefix
3. **resultsTableKey pattern**: Required to force component re-render when settings change (Vue doesn't deep-watch complex props by default)
4. **Country dropdown**: Hardcoded list specific to CSRO region (Caribbean + North America)
5. **Best lap highlighting**: Green background applied via `:class` binding to fastest lap row
