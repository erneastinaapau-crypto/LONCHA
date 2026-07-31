-- ================================================
-- CREATE HERO MEDIA TABLE
-- ================================================
-- This table stores hero section media (videos and images)
-- for dynamic management of the hero carousel
-- ================================================

-- Create the hero_media table
CREATE TABLE IF NOT EXISTS hero_media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('video', 'image')),
  uri TEXT NOT NULL,
  title TEXT,
  description TEXT,
  kicker TEXT,
  hero_title TEXT,
  hero_body TEXT,
  button_text_primary TEXT DEFAULT 'SHOP NOW',
  button_text_secondary TEXT DEFAULT 'VIEW CART',
  position INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- ADD MISSING COLUMNS IF TABLE ALREADY EXISTS
-- ================================================
-- Run these ALTER statements if you already have the table
-- without the new text columns

ALTER TABLE hero_media ADD COLUMN IF NOT EXISTS kicker TEXT;
ALTER TABLE hero_media ADD COLUMN IF NOT EXISTS hero_title TEXT;
ALTER TABLE hero_media ADD COLUMN IF NOT EXISTS hero_body TEXT;
ALTER TABLE hero_media ADD COLUMN IF NOT EXISTS button_text_primary TEXT DEFAULT 'SHOP NOW';
ALTER TABLE hero_media ADD COLUMN IF NOT EXISTS button_text_secondary TEXT DEFAULT 'VIEW CART';

-- Create an index on position for ordered queries
CREATE INDEX IF NOT EXISTS idx_hero_media_position ON hero_media(position);

-- Create an index on is_active for filtering
CREATE INDEX IF NOT EXISTS idx_hero_media_active ON hero_media(is_active);

-- ================================================
-- INSERT SAMPLE HERO MEDIA DATA
-- ================================================

-- Insert shoe images only (video removed due to web compatibility issues)
INSERT INTO hero_media (type, uri, title, description, kicker, hero_title, hero_body, button_text_primary, button_text_secondary, position, is_active)
VALUES
  (
    'image',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80',
    'Red Nike Shoes',
    'Classic red Nike sneakers',
    'Osebo-Shoes',
    'Step Into Style, Walk in Confidence.',
    'Premium footwear for every occasion. Discover the finest collection of shoes, sneakers and sandals — proudly available at Osebo-Shoes.',
    'SHOP NOW',
    'VIEW CART',
    1,
    true
  ),
  (
    'image',
    'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9ff?auto=format&fit=crop&w=1200&q=80',
    'Nike Air Max',
    'Nike Air Max running shoes',
    'Osebo-Shoes',
    'Bold & Beautiful',
    'Stand out with our premium red collection. Quality craftsmanship meets stunning design.',
    'SHOP NOW',
    'VIEW CART',
    2,
    true
  ),
  (
    'image',
    'https://images.unsplash.com/photo-1543163521-1bf539e0cf6d?auto=format&fit=crop&w=1200&q=80',
    'White Sneakers',
    'Clean white sneakers',
    'Osebo-Shoes',
    'Performance First',
    'Engineered for comfort and speed. Experience the difference with our athletic collection.',
    'SHOP NOW',
    'VIEW CART',
    3,
    true
  ),
  (
    'image',
    'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&w=1200&q=80',
    'Running Shoes',
    'Performance running shoes',
    'Osebo-Shoes',
    'Timeless Classics',
    'Clean, versatile, and always in style. Perfect for any occasion.',
    'SHOP NOW',
    'VIEW CART',
    4,
    true
  ),
  (
    'image',
    'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=1200&q=80',
    'Sport Shoes',
    'Sport performance shoes',
    'Osebo-Shoes',
    'Go The Distance',
    'Push your limits with our professional running gear. Built for champions.',
    'SHOP NOW',
    'VIEW CART',
    5,
    true
  );

-- ================================================
-- CREATE FUNCTION TO UPDATE UPDATED_AT TIMESTAMP
-- ================================================

CREATE OR REPLACE FUNCTION update_hero_media_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS trigger_update_hero_media_updated_at ON hero_media;
CREATE TRIGGER trigger_update_hero_media_updated_at
  BEFORE UPDATE ON hero_media
  FOR EACH ROW
  EXECUTE FUNCTION update_hero_media_updated_at();

-- ================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ================================================

ALTER TABLE hero_media ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public read access (for frontend)
CREATE POLICY "Allow public read access on hero_media"
  ON hero_media FOR SELECT
  USING (true);

-- Policy: Allow authenticated users to insert/update/delete
CREATE POLICY "Allow authenticated users to manage hero_media"
  ON hero_media FOR ALL
  USING (auth.role() = 'authenticated');

-- ================================================
-- QUERIES FOR HERO MEDIA MANAGEMENT
-- ================================================

-- Query to get all active hero media ordered by position
-- This shows you the UUIDs you need for updates
SELECT * FROM hero_media
WHERE is_active = true
ORDER BY position ASC;

-- Query to add new hero media
INSERT INTO hero_media (type, uri, title, description, kicker, hero_title, hero_body, position, is_active)
VALUES ('image', 'https://your-image-url.jpg', 'Title', 'Description', 'Kicker', 'Hero Title', 'Hero Body', 6, true);

-- Query to update hero media (REPLACE 'your-uuid' WITH ACTUAL UUID FROM ABOVE SELECT)
UPDATE hero_media
SET uri = 'https://new-url.jpg',
    kicker = 'New Kicker',
    hero_title = 'New Title',
    hero_body = 'New description',
    position = 1
WHERE id = 'your-uuid';

-- Query to update hero text only (REPLACE 'your-uuid' WITH ACTUAL UUID)
UPDATE hero_media
SET kicker = 'Your Brand',
    hero_title = 'Your Title',
    hero_body = 'Your description'
WHERE id = 'your-uuid';

-- Query to convert video to image (REPLACE 'your-uuid' WITH ACTUAL UUID)
UPDATE hero_media
SET type = 'image',
    uri = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80'
WHERE id = 'your-uuid' AND type = 'video';

-- Or delete the video record entirely
DELETE FROM hero_media WHERE type = 'video';

-- Query to deactivate hero media (soft delete)
UPDATE hero_media
SET is_active = false
WHERE id = 'your-uuid';

-- Query to reorder hero media
UPDATE hero_media
SET position = new_position
WHERE id = 'your-uuid';
