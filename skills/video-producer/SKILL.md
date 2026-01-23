---
name: video-producer
description: Generate videos using code with Remotion. Transform text descriptions into professional videos through React components.
---

# Video Producer Skill

Generate professional videos and images for social media platforms using Remotion (React-based programmatic video).

## Usage

This skill is typically invoked by `social-publisher` via the `media_generator.py` bridge script.

### Direct CLI Usage

```bash
# Check environment
python3 scripts/media_generator.py check

# Generate image
python3 scripts/media_generator.py generate \
  --platform twitter \
  --type image \
  --template text_animation \
  --title "Your Title" \
  --subtitle "Your Subtitle"

# Generate video
python3 scripts/media_generator.py generate \
  --platform xiaohongshu \
  --type video \
  --template list_countdown \
  --duration 15 \
  --title "Top 5 Trends" \
  --items '["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]'
```

## Available Templates

| Template | Best For | Default Aspect |
|----------|----------|----------------|
| `text_animation` | Key points, announcements | 16:9 (horizontal) |
| `data_visualization` | Trends, statistics | 16:9 (horizontal) |
| `list_countdown` | Top N lists, rankings | 9:16 (vertical) |
| `product_showcase` | Product demos, features | 16:9 (horizontal) |

## Platform Presets

| Platform | Video Size | Image Size | Notes |
|----------|------------|------------|-------|
| Twitter | 1280x720 | 1200x675 | Horizontal 16:9 |
| Xiaohongshu | 1080x1920 | 1080x1440 | Vertical 9:16 / 3:4 |
| WeChat | 1920x1080 | 900x500 | Horizontal |

## Props Schema

All templates accept the following props:

```typescript
interface TemplateProps {
  title: string;           // Main title
  subtitle: string;        // Secondary text
  items: string[];         // List items (for list-based templates)
  backgroundColor: string; // Background color (hex)
  textColor: string;       // Text color (hex)
  accentColor: string;     // Accent/highlight color (hex)
}
```

## Development

### Start Remotion Studio

```bash
cd skills/video-producer
npm run start
```

### Render Manually

```bash
# Render video
npx remotion render src/index.ts TextAnimation out.mp4 --props='{"title":"Test"}'

# Render image (still)
npx remotion still src/index.ts TextAnimation out.png --props='{"title":"Test"}'
```

## Dependencies

- Node.js 18+
- Remotion 4.x
- React 18.x

## Integration with social-publisher

The `social-publisher` skill automatically discovers this project at:
- `~/.claude/skills/video-producer/`
- `./skills/video-producer/` (relative to social-publisher)

When generating media content, social-publisher will:
1. Check for Remotion project
2. Generate props file
3. Call `npx remotion render/still` via subprocess
4. Return the generated media path
