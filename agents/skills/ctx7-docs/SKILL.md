---
name: ctx7-docs
description: Use when working with any third-party framework, library, SDK, CLI, or API and needing current official docs (React, Next.js, Prisma, Tailwind, Biome, etc.).
---

# Third-party docs via Context7

Use only for external frameworks/SDKs/CLIs/APIs — never for internal logic,
generic refactoring, or language fundamentals.

```bash
npx ctx7@latest library <LibraryName> "<topic>"
npx ctx7@latest docs <libraryId> "<topic>"
```

Ground implementation in fetched official docs, not assumptions.
