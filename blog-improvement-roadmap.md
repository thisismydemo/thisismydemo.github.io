# Blog Site Improvement Roadmap - This Is My Demo

**Date:** April 2026
**Current Platform:** Hugo (Static Site Generator)
**Current Theme:** Mainroad (customized with layout overrides)
**Hosting:** GitHub Pages
**Domain:** thisismydemo.cloud

---

## Current Site State

The blog has grown significantly since the original roadmap in July 2025. There are now 40+ published posts including a flagship 21-post Hyper-V Renaissance series with a companion GitHub toolkit repository. Content quality and volume are strong. The site infrastructure has not kept up.

**What works today:**
- Hugo builds and deploys reliably via GitHub Actions
- Giscus comments (GitHub Discussions) are active
- Google Analytics 4 is tracking
- OpenGraph and Twitter Cards are enabled
- Author box displays on posts
- Sidebar has search, recent posts, categories, tags, social links
- Previous/Next post navigation is functional
- RSS and sitemap are configured
- Custom CSS override is in place
- Minification is enabled in the build pipeline

**What is missing or broken:**
- No homepage content (no `content/_index.md`, just a paginated post list)
- Main navigation menu only has "About" (no series page, no resources, no toolkit)
- No favicon
- No social sharing buttons on posts
- No table of contents on long posts (template supports it, no posts enable it)
- No reading time display
- No related posts
- No newsletter signup or email capture
- No contact page
- No series landing page for the Hyper-V Renaissance
- No schema markup (disabled in config)
- "Read more" buttons disabled in post lists
- Image naming is inconsistent across static folders
- No archive browsing widget

---

## Platform Evaluation: Stay on Hugo or Switch?

### Hugo (Current)

**Strengths:**
- Fastest static site generator available, builds 500+ pages in under 6 seconds
- Zero runtime dependencies, no server, no database
- GitHub Pages deployment is already working and free
- Markdown-native workflow matches the current content creation process
- Huge theme ecosystem with active development
- Go templating is powerful once you know it

**Weaknesses:**
- Mainroad theme is functional but visually dated, limited layout flexibility
- Go template syntax is not intuitive and makes customization harder than it should be
- Component reuse is clunky compared to modern frameworks
- No built-in interactive component support (everything is static HTML)
- Plugin/extension ecosystem is thin compared to alternatives

**Verdict:** Hugo itself is not the problem. The theme is.

### Jekyll

**Strengths:**
- Native GitHub Pages support (no CI workflow needed)
- Ruby ecosystem, large plugin library
- Simpler templating (Liquid) than Hugo's Go templates

**Weaknesses:**
- Significantly slower builds (Ruby-based, would struggle with 500+ pages)
- Ruby dependency management is painful on Windows
- Theme ecosystem is shrinking, not growing
- Feature set is a subset of what Hugo already provides
- Moving to Jekyll would be a lateral move at best, a downgrade at worst

**Verdict:** No. Jekyll is not an upgrade from Hugo. It is older, slower, and the theme ecosystem is weaker. Skip.

### Astro

**Strengths:**
- Modern component-based architecture (supports React, Vue, Svelte, or plain HTML)
- "Islands" architecture means interactive components only where needed, rest is static HTML
- Excellent performance (ships zero JS by default, adds it per-component)
- Growing theme ecosystem with modern, polished designs
- Built-in image optimization, RSS, sitemap, MDX support
- First-class Markdown and MDX content collections
- TypeScript support throughout
- Active development and growing community
- Free tier on Netlify, Vercel, or Cloudflare Pages (or keep GitHub Pages)

**Weaknesses:**
- Migration effort: would need to convert Go templates to Astro components
- Front matter and content structure would need adjustment
- Node.js dependency (but this is standard for modern web dev)
- Newer platform, some themes are less battle-tested than Hugo's mature options
- Learning curve for the component model if you have never used React/Vue/Svelte

**Verdict:** Astro is the only platform worth considering as a replacement. If the goal is a more modern look, more customizable themes, and more features without paying for hosting, Astro delivers all of that. The migration cost is real but manageable since all content is already Markdown.

### Recommendation

**Short term: Stay on Hugo, switch themes.** The fastest path to a better-looking site with more features is replacing Mainroad with a modern Hugo theme. This preserves all existing content, keeps the GitHub Actions pipeline, and avoids a full platform migration.

**Medium term: Evaluate an Astro migration** if the new Hugo theme still feels limiting after 3-6 months. Astro would give you component-level control, modern UI patterns, and a much richer plugin ecosystem. But do the theme swap first because it solves most of the visual and feature complaints immediately.

---

## Theme Recommendations

### What to keep from Mainroad
The current layout pattern of title, then subtitle/lead text, then featured image/thumbnail works well. Any replacement theme must support:
- Post title prominently displayed
- Optional subtitle or lead paragraph
- Featured image per post
- Author box
- Sidebar with widgets
- Category and tag taxonomy
- Series or multi-part post support
- Dark/light mode (nice to have)

### Hugo Theme Candidates (Free)

