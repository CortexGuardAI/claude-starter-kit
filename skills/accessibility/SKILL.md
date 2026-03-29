---
name: accessibility
description: Use this skill when building or reviewing UI components, forms, navigation, or any user-facing interface. Ensures WCAG 2.1 AA compliance, keyboard navigation, screen reader support, and inclusive design.
---

# Accessibility (a11y) Skill

## When to Activate

- Building or reviewing UI components (forms, modals, menus, tables)
- Implementing navigation or routing in a frontend app
- Adding interactive elements (buttons, dropdowns, sliders, carousels)
- Reviewing code before release for WCAG compliance
- Debugging screen reader or keyboard navigation issues

---

## Core Standard: WCAG 2.1 AA

The 4 principles (**POUR**):

| Principle | Meaning | Key Requirements |
|-----------|---------|-----------------|
| **Perceivable** | Users can perceive all content | Alt text, captions, color contrast |
| **Operable** | UI is keyboard-operable | Tab order, focus indicators, no timing traps |
| **Understandable** | Content is understandable | Error messages, labels, consistent nav |
| **Robust** | Works across assistive tech | Semantic HTML, valid ARIA |

---

## Semantic HTML First

Use the right HTML element before reaching for ARIA.

```html
<!-- WRONG: div soup -->
<div class="button" onclick="submit()">Submit</div>
<div class="nav">...</div>
<div class="header">...</div>

<!-- CORRECT: semantic HTML -->
<button type="submit">Submit</button>
<nav aria-label="Main navigation">...</nav>
<header>...</header>

<!-- Landmark elements -->
<header>   <!-- site header -->
<nav>      <!-- navigation -->
<main>     <!-- main content (only one per page) -->
<aside>    <!-- sidebar / complementary -->
<footer>   <!-- site footer -->
<section>  <!-- grouped content with heading -->
<article>  <!-- self-contained content -->
```

---

## Images and Icons

```html
<!-- Informative image: describe the content -->
<img src="chart.png" alt="Revenue increased 40% from Q1 to Q2 2024" />

<!-- Decorative image: empty alt (screen readers skip it) -->
<img src="divider.svg" alt="" role="presentation" />

<!-- Icon button: label the button, not the icon -->
<button aria-label="Close dialog">
  <svg aria-hidden="true" focusable="false">...</svg>
</button>

<!-- Icon with adjacent text: hide the icon -->
<button>
  <svg aria-hidden="true" focusable="false">...</svg>
  Save changes
</button>
```

---

## Forms

```html
<!-- Every input needs a visible label -->
<label for="email">Email address</label>
<input
  id="email"
  type="email"
  name="email"
  autocomplete="email"
  aria-required="true"
  aria-describedby="email-hint email-error"
/>
<p id="email-hint">We will never share your email.</p>
<p id="email-error" role="alert" aria-live="polite">
  <!-- Error message injected here by JS -->
</p>

<!-- Group related inputs -->
<fieldset>
  <legend>Shipping address</legend>
  <label for="street">Street</label>
  <input id="street" type="text" name="street" autocomplete="street-address" />
  <label for="city">City</label>
  <input id="city" type="text" name="city" autocomplete="address-level2" />
</fieldset>

<!-- Required field indicators -->
<label for="name">
  Full name
  <span aria-hidden="true">*</span>
  <span class="sr-only">(required)</span>
</label>
```

---

## Keyboard Navigation

```html
<!-- tabindex rules:
  0 = natural tab order (use for custom interactive elements)
 -1 = focusable by JS but not by tab (use for controlled focus)
 >0 = AVOID (breaks natural tab order)
-->

<!-- Make custom interactive element keyboard accessible -->
<div
  role="button"
  tabindex="0"
  onkeydown="if(e.key==='Enter'||e.key===' ') handleClick()"
  onclick="handleClick()"
>
  Custom button
</div>

<!-- Trap focus inside modal -->
<!-- Use a focus-trap library or implement: -->
<!-- On open: focus first element. On Tab/Shift+Tab: cycle within modal. On Escape: close. -->
```

