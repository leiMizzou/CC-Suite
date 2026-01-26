import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
  Sequence,
  Audio,
  staticFile,
} from 'remotion';

export interface CCPromoProps {
  theme?: 'dark' | 'light';
}

// Figma-style color palette
const colors = {
  // Light, trendy gradients
  bgLight: '#f8f9ff',
  bgGradient1: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  bgGradient2: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  bgGradient3: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  bgGradient4: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  // Accent colors
  purple: '#a855f7',
  pink: '#ec4899',
  blue: '#3b82f6',
  cyan: '#06b6d4',
  green: '#10b981',
  orange: '#f97316',
  // Text
  dark: '#1e1b4b',
  gray: '#64748b',
};

// Scene 1: Epic Intro - Figma Style
const IntroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoScale = spring({
    frame,
    fps,
    config: { damping: 8, stiffness: 120, mass: 0.5 },
  });

  const logoRotate = interpolate(frame, [0, 30], [-10, 0], {
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.back(1.5)),
  });

  const titleProgress = spring({
    frame: frame - 15,
    fps,
    config: { damping: 10, stiffness: 150 },
  });

  const subtitleProgress = spring({
    frame: frame - 35,
    fps,
    config: { damping: 12, stiffness: 100 },
  });

  // Floating orbs with more dynamic movement
  const orbs = Array.from({ length: 8 }, (_, i) => ({
    x: Math.sin(i * 0.8 + frame * 0.04) * 500 + 960,
    y: Math.cos(i * 1.2 + frame * 0.03) * 350 + 540,
    size: 80 + i * 30,
    color: ['#a855f7', '#ec4899', '#3b82f6', '#06b6d4', '#10b981', '#f97316', '#8b5cf6', '#f472b6'][i],
    opacity: 0.15 + Math.sin(i + frame * 0.05) * 0.1,
  }));

  // Animated gradient background rotation
  const bgRotation = interpolate(frame, [0, 120], [0, 15], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(${135 + bgRotation}deg, #faf5ff 0%, #f0e7ff 30%, #e0f2fe 70%, #f0fdf4 100%)`,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      {/* Floating gradient orbs */}
      {orbs.map((orb, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: orb.x - orb.size / 2,
            top: orb.y - orb.size / 2,
            width: orb.size,
            height: orb.size,
            borderRadius: '50%',
            background: `radial-gradient(circle, ${orb.color}40, ${orb.color}00)`,
            opacity: orb.opacity,
            filter: 'blur(40px)',
          }}
        />
      ))}

      {/* Animated rings */}
      {[300, 400, 500].map((size, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            width: size,
            height: size,
            borderRadius: '50%',
            border: `2px solid rgba(168, 85, 247, ${0.2 - i * 0.05})`,
            transform: `rotate(${frame * (1 + i * 0.5)}deg)`,
          }}
        />
      ))}

      {/* Logo with bounce */}
      <div
        style={{
          transform: `scale(${logoScale}) rotate(${logoRotate}deg)`,
          marginBottom: 20,
        }}
      >
        <div
          style={{
            width: 180,
            height: 180,
            borderRadius: 40,
            background: 'linear-gradient(135deg, #a855f7 0%, #ec4899 50%, #f97316 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 30px 60px rgba(168, 85, 247, 0.4)',
          }}
        >
          <span style={{ fontSize: 100 }}>⚡</span>
        </div>
      </div>

      {/* Title with gradient */}
      <div
        style={{
          opacity: interpolate(titleProgress, [0, 1], [0, 1]),
          transform: `translateY(${interpolate(titleProgress, [0, 1], [60, 0])}px) scale(${interpolate(titleProgress, [0, 1], [0.8, 1])})`,
          fontSize: 130,
          fontWeight: 900,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 50%, #f97316 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          letterSpacing: -3,
        }}
      >
        CC Suite
      </div>

      {/* Subtitle with slide-up */}
      <div
        style={{
          opacity: interpolate(subtitleProgress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
          transform: `translateY(${interpolate(subtitleProgress, [0, 1], [30, 0], { extrapolateLeft: 'clamp' })}px)`,
          fontSize: 32,
          color: colors.gray,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          marginTop: 25,
          letterSpacing: 6,
          fontWeight: 500,
        }}
      >
        THE STANDARD LIBRARY FOR CLAUDE CODE
      </div>
    </AbsoluteFill>
  );
};

