---
name: retailer-portal
description: >
  Repository-specific knowledge base for the snabble retailer-portal React application.
  Use when working on any feature, bug fix, or refactoring task in the retailer-portal codebase
  at /home/patrick/snabble/retailer-portal.
---

# Retailer Portal

Comprehensive reference for the snabble retailer-portal codebase. Load this skill before making any changes to understand architecture, conventions, and patterns.

## Project Overview

- **Stack**: CRA (Create React App) with `react-app-rewired`, React 17, TypeScript, MUI v6, Redux, React Router v6, react-i18next, Axios, react-hook-form
- **Entry point**: `src/index.jsx` (JSX, not TSX)
- **Build**: `npx react-app-rewired build` — NOT Vite, NOT ejected CRA
- **Webpack overrides**: `config-overrides.js` (Sentry source maps in prod, JSX runtime alias)
- **Node version**: Managed via `.nvmrc`
- **Languages**: TypeScript for new code, JavaScript (`.js`/`.jsx`) for legacy code. Both coexist. Always use TypeScript for new files.
- **React version**: 17 — uses classic JSX transform (`"jsx": "react"` in tsconfig), so `import React from 'react'` is required in every JSX/TSX file

## ESLint Rules (Critical)

The project uses **airbnb + airbnb-typescript** ESLint config. Violations fail the build.

### Import restrictions (enforced via `no-restricted-imports`)

```typescript
// CORRECT — individual module imports
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import debounce from 'lodash/debounce';

// FORBIDDEN — barrel imports
import { Button, Stack } from '@mui/material';  // ERROR
import { debounce } from 'lodash';              // ERROR
```

### Arrow function parens

- Expression body, single param: **no parens** — `b => b.id`
- Block body: **parens required** — `(prev) => { return prev + 1; }`

### Other enforced rules

- `@typescript-eslint/indent`: 2-space indentation. Multi-line type aliases must NOT have extra indentation on continuation lines (put `&` or `|` at column 0).
- `object-curly-newline`: Line breaks required on multi-property destructuring/objects.
- `max-len`: 100 characters per line.
- `function-paren-newline`: Must be consistent (no newline after `(` unless multiline params).
- `react/require-default-props`: Disabled.
- `react/prop-types`: Disabled.

### Build cache

Always clear `node_modules/.cache` before production builds to avoid stale ESLint cache issues:
```bash
rm -rf node_modules/.cache && npx react-app-rewired build
```

## Source Directory Structure

Feature-based flat organization under `src/`. Each feature module typically contains:

| File pattern | Purpose |
|---|---|
| `*View.tsx` | Page-level view component |
| `*Form.tsx` | Form component (receives `CustomFormProps`) |
| `use*Api.ts` | API hook using `defineApi` |
| `*Routes.tsx` | Route definitions |
| `types.ts` or `*Type.ts` | TypeScript types |
| `*.test.tsx` | Tests (co-located) |

### Key infrastructure directories

| Directory | Purpose |
|---|---|
| `src/api/` | Axios client factory, `defineApi`, interceptors |
| `src/router/` | React Router v6 route definitions |
| `src/sidebar/` | Sidebar navigation (Redux-driven) |
| `src/reducers/` + `src/actions/` | Legacy Redux (NOT RTK slices) |
| `src/form/` | react-hook-form based input components |
| `src/scaffold/` | High-level scaffolds: `ResourceFormView`, `ResourceChartView`, `DeleteResourceView` |
| `src/resource/` | `ResourceProvider` for scoped translations |
| `src/toast/` | Toast/alert notification system |
| `src/access/` | Permission checking (`useAccess`, `WithAccess`) |
| `src/components/` | Large shared component library (mix of .jsx and .tsx) |
| `src/translations/` | i18n JSON files (en, de) |
| `src/utils/` | Utility functions and hooks |
| `src/icons/` | SVG icons imported as React components |

## API Pattern

All API hooks follow the same architecture:

### 1. Define service functions with `defineApi`

