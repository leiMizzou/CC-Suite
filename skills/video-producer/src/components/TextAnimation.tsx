import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from 'remotion';

export interface TextAnimationProps {
  title: string;
  subtitle: string;
  items: string[];
  backgroundColor: string;
  textColor: string;
  accentColor: string;
}

export const TextAnimation: React.FC<TextAnimationProps> = ({
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
  const baseFontSize = isVertical ? 60 : 80;

  // Title animation
  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const titleOpacity = interpolate(titleProgress, [0, 1], [0, 1]);
  const titleY = interpolate(titleProgress, [0, 1], [50, 0]);

  // Subtitle animation (delayed)
  const subtitleProgress = spring({
    frame: frame - 15,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const subtitleOpacity = interpolate(subtitleProgress, [0, 1], [0, 1], {
    extrapolateLeft: 'clamp',
  });
  const subtitleY = interpolate(subtitleProgress, [0, 1], [30, 0], {
    extrapolateLeft: 'clamp',
  });

  // Accent line animation
  const lineWidth = interpolate(frame, [30, 60], [0, 200], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
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
      }}
    >
      {/* Title */}
      <div
        style={{
          opacity: titleOpacity,
          transform: `translateY(${titleY}px)`,
          color: textColor,
          fontSize: baseFontSize * 1.5,
          fontWeight: 'bold',
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
          lineHeight: 1.2,
          maxWidth: '90%',
        }}
      >
        {title}
      </div>

      {/* Accent line */}
      <div
        style={{
          width: lineWidth,
          height: 4,
          backgroundColor: accentColor,
          marginTop: 30,
          marginBottom: 30,
          borderRadius: 2,
        }}
      />

      {/* Subtitle */}
      <div
        style={{
          opacity: subtitleOpacity,
          transform: `translateY(${subtitleY}px)`,
          color: textColor,
          fontSize: baseFontSize,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
          opacity: 0.8,
          maxWidth: '80%',
        }}
      >
        {subtitle}
      </div>

      {/* Items (if provided) */}
      {items.length > 0 && (
        <div
          style={{
            marginTop: 60,
            display: 'flex',
            flexDirection: 'column',
            gap: 20,
            alignItems: 'center',
          }}
        >
          {items.map((item, index) => {
            const itemProgress = spring({
              frame: frame - 45 - index * 10,
              fps,
              config: { damping: 200, stiffness: 100 },
            });

            const itemOpacity = interpolate(itemProgress, [0, 1], [0, 1], {
              extrapolateLeft: 'clamp',
            });
            const itemX = interpolate(itemProgress, [0, 1], [-50, 0], {
              extrapolateLeft: 'clamp',
            });

            return (
              <div
                key={index}
                style={{
                  opacity: itemOpacity,
                  transform: `translateX(${itemX}px)`,
                  color: textColor,
                  fontSize: baseFontSize * 0.6,
                  fontFamily: 'system-ui, -apple-system, sans-serif',
                  padding: '15px 30px',
                  backgroundColor: `${accentColor}22`,
                  borderLeft: `4px solid ${accentColor}`,
                  borderRadius: 8,
                }}
              >
                {item}
              </div>
            );
          })}
        </div>
      )}
    </AbsoluteFill>
  );
};
