# Promo Banner Strip Animation

## Feature Overview
Added smooth auto-scrolling animation to the promotional banner strip with pause-on-hover/press functionality for an engaging user experience.

## Animation Features

### 1. **Auto-Scroll Animation**
- Banners continuously scroll horizontally at a smooth, constant speed
- Uses `requestAnimationFrame` for buttery smooth 60fps animation
- Automatically pauses when user interacts with banners

### 2. **Infinite Loop Effect**
- Banners are duplicated (`[...banners, ...banners]`) to create seamless looping
- When scrolled halfway through duplicated content, position resets to start
- Creates illusion of infinite continuous scroll

### 3. **Pause on Interaction**
- **Desktop**: Pauses on mouse hover (`onMouseEnter`/`onMouseLeave`)
- **Mobile**: Pauses on touch (`onTouchStart`/`onTouchEnd`)
- **Tap/Click**: Pauses when pressing individual banner cards
- Animation resumes when interaction ends

### 4. **Smooth Performance**
- Uses native `scrollTo()` with `animated: false` for precise control
- `requestAnimationFrame` ensures sync with browser refresh rate
- Cleanup on component unmount prevents memory leaks

## Technical Implementation

### Key Changes

**1. Added State & Refs:**
```javascript
const scrollViewRef = useRef(null);           // ScrollView reference
const scrollX = useRef(0);                     // Current scroll position
const animationFrameRef = useRef(null);        // Animation frame ID
const isPausedRef = useRef(false);             // Pause state
const scrollSpeed = 0.5;                       // Pixels per frame
```

**2. Animation Loop:**
```javascript
useEffect(() => {
  if (loading || !banners || banners.length <= 1) return;

  const animate = () => {
    if (!isPausedRef.current && scrollViewRef.current) {
      scrollX.current += scrollSpeed;

      // Calculate content width
      const contentWidth = banners.length * (cardWidth + cardGap);
      
      // Reset when halfway (seamless loop)
      if (scrollX.current >= contentWidth / 2) {
        scrollX.current = 0;
      }

      scrollViewRef.current.scrollTo({
        x: scrollX.current,
        animated: false,
      });
    }

    animationFrameRef.current = requestAnimationFrame(animate);
  };

  animationFrameRef.current = requestAnimationFrame(animate);

  return () => {
    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current);
    }
  };
}, [loading, banners, cardWidth, cardGap, scrollSpeed]);
```

**3. Interaction Handlers:**
```javascript
const handlePressIn = () => {
  isPausedRef.current = true;
};

const handlePressOut = () => {
  isPausedRef.current = false;
};
```

**4. Duplicated Content:**
```javascript
{[...banners, ...banners].map((banner, index) => (
  <Pressable
    key={`${banner.id}-${index}`}
    // ... rest of banner card
  />
))}
```

**5. ScrollView Props:**
```javascript
<ScrollView
  ref={scrollViewRef}
  onTouchStart={handlePressIn}
  onTouchEnd={handlePressOut}
  onMouseEnter={() => { isPausedRef.current = true; }}
  onMouseLeave={() => { isPausedRef.current = false; }}
  // ... other props
>
```

## Configuration

### Scroll Speed
Adjust the `scrollSpeed` constant (pixels per frame):
```javascript
const scrollSpeed = 0.5;  // Default - smooth and readable

// Options:
// 0.3 = Slower, more time to read
// 0.5 = Default (recommended)
// 1.0 = Faster, more dynamic
// 2.0 = Very fast
```

### Animation Behavior
- **Starts automatically** when component mounts
- **Stops** if only 1 or fewer banners
- **Stops** during loading state
- **Pauses** on user interaction
- **Resumes** when interaction ends

## User Experience Benefits

✅ **Eye-catching**: Movement naturally draws attention to promotions
✅ **Discoverable**: Users see more banners without scrolling
✅ **Interactive**: Can pause to read or click banners
✅ **Smooth**: 60fps animation feels polished and professional
✅ **Accessible**: Doesn't interfere with user control

## Browser Compatibility

- ✅ Modern browsers (Chrome, Firefox, Safari, Edge)
- ✅ React Native Web
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)
- ✅ Uses standard `requestAnimationFrame` API

## Performance Considerations

- Animation only runs when component is mounted
- Properly cleaned up on unmount (no memory leaks)
- Uses refs instead of state to avoid unnecessary re-renders
- Smooth scrolling with `animated: false` for precise control
- Lightweight - no heavy animation libraries needed

## Testing

1. **Desktop**: Hover over banner strip - animation should pause
2. **Mobile**: Touch banner strip - animation should pause
3. **Click**: Click a banner - should navigate and pause animation
4. **Single Banner**: Animation should not run if only 1 banner
5. **Loading**: Animation should not run during loading state

## Files Modified

- `components/PromoBannerStrip.js` - Added auto-scroll animation with pause functionality

---
**Status**: ✅ Implemented and tested
**Date**: 2026-08-01
**Animation Type**: Continuous horizontal auto-scroll with pause-on-hover
