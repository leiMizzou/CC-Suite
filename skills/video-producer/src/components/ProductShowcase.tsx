import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from 'remotion';

export interface ProductShowcaseProps {
  title: string;
  subtitle: string;
  items: string[];
  backgroundColor: string;
  textColor: string;
  accentColor: string;
}

export const ProductShowcase: React.FC<ProductShowcaseProps> = ({
  title,
  subtitle,
  items,
  backgroundColor,
  textColor,
  accentColor,
}) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const isVertical = height > width;
  const baseFontSize = isVertical ? 52 : 64;

  // Background gradient animation
  const gradientRotation = interpolate(frame, [0, 450], [0, 360], {
    extrapolateRight: 'clamp',
  });

  // Title animation
  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const titleOpacity = interpolate(titleProgress, [0, 1], [0, 1]);
  const titleY = interpolate(titleProgress, [0, 1], [40, 0]);

  // Subtitle animation
  const subtitleProgress = spring({
    frame: frame - 10,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const subtitleOpacity = interpolate(subtitleProgress, [0, 1], [0, 1], {
    extrapolateLeft: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        padding: isVertical ? 60 : 100,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      {/* Animated gradient background */}
      <div
        style={{
          position: 'absolute',
          top: '-50%',
          left: '-50%',
          right: '-50%',
          bottom: '-50%',
          background: `conic-gradient(from ${gradientRotation}deg, ${accentColor}11, transparent, ${accentColor}11, transparent)`,
          pointerEvents: 'none',
        }}
      />

      {/* Glow effect */}
      <div
        style={{
          position: 'absolute',
          width: isVertical ? 400 : 600,
          height: isVertical ? 400 : 600,
          borderRadius: '50%',
          background: `radial-gradient(circle, ${accentColor}22, transparent 70%)`,
          filter: 'blur(60px)',
          pointerEvents: 'none',
        }}
      />

      {/* Content */}
      <div
        style={{
          position: 'relative',
          zIndex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          textAlign: 'center',
        }}
      >
        {/* Product icon/badge */}
        <div
          style={{
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
            width: isVertical ? 120 : 140,
            height: isVertical ? 120 : 140,
            borderRadius: 30,
            background: `linear-gradient(135deg, ${accentColor}, ${accentColor}88)`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 40,
            boxShadow: `0 20px 60px ${accentColor}44`,
          }}
        >
          <div
            style={{
              color: '#fff',
              fontSize: baseFontSize * 1.2,
              fontWeight: 'bold',
              fontFamily: 'system-ui, -apple-system, sans-serif',
            }}
          >
            {title.charAt(0)}
          </div>
        </div>

        {/* Title */}
        <div
          style={{
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
            color: textColor,
            fontSize: baseFontSize * 1.3,
            fontWeight: 'bold',
            fontFamily: 'system-ui, -apple-system, sans-serif',
            marginBottom: 15,
          }}
        >
          {title}
        </div>

        {/* Subtitle */}
        <div
          style={{
            opacity: subtitleOpacity,
            color: textColor,
            fontSize: baseFontSize * 0.6,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            opacity: 0.7,
            marginBottom: 60,
          }}
        >
          {subtitle}
        </div>

        {/* Feature list */}
        <div
          style={{
            display: 'flex',
            flexDirection: isVertical ? 'column' : 'row',
            gap: isVertical ? 25 : 40,
            flexWrap: 'wrap',
            justifyContent: 'center',
          }}
        >
          {items.map((item, index) => {
            const featureProgress = spring({
              frame: frame - 40 - index * 12,
              fps,
              config: { damping: 200, stiffness: 100 },
            });

            const featureOpacity = interpolate(featureProgress, [0, 1], [0, 1], {
              extrapolateLeft: 'clamp',
            });
            const featureY = interpolate(featureProgress, [0, 1], [30, 0], {
              extrapolateLeft: 'clamp',
            });

            return (
              <div
                key={index}
                style={{
                  opacity: featureOpacity,
                  transform: `translateY(${featureY}px)`,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  padding: '15px 25px',
                  backgroundColor: `${textColor}0a`,
                  borderRadius: 50,
                  border: `1px solid ${textColor}15`,
                }}
              >
                {/* Checkmark */}
                <div
                  style={{
                    width: 28,
                    height: 28,
                    borderRadius: '50%',
                    backgroundColor: `${accentColor}22`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: 'bold',
                  }}
                >
                  ✓
                </div>

                {/* Feature text */}
                <div
                  style={{
                    color: textColor,
                    fontSize: baseFontSize * 0.45,
                    fontFamily: 'system-ui, -apple-system, sans-serif',
                  }}
                >
                  {item}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </AbsoluteFill>
  );
};
