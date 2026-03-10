# CSS

Plain CSS. No preprocessors, no build step, no frameworks.

- **CSS Grid for layout**: Use `grid` for page structure and repeating layouts. Flexbox for single-axis alignment within components.
- **Custom properties for theming**: Define colors, spacing, and typography as `--var` on `:root`. No magic numbers scattered through the file.
- **Mobile-first**: Base styles are mobile. Widen with `min-width` media queries. Never `max-width`.
- **No utility classes**: This is not Tailwind. Use semantic class names that describe what the element is, not how it looks.
- **No `!important`**: If specificity is fighting you, simplify your selectors.
- **System fonts**: `font-family: system-ui, sans-serif`. No web font downloads unless the design demands it.
- **Logical properties**: Prefer `margin-inline`, `padding-block`, `inset-inline-start` over directional (`margin-left`). Handles RTL for free.
- **Minimal files**: Start with a single stylesheet. Split by page area only when it grows unwieldy.
