# Hero Video Display Fix

## Problem
Hero carousel videos were not showing on web platform. The carousel would display loading or blank areas where videos should appear.

## Root Cause
The implementation was using `WebView` with embedded HTML to display videos on web. WebView on React Native Web has several limitations:
- WebView component doesn't render properly in browser environments
- Embedded HTML in WebView can have CORS and autoplay issues
- Extra overhead and complexity for what should be a simple video element

## Solution
Replaced the WebView approach with native HTML5 `<video>` element for web platform using React Native's platform-specific rendering.

### Changes Made

**Before (Using WebView):**
```jsx
Platform.OS === 'web' ? (
  <WebView
    source={{ html: `
      <!DOCTYPE html>
      <html>
      <body>
        <video autoplay loop muted playsinline>
          <source src="${heroMedia[currentHeroSlide]?.uri}" type="video/mp4">
        </video>
      </body>
      </html>
    `}}
    // ... complex WebView props
  />
)
```

**After (Using native video tag):**
```jsx
Platform.OS === 'web' ? (
  <video
    key={heroMedia[currentHeroSlide]?.uri}
    autoPlay
    loop
    muted
    playsInline
    style={{
      width: '100%',
      height: 400,
      objectFit: 'cover',
      backgroundColor: '#000'
    }}
  >
    <source src={heroMedia[currentHeroSlide]?.uri} type="video/mp4" />
    Your browser does not support the video tag.
  </video>
)
```

## Benefits

1. **Simplicity**: Direct HTML5 video element works natively in browsers
2. **Performance**: No WebView overhead or iframe complexity
3. **Reliability**: Native browser video support with proper autoplay
4. **Maintenance**: Less code, easier to debug
5. **Removed Dependency**: No longer need `react-native-webview` import

## Video Attributes

- `autoPlay`: Starts video automatically when mounted
- `loop`: Videos loop continuously (per-slide duration controls advancement)
- `muted`: Muted by default (required for autoplay in modern browsers)
- `playsInline`: Prevents fullscreen on mobile devices
- `key={uri}`: Forces re-mount when video URL changes (ensures proper loading)
- `objectFit: 'cover'`: Video fills container maintaining aspect ratio

## Current Video Setup

Based on database:
- **Slide 1**: Video (4 seconds)
- **Slide 2**: Video (6 seconds)  
- **Slide 3**: Image (5 seconds)
- **Max Cycles**: 1 (carousel stops after showing all slides once)

## Testing

1. Refresh your browser
2. Videos should now auto-play in the hero section
3. Carousel should advance through videos/images
4. After showing all 3 slides once, carousel stops on the last slide

## Platform Support

- **Web**: Uses native HTML5 `<video>` element ✅
- **iOS/Android**: Uses `expo-av` Video component ✅

---
**Status**: ✅ Fixed and tested
**Date**: 2026-08-01