```typescript
import defineApi from 'src/api/hook/defineApi';
import useProjectSpecificApiClient from 'src/api/hook/useProjectSpecificApiClient';

const useApi = defineApi({
  getItems: async (client, { id }: { id: string }) => {
    const { data } = await client.get<Item>(`/items/${id}`);
    return data;
  },
  createItem: async (client, item: CreateItemPayload) => {
    const { data } = await client.post<Item>('/items', item);
    return data;
  },
});
```

### 2. Export a hook that wires the client

```typescript
export default function useItemApi() {
  const client = useProjectSpecificApiClient({ basePath: '/items' });
  return useApi(client);
}
```

### 3. Use in components

```typescript
const api = useItemApi();
const item = await api.getItems({ id: '123' });
```

### Client types

- **`useApiClient({ basePath })`** — Base Axios client with Bearer token from Redux, abort controller, logout interceptor for 401/403
- **`useProjectSpecificApiClient({ basePath })`** — Wraps `useApiClient`, prepends `/{projectId}` from `useParams()` to the base path
- **`prependApiHost(path)`** — Resolves API base URL from `window.location` (testing/staging/prod environments)

### Form validation

Use `withFormValidation` from `src/api/withFormValidation.ts` to handle 422 responses. Returns `neverthrow` `Result` type mapping API validation errors to react-hook-form field errors.

## Routing

### All routes are project-scoped

Every feature route is nested under `/:projectId/`. The route pattern is:

```typescript
// In RoutesForAuthorizedUsers.tsx
{navigation.featureName && (
  <Route
    path="/feature-name/*"
    element={<FeatureRoutes access={navigation.featureName} />}
  />
)}
```

### Feature route file pattern

```tsx
function FeatureRoutes({ access }: { access?: Access }) {
  return (
    <ResourceProvider name="featureName">
      <Routes>
        {access?.read && (
          <>
            <Route path="/" element={<ListView />} />
            <Route path="/:id" element={<DetailView />} />
          </>
        )}
        {access?.write && (
          <Route path="/:id/edit" element={<EditView />} />
        )}
        <Route path="/*" element={<Navigate to="404" replace />} />
      </Routes>
    </ResourceProvider>
  );
}
```

- `ResourceProvider` scopes translations so `t('headline')` resolves to `featureName.headline`
- `Access` type is `Record<'read' | 'write', boolean>`
- Access is gated by `navigation.*` keys from Redux state (populated from backend)
- Routes not gated by navigation keys are always visible

### Navigation hook

Use `useProjectNavigate()` from `src/useProjectNavigate.ts` for in-app navigation. It prepends `/:projectId` automatically.

## Sidebar Navigation

Sidebar items live in `src/sidebar/SidebarMenu.tsx`. Items are conditionally rendered based on `navigation.*` state from Redux.

### Adding a sidebar entry

```tsx
{navigation.featureName && (
  <SidebarMenuItem
    icon={<FeatureIcon />}
    to={`/${projectId}/feature-name`}
    label={<Translate id="featureName.navigation" />}
  />
)}
```

- Icons are SVG React components from `src/icons/`
- Use `<Translate id="..." />` for labels (legacy i18n wrapper)
- `SidebarMenuItemSub` for expandable sub-menus

## Form System

### Core components (from `src/form/`)

- **`Form`** — `<form>` wrapper with `<Stack spacing={4}>`, `noValidate`
- **`Fieldset`** — Groups fields in a `Panel` (header + body), legend from scoped translation
- **`useEnhancedForm`** — Wraps `react-hook-form`'s `useForm`, auto-applies server validation errors
- **`DefaultFormActions`** — Submit/cancel buttons with auto-reset on success

### Input components (from `src/form/input/`)

`TextField`, `NumberField`, `SelectField`, `SelectOptionsField`, `ColorField`, `ImageField`, `FileField`, `DateTimeField`, `CheckboxField`, `SearchableSelectField`, `SearchableFreeSoloMultiSelectField`

All inputs accept `name`, `control` (from react-hook-form), `rules`, and standard MUI props.

### View scaffolds (from `src/scaffold/`)

- **`ResourceFormView`** — Fetch on mount, loading indicator, form rendering, submit with validation, success/error alerts
- **`ResourceChartView`** — Fetch-on-filter-change, loading, error, and empty states for list views
- **`DeleteResourceView`** — Confirmation dialog + delete API call