```css
/* NEVER hide the focus indicator -- make it better instead */
:focus-visible {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
  border-radius: 2px;
}

/* Skip link for keyboard users */
.skip-link {
  position: absolute;
  top: -100%;
}
.skip-link:focus {
  top: 0;
}
```

---

## ARIA Roles and Properties

```html
<!-- Live regions: announce dynamic content to screen readers -->
<div role="status" aria-live="polite">
  <!-- Polite: reads after current speech (form success messages) -->
  Form submitted successfully!
</div>

<div role="alert" aria-live="assertive">
  <!-- Assertive: interrupts current speech (errors) -->
  Error: Please correct the fields below.
</div>

<!-- Expandable sections -->
<button aria-expanded="false" aria-controls="panel1" id="header1">
  Frequently Asked Questions
</button>
<div id="panel1" role="region" aria-labelledby="header1" hidden>
  Content...
</div>

<!-- Loading states -->
<button aria-busy="true" aria-label="Saving, please wait...">
  <span aria-hidden="true">Saving...</span>
</button>

<!-- Tables -->
<table>
  <caption>Monthly sales by region</caption>
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Sales</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">North</th>
      <td>$100,000</td>
    </tr>
  </tbody>
</table>
```

---

## Color and Contrast

**WCAG AA minimums:**
- Normal text (< 18pt): 4.5:1 contrast ratio
- Large text (≥ 18pt or ≥ 14pt bold): 3:1 contrast ratio
- UI components (buttons, inputs, icons): 3:1

**Never use color alone to convey information:**
```html
<!-- WRONG: only color indicates the error -->
<input style="border-color: red" />

<!-- CORRECT: color + icon + text -->
<input
  style="border-color: red"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<p id="email-error">
  <span aria-hidden="true">⚠</span> Please enter a valid email address.
</p>
```

---

## React / Component Patterns

```tsx
// Accessible Modal
function Modal({ isOpen, onClose, title, children }) {
  const titleId = useId()

  useEffect(() => {
    if (isOpen) {
      const previousFocus = document.activeElement as HTMLElement
      return () => previousFocus?.focus()
    }
  }, [isOpen])

  if (!isOpen) return null
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
    >
      <h2 id={titleId}>{title}</h2>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  )
}

// Screen-reader-only text utility
function SrOnly({ children }) {
  return (
    <span
      style={{
        position: 'absolute', width: 1, height: 1,
        padding: 0, margin: -1, overflow: 'hidden',
        clip: 'rect(0,0,0,0)', border: 0
      }}
    >
      {children}
    </span>
  )
}
```

---

## Accessibility Checklist

### Semantic Structure
- [ ] Single `<h1>` per page, logical heading hierarchy (h1→h2→h3)
- [ ] Landmark regions used (header, nav, main, footer)
- [ ] Page `<title>` is descriptive and unique per page
- [ ] Language attribute set: `<html lang="en">`

### Images and Media
- [ ] All informative images have descriptive alt text
- [ ] Decorative images have `alt=""`
- [ ] Videos have captions; audio has transcripts

### Forms
- [ ] All inputs have associated `<label>` elements
- [ ] Error messages are programmatically associated (`aria-describedby`)
- [ ] Required fields indicated with text (not just color)
- [ ] Form group `<fieldset>` and `<legend>` used for radio/checkbox groups

### Keyboard and Focus
- [ ] All interactive elements reachable by Tab key
- [ ] Logical tab order matches visual order
- [ ] Focus indicator visible on all focusable elements
- [ ] Modals trap focus; Escape closes them
- [ ] Skip navigation link present at top of page

### Color and Contrast
- [ ] Text meets 4.5:1 contrast (normal) / 3:1 (large)
- [ ] UI components meet 3:1 contrast
- [ ] Information not conveyed by color alone

### Dynamic Content
- [ ] Loading states announced (`aria-busy`, `aria-live`)
- [ ] Error messages use `role="alert"`
- [ ] Success messages use `role="status"`

---

**Remember**: Accessibility is not a feature -- it is a quality. A11y issues are bugs.
