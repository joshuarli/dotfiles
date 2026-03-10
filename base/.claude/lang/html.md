# HTML

Semantic, accessible, unstyled by default. The HTML should make sense with CSS disabled.

- **Semantic elements**: `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`, `<header>`, `<footer>`. No `<div>` soup.
- **Headings are hierarchical**: One `<h1>` per page. `<h2>` through `<h4>` nest logically. Never skip levels.
- **Forms are accessible**: Every `<input>` has a `<label>` with `for=`. Use `<fieldset>` and `<legend>` for groups. `<button>` over `<input type="submit">`.
- **Images have `alt`**: Descriptive for content images, empty (`alt=""`) for decorative ones. Always include `width` and `height` to prevent layout shift.
- **Links are links, buttons are buttons**: `<a>` navigates, `<button>` performs an action. Never `<a href="#">` with a click handler.
- **Tables for tabular data**: Not for layout. Use `<thead>`, `<tbody>`, `<th scope="col">`.
- **No inline styles**: No `style=` attributes. All styling in the CSS file.
- **No inline JS**: No `onclick=` attributes. All behavior via event listeners.
- **Templates**: Keep logic minimal — format data in the handler/controller, not the template.