// Scene 2: Value Proposition - Figma Style with Dynamic Animations
const ValueScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const values = [
    { icon: '🔍', text: '发现趋势', sub: 'Discover', gradient: 'linear-gradient(135deg, #3b82f6, #06b6d4)' },
    { icon: '⚡', text: '高效开发', sub: 'Develop', gradient: 'linear-gradient(135deg, #ec4899, #f97316)' },
    { icon: '🛡️', text: '对抗验证', sub: 'Verify', gradient: 'linear-gradient(135deg, #8b5cf6, #a855f7)' },
    { icon: '📢', text: '快速传播', sub: 'Publish', gradient: 'linear-gradient(135deg, #10b981, #34d399)' },
  ];

  // More dynamic rotation
  const rotation = interpolate(frame, [0, 120], [0, 180], {
    extrapolateRight: 'clamp',
    easing: Easing.inOut(Easing.cubic),
  });

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 10, stiffness: 120 },
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(180deg, #faf5ff 0%, #f0f9ff 50%, #ecfdf5 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 80,
        overflow: 'hidden',
      }}
    >
      {/* Background decorative elements */}
      <div
        style={{
          position: 'absolute',
          top: -200,
          right: -200,
          width: 600,
          height: 600,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(168, 85, 247, 0.1), transparent 70%)',
          filter: 'blur(60px)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: -200,
          left: -200,
          width: 500,
          height: 500,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(59, 130, 246, 0.1), transparent 70%)',
          filter: 'blur(60px)',
        }}
      />

      {/* Title */}
      <div
        style={{
          opacity: interpolate(titleProgress, [0, 1], [0, 1]),
          transform: `translateY(${interpolate(titleProgress, [0, 1], [40, 0])}px)`,
          fontSize: 60,
          fontWeight: 800,
          background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: 15,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
        }}
      >
        AI 时代的开发者闭环
      </div>

      <div
        style={{
          fontSize: 26,
          color: colors.gray,
          marginBottom: 60,
          fontFamily: 'system-ui',
          opacity: interpolate(frame, [20, 40], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
        }}
      >
        从信息发现到价值传播，一站式解决
      </div>

      {/* Circular flow with dynamic center */}
      <div style={{ position: 'relative', width: 900, height: 480 }}>
        {/* Animated center hub */}
        <div
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            transform: `translate(-50%, -50%) scale(${interpolate(frame, [0, 30], [0, 1], { extrapolateRight: 'clamp', easing: Easing.out(Easing.back(1.5)) })})`,
          }}
        >
          {/* Pulsing rings */}
          {[1, 2, 3].map((ring) => (
            <div
              key={ring}
              style={{
                position: 'absolute',
                left: '50%',
                top: '50%',
                transform: 'translate(-50%, -50%)',
                width: 100 + ring * 40,
                height: 100 + ring * 40,
                borderRadius: '50%',
                border: `2px solid rgba(168, 85, 247, ${0.3 - ring * 0.08})`,
                opacity: Math.sin(frame * 0.1 - ring * 0.5) * 0.3 + 0.5,
              }}
            />
          ))}
          <div
            style={{
              width: 110,
              height: 110,
              borderRadius: '50%',
              background: 'linear-gradient(135deg, #a855f7 0%, #ec4899 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 20px 50px rgba(168, 85, 247, 0.4)',
            }}
          >
            <span style={{ fontSize: 42, color: '#fff', fontWeight: 'bold', fontFamily: 'system-ui' }}>CC</span>
          </div>
        </div>

        {/* Rotating connector line */}
        <svg
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            transform: `translate(-50%, -50%) rotate(${rotation}deg)`,
            width: 320,
            height: 320,
          }}
        >
          <defs>
            <linearGradient id="gradRing" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#3b82f6" />
              <stop offset="33%" stopColor="#a855f7" />
              <stop offset="66%" stopColor="#ec4899" />
              <stop offset="100%" stopColor="#10b981" />
            </linearGradient>
          </defs>
          <circle
            cx="160"
            cy="160"
            r="150"
            fill="none"
            stroke="url(#gradRing)"
            strokeWidth="3"
            strokeDasharray="40 20"
            strokeLinecap="round"
          />
        </svg>

        {/* Value cards with staggered bounce animation */}
        {values.map((value, i) => {
          const delay = i * 8;
          const progress = spring({
            frame: frame - delay - 20,
            fps,
            config: { damping: 8, stiffness: 100, mass: 0.8 },
          });

          const floatY = Math.sin(frame * 0.06 + i * 1.5) * 8;

          const positions = [
            { x: -380, y: -110 },
            { x: 380, y: -110 },
            { x: -380, y: 130 },
            { x: 380, y: 130 },
          ];

          return (
            <div
              key={i}
              style={{
                position: 'absolute',
                left: '50%',
                top: '50%',
                transform: `translate(calc(-50% + ${positions[i].x}px), calc(-50% + ${positions[i].y + floatY}px)) scale(${interpolate(progress, [0, 1], [0.5, 1], { extrapolateLeft: 'clamp' })})`,
                opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
              }}
            >
              <div
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  padding: '28px 40px',
                  background: '#fff',
                  borderRadius: 24,
                  boxShadow: '0 15px 40px rgba(0,0,0,0.08)',
                  minWidth: 170,
                }}
              >
                <div
                  style={{
                    width: 70,
                    height: 70,
                    borderRadius: 20,
                    background: value.gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginBottom: 15,
                    boxShadow: '0 10px 25px rgba(0,0,0,0.15)',
                  }}
                >
                  <span style={{ fontSize: 36 }}>{value.icon}</span>
                </div>
                <span style={{ fontSize: 26, color: colors.dark, fontWeight: 700, fontFamily: 'system-ui' }}>
                  {value.text}
                </span>
                <span style={{ fontSize: 16, color: colors.gray, fontFamily: 'system-ui', marginTop: 5, textTransform: 'uppercase', letterSpacing: 2 }}>
                  {value.sub}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// Scene 3: Solution - CrossCheck - Horizontal Battle Layout
const CrossCheckScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Three models in horizontal battle formation
  const models = [
    { name: 'Claude', gradient: 'linear-gradient(135deg, #a855f7, #7c3aed)', weapon: '⚔️', x: -280 },
    { name: 'Codex', gradient: 'linear-gradient(135deg, #10b981, #059669)', weapon: '🔫', x: 0 },
    { name: 'Gemini', gradient: 'linear-gradient(135deg, #f59e0b, #d97706)', weapon: '💣', x: 280 },
  ];

  // Attack animation cycles
  const attackCycle = (frame % 45) / 45;
  const attackPhase = Math.floor(frame / 15) % 3; // Which model is attacking

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #faf5ff 0%, #f5f3ff 50%, #ede9fe 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      {/* Dynamic battle background effects */}
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: '50%',
            top: '52%',
            transform: `translate(-50%, -50%) rotate(${frame * 0.5 + i * 120}deg)`,
            width: 500 + i * 80,
            height: 500 + i * 80,
            borderRadius: '50%',
            border: `2px dashed rgba(168, 85, 247, ${0.12 - i * 0.03})`,
            opacity: 0.5,
          }}
        />
      ))}

      {/* Badge */}
      <div
        style={{
          position: 'absolute',
          top: 60,
          left: 60,
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          padding: '12px 24px',
          background: 'linear-gradient(135deg, #a855f7, #7c3aed)',
          borderRadius: 50,
          boxShadow: '0 8px 25px rgba(168, 85, 247, 0.35)',
        }}
      >
        <span style={{ fontSize: 26 }}>🛡️</span>
        <span style={{ fontSize: 22, color: '#fff', fontWeight: 700, fontFamily: 'system-ui' }}>
          CrossCheck
        </span>
      </div>

      {/* Title */}
      <div
        style={{
          fontSize: 52,
          fontWeight: 800,
          background: 'linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: 8,
          marginTop: -30,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: 'clamp' }),
          transform: `translateY(${interpolate(frame, [0, 20], [30, 0], { extrapolateRight: 'clamp' })}px)`,
        }}
      >
        模型对抗验证
      </div>

      <div
        style={{
          fontSize: 22,
          color: colors.gray,
          marginBottom: 40,
          fontFamily: 'system-ui',
          opacity: interpolate(frame, [15, 35], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
        }}
      >
        用 AI 验证 AI，消除幻觉与锯齿状智能
      </div>

      {/* Battle arena - Horizontal layout */}
      <div style={{ position: 'relative', width: 800, height: 280 }}>
        {/* Attack lines SVG */}
        <svg style={{ position: 'absolute', width: '100%', height: '100%', pointerEvents: 'none' }}>
          <defs>
            <linearGradient id="attackGrad1h" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#a855f7" />
              <stop offset="100%" stopColor="#ef4444" />
            </linearGradient>
            <linearGradient id="attackGrad2h" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#10b981" />
              <stop offset="100%" stopColor="#ef4444" />
            </linearGradient>
            <linearGradient id="attackGrad3h" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#f59e0b" />
              <stop offset="100%" stopColor="#ef4444" />
            </linearGradient>
            <filter id="attackGlowH">
              <feGaussianBlur stdDeviation="4" result="blur"/>
              <feMerge>
                <feMergeNode in="blur"/>
                <feMergeNode in="SourceGraphic"/>
              </feMerge>
            </filter>
          </defs>

          {/* Connecting dashed lines */}
          <line x1="170" y1="140" x2="350" y2="140" stroke="rgba(100,100,100,0.2)" strokeWidth="2" strokeDasharray="8 6" />
          <line x1="450" y1="140" x2="630" y2="140" stroke="rgba(100,100,100,0.2)" strokeWidth="2" strokeDasharray="8 6" />
          <path d="M 170 140 Q 400 50 630 140" fill="none" stroke="rgba(100,100,100,0.15)" strokeWidth="2" strokeDasharray="8 6" />

          {/* Attack beams */}
          {attackPhase === 0 && (
            <>
              <line x1="170" y1="140" x2={170 + 180 * attackCycle} y2="140" stroke="url(#attackGrad1h)" strokeWidth="8" filter="url(#attackGlowH)" strokeLinecap="round" />
              <circle cx={170 + 180 * attackCycle} cy="140" r="12" fill="#ef4444" filter="url(#attackGlowH)" />
            </>
          )}
          {attackPhase === 1 && (
            <>
              <line x1="450" y1="140" x2={450 + 180 * attackCycle} y2="140" stroke="url(#attackGrad2h)" strokeWidth="8" filter="url(#attackGlowH)" strokeLinecap="round" />
              <circle cx={450 + 180 * attackCycle} cy="140" r="12" fill="#ef4444" filter="url(#attackGlowH)" />
            </>
          )}
          {attackPhase === 2 && (
            <>
              <line x1="630" y1="140" x2={630 - 460 * attackCycle} y2="140" stroke="url(#attackGrad3h)" strokeWidth="8" filter="url(#attackGlowH)" strokeLinecap="round" />
              <circle cx={630 - 460 * attackCycle} cy="140" r="12" fill="#ef4444" filter="url(#attackGlowH)" />
            </>
          )}
        </svg>

        {/* Model orbs - horizontal layout */}
        {models.map((model, i) => {
          const delay = i * 10;
          const progress = spring({
            frame: frame - delay,
            fps,
            config: { damping: 8, stiffness: 120 },
          });

          // Battle shake when being attacked
          const isBeingAttacked = (attackPhase === 0 && i === 1) || (attackPhase === 1 && i === 2) || (attackPhase === 2 && i === 0);
          const shakeX = isBeingAttacked ? Math.sin(frame * 0.8) * 6 : 0;
          const shakeY = isBeingAttacked ? Math.cos(frame * 0.8) * 4 : 0;

          // Float animation
          const floatY = Math.sin(frame * 0.06 + i * 2) * 6;
          const isAttacking = attackPhase === i;

          return (
            <div
              key={i}
              style={{
                position: 'absolute',
                left: '50%',
                top: '50%',
                transform: `translate(calc(-50% + ${model.x + shakeX}px), calc(-50% + ${floatY + shakeY}px)) scale(${interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' })})`,
                opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
              }}
            >
              {/* Weapon indicator */}
              <div
                style={{
                  position: 'absolute',
                  top: -35,
                  left: '50%',
                  transform: `translateX(-50%) rotate(${isAttacking ? Math.sin(frame * 0.3) * 25 : 0}deg) scale(${isAttacking ? 1.2 : 1})`,
                  fontSize: 36,
                  opacity: isAttacking ? 1 : 0.4,
                }}
              >
                {model.weapon}
              </div>

              {/* Model orb */}
              <div
                style={{
                  width: 100,
                  height: 100,
                  borderRadius: '50%',
                  background: model.gradient,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: `0 15px 40px rgba(0,0,0,0.2)${isAttacking ? ', 0 0 40px rgba(239, 68, 68, 0.6)' : ''}`,
                  border: isAttacking ? '4px solid #ef4444' : '4px solid transparent',
                }}
              >
                <span style={{ fontSize: 42, color: '#fff', fontWeight: 800, fontFamily: 'system-ui' }}>
                  {model.name.charAt(0)}
                </span>
              </div>

              {/* Model name */}
              <div
                style={{
                  textAlign: 'center',
                  marginTop: 14,
                  fontSize: 22,
                  color: colors.dark,
                  fontFamily: 'system-ui',
                  fontWeight: 700,
                }}
              >
                {model.name}
              </div>
            </div>
          );
        })}

        {/* Spark effects around models */}
        {Array.from({ length: 6 }, (_, i) => {
          const sparkX = (i % 3 - 1) * 280;
          const sparkY = Math.sin(frame * 0.1 + i * 2) * 30;
          return (
            <div
              key={i}
              style={{
                position: 'absolute',
                left: `calc(50% + ${sparkX + Math.sin(frame * 0.08 + i) * 20}px)`,
                top: `calc(50% + ${sparkY}px)`,
                fontSize: 14 + Math.sin(frame * 0.15 + i) * 6,
                opacity: 0.5 + Math.sin(frame * 0.1 + i * 0.7) * 0.3,
                transform: `rotate(${frame * 2 + i * 60}deg)`,
              }}
            >
              ✨
            </div>
          );
        })}
      </div>

      {/* Benefits with stagger */}
      <div style={{ display: 'flex', gap: 25, marginTop: 35 }}>
        {[
          { icon: '🎯', text: '消除幻觉', gradient: 'linear-gradient(135deg, #a855f7, #7c3aed)' },
          { icon: '📐', text: '平滑锯齿智能', gradient: 'linear-gradient(135deg, #3b82f6, #06b6d4)' },
          { icon: '✓', text: '可靠决策', gradient: 'linear-gradient(135deg, #10b981, #34d399)' },
        ].map((benefit, i) => {
          const progress = spring({
            frame: frame - 70 - i * 10,
            fps,
            config: { damping: 10, stiffness: 120 },
          });

          return (
            <div
              key={i}
              style={{
                opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                transform: `translateY(${interpolate(progress, [0, 1], [30, 0], { extrapolateLeft: 'clamp' })}px)`,
                display: 'flex',
                alignItems: 'center',
                gap: 14,
                padding: '16px 28px',
                background: '#fff',
                borderRadius: 16,
                boxShadow: '0 10px 30px rgba(0,0,0,0.08)',
              }}
            >
              <div
                style={{
                  width: 45,
                  height: 45,
                  borderRadius: 12,
                  background: benefit.gradient,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <span style={{ fontSize: 22 }}>{benefit.icon}</span>
              </div>
              <span style={{ fontSize: 22, color: colors.dark, fontFamily: 'system-ui', fontWeight: 600 }}>{benefit.text}</span>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// Scene 4: Solution - SocialPublisher - Figma Style
const SocialScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const steps = [
    { icon: '🔍', title: '发现趋势', desc: '搜索热门技术讨论', gradient: 'linear-gradient(135deg, #3b82f6, #06b6d4)' },
    { icon: '🧠', title: '理解消化', desc: 'AI 提炼核心观点', gradient: 'linear-gradient(135deg, #8b5cf6, #a855f7)' },
    { icon: '📢', title: '多平台传播', desc: '一键发布所有平台', gradient: 'linear-gradient(135deg, #10b981, #34d399)' },
  ];

  const platforms = [
    { icon: '𝕏', name: 'Twitter', color: '#000' },
    { icon: '💬', name: '微信', color: '#07c160' },
    { icon: '📕', name: '小红书', color: '#fe2c55' },
  ];

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #ecfeff 0%, #f0f9ff 50%, #eff6ff 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 80,
        overflow: 'hidden',
      }}
    >
      {/* Background blobs */}
      <div style={{ position: 'absolute', top: -100, left: -100, width: 400, height: 400, borderRadius: '50%', background: 'radial-gradient(circle, rgba(6, 182, 212, 0.15), transparent 70%)', filter: 'blur(50px)' }} />
      <div style={{ position: 'absolute', bottom: -100, right: -100, width: 500, height: 500, borderRadius: '50%', background: 'radial-gradient(circle, rgba(16, 185, 129, 0.12), transparent 70%)', filter: 'blur(50px)' }} />

      {/* Badge */}
      <div
        style={{
          position: 'absolute',
          top: 70,
          left: 70,
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          padding: '12px 24px',
          background: 'linear-gradient(135deg, #06b6d4, #10b981)',
          borderRadius: 50,
          boxShadow: '0 8px 25px rgba(6, 182, 212, 0.3)',
        }}
      >
        <span style={{ fontSize: 26 }}>📢</span>
        <span style={{ fontSize: 22, color: '#fff', fontWeight: 700, fontFamily: 'system-ui' }}>
          SocialPublisher
        </span>
      </div>

      {/* Title */}
      <div
        style={{
          fontSize: 56,
          fontWeight: 800,
          background: 'linear-gradient(135deg, #0891b2 0%, #059669 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: 15,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
          opacity: interpolate(frame, [0, 20], [0, 1], { extrapolateRight: 'clamp' }),
          transform: `translateY(${interpolate(frame, [0, 20], [30, 0], { extrapolateRight: 'clamp' })}px)`,
        }}
      >
        发现趋势 · 理解传播
      </div>

      <div
        style={{
          fontSize: 24,
          color: colors.gray,
          marginBottom: 50,
          fontFamily: 'system-ui',
          opacity: interpolate(frame, [15, 35], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
        }}
      >
        从信息噪音中提炼价值，扩大你的技术影响力
      </div>

      {/* Flow steps with animated connectors */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 20, marginBottom: 50 }}>
        {steps.map((step, i) => {
          const delay = i * 15;
          const progress = spring({
            frame: frame - delay - 10,
            fps,
            config: { damping: 10, stiffness: 120 },
          });

          const floatY = Math.sin(frame * 0.07 + i * 2) * 6;
          const isLast = i === steps.length - 1;

          return (
            <React.Fragment key={i}>
              <div
                style={{
                  opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                  transform: `translateY(${interpolate(progress, [0, 1], [50, floatY], { extrapolateLeft: 'clamp' })}px) scale(${interpolate(progress, [0, 1], [0.8, 1], { extrapolateLeft: 'clamp' })})`,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  padding: '35px 45px',
                  background: '#fff',
                  borderRadius: 28,
                  boxShadow: '0 20px 50px rgba(0,0,0,0.08)',
                  minWidth: 260,
                }}
              >
                <div
                  style={{
                    width: 80,
                    height: 80,
                    borderRadius: 24,
                    background: step.gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginBottom: 20,
                    boxShadow: '0 12px 30px rgba(0,0,0,0.15)',
                  }}
                >
                  <span style={{ fontSize: 42 }}>{step.icon}</span>
                </div>
                <span style={{ fontSize: 28, color: colors.dark, fontWeight: 700, fontFamily: 'system-ui', marginBottom: 8 }}>
                  {step.title}
                </span>
                <span style={{ fontSize: 18, color: colors.gray, fontFamily: 'system-ui', textAlign: 'center' }}>
                  {step.desc}
                </span>
              </div>
              {!isLast && (
                <div
                  style={{
                    fontSize: 36,
                    opacity: interpolate(frame - delay, [30, 45], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
                    transform: `translateX(${interpolate(frame - delay, [30, 45], [-10, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })}px)`,
                  }}
                >
                  <span style={{ background: 'linear-gradient(135deg, #06b6d4, #10b981)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>→</span>
                </div>
              )}
            </React.Fragment>
          );
        })}
      </div>

      {/* Platform badges with bounce */}
      <div
        style={{
          display: 'flex',
          gap: 16,
        }}
      >
        {platforms.map((platform, i) => {
          const progress = spring({
            frame: frame - 70 - i * 8,
            fps,
            config: { damping: 8, stiffness: 150 },
          });

          return (
            <div
              key={i}
              style={{
                opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                transform: `scale(${interpolate(progress, [0, 1], [0.5, 1], { extrapolateLeft: 'clamp' })})`,
                padding: '14px 28px',
                background: '#fff',
                borderRadius: 50,
                boxShadow: '0 8px 25px rgba(0,0,0,0.08)',
                display: 'flex',
                alignItems: 'center',
                gap: 10,
              }}
            >
              <span style={{ fontSize: 24 }}>{platform.icon}</span>
              <span style={{ fontSize: 20, color: colors.dark, fontFamily: 'system-ui', fontWeight: 600 }}>{platform.name}</span>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// Scene 5: Solution - BorisWorkflow - Figma Style
const WorkflowScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const tweets = [
    { text: '"CLAUDE.md 是你项目的灵魂"', likes: '2.3K' },
    { text: '"让 Claude 自己写测试，自己跑测试"', likes: '1.8K' },
    { text: '"Permission 配置决定 Agent 能力边界"', likes: '1.5K' },
  ];

  const avatarScale = spring({
    frame,
    fps,
    config: { damping: 8, stiffness: 100 },
  });

  const avatarRotate = Math.sin(frame * 0.05) * 3;

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #fdf4ff 0%, #faf5ff 50%, #f5f3ff 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 70,
        overflow: 'hidden',
      }}
    >
      {/* Background elements */}
      <div style={{ position: 'absolute', top: -150, right: -150, width: 500, height: 500, borderRadius: '50%', background: 'radial-gradient(circle, rgba(236, 72, 153, 0.12), transparent 70%)', filter: 'blur(60px)' }} />
      <div style={{ position: 'absolute', bottom: -100, left: -100, width: 400, height: 400, borderRadius: '50%', background: 'radial-gradient(circle, rgba(168, 85, 247, 0.1), transparent 70%)', filter: 'blur(50px)' }} />

      {/* Badge */}
      <div
        style={{
          position: 'absolute',
          top: 70,
          left: 70,
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          padding: '12px 24px',
          background: 'linear-gradient(135deg, #ec4899, #a855f7)',
          borderRadius: 50,
          boxShadow: '0 8px 25px rgba(236, 72, 153, 0.3)',
        }}
      >
        <span style={{ fontSize: 26 }}>⚡</span>
        <span style={{ fontSize: 22, color: '#fff', fontWeight: 700, fontFamily: 'system-ui' }}>
          BorisWorkflow
        </span>
      </div>

      {/* Boris intro */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 35, marginBottom: 40 }}>
        <div
          style={{
            transform: `scale(${avatarScale}) rotate(${avatarRotate}deg)`,
            width: 130,
            height: 130,
            borderRadius: '50%',
            background: 'linear-gradient(135deg, #ec4899 0%, #a855f7 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 65,
            boxShadow: '0 20px 50px rgba(236, 72, 153, 0.35)',
          }}
        >
          👨‍💻
        </div>
        <div>
          <div style={{ fontSize: 46, fontWeight: 800, color: colors.dark, fontFamily: 'system-ui' }}>
            Boris Cherny
          </div>
          <div style={{ fontSize: 24, color: colors.gray, fontFamily: 'system-ui', display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 20 }}>𝕏</span> Claude Code 之父 · @anthropic
          </div>
        </div>
      </div>

      {/* Title */}
      <div
        style={{
          fontSize: 40,
          fontWeight: 700,
          color: colors.dark,
          marginBottom: 40,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
          lineHeight: 1.4,
        }}
      >
        将 Boris 的 Twitter 最佳实践
        <br/>
        <span style={{ background: 'linear-gradient(135deg, #ec4899, #a855f7)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>一键集成到你的项目</span>
      </div>

      {/* Tweet cards */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 18, width: '85%' }}>
        {tweets.map((tweet, i) => {
          const delay = i * 12;
          const progress = spring({
            frame: frame - 15 - delay,
            fps,
            config: { damping: 10, stiffness: 120 },
          });

          const slideX = interpolate(progress, [0, 1], [i % 2 === 0 ? -80 : 80, 0], { extrapolateLeft: 'clamp' });

          return (
            <div
              key={i}
              style={{
                opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                transform: `translateX(${slideX}px)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '22px 35px',
                background: '#fff',
                borderRadius: 20,
                boxShadow: '0 10px 35px rgba(0,0,0,0.06)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
                <div style={{ width: 42, height: 42, borderRadius: '50%', background: '#000', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <span style={{ fontSize: 22, color: '#fff' }}>𝕏</span>
                </div>
                <span style={{ fontSize: 26, color: colors.dark, fontFamily: 'system-ui', fontStyle: 'italic' }}>
                  {tweet.text}
                </span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontSize: 22 }}>❤️</span>
                <span style={{ fontSize: 20, color: '#ef4444', fontFamily: 'system-ui', fontWeight: 600 }}>{tweet.likes}</span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Commands with stagger animation */}
      <div
        style={{
          marginTop: 35,
          display: 'flex',
          gap: 14,
        }}
      >
        {['/init', '/setup-permissions', '/create-subagent', '/ralph-loop'].map((cmd, i) => {
          const cmdProgress = spring({
            frame: frame - 70 - i * 6,
            fps,
            config: { damping: 10, stiffness: 150 },
          });

          return (
            <div
              key={i}
              style={{
                opacity: interpolate(cmdProgress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                transform: `translateY(${interpolate(cmdProgress, [0, 1], [20, 0], { extrapolateLeft: 'clamp' })}px)`,
                padding: '12px 22px',
                background: 'linear-gradient(135deg, rgba(236, 72, 153, 0.1), rgba(168, 85, 247, 0.1))',
                borderRadius: 12,
                border: '1px solid rgba(168, 85, 247, 0.3)',
                fontSize: 18,
                color: '#a855f7',
                fontFamily: 'monospace',
                fontWeight: 600,
              }}
            >
              {cmd}
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// Scene 6: Ultimate Workflow - Figma Style
const UltimateScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phases = [
    { icon: '🔍', name: '发现', gradient: 'linear-gradient(135deg, #3b82f6, #06b6d4)' },
    { icon: '✓', name: '验证', gradient: 'linear-gradient(135deg, #8b5cf6, #a855f7)' },
    { icon: '🔨', name: '开发', gradient: 'linear-gradient(135deg, #ec4899, #f472b6)' },
    { icon: '🔄', name: '复核', gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)' },
    { icon: '📢', name: '发布', gradient: 'linear-gradient(135deg, #10b981, #34d399)' },
  ];

  // Animated connecting line progress
  const lineProgress = interpolate(frame, [60, 120], [0, 100], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(180deg, #faf5ff 0%, #f0f9ff 50%, #ecfdf5 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      {/* Background decorations */}
      <div style={{ position: 'absolute', top: -200, left: '50%', transform: 'translateX(-50%)', width: 1000, height: 400, background: 'radial-gradient(ellipse, rgba(168, 85, 247, 0.08), transparent 70%)', filter: 'blur(60px)' }} />

      {/* Title with fire emoji animation */}
      <div
        style={{
          fontSize: 58,
          fontWeight: 800,
          marginBottom: 70,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          display: 'flex',
          alignItems: 'center',
          gap: 15,
          opacity: interpolate(frame, [0, 25], [0, 1], { extrapolateRight: 'clamp' }),
          transform: `translateY(${interpolate(frame, [0, 25], [40, 0], { extrapolateRight: 'clamp' })}px)`,
        }}
      >
        <span style={{ transform: `scale(${1 + Math.sin(frame * 0.15) * 0.1})`, display: 'inline-block' }}>🔥</span>
        <span style={{ background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 50%, #f97316 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
          终极闭环工作流
        </span>
      </div>

      {/* Flow diagram with connecting line */}
      <div style={{ position: 'relative' }}>
        {/* Animated gradient line */}
        <svg style={{ position: 'absolute', top: 55, left: 60, width: 'calc(100% - 120px)', height: 10, zIndex: 0 }}>
          <defs>
            <linearGradient id="flowLineGrad" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#3b82f6" />
              <stop offset="25%" stopColor="#8b5cf6" />
              <stop offset="50%" stopColor="#ec4899" />
              <stop offset="75%" stopColor="#f59e0b" />
              <stop offset="100%" stopColor="#10b981" />
            </linearGradient>
          </defs>
          <line
            x1="0"
            y1="5"
            x2={`${lineProgress}%`}
            y2="5"
            stroke="url(#flowLineGrad)"
            strokeWidth="4"
            strokeLinecap="round"
          />
        </svg>

        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 35, position: 'relative', zIndex: 1 }}>
          {phases.map((phase, i) => {
            const delay = i * 12;
            const progress = spring({
              frame: frame - delay - 10,
              fps,
              config: { damping: 8, stiffness: 120 },
            });

            const floatY = Math.sin(frame * 0.06 + i * 1.3) * 6;

            return (
              <div
                key={i}
                style={{
                  opacity: interpolate(progress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                  transform: `translateY(${interpolate(progress, [0, 1], [50, floatY], { extrapolateLeft: 'clamp' })}px) scale(${interpolate(progress, [0, 1], [0.7, 1], { extrapolateLeft: 'clamp' })})`,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: 15,
                }}
              >
                <div
                  style={{
                    width: 110,
                    height: 110,
                    borderRadius: 30,
                    background: phase.gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 50,
                    boxShadow: '0 20px 45px rgba(0,0,0,0.15)',
                  }}
                >
                  {phase.icon}
                </div>
                <div
                  style={{
                    fontSize: 24,
                    background: phase.gradient,
                    WebkitBackgroundClip: 'text',
                    WebkitTextFillColor: 'transparent',
                    fontWeight: 700,
                    fontFamily: 'system-ui',
                  }}
                >
                  {phase.name}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Subtitle */}
      <div
        style={{
          marginTop: 60,
          fontSize: 24,
          color: colors.gray,
          fontFamily: 'system-ui',
          opacity: interpolate(frame, [90, 110], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
        }}
      >
        趋势发现 → 多模型验证 → TDD 开发 → 代码审查 → 多平台发布
      </div>
    </AbsoluteFill>
  );
};

// Scene 7: Call to Action - Figma Style
const CTAScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 8, stiffness: 100 },
  });

  const codeProgress = spring({
    frame: frame - 25,
    fps,
    config: { damping: 10, stiffness: 120 },
  });

  const features = [
    { icon: '🛡️', text: '信任', gradient: 'linear-gradient(135deg, #a855f7, #7c3aed)' },
    { icon: '📢', text: '传播', gradient: 'linear-gradient(135deg, #3b82f6, #06b6d4)' },
    { icon: '⚡', text: '效率', gradient: 'linear-gradient(135deg, #f97316, #fbbf24)' },
  ];

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #faf5ff 0%, #f0f9ff 30%, #ecfdf5 70%, #fffbeb 100%)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      {/* Animated background blobs */}
      {[
        { x: -400, y: -200, color: 'rgba(168, 85, 247, 0.12)', size: 500 },
        { x: 400, y: 200, color: 'rgba(59, 130, 246, 0.1)', size: 450 },
        { x: 0, y: -300, color: 'rgba(249, 115, 22, 0.08)', size: 400 },
      ].map((blob, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: `calc(50% + ${blob.x + Math.sin(frame * 0.015 + i * 2) * 40}px)`,
            top: `calc(50% + ${blob.y + Math.cos(frame * 0.02 + i * 1.5) * 30}px)`,
            width: blob.size,
            height: blob.size,
            borderRadius: '50%',
            background: `radial-gradient(circle, ${blob.color}, transparent 70%)`,
            filter: 'blur(60px)',
          }}
        />
      ))}

      {/* Sparkle decorations */}
      {Array.from({ length: 12 }, (_, i) => {
        const angle = (i / 12) * Math.PI * 2;
        const radius = 350 + Math.sin(frame * 0.05 + i) * 30;
        const x = Math.cos(angle + frame * 0.01) * radius;
        const y = Math.sin(angle + frame * 0.01) * radius;
        const sparkleScale = 0.5 + Math.sin(frame * 0.1 + i * 0.5) * 0.3;

        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: `calc(50% + ${x}px)`,
              top: `calc(50% + ${y}px)`,
              fontSize: 20,
              transform: `scale(${sparkleScale})`,
              opacity: 0.6 + Math.sin(frame * 0.08 + i) * 0.3,
            }}
          >
            ✨
          </div>
        );
      })}

      {/* Title with gradient */}
      <div
        style={{
          opacity: interpolate(titleProgress, [0, 1], [0, 1]),
          transform: `scale(${interpolate(titleProgress, [0, 1], [0.7, 1])}) translateY(${interpolate(titleProgress, [0, 1], [50, 0])}px)`,
          fontSize: 68,
          fontWeight: 800,
          background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 50%, #f97316 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          marginBottom: 45,
          fontFamily: 'system-ui, -apple-system, sans-serif',
          textAlign: 'center',
        }}
      >
        立即开始使用 CC Suite
      </div>

      {/* Install command card */}
      <div
        style={{
          opacity: interpolate(codeProgress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
          transform: `translateY(${interpolate(codeProgress, [0, 1], [40, 0], { extrapolateLeft: 'clamp' })}px)`,
          padding: '25px 50px',
          background: '#fff',
          borderRadius: 20,
          boxShadow: '0 25px 60px rgba(0,0,0,0.1)',
          marginBottom: 50,
          display: 'flex',
          alignItems: 'center',
          gap: 20,
        }}
      >
        <div
          style={{
            width: 50,
            height: 50,
            borderRadius: 12,
            background: 'linear-gradient(135deg, #1e1e1e, #333)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 24,
          }}
        >
          💻
        </div>
        <div style={{ fontFamily: 'monospace', fontSize: 26, color: colors.dark }}>
          git clone https://github.com/leiMizzou/CC-Suite.git
        </div>
      </div>

      {/* Feature pills with stagger */}
      <div style={{ display: 'flex', gap: 30 }}>
        {features.map((feature, i) => {
          const featureProgress = spring({
            frame: frame - 50 - i * 10,
            fps,
            config: { damping: 8, stiffness: 120 },
          });

          return (
            <div
              key={i}
              style={{
                opacity: interpolate(featureProgress, [0, 1], [0, 1], { extrapolateLeft: 'clamp' }),
                transform: `translateY(${interpolate(featureProgress, [0, 1], [30, 0], { extrapolateLeft: 'clamp' })}px) scale(${interpolate(featureProgress, [0, 1], [0.8, 1], { extrapolateLeft: 'clamp' })})`,
                padding: '18px 35px',
                background: '#fff',
                borderRadius: 50,
                boxShadow: '0 12px 35px rgba(0,0,0,0.08)',
                display: 'flex',
                alignItems: 'center',
                gap: 12,
              }}
            >
              <span style={{ fontSize: 28 }}>{feature.icon}</span>
              <span
                style={{
                  fontSize: 26,
                  fontWeight: 700,
                  background: feature.gradient,
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  fontFamily: 'system-ui',
                }}
              >
                {feature.text}
              </span>
            </div>
          );
        })}
      </div>

      {/* GitHub link with real QR code */}
      <div
        style={{
          position: 'absolute',
          bottom: 50,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 12,
          opacity: interpolate(frame, [100, 130], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }),
        }}
      >
        {/* Real QR Code image */}
        <div
          style={{
            width: 110,
            height: 110,
            background: '#fff',
            borderRadius: 12,
            boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
            padding: 8,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <img
            src={staticFile('images/qrcode.png')}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'contain',
            }}
          />
        </div>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '12px 28px',
            background: 'rgba(255,255,255,0.9)',
            borderRadius: 50,
            boxShadow: '0 8px 25px rgba(0,0,0,0.08)',
          }}
        >
          <span style={{ fontSize: 22, transform: `scale(${1 + Math.sin(frame * 0.1) * 0.15})`, display: 'inline-block' }}>⭐</span>
          <span style={{ fontSize: 20, color: colors.dark, fontFamily: 'system-ui', fontWeight: 600 }}>
            github.com/leiMizzou/CC-Suite
          </span>
        </div>

        <span style={{ fontSize: 15, color: colors.gray, fontFamily: 'system-ui' }}>
          扫码访问 · Star 支持
        </span>
      </div>
    </AbsoluteFill>
  );
};

// Main composition - 29 seconds version (870 frames)
export const CCPromo: React.FC<CCPromoProps> = ({ theme = 'dark' }) => {
  return (
    <AbsoluteFill>
      {/* Background Music - Happy Upbeat */}
      <Audio
        src={staticFile('audio/bgm.mp3')}
        volume={0.4}
        startFrom={0}
      />

      {/* Scene 1: Intro (0-3s) */}
      <Sequence from={0} durationInFrames={90}>
        <IntroScene />
      </Sequence>

      {/* Scene 2: Value Proposition - The Loop (3-6s) */}
      <Sequence from={90} durationInFrames={90}>
        <ValueScene />
      </Sequence>

      {/* Scene 3: SocialPublisher - Discover Trends (6-10s) */}
      <Sequence from={180} durationInFrames={120}>
        <SocialScene />
      </Sequence>

      {/* Scene 4: BorisWorkflow - Efficient Development (10-14s) */}
      <Sequence from={300} durationInFrames={120}>
        <WorkflowScene />
      </Sequence>

      {/* Scene 5: CrossCheck - Model Adversarial (14-18s) */}
      <Sequence from={420} durationInFrames={120}>
        <CrossCheckScene />
      </Sequence>

      {/* Scene 6: Ultimate Workflow (18-22s) */}
      <Sequence from={540} durationInFrames={120}>
        <UltimateScene />
      </Sequence>

      {/* Scene 7: CTA (22-29s) */}
      <Sequence from={660} durationInFrames={210}>
        <CTAScene />
      </Sequence>
    </AbsoluteFill>
  );
};
