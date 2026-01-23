import React from 'react';
import { Composition, Still } from 'remotion';
import { TextAnimation, TextAnimationProps } from './components/TextAnimation';
import { DataVisualization, DataVisualizationProps } from './components/DataVisualization';
import { ListCountdown, ListCountdownProps } from './components/ListCountdown';
import { ProductShowcase, ProductShowcaseProps } from './components/ProductShowcase';

// Default props for each composition
const defaultTextProps: TextAnimationProps = {
  title: 'Welcome',
  subtitle: 'Your text here',
  items: [],
  backgroundColor: '#1a1a2e',
  textColor: '#ffffff',
  accentColor: '#4ecdc4',
};

const defaultDataProps: DataVisualizationProps = {
  title: 'Data Insights',
  subtitle: 'Trends Analysis',
  items: ['Trend 1: 45%', 'Trend 2: 30%', 'Trend 3: 25%'],
  backgroundColor: '#0f0f23',
  textColor: '#ffffff',
  accentColor: '#00d4ff',
};

const defaultListProps: ListCountdownProps = {
  title: 'Top 5',
  subtitle: 'Today\'s Highlights',
  items: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'],
  backgroundColor: '#1a1a2e',
  textColor: '#ffffff',
  accentColor: '#ff6b6b',
};

const defaultProductProps: ProductShowcaseProps = {
  title: 'Product Demo',
  subtitle: 'Feature Showcase',
  items: ['Feature 1', 'Feature 2', 'Feature 3'],
  backgroundColor: '#16213e',
  textColor: '#ffffff',
  accentColor: '#e94560',
};

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* Text Animation - for key points display */}
      <Composition
        id="TextAnimation"
        component={TextAnimation}
        durationInFrames={450}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={defaultTextProps}
      />
      <Still
        id="TextAnimationStill"
        component={TextAnimation}
        width={1920}
        height={1080}
        defaultProps={defaultTextProps}
      />

      {/* Data Visualization - for trends and charts */}
      <Composition
        id="DataVisualization"
        component={DataVisualization}
        durationInFrames={450}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={defaultDataProps}
      />
      <Still
        id="DataVisualizationStill"
        component={DataVisualization}
        width={1920}
        height={1080}
        defaultProps={defaultDataProps}
      />

      {/* List Countdown - for top N lists (vertical for Xiaohongshu) */}
      <Composition
        id="ListCountdown"
        component={ListCountdown}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={defaultListProps}
      />
      <Still
        id="ListCountdownStill"
        component={ListCountdown}
        width={1080}
        height={1920}
        defaultProps={defaultListProps}
      />

      {/* Product Showcase - for tool/product introduction */}
      <Composition
        id="ProductShowcase"
        component={ProductShowcase}
        durationInFrames={450}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={defaultProductProps}
      />
      <Still
        id="ProductShowcaseStill"
        component={ProductShowcase}
        width={1920}
        height={1080}
        defaultProps={defaultProductProps}
      />
    </>
  );
};