**1. Blowfish** (https://blowfish.page)
- Modern, clean design with Tailwind CSS
- Built-in dark/light mode toggle
- Table of contents, reading time, related posts, all built in
- Series support with automatic navigation
- Social sharing buttons included
- Search built in (Fuse.js)
- Multiple homepage layouts (profile, hero, card grid)
- Active development, large community
- Keeps the title/subtitle/thumbnail pattern you like
- **Best fit for this site**

**2. Congo** (https://jpanther.github.io/congo)
- Tailwind CSS, modern and minimal
- Multiple layout options (page, profile, hero, card, background)
- Built-in search, table of contents, reading time
- Dark/light mode
- Social sharing
- Firebase or Fathom analytics support alongside GA
- Series taxonomy support
- Very customizable without touching code

**3. PaperMod** (https://adityatelange.github.io/hugo-PaperMod)
- Clean, fast, widely used
- Dark/light/auto mode
- Search, table of contents, reading time
- Social sharing icons
- Cover images per post
- Profile mode for homepage
- Simpler than Blowfish but also less flexible

**4. Stack** (https://stack.jimmycai.com)
- Card-based layout, visually distinct
- Built-in search, archives, table of contents
- Dark mode
- Social links, reading time
- Gallery support
- Good for a site that wants to look different from typical blogs

### Astro Theme Candidates (Free, for future consideration)

**1. AstroPaper** - Clean, minimal, accessible, Markdown-native
**2. Astro-Starter-Blog** - Full-featured blog starter with MDX support
**3. Starlight** - Documentation-focused, excellent for technical content hubs

### Theme Recommendation

**Switch to Blowfish.** It is the most feature-complete free Hugo theme available, it supports every feature currently missing from this site (ToC, reading time, social sharing, search, series navigation, dark mode, homepage layouts), and it keeps the title/subtitle/thumbnail post structure. The migration is a config and template adjustment, not a content rewrite.

---

## Site Infrastructure Gaps (Prioritized)

### Phase 1: Immediate (Theme Switch + Quick Wins)

| Item | Priority | Notes |
|------|----------|-------|
| Switch theme from Mainroad to Blowfish | HIGH | Solves most feature gaps in one move |
| Create homepage content (`content/_index.md`) | HIGH | Add intro, featured series, "start here" section |
| Expand main navigation menu | HIGH | Add: Series, Resources, Toolkit, About |
| Add favicon | HIGH | Basic branding, takes 5 minutes |
| Enable table of contents on all 21 Hyper-V posts | HIGH | Set `toc: true` in front matter |
| Enable reading time display | HIGH | Theme config toggle |
| Enable social sharing buttons | HIGH | Theme config toggle |
| Enable schema markup | HIGH | Add `schema = true` to config |
| Enable "Read more" buttons on post lists | HIGH | Config toggle |

### Phase 2: Content Structure

| Item | Priority | Notes |
|------|----------|-------|
| Create Hyper-V Renaissance series landing page | HIGH | Dedicated overview page with all 21 posts |
| Create resource/hub pages by technology | MEDIUM | Azure, Hyper-V, Windows Server, Azure Arc |
| Add contact page | MEDIUM | Professional inquiry channel |
| Standardize featured images across all posts | MEDIUM | Consistent thumbnails, proper sizing |
| Clean up image naming in static folders | LOW | Some still have hash-based names from 2023 |

### Phase 3: Engagement

| Item | Priority | Notes |
|------|----------|-------|
| Newsletter signup | MEDIUM | Buttondown or Substack (both free tier) |
| Related posts | MEDIUM | Most modern themes handle this automatically |
| Archive widget or page | LOW | Monthly/yearly browsing |
| Search optimization | LOW | Most modern themes include Fuse.js or Pagefind |

### Phase 4: Analytics and SEO

| Item | Priority | Notes |
|------|----------|-------|
| GA4 goal tracking (shares, series completion) | MEDIUM | Measure what matters |
| Google Search Console verification | MEDIUM | Monitor search performance |
| Internal linking audit | LOW | Cross-reference related posts more aggressively |
| Meta descriptions on all posts | LOW | Front matter `description` field |

---

## What NOT to Do

- **Do not add AMP.** It is effectively dead for blogs. Google no longer gives AMP preferential treatment.
- **Do not add PWA.** Overkill for a technical blog. No reader is installing this as an app.
- **Do not pay for a CDN.** GitHub Pages already serves globally. Cloudflare free tier is available if needed later.
- **Do not add a language switcher.** The site is English-only. Remove the languages widget from the sidebar config.
- **Do not build a custom theme from scratch.** The maintenance burden is not worth it when free themes already exist that do everything needed.

---

## Next Steps

1. Pick the new theme (Blowfish recommended)
2. Set up a test branch and install the theme
3. Migrate config settings and test with existing content
4. Adjust layout overrides to preserve any customizations
5. Enable all the feature toggles (ToC, reading time, sharing, search, dark mode)
6. Create homepage content and series landing page
7. Update navigation menu
8. Test, deploy, done

---

**Document Version:** 2.0
**Last Updated:** April 2026
**Previous Version:** July 2025 (fully replaced)

*This roadmap covers site infrastructure and platform decisions only. Blog content strategy and series planning are tracked separately.*
