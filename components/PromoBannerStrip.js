import React, { useEffect, useState, useRef } from 'react';
import { View, Text, Image, ImageBackground, StyleSheet, Pressable, ScrollView, useWindowDimensions, Platform, Animated } from 'react-native';
import { supabase } from '../lib/supabase';

const FALLBACK_BANNERS = [
  {
    id: 'f1',
    title: 'Luxury Autumn Collection',
    subtitle: 'Luxury footwear for every occasion',
    image_url: 'https://images.unsplash.com/photo-1543163521-1bf539e0cf6d?auto=format&fit=crop&w=900&q=80',
    promo_label: 'HOT DEAL',
    label_color: '#F59E0B',
  },
  {
    id: 'f2',
    title: 'Premium Sneaker Sale',
    subtitle: 'Up to 30% off selected styles this week',
    image_url: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
    promo_label: 'SALE 30%',
    label_color: '#EF4444',
  },
  {
    id: 'f3',
    title: 'New Season Arrivals',
    subtitle: 'Fresh designs from Nike, Adidas & more',
    image_url: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9ff?auto=format&fit=crop&w=900&q=80',
    promo_label: 'NEW',
    label_color: '#10B981',
  },
];

export default function PromoBannerStrip({ onBannerPress }) {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  const { width } = useWindowDimensions();
  const scrollViewRef = useRef(null);
  const scrollX = useRef(0);
  const animationFrameRef = useRef(null);
  const isPausedRef = useRef(false);

  // Detect phone vs desktop/tablet
  const isPhone = width < 768;

  // Calculate card width to fill the row with equal spacing
  const numCards = 3; // Number of cards visible at once
  const horizontalPadding = 32; // 16px on each side
  const cardGap = 12; // Gap between cards
  const totalGaps = (numCards - 1) * cardGap;
  const cardWidth = (width - horizontalPadding - totalGaps) / numCards;

  // Reduced height for phone
  const cardHeight = isPhone ? 110 : 150;

  // Animation speed (pixels per frame)
  const scrollSpeed = 0.5;

  useEffect(() => {
    fetchPromoBanners();
  }, []);

  // Auto-scroll animation
  useEffect(() => {
    if (loading || !banners || banners.length <= 1) return;

    const animate = () => {
      if (!isPausedRef.current && scrollViewRef.current) {
        scrollX.current += scrollSpeed;

        // Calculate total scrollable width
        // Each banner is cardWidth + cardGap, except the last one
        const contentWidth = banners.length * (cardWidth + cardGap);
        
        // Reset to start when we've scrolled past half the content
        // This creates a seamless infinite loop effect
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

  const handlePressIn = () => {
    isPausedRef.current = true;
  };

  const handlePressOut = () => {
    isPausedRef.current = false;
  };

  const fetchPromoBanners = async () => {
    try {
      // Fetch ALL rows — no is_active filter
      const { data, error } = await supabase
        .from('promotional_banners')
        .select('*')
        .order('display_position', { ascending: true });

      if (error) throw error;
      setBanners(data && data.length > 0 ? data : FALLBACK_BANNERS);
      console.log('[PromoBanners] Loaded', data?.length || 0, 'banners from database');
    } catch (error) {
      console.warn('[PromoBanners] Using fallback data:', error.message);
      setBanners(FALLBACK_BANNERS);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <View style={[styles.skeletonCard, { width: cardWidth, height: cardHeight }]} />
        <View style={[styles.skeletonCard, { width: cardWidth, height: cardHeight }]} />
        <View style={[styles.skeletonCard, { width: cardWidth, height: cardHeight }]} />
      </View>
    );
  }

  if (!banners || banners.length === 0) {
    return null;
  }

  return (
    <View style={styles.container}>
      <ScrollView
        ref={scrollViewRef}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
        scrollEventThrottle={16}
        onTouchStart={handlePressIn}
        onTouchEnd={handlePressOut}
        onMouseEnter={() => { isPausedRef.current = true; }}
        onMouseLeave={() => { isPausedRef.current = false; }}
      >
        {/* Duplicate banners for seamless infinite scroll */}
        {[...banners, ...banners].map((banner, index) => (
          <Pressable
            key={`${banner.id}-${index}`}
            style={[styles.bannerCard, { width: cardWidth, height: cardHeight }]}
            onPress={() => onBannerPress?.(banner)}
            onPressIn={handlePressIn}
            onPressOut={handlePressOut}
            accessibilityRole="button"
            accessibilityLabel={`${banner.promo_label}: ${banner.title}`}
          >
            {/* LAYER 1 (bottom): Blurred backdrop - web uses CSS filter, native uses blurRadius */}
            {Platform.OS === 'web' ? (
              <View style={{ ...StyleSheet.absoluteFillObject, overflow: 'hidden', zIndex: 0 }}>
                <Image
                  source={{ uri: banner.image_url }}
                  style={{
                    position: 'absolute',
                    top: 0, left: 0, right: 0, bottom: 0,
                    width: '100%', height: '100%',
                    filter: 'blur(18px)',
                    transform: [{ scale: 1.12 }],
                  }}
                  resizeMode="cover"
                />
                <View style={{ ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(255,255,255,0.15)' }} />
              </View>
            ) : (
              <ImageBackground
                source={{ uri: banner.image_url }}
                style={{ ...StyleSheet.absoluteFillObject, zIndex: 0 }}
                blurRadius={50}
                resizeMode="cover"
              >
                <View style={{ ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(255,255,255,0.15)' }} />
              </ImageBackground>
            )}

            {/* LAYER 2: Sharp centered foreground image */}
            <Image
              source={{ uri: banner.image_url }}
              style={styles.bannerImage}
              resizeMode="contain"
            />

            {/* LAYER 3: Dark overlay for text readability */}
            <View style={styles.overlay} />

            {/* LAYER 4 (top): Promo badge */}
            <View
              style={[
                styles.promoBadge,
                { backgroundColor: banner.label_color || '#FF6B6B' },
              ]}
            >
              <Text style={styles.promoBadgeText}>{banner.promo_label || 'PROMO'}</Text>
            </View>

            {/* LAYER 4 (top): Text content */}
            <View style={styles.textContent}>
              <Text style={[styles.bannerTitle, isPhone && styles.bannerTitlePhone]} numberOfLines={2}>
                {banner.title}
              </Text>
              {banner.subtitle && (
                <Text style={[styles.bannerSubtitle, isPhone && styles.bannerSubtitlePhone]} numberOfLines={2}>
                  {banner.subtitle}
                </Text>
              )}
              {banner.discount_percentage > 0 && (
                <Text style={[styles.discountText, isPhone && styles.discountTextPhone]}>
                  {banner.discount_percentage}% OFF
                </Text>
              )}
            </View>
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  loadingContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    gap: 12,
    marginVertical: 16,
    justifyContent: 'center',
  },
  skeletonCard: {
    // width and height are set dynamically via inline style
    borderRadius: 12,
    backgroundColor: '#E5E7EB',
  },
  scrollContent: {
    paddingHorizontal: 16,
    gap: 12,
  },
  bannerCard: {
    // width and height are set dynamically via inline style
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: '#1B1C1C',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
  },
  bannerImage: {
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.35)',
  },
  promoBadge: {
    position: 'absolute',
    top: 12,
    left: 12,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 6,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.3,
    shadowRadius: 2,
  },
  promoBadgeText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  textContent: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: 14,
  },
  bannerTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 4,
    letterSpacing: 0.3,
  },
  bannerTitlePhone: {
    fontSize: 13,
    marginBottom: 2,
  },
  bannerSubtitle: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.85)',
    lineHeight: 16,
    marginBottom: 4,
  },
  bannerSubtitlePhone: {
    fontSize: 10,
    lineHeight: 14,
    marginBottom: 2,
  },
  discountText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFD700',
    marginTop: 4,
  },
  discountTextPhone: {
    fontSize: 12,
    marginTop: 2,
  },
});