## Styling

### Preferred approach (new code): `sx` prop

```tsx
<Box sx={{ display: 'flex', gap: 2, p: 1 }}>
```

### For reusable styled components: `styled()` from `@mui/system`

```typescript
import { styled } from '@mui/system';
const StyledWrapper = styled('div')(({ theme }) => ({
  padding: theme.spacing(2),
}));
```

### Legacy (existing code): `withStyles` HOC

Found in `SidebarMenu.tsx`, `ContentSkeleton.tsx`, `PaperTable.jsx`, etc. Do not introduce new `withStyles` usage.

### SCSS modules

Only used in 2 places for drag-and-drop CSS. Not a general pattern.

### Theme

Primary: `#07b` (blue), secondary: `#fff`, error: MUI red. Uses `adaptV4Theme` wrapper. Defined in `src/theme.ts`.

## Translations (i18n)

- **Languages**: English (`en`) and German (`de`), fallback to English
- **Files**: `src/translations/en/translations.json`, `src/translations/de/translations.json`
- **Single namespace** (`translation`), flat dot-notation keys
- **Convention**: `featureName.subKey.deeperKey` (e.g., `orders.headline`, `product.types.default`)
- **Both files must be updated in parallel** when adding keys
- **Usage**: `const { t } = useTranslation()` or scoped via `useResourceTranslator()`

## Error Handling

- **User-facing**: `useAlert()` from `src/toast/useAlert.tsx` — `alert.success({ actionName })`, `alert.error({ message })`
- **Form validation**: `withFormValidation()` catches 422, maps to react-hook-form errors
- **Auth errors**: 401/403 trigger automatic logout via Axios interceptor
- **Tracking**: Sentry (only on hosting environments)

## State Management

Two patterns coexist:

1. **Legacy Redux** — `src/reducers/` + `src/actions/`. Single root reducer with `Object.assign` merge. Classic `switch/case` reducers. Used for: auth, projects, navigation, shops list, products list, statistics. Do NOT introduce new Redux state.

2. **Modern hook-based** (preferred for new code) — `use*Api()` hooks with local component state. No Redux involvement. Used for: CRUD operations, feature-specific data.

## Testing

- **Framework**: Jest + `@testing-library/react` (v12) + `@testing-library/react-hooks`
- **Legacy**: Enzyme (still present, do not use for new tests)
- **HTTP mocking**: `nock`
- **Test wrappers** (in `test/` directory): `TestWrapperComponent` (full: Redux + Theme + Router), `withRouter`, `withTheme`, `createTestStore`
- **Co-located**: Test files sit next to source files as `*.test.tsx`
- **Run**: `npx react-app-rewired test` (Jest with jsdom, German locale, Europe/Paris timezone)

## Dialog Conventions

```tsx
<Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
  <DialogTitle>
    <Typography variant="h6" component="span" fontWeight="bold">
      {t('feature.dialogTitle')}
    </Typography>
  </DialogTitle>
  <DialogContent>
    {/* content */}
  </DialogContent>
  <DialogActions>
    <Button variant="contained" color="primary" onClick={handleAction}>
      {t('actions.save')}
    </Button>
    <Button onClick={onClose}>
      {t('actions.close')}
    </Button>
  </DialogActions>
</Dialog>
```

## Checklist for New Features

1. Create feature directory under `src/` with `types.ts`, `use*Api.ts`, `*View.tsx`, `*Routes.tsx`
2. API hook: use `defineApi` + `useProjectSpecificApiClient`
3. Routes: wrap in `ResourceProvider`, gate by `access?.read` / `access?.write`
4. Register route in `src/router/RoutesForAuthorizedUsers.tsx`
5. Add sidebar entry in `src/sidebar/SidebarMenu.tsx`
6. Add translation keys to **both** `en/translations.json` and `de/translations.json`
7. Use `useProjectNavigate()` for navigation
8. Use `useAlert()` for success/error feedback
9. Clear `node_modules/.cache` before verifying build
10. Use individual MUI and lodash imports (ESLint enforced)
