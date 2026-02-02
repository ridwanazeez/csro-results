# CSRO Results Generator - AI Coding Agent Instructions

## Project Overview

Single-page Vue 3 application for formatting Assetto Corsa racing server results (JSON) into readable tables for CSRO (Caribbean Sim Racing Organization) admins. Built with Vue 3 Composition API, TailwindCSS, and Vite. Deployed to GitHub Pages at `/csro-results/` base path.

## Architecture & Data Flow

### Core Components (3-component system)

- **App.vue**: Root component handling file upload, localStorage orchestration, and settings propagation
- **ResultsTable.vue**: Main table display with custom time calculation logic for race/qualifying results
- **SideNav.vue**: Settings panel for series branding (title/logo) with image file upload

### Data Persistence Pattern

Uses localStorage exclusively (no backend):

- Key: `CSRO_RESULT` stores uploaded JSON race data
- Data flows: Upload → App.vue → localStorage → ResultsTable.vue
- Settings (title/logo) flow through reactive props, triggering re-renders via `resultsTableKey` increment

### State Management

No Vuex/Pinia. State managed via:

- Parent-child props (`raceData` from App → ResultsTable)
- Custom events (`@settings` emitted from SideNav → App)
- localStorage for persistence across sessions
- Force re-render pattern: `resultsTableKey` incremented to refresh ResultsTable

## Critical Domain Logic

### Time Calculation (ResultsTable.vue)

`calculateBestLap(x, penalty)` converts milliseconds from Assetto Corsa JSON to `M:SS.mmm` format:

- Input: milliseconds as integer (e.g., 71234 = 1:11.234)
- Logic handles edge cases: <10s, <100ms, <10ms padding with zeros
- Used for TotalTime, BestLap, and gap calculations
- DO NOT refactor to use Date objects - manual calculation required for game-specific format

### Race Gap Calculation

`calculateRaceGap()` computes time differences relative to P1's best lap (qualifying mode only):

- Gap = Current driver BestLap - P1 BestLap
- Returns formatted time strings in array indexed by position

### Lap Counting

`calculateTotalLaps(data, driver)` iterates full `Laps` array to count laps per driver (DriverName matching)

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
- Inter var font from CDN (index.html), extended in Tailwind config
- `@tailwindcss/forms` plugin for select/input styling

### File Structure

- Components: Single-file Vue components (.vue) in `src/components/`
- Assets: `public/images/` for static images (deployed as-is)
- Path alias: `@` → `src/` (vite.config.js)

### Vue Patterns

- **Options API exclusively** - no `<script setup>` or Composition API
- Props: Always define with `type` and `default`
- Reactivity: Standard data() return objects, avoid refs
- Conditional rendering: v-if for feature toggles (e.g., uploaded state, qualifying vs race)

## Integration Points

### External Dependencies

- **Assetto Corsa JSON format**: Expects specific structure:
  - `Type`: "QUALIFY" or "RACE"
  - `Result[]`: Array with `DriverName`, `BestLap`, `TotalTime`
  - `Laps[]`: Array with `DriverName` for lap counting
  - `Date`: ISO date string
- **localStorage API**: Must be available (no SSR compatibility)
- **FileReader API**: For JSON and image file uploads

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
