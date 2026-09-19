// Assetto Corsa writes 999999999 into BestLap/TotalTime when a driver never set
// a timed lap (DNF, retired in the pits, joined late). Formatting that sentinel
// as a real duration is where "16666:39.999" came from.
export const NO_TIME = 999999999

// True only for a time we can actually render. Rejects the sentinel, 0/missing
// times, and negatives (a gap can go negative once rows are reordered by hand).
export const hasTime = (ms) => typeof ms === 'number' && ms > 0 && ms < NO_TIME
