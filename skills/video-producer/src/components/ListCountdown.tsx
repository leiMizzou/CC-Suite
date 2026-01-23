import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from 'remotion';

export interface ListCountdownProps {
  title: string;
  subtitle: string;
  items: string[];
  backgroundColor: string;
  textColor: string;
  accentColor: string;
}

export const ListCountdown: React.FC<ListCountdownProps> = ({
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
  const baseFontSize = isVertical ? 48 : 56;

  // Title animation
  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const titleOpacity = interpolate(titleProgress, [0, 1], [0, 1]);
  const titleY = interpolate(titleProgress, [0, 1], [-30, 0]);

  // Reverse items for countdown effect (show last item first if desired)
  const displayItems = [...items].reverse();

  return (
    <AbsoluteFill
      style={{
        backgroundColor,
        display: 'flex',
        flexDirection: 'column',
        padding: isVertical ? 80 : 60,
      }}
    >
      {/* Header */}
      <div
        style={{
          opacity: titleOpacity,
          transform: `translateY(${titleY}px)`,
          textAlign: 'center',
          marginBottom: 60,
        }}
      >
        <div
          style={{
            color: accentColor,
            fontSize: baseFontSize * 0.6,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            fontWeight: 600,
            marginBottom: 15,
          }}
        >
          {subtitle}
        </div>
        <div
          style={{
            color: textColor,
            fontSize: baseFontSize * 1.4,
            fontWeight: 'bold',
            fontFamily: 'system-ui, -apple-system, sans-serif',
          }}
        >
          {title}
        </div>
      </div>

      {/* List items */}
      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          gap: isVertical ? 30 : 25,
        }}
      >
        {displayItems.map((item, index) => {
          const rank = displayItems.length - index;
          const startFrame = 30 + index * 20;

          const itemProgress = spring({
            frame: frame - startFrame,
            fps,
            config: { damping: 200, stiffness: 80 },
          });

          const itemOpacity = interpolate(itemProgress, [0, 1], [0, 1], {
            extrapolateLeft: 'clamp',
          });
          const itemX = interpolate(itemProgress, [0, 1], [100, 0], {
            extrapolateLeft: 'clamp',
          });
          const itemScale = interpolate(itemProgress, [0, 0.5, 1], [0.8, 1.05, 1], {
            extrapolateLeft: 'clamp',
          });

          // Highlight top 3
          const isTop3 = rank <= 3;
          const rankColors = ['#ffd700', '#c0c0c0', '#cd7f32'];
          const rankColor = isTop3 ? rankColors[rank - 1] : accentColor;

          return (
            <div
              key={index}
              style={{
                opacity: itemOpacity,
                transform: `translateX(${itemX}px) scale(${itemScale})`,
                display: 'flex',
                alignItems: 'center',
                gap: 20,
                padding: isVertical ? '25px 30px' : '20px 25px',
                backgroundColor: `${textColor}08`,
                borderRadius: 16,
                border: isTop3 ? `2px solid ${rankColor}44` : 'none',
              }}
            >
              {/* Rank number */}
              <div
                style={{
                  width: isVertical ? 70 : 60,
                  height: isVertical ? 70 : 60,
                  borderRadius: '50%',
                  backgroundColor: `${rankColor}22`,
                  border: `3px solid ${rankColor}`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: rankColor,
                  fontSize: baseFontSize * 0.8,
                  fontWeight: 'bold',
                  fontFamily: 'system-ui, -apple-system, sans-serif',
                  flexShrink: 0,
                }}
              >
                {rank}
              </div>

              {/* Item text */}
              <div
                style={{
                  color: textColor,
                  fontSize: baseFontSize * (isTop3 ? 0.7 : 0.6),
                  fontFamily: 'system-ui, -apple-system, sans-serif',
                  fontWeight: isTop3 ? 600 : 400,
                  flex: 1,
                  lineHeight: 1.3,
                }}
              >
                {item}
              </div>
            </div>
          );
        })}
      </div>

      {/* Bottom decoration */}
      <div
        style={{
          height: 4,
          background: `linear-gradient(90deg, transparent, ${accentColor}, transparent)`,
          marginTop: 40,
          borderRadius: 2,
        }}
      />
    </AbsoluteFill>
  );
};
