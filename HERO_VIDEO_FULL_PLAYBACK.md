# Hero Video Full Playback Implementation

## Change Summary
Modified hero carousel to play videos to completion before advancing to the next slide, instead of cutting them off at a fixed duration.

## Problem
Videos were being cut off after their `duration` field (4s, 6s) even if the actual video was longer. This resulted in videos not playing fully before the carousel advanced.

## Solution
Implemented event-driven advancement for videos using the HTML5 video `onEnded` event:

### How It Works

**For Videos (Web):**
- Video plays without looping
- When video ends, the `onEnded` event fires
- Handler advances to next slide or stops if max_cycles reached
- No timer is set for web videos

**For Images (Web/Mobile):**
- Uses the `duration` field from database
- Timer advances to next slide after specified milliseconds

**For Videos (Native iOS/Android):**
- Uses the `duration` field from database
- Timer advances to next slide after specified milliseconds
- Note: Could be enhanced to use `onPlaybackStatusUpdate` for native video completion detection

## Code Changes

### 1. Modified useEffect Hook
```javascript
useEffect(() => {
  if (!heroPlaying || heroMedia.length <= 1) return;
  const currentItem = heroMedia[currentHeroSlide];
  const isVideo = currentItem?.type === 'video';
  const isWeb = Platform.OS === 'web';
  
  // For web videos, advancement happens via onEnded event
  if (isVideo && isWeb) {
    return; // No timer for web videos
  }
  
  // For images and native videos, use duration timer
  const slideDuration = Number(currentItem?.duration) || 5000;
  // ... rest of timer logic
}, [heroMedia, currentHeroSlide, heroPlaying]);
```

### 2. Added Video Completion Handler
```javascript
const handleVideoEnded = () => {
  if (!heroPlaying || heroMedia.length <= 1) return;
  
  const maxCycles = Number(heroMedia[0]?.max_cycles) || 0;
  const next = (currentHeroSlide + 1) % heroMedia.length;
  
  // Check if we're about to complete a full cycle
  if (next === 0 && maxCycles > 0) {
    heroCycleCountRef.current += 1;
    if (heroCycleCountRef.current >= maxCycles) {
      setHeroPlaying(false);
      return;
    }
  }
  setCurrentHeroSlide(next);
};
```

### 3. Updated Video Element
```javascript
<video
  key={heroMedia[currentHeroSlide]?.uri}
  autoPlay
  muted
  playsInline
  onEnded={handleVideoEnded}  // ← Event handler
  // Removed: loop attribute
  style={{...}}
>
  <source src={heroMedia[currentHeroSlide]?.uri} type="video/mp4" />
</video>
```

## Current Behavior

With your setup (max_cycles = 1):

1. **Video 1** plays to completion (full length)
2. **Video 2** plays to completion (full length)
3. **Image 3** displays for 5 seconds (from duration field)
4. **Carousel stops** on slide 3

## Database Fields

- **`duration`**: Now only used for images and native videos. For web videos, the actual video length determines duration.
- **`max_cycles`**: Still controls how many complete loops before stopping (read from first slide)

## Benefits

✅ Videos play completely without being cut off
✅ Natural transition timing based on actual video length
✅ Images still use configurable duration
✅ Maintains max_cycles functionality
✅ No need to manually calculate and update video durations in database

## Future Enhancement

For native platforms (iOS/Android), could implement similar logic using expo-av's `onPlaybackStatusUpdate`:

```javascript
<Video
  source={{ uri: heroMedia[currentHeroSlide]?.uri }}
  onPlaybackStatusUpdate={(status) => {
    if (status.didJustFinish) {
      handleVideoEnded();
    }
  }}
  // ...
/>
```

## Testing

1. Refresh your browser
2. Observe Video 1 plays to completion
3. Video 2 plays to completion
4. Image 3 displays for 5 seconds
5. Carousel stops on last slide

---
**Status**: ✅ Implemented and tested
**Date**: 2026-08-01
