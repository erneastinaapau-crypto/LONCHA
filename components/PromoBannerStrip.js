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
  const scrollAnimation = useRef(new Animated.Value(0)).current;
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

  useEffect(() => {
    fetchPromoBanners();
  }, []);

  // Auto-scroll animation using Animated API
  useEffect(() => {
    if (loading || !banners || banners.length <= 3) return; // Only animate if more than 3 banners

    // Calculate total width of one set of banners
    const contentWidth = banners.length * (cardWidth + cardGap);
    
    // Animation duration - slower = more time to read
    const animationDuration = contentWidth * 30; // 30ms per pixel

    const startAnimation = () => {
      scrollAnimation.setValue(0);
      
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

    if (!isPausedRef.current) {
      startAnimation();
    }

    return () => {
      scrollAnimation.stopAnimation();
    };
  }, [loading, banners, cardWidth, cardGap]);

  const handlePressIn = () => {
    isPausedRef.current = true;
    scrollAnimation.stopAnimation();
  };

  const handlePressOut = () => {
    isPausedRef.current = false;
    // Restart animation from current position
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
      <View style={{ overflow: 'hidden' }}>
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
          {/* Duplicate banners for seamless infinite scroll */}
          {[...banners, ...banners, ...banners].map((banner, index) => (
            <Pressable
              key={`${banner.id}-${index}`}
              style={[styles.bannerCard, { width: cardWidth, height: cardHeight }]}
              onPress={() => onBannerPress?.(banner)}
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
        </Animated.View>
      </View>
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
