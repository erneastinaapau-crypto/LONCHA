# Promo Banner Strip Animation

## Feature Overview
Added smooth auto-scrolling animation to the promotional banner strip using React Native's Animated API for reliable cross-platform performance.

## Animation Features

### 1. **Auto-Scroll Animation**
- Banners continuously scroll horizontally using Animated.timing
- Uses `translateX` transform for smooth GPU-accelerated animation
- Automatically pauses when user interacts with banners

### 2. **Infinite Loop Effect**
- Banners are triplicated (`[...banners, ...banners, ...banners]`) for seamless looping
- Animation loops continuously with Animated.loop
- Creates illusion of infinite continuous scroll

### 3. **Pause on Interaction**
- **Desktop/Mobile**: Pauses on press/touch
- Animation stops when pressing individual banner cards
- Animation resumes when interaction ends

### 4. **Smooth Performance**
- Uses React Native's Animated API with native driver
- GPU-accelerated transforms for buttery smooth animation
- Cleanup on component unmount prevents memory leaks

## Technical Implementation

### Key Changes

**1. Added State & Refs:**
```javascript
const scrollAnimation = useRef(new Animated.Value(0)).current;  // Animated value
const isPausedRef = useRef(false);                              // Pause state
```

**2. Animation Loop:**
```javascript
useEffect(() => {
  if (loading || !banners || banners.length <= 3) return;

  const contentWidth = banners.length * (cardWidth + cardGap);
  const animationDuration = contentWidth * 30; // 30ms per pixel

  const startAnimation = () => {
    scrollAnimation.setValue(0);
    
    Animated.loop(
      Animated.sequence([
        Animated.timing(scrollAnimation, {
          toValue: contentWidth,
          duration: animationDuration,
          useNativeDriver: true,  // GPU acceleration
        }),
      ])
    ).start();
  };

  if (!isPausedRef.current) {
    startAnimation();
  }

  return () => {
    scrollAnimation.stopAnimation();
  };
}, [loading, banners, cardWidth, cardGap]);
```

**3. Interaction Handlers:**
```javascript
const handlePressIn = () => {
  isPausedRef.current = true;
  scrollAnimation.stopAnimation();
};

const handlePressOut = () => {
  isPausedRef.current = false;
  // Restart animation
  const contentWidth = banners.length * (cardWidth + cardGap);
  const animationDuration = contentWidth * 30;
  
  Animated.loop(
    Animated.sequence([
      Animated.timing(scrollAnimation, {
        toValue: contentWidth,
        duration: animationDuration,
        useNativeDriver: true,
      }),
    ])
  ).start();
};
```

**4. Animated Transform:**
```javascript
<Animated.View
  style={{
    flexDirection: 'row',
    gap: cardGap,
    paddingHorizontal: 16,
    transform: [
      {
        translateX: scrollAnimation.interpolate({
          inputRange: [0, banners.length * (cardWidth + cardGap)],
          outputRange: [0, -banners.length * (cardWidth + cardGap)],
        }),
      },
    ],
  }}
  onStartShouldSetResponder={() => true}
  onResponderGrant={handlePressIn}
  onResponderRelease={handlePressOut}
>
  {/* Triplicated banners */}
  {[...banners, ...banners, ...banners].map((banner, index) => (
    <Pressable key={`${banner.id}-${index}`} ... />
  ))}
</Animated.View>
```

## Configuration

### Animation Speed
Adjust the duration multiplier (milliseconds per pixel):
```javascript
const animationDuration = contentWidth * 30;  // Default - smooth and readable

// Options:
// contentWidth * 50  = Slower, more time to read
// contentWidth * 30  = Default (recommended)
// contentWidth * 15  = Faster, more dynamic
// contentWidth * 10  = Very fast
```

### Animation Behavior
- **Starts automatically** when component mounts
- **Only animates** if more than 3 banners
- **Stops** during loading state
- **Pauses** on user touch/press
- **Resumes** when interaction ends

## User Experience Benefits

✅ **Eye-catching**: Movement naturally draws attention to promotions
✅ **Discoverable**: Users see more banners continuously
✅ **Interactive**: Can pause to read or click banners
✅ **Smooth**: GPU-accelerated transform animation
✅ **Accessible**: Doesn't interfere with user control
✅ **Cross-platform**: Works on web and native

## Browser Compatibility

- ✅ Modern browsers (Chrome, Firefox, Safari, Edge)
- ✅ React Native Web
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)
- ✅ iOS and Android native apps
- ✅ Uses React Native's Animated API with native driver

## Performance Considerations

- Animation uses `useNativeDriver: true` for GPU acceleration
- Transform-based animation (no layout recalculation)
- Properly cleaned up on unmount (no memory leaks)
- Uses refs to avoid unnecessary re-renders
- Lightweight - uses built-in React Native Animated API

## Testing

1. **Desktop/Mobile**: Touch/press banner strip - animation should pause
2. **Click**: Click a banner - should navigate and pause animation
3. **Few Banners**: Animation doesn't run if 3 or fewer banners
4. **Loading**: Animation doesn't run during loading state
5. **Release**: Animation resumes when touch/press is released

## Files Modified

- `components/PromoBannerStrip.js` - Added auto-scroll animation with pause functionality

---
**Status**: ✅ Implemented and tested
**Date**: 2026-08-01
**Animation Type**: Continuous horizontal auto-scroll using Animated API with GPU acceleration
**Method**: Transform-based (translateX) for optimal performance
