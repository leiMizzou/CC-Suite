import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from 'remotion';

export interface DataVisualizationProps {
  title: string;
  subtitle: string;
  items: string[];
  backgroundColor: string;
  textColor: string;
  accentColor: string;
}

export const DataVisualization: React.FC<DataVisualizationProps> = ({
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
  const baseFontSize = isVertical ? 50 : 64;

  // Title animation
  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 200, stiffness: 100 },
  });

  const titleOpacity = interpolate(titleProgress, [0, 1], [0, 1]);
  const titleScale = interpolate(titleProgress, [0, 1], [0.8, 1]);

  return (
    <AbsoluteFill
      style={{
        backgroundColor,
        display: 'flex',
        flexDirection: 'column',
        padding: isVertical ? 60 : 80,
      }}
    >
      {/* Header */}
      <div
        style={{
          opacity: titleOpacity,
          transform: `scale(${titleScale})`,
          marginBottom: 40,
        }}
      >
        <div
          style={{
            color: accentColor,
            fontSize: baseFontSize * 0.5,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            fontWeight: 600,
            letterSpacing: 2,
            textTransform: 'uppercase',
            marginBottom: 10,
          }}
        >
          {subtitle}
        </div>
        <div
          style={{
            color: textColor,
            fontSize: baseFontSize * 1.2,
            fontWeight: 'bold',
            fontFamily: 'system-ui, -apple-system, sans-serif',
          }}
        >
          {title}
        </div>
      </div>

      {/* Data bars */}
      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          gap: isVertical ? 40 : 30,
        }}
      >
        {items.map((item, index) => {
          // Parse percentage from item if format is "Label: XX%"
          const match = item.match(/(\d+)%?$/);
          const percentage = match ? parseInt(match[1], 10) : 50 + Math.random() * 50;

          const barProgress = interpolate(
            frame,
            [30 + index * 15, 60 + index * 15],
            [0, percentage / 100],
            {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
              easing: Easing.out(Easing.cubic),
            }
          );

          const labelOpacity = interpolate(
            frame,
            [20 + index * 15, 35 + index * 15],
            [0, 1],
            { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
          );

          return (
            <div key={index} style={{ opacity: labelOpacity }}>
              {/* Label */}
              <div
                style={{
                  color: textColor,
                  fontSize: baseFontSize * 0.5,
                  fontFamily: 'system-ui, -apple-system, sans-serif',
                  marginBottom: 12,
                  display: 'flex',
                  justifyContent: 'space-between',
                }}
              >
                <span>{item.replace(/:\s*\d+%?$/, '')}</span>
                <span style={{ color: accentColor, fontWeight: 'bold' }}>
                  {Math.round(barProgress * 100)}%
                </span>
              </div>

              {/* Bar background */}
              <div
                style={{
                  width: '100%',
                  height: isVertical ? 24 : 20,
                  backgroundColor: `${textColor}15`,
                  borderRadius: 10,
                  overflow: 'hidden',
                }}
              >
                {/* Bar fill */}
                <div
                  style={{
                    width: `${barProgress * 100}%`,
                    height: '100%',
                    background: `linear-gradient(90deg, ${accentColor}, ${accentColor}aa)`,
                    borderRadius: 10,
                    boxShadow: `0 0 20px ${accentColor}44`,
                  }}
                />
              </div>
            </div>
          );
        })}
      </div>

      {/* Decorative grid */}
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundImage: `
            linear-gradient(${textColor}08 1px, transparent 1px),
            linear-gradient(90deg, ${textColor}08 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px',
          pointerEvents: 'none',
        }}
      />
    </AbsoluteFill>
  );
};
