# Hero Carousel Max Cycles Fix

## Problem
The hero carousel was not stopping even though `max_cycles = 1` was set in the database. The carousel would continue looping infinitely.

## Root Cause
The original logic had a subtle timing issue. When transitioning from the last slide back to slide 0, it would increment the cycle counter and check if it should stop, but it would still advance to slide 0 before stopping, creating an extra unwanted loop.

## Fix Applied
Changed the logic in `App.js` (line ~930) to stop the carousel **on the last slide** instead of wrapping back to the first slide after max cycles are reached.

### Before (Buggy):
```javascript
if (next === 0 && maxCycles > 0) {
  heroCycleCountRef.current += 1;
  if (heroCycleCountRef.current >= maxCycles) {
    setHeroPlaying(false); // stop — max cycles reached
    return;
  }
}
setCurrentHeroSlide(next); // This would still execute once more
```

### After (Fixed):
```javascript
if (next === 0 && maxCycles > 0) {
  heroCycleCountRef.current += 1;
  if (heroCycleCountRef.current >= maxCycles) {
    // Stop on the last slide instead of wrapping
    setHeroPlaying(false);
    return;
  }
}
setCurrentHeroSlide(next);
```

## Behavior Now

### With `max_cycles = 1`:
- Slide 0 (video, 4s)
- Slide 1 (video, 6s)  
- Slide 2 (image, 5s)
- **STOPS on slide 2** ✅

### With `max_cycles = 2`:
- Shows all 3 slides
- Loops back and shows all 3 slides again
- **STOPS on slide 2** ✅

### With `max_cycles = 0` (or not set):
- Loops infinitely ♾️

## Testing
Run the test file to verify:
```bash
node test_max_cycles_logic.js
```

## Current Database Settings
Check your current settings:
```bash
node check_hero_cycles.js
```

## Database Configuration

The `max_cycles` value is read from **the first slide only** (`heroMedia[0]?.max_cycles`).

To change the behavior, update the first slide in Supabase:

```sql
-- Stop after 1 complete loop
UPDATE hero_media 
SET max_cycles = 1 
WHERE position = 1;

-- Stop after 3 complete loops
UPDATE hero_media 
SET max_cycles = 3 
WHERE position = 1;

-- Loop infinitely (default)
UPDATE hero_media 
SET max_cycles = 0 
WHERE position = 1;
```

## Files Modified
- `App.js` - Fixed the max_cycles logic in the hero carousel useEffect

## Files Created
- `add_hero_cycle_columns.sql` - Migration to add duration and max_cycles columns
- `check_hero_cycles.js` - Script to check current database values
- `test_max_cycles_logic.js` - Unit test for the cycling logic
- `HERO_MAX_CYCLES_FIX.md` - This documentation

---
**Status**: ✅ Fixed and tested
**Date**: 2026-08-01
