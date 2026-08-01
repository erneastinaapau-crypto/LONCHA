-- ================================================
-- ADD DURATION AND MAX_CYCLES COLUMNS TO HERO_MEDIA
-- ================================================
-- This migration adds slideshow timing control columns
-- ================================================

-- Add duration column (milliseconds per slide)
ALTER TABLE hero_media 
ADD COLUMN IF NOT EXISTS duration INTEGER DEFAULT 5000;

-- Add max_cycles column (how many complete loops before stopping, 0 = infinite)
ALTER TABLE hero_media 
ADD COLUMN IF NOT EXISTS max_cycles INTEGER DEFAULT 0;

-- Add comments for documentation
COMMENT ON COLUMN hero_media.duration IS 'Duration in milliseconds to display this slide (default: 5000ms = 5 seconds)';
COMMENT ON COLUMN hero_media.max_cycles IS 'Maximum number of complete carousel loops before stopping. 0 = infinite loop. Only read from first slide.';

-- ================================================
-- EXAMPLE QUERIES
-- ================================================

-- Set all slides to 7 seconds duration
-- UPDATE hero_media SET duration = 7000;

-- Set first slide to control max cycles (e.g., loop 3 times then stop)
-- UPDATE hero_media SET max_cycles = 3 WHERE position = 1;

-- Set infinite looping (default)
-- UPDATE hero_media SET max_cycles = 0 WHERE position = 1;

-- Check current values
SELECT id, position, type, duration, max_cycles, is_active 
FROM hero_media 
WHERE is_active = true 
ORDER BY position ASC;
