---
name: solidjs
description: SolidJS framework development skill for building reactive web applications with fine-grained reactivity. Use when working with SolidJS projects
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
---

# SolidJS Development

SolidJS is a declarative JavaScript library for building user interfaces with fine-grained reactivity. Unlike virtual DOM frameworks, Solid compiles templates to real DOM nodes and updates them with fine-grained reactions.

## Core Principles

1. **Components run once** — Component functions execute only during initialization, not on every update
2. **Fine-grained reactivity** — Only the specific DOM nodes that depend on changed data update
3. **No virtual DOM** — Direct DOM manipulation via compiled templates
4. **Signals are functions** — Access values by calling: `count()` not `count`

## Reactivity Primitives

### Signals — Basic State

```tsx
import { createSignal } from "solid-js";

const [count, setCount] = createSignal(0);

// Read value (getter)
console.log(count()); // 0

// Update value (setter)
setCount(1);
setCount((prev) => prev + 1); // Functional update
```

**Options:**

```tsx
const [value, setValue] = createSignal(initialValue, {
  equals: false, // Always trigger updates, even if value unchanged
  name: "debugName", // For devtools
});
```

### Effects — Side Effects

```tsx
import { createEffect } from "solid-js";

createEffect(() => {
  console.log("Count changed:", count());
  // Runs after render, re-runs when dependencies change
});
```

**Key behaviors:**

- Initial run: after render, before browser paint
- Subsequent runs: when tracked dependencies change
- Never runs during SSR or hydration
- Use `onCleanup` for cleanup logic

### Memos — Derived/Cached Values

```tsx
import { createMemo } from "solid-js";

const doubled = createMemo(() => count() * 2);

// Access like signal
console.log(doubled()); // Cached, only recalculates when count changes
```

Use memos when:

- Derived value is expensive to compute
- Derived value is accessed multiple times
- You want to prevent downstream updates when result unchanged

### Resources — Async Data

```tsx
import { createResource } from "solid-js";

const [user, { mutate, refetch }] = createResource(userId, fetchUser);

// In JSX
<Show when={!user.loading} fallback={<Loading />}>
  <div>{user()?.name}</div>
</Show>;

// Resource properties
user.loading; // boolean
user.error; // error if failed
user.state; // "unresolved" | "pending" | "ready" | "refreshing" | "errored"
user.latest; // last successful value
```

## Stores — Complex State

For nested objects/arrays with fine-grained updates:

```tsx
import { createStore } from "solid-js/store";

const [state, setState] = createStore({
  user: { name: "John", age: 30 },
  todos: [],
});

// Path syntax updates
setState("user", "name", "Jane");
setState("todos", (todos) => [...todos, newTodo]);
setState("todos", 0, "completed", true);

// Produce for immer-like updates
import { produce } from "solid-js/store";
setState(
  produce((s) => {
    s.user.age++;
    s.todos.push(newTodo);
  }),
);
```

**Store utilities:**

- `produce` — Immer-like mutations
- `reconcile` — Diff and patch data (for API responses)
- `unwrap` — Get raw non-reactive object

## Components

### Basic Component

```tsx
import { Component } from "solid-js";

const MyComponent: Component<{ name: string }> = (props) => {
  return <div>Hello, {props.name}</div>;
};
```

### Props Handling

```tsx
import { splitProps, mergeProps } from "solid-js";

// Default props
const merged = mergeProps({ size: "medium" }, props);

// Split props (for spreading)
const [local, others] = splitProps(props, ["class", "onClick"]);
return <button class={local.class} {...others} />;
```

**Props rules:**

- Props are reactive getters — don't destructure at top level
- Use `props.value` in JSX, not `const { value } = props`

### Children Helper

```tsx
import { children } from "solid-js";

const Wrapper: Component = (props) => {
  const resolved = children(() => props.children);

  createEffect(() => {
    console.log("Children:", resolved());
  });

  return <div>{resolved()}</div>;
};
```

## Control Flow Components

### Show — Conditional Rendering

```tsx
import { Show } from "solid-js";

<Show when={user()} fallback={<Login />}>
  {(user) => <Profile user={user()} />}
</Show>;
```

### For — List Rendering (keyed by reference)

```tsx
import { For } from "solid-js";

<For each={items()} fallback={<Empty />}>
  {(item, index) => (
    <div>
      {index()}: {item.name}
    </div>
  )}
</For>;
```

**Note:** `index` is a signal, `item` is the value.

### Index — List Rendering (keyed by index)

```tsx
import { Index } from "solid-js";

<Index each={items()}>{(item, index) => <input value={item().text} />}</Index>;
```

**Note:** `item` is a signal, `index` is the value. Better for primitive arrays or inputs.

### Switch/Match — Multiple Conditions

```tsx
import { Switch, Match } from "solid-js";

<Switch fallback={<Default />}>
  <Match when={state() === "loading"}>
    <Loading />
  </Match>
  <Match when={state() === "error"}>
    <Error />
  </Match>
  <Match when={state() === "success"}>
    <Success />
  </Match>
</Switch>;
```

### Dynamic — Dynamic Component

```tsx
import { Dynamic } from "solid-js/web";

<Dynamic component={selected()} someProp="value" />;
```

### Portal — Render Outside DOM Hierarchy

```tsx
import { Portal } from "solid-js/web";

<Portal mount={document.body}>
  <Modal />
</Portal>;
```

### ErrorBoundary — Error Handling

```tsx
import { ErrorBoundary } from "solid-js";

<ErrorBoundary
  fallback={(err, reset) => (
    <div>
      Error: {err.message}
      <button onClick={reset}>Retry</button>
    </div>
  )}
>
  <RiskyComponent />
</ErrorBoundary>;
```

### Suspense — Async Loading

```tsx
import { Suspense } from "solid-js";

<Suspense fallback={<Loading />}>
  <AsyncComponent />
</Suspense>;
```

## Context API

```tsx
import { createContext, useContext } from "solid-js";

// Create context
const CounterContext = createContext<{
  count: () => number;
  increment: () => void;
}>();

// Provider component
export function CounterProvider(props) {
  const [count, setCount] = createSignal(0);

  return (
    <CounterContext.Provider
      value={{
        count,
        increment: () => setCount((c) => c + 1),
      }}
    >
      {props.children}
    </CounterContext.Provider>
  );
}

// Consumer hook
export function useCounter() {
  const ctx = useContext(CounterContext);
  if (!ctx) throw new Error("useCounter must be used within CounterProvider");
  return ctx;
}
```

## Lifecycle

```tsx
import { onMount, onCleanup } from "solid-js";

function MyComponent() {
  onMount(() => {
    console.log("Mounted");
    const handler = () => {};
    window.addEventListener("resize", handler);

    onCleanup(() => {
      window.removeEventListener("resize", handler);
    });
  });

  return <div>Content</div>;
}
```

## Refs

```tsx
let inputRef: HTMLInputElement;

<input ref={inputRef} />
<input ref={(el) => { /* el is the DOM element */ }} />
```

## Event Handling

```tsx
// Standard events (lowercase)
<button onClick={handleClick}>Click</button>
<button onClick={(e) => handleClick(e)}>Click</button>

// Delegated events (on:)
<input on:input={handleInput} />

// Native events (on:) - not delegated
<div on:scroll={handleScroll} />
```

## Routing (Solid Router)

See [references/routing.md](references/routing.md) for complete routing guide.

Quick setup:

```tsx
import { Router, Route } from "@solidjs/router";

<Router>
  <Route path="/" component={Home} />
  <Route path="/users/:id" component={User} />
  <Route path="*404" component={NotFound} />
</Router>;
```

## SolidStart

See [references/solidstart.md](references/solidstart.md) for full-stack development guide.

Quick setup:

```bash
npm create solid@latest my-app
cd my-app && npm install && npm run dev
```

## Common Patterns

### Conditional Classes

```tsx
import { clsx } from "clsx"; // or classList

<div class={clsx("base", { active: isActive() })} />
<div classList={{ active: isActive(), disabled: isDisabled() }} />
```

### Batch Updates

```tsx
import { batch } from "solid-js";

batch(() => {
  setName("John");
  setAge(30);
  // Effects run once after batch completes
});
```

### Untrack

```tsx
import { untrack } from "solid-js";

createEffect(() => {
  console.log(count()); // tracked
  console.log(untrack(() => other())); // not tracked
});
```

## TypeScript

```tsx
import type { Component, ParentComponent, JSX } from "solid-js";

// Basic component
const Button: Component<{ label: string }> = (props) => (
  <button>{props.label}</button>
);

// With children
const Layout: ParentComponent<{ title: string }> = (props) => (
  <div>
    <h1>{props.title}</h1>
    {props.children}
  </div>
);

// Event handler types
const handleClick: JSX.EventHandler<HTMLButtonElement, MouseEvent> = (e) => {
  console.log(e.currentTarget);
};
```

## Project Setup

```bash
# Create new project
npm create solid@latest my-app

# With template
npx degit solidjs/templates/ts my-app

# SolidStart
npm create solid@latest my-app -- --template solidstart
```

**vite.config.ts:**

```ts
import { defineConfig } from "vite";
import solid from "vite-plugin-solid";

export default defineConfig({
  plugins: [solid()],
});
```

## Anti-Patterns to Avoid

1. **Destructuring props** — Breaks reactivity

   ```tsx
   // ❌ Bad
   const { name } = props;

   // ✅ Good
   props.name;
   ```

2. **Accessing signals outside tracking scope**

   ```tsx
   // ❌ Won't update
   console.log(count());

   // ✅ Will update
   createEffect(() => console.log(count()));
   ```

3. **Forgetting to call signal getters**

   ```tsx
   // ❌ Passes the function
   <div>{count}</div>

   // ✅ Passes the value
   <div>{count()}</div>
   ```

4. **Using array index as key** — Use `<For>` for reference-keyed, `<Index>` for index-keyed

5. **Side effects during render** — Use `createEffect` or `onMount`

# SolidJS Patterns & Best Practices

Common patterns, recipes, and best practices for SolidJS development.

## Component Patterns

### Controlled vs Uncontrolled Inputs

**Controlled:**

```tsx
function ControlledInput() {
  const [value, setValue] = createSignal("");

  return (
    <input value={value()} onInput={(e) => setValue(e.currentTarget.value)} />
  );
}
```

**Uncontrolled with ref:**

```tsx
function UncontrolledInput() {
  let inputRef: HTMLInputElement;

  const handleSubmit = () => {
    console.log(inputRef.value);
  };

  return (
    <>
      <input ref={inputRef!} />
      <button onClick={handleSubmit}>Submit</button>
    </>
  );
}
```

### Compound Components

```tsx
const Tabs = {
  Root: (props: ParentProps<{ defaultTab?: string }>) => {
    const [activeTab, setActiveTab] = createSignal(props.defaultTab ?? "");

    return (
      <TabsContext.Provider value={{ activeTab, setActiveTab }}>
        <div class="tabs">{props.children}</div>
      </TabsContext.Provider>
    );
  },

  List: (props: ParentProps) => (
    <div class="tabs-list" role="tablist">
      {props.children}
    </div>
  ),

  Tab: (props: ParentProps<{ value: string }>) => {
    const ctx = useTabsContext();
    return (
      <button
        role="tab"
        aria-selected={ctx.activeTab() === props.value}
        onClick={() => ctx.setActiveTab(props.value)}
      >
        {props.children}
      </button>
    );
  },

  Panel: (props: ParentProps<{ value: string }>) => {
    const ctx = useTabsContext();
    return (
      <Show when={ctx.activeTab() === props.value}>
        <div role="tabpanel">{props.children}</div>
      </Show>
    );
  },
};

// Usage
<Tabs.Root defaultTab="first">
  <Tabs.List>
    <Tabs.Tab value="first">First</Tabs.Tab>
    <Tabs.Tab value="second">Second</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="first">First Content</Tabs.Panel>
  <Tabs.Panel value="second">Second Content</Tabs.Panel>
</Tabs.Root>;
```

### Render Props

```tsx
function MouseTracker(props: {
  children: (pos: { x: number; y: number }) => JSX.Element;
}) {
  const [pos, setPos] = createSignal({ x: 0, y: 0 });

  onMount(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY });
    window.addEventListener("mousemove", handler);
    onCleanup(() => window.removeEventListener("mousemove", handler));
  });

  return <>{props.children(pos())}</>;
}

// Usage
<MouseTracker>
  {(pos) => (
    <div>
      Mouse: {pos.x}, {pos.y}
    </div>
  )}
</MouseTracker>;
```

### Higher-Order Components

```tsx
function withAuth<P extends object>(Component: Component<P>) {
  return (props: P) => {
    const { user } = useAuth();

    return (
      <Show when={user()} fallback={<Redirect to="/login" />}>
        <Component {...props} />
      </Show>
    );
  };
}

const ProtectedDashboard = withAuth(Dashboard);
```

### Polymorphic Components

```tsx
type PolymorphicProps<E extends keyof JSX.IntrinsicElements> = {
  as?: E;
} & JSX.IntrinsicElements[E];

function Box<E extends keyof JSX.IntrinsicElements = "div">(
  props: PolymorphicProps<E>
) {
  const [local, others] = splitProps(props as PolymorphicProps<"div">, ["as"]);

  return <Dynamic component={local.as || "div"} {...others} />;
}

// Usage
<Box>Default div</Box>
<Box as="section">Section element</Box>
<Box as="button" onClick={handleClick}>Button</Box>
```

## State Patterns

### Derived State with Multiple Sources

```tsx
function SearchResults() {
  const [query, setQuery] = createSignal("");
  const [filters, setFilters] = createSignal({ category: "all" });

  const results = createMemo(() => {
    const q = query().toLowerCase();
    const f = filters();

    return allItems()
      .filter((item) => item.name.toLowerCase().includes(q))
      .filter((item) => f.category === "all" || item.category === f.category);
  });

  return <For each={results()}>{(item) => <Item item={item} />}</For>;
}
```

### State Machine Pattern

```tsx
type State = "idle" | "loading" | "success" | "error";
type Event =
  | { type: "FETCH" }
  | { type: "SUCCESS"; data: any }
  | { type: "ERROR"; error: Error };

function createMachine(initial: State) {
  const [state, setState] = createSignal<State>(initial);
  const [data, setData] = createSignal<any>(null);
  const [error, setError] = createSignal<Error | null>(null);

  const send = (event: Event) => {
    const current = state();

    switch (current) {
      case "idle":
        if (event.type === "FETCH") setState("loading");
        break;
      case "loading":
        if (event.type === "SUCCESS") {
          setData(event.data);
          setState("success");
        } else if (event.type === "ERROR") {
          setError(event.error);
          setState("error");
        }
        break;
    }
  };

  return { state, data, error, send };
}
```

### Optimistic Updates

```tsx
const [todos, setTodos] = createStore<Todo[]>([]);

async function deleteTodo(id: string) {
  const original = [...unwrap(todos)];

  // Optimistic remove
  setTodos((todos) => todos.filter((t) => t.id !== id));

  try {
    await api.deleteTodo(id);
  } catch {
    // Rollback on error
    setTodos(reconcile(original));
  }
}
```

### Undo/Redo

```tsx
function createHistory<T>(initial: T) {
  const [past, setPast] = createSignal<T[]>([]);
  const [present, setPresent] = createSignal<T>(initial);
  const [future, setFuture] = createSignal<T[]>([]);

  const canUndo = () => past().length > 0;
  const canRedo = () => future().length > 0;

  const set = (value: T | ((prev: T) => T)) => {
    const newValue =
      typeof value === "function"
        ? (value as (prev: T) => T)(present())
        : value;

    setPast((p) => [...p, present()]);
    setPresent(newValue);
    setFuture([]);
  };

  const undo = () => {
    if (!canUndo()) return;

    const previous = past()[past().length - 1];
    setPast((p) => p.slice(0, -1));
    setFuture((f) => [present(), ...f]);
    setPresent(previous);
  };

  const redo = () => {
    if (!canRedo()) return;

    const next = future()[0];
    setPast((p) => [...p, present()]);
    setFuture((f) => f.slice(1));
    setPresent(next);
  };

  return { value: present, set, undo, redo, canUndo, canRedo };
}
```

## Custom Hooks/Primitives

### useLocalStorage

```tsx
function createLocalStorage<T>(key: string, initialValue: T) {
  const stored = localStorage.getItem(key);
  const initial = stored ? JSON.parse(stored) : initialValue;

  const [value, setValue] = createSignal<T>(initial);

  createEffect(() => {
    localStorage.setItem(key, JSON.stringify(value()));
  });

  return [value, setValue] as const;
}
```

### useDebounce

```tsx
function createDebounce<T>(source: () => T, delay: number) {
  const [debounced, setDebounced] = createSignal<T>(source());

  createEffect(() => {
    const value = source();
    const timer = setTimeout(() => setDebounced(() => value), delay);
    onCleanup(() => clearTimeout(timer));
  });

  return debounced;
}

// Usage
const debouncedQuery = createDebounce(query, 300);
```

### useThrottle

```tsx
function createThrottle<T>(source: () => T, delay: number) {
  const [throttled, setThrottled] = createSignal<T>(source());
  let lastRun = 0;

  createEffect(() => {
    const value = source();
    const now = Date.now();

    if (now - lastRun >= delay) {
      lastRun = now;
      setThrottled(() => value);
    } else {
      const timer = setTimeout(
        () => {
          lastRun = Date.now();
          setThrottled(() => value);
        },
        delay - (now - lastRun),
      );
      onCleanup(() => clearTimeout(timer));
    }
  });

  return throttled;
}
```

### useMediaQuery

```tsx
function createMediaQuery(query: string) {
  const mql = window.matchMedia(query);
  const [matches, setMatches] = createSignal(mql.matches);

  onMount(() => {
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener("change", handler);
    onCleanup(() => mql.removeEventListener("change", handler));
  });

  return matches;
}

// Usage
const isMobile = createMediaQuery("(max-width: 768px)");
```

### useClickOutside

```tsx
function createClickOutside(
  ref: () => HTMLElement | undefined,
  callback: () => void,
) {
  onMount(() => {
    const handler = (e: MouseEvent) => {
      const el = ref();
      if (el && !el.contains(e.target as Node)) {
        callback();
      }
    };
    document.addEventListener("click", handler);
    onCleanup(() => document.removeEventListener("click", handler));
  });
}

// Usage
let dropdownRef: HTMLDivElement;
createClickOutside(
  () => dropdownRef,
  () => setOpen(false),
);
```

### useIntersectionObserver

```tsx
function createIntersectionObserver(
  ref: () => HTMLElement | undefined,
  options?: IntersectionObserverInit,
) {
  const [isIntersecting, setIsIntersecting] = createSignal(false);

  onMount(() => {
    const el = ref();
    if (!el) return;

    const observer = new IntersectionObserver(([entry]) => {
      setIsIntersecting(entry.isIntersecting);
    }, options);

    observer.observe(el);
    onCleanup(() => observer.disconnect());
  });

  return isIntersecting;
}
```

## Form Patterns

### Form Validation

```tsx
function createForm<T extends Record<string, any>>(initial: T) {
  const [values, setValues] = createStore<T>(initial);
  const [errors, setErrors] = createStore<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = createStore<Partial<Record<keyof T, boolean>>>({});

  const handleChange = (field: keyof T) => (e: Event) => {
    const target = e.target as HTMLInputElement;
    setValues(field as any, target.value as any);
  };

  const handleBlur = (field: keyof T) => () => {
    setTouched(field as any, true);
  };

  const validate = (validators: Partial<Record<keyof T, (v: any) => string | undefined>>) => {
    let isValid = true;

    for (const [field, validator] of Object.entries(validators)) {
      if (validator) {
        const error = validator(values[field as keyof T]);
        setErrors(field as any, error as any);
        if (error) isValid = false;
      }
    }

    return isValid;
  };

  return { values, errors, touched, handleChange, handleBlur, validate, setValues };
}

// Usage
const form = createForm({ email: "", password: "" });

<input
  value={form.values.email}
  onInput={form.handleChange("email")}
  onBlur={form.handleBlur("email")}
/>
<Show when={form.touched.email && form.errors.email}>
  <span class="error">{form.errors.email}</span>
</Show>
```

### Field Array

```tsx
function createFieldArray<T>(initial: T[] = []) {
  const [fields, setFields] = createStore<T[]>(initial);

  const append = (value: T) => setFields((f) => [...f, value]);
  const remove = (index: number) =>
    setFields((f) => f.filter((_, i) => i !== index));
  const update = (index: number, value: Partial<T>) =>
    setFields(index, (v) => ({ ...v, ...value }));
  const move = (from: number, to: number) => {
    setFields(
      produce((f) => {
        const [item] = f.splice(from, 1);
        f.splice(to, 0, item);
      }),
    );
  };

  return { fields, append, remove, update, move };
}
```

## Performance Patterns

### Virtualized List

```tsx
function VirtualList<T>(props: {
  items: T[];
  itemHeight: number;
  height: number;
  renderItem: (item: T, index: number) => JSX.Element;
}) {
  const [scrollTop, setScrollTop] = createSignal(0);

  const startIndex = createMemo(() =>
    Math.floor(scrollTop() / props.itemHeight),
  );

  const visibleCount = createMemo(
    () => Math.ceil(props.height / props.itemHeight) + 1,
  );

  const visibleItems = createMemo(() =>
    props.items.slice(startIndex(), startIndex() + visibleCount()),
  );

  return (
    <div
      style={{ height: `${props.height}px`, overflow: "auto" }}
      onScroll={(e) => setScrollTop(e.currentTarget.scrollTop)}
    >
      <div
        style={{
          height: `${props.items.length * props.itemHeight}px`,
          position: "relative",
        }}
      >
        <For each={visibleItems()}>
          {(item, i) => (
            <div
              style={{
                position: "absolute",
                top: `${(startIndex() + i()) * props.itemHeight}px`,
                height: `${props.itemHeight}px`,
              }}
            >
              {props.renderItem(item, startIndex() + i())}
            </div>
          )}
        </For>
      </div>
    </div>
  );
}
```

### Lazy Loading with Intersection Observer

```tsx
function LazyLoad(props: ParentProps<{ placeholder?: JSX.Element }>) {
  let ref: HTMLDivElement;
  const [isVisible, setIsVisible] = createSignal(false);

  onMount(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          observer.disconnect();
        }
      },
      { rootMargin: "100px" },
    );
    observer.observe(ref);
    onCleanup(() => observer.disconnect());
  });

  return (
    <div ref={ref!}>
      <Show when={isVisible()} fallback={props.placeholder}>
        {props.children}
      </Show>
    </div>
  );
}
```

### Memoized Component

```tsx
// For expensive components that shouldn't re-render on parent updates
function MemoizedExpensiveList(props: { items: Item[] }) {
  // Component only re-renders when items actually change
  return (
    <For each={props.items}>{(item) => <ExpensiveItem item={item} />}</For>
  );
}
```

## Testing Patterns

### Component Testing

```tsx
import { render, fireEvent, screen } from "@solidjs/testing-library";

test("Counter increments", async () => {
  render(() => <Counter />);

  const button = screen.getByRole("button", { name: /increment/i });
  expect(screen.getByText("Count: 0")).toBeInTheDocument();

  fireEvent.click(button);
  expect(screen.getByText("Count: 1")).toBeInTheDocument();
});
```

### Testing with Context

```tsx
function renderWithContext(component: () => JSX.Element) {
  return render(() => (
    <ThemeProvider>
      <AuthProvider>{component()}</AuthProvider>
    </ThemeProvider>
  ));
}

test("Dashboard shows user", () => {
  renderWithContext(() => <Dashboard />);
  // ...
});
```

### Testing Async Components

```tsx
import { render, waitFor, screen } from "@solidjs/testing-library";

test("Loads user data", async () => {
  render(() => <UserProfile userId="123" />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  await waitFor(() => {
    expect(screen.getByText("John Doe")).toBeInTheDocument();
  });
});
```

## Error Handling Patterns

### Global Error Handler

```tsx
function App() {
  return (
    <ErrorBoundary
      fallback={(err, reset) => <ErrorPage error={err} onRetry={reset} />}
    >
      <Suspense fallback={<AppLoader />}>
        <Router>{/* Routes */}</Router>
      </Suspense>
    </ErrorBoundary>
  );
}
```

### Async Error Handling

```tsx
function DataComponent() {
  const [data] = createResource(fetchData);

  return (
    <Switch>
      <Match when={data.loading}>
        <Loading />
      </Match>
      <Match when={data.error}>
        <Error error={data.error} onRetry={() => refetch()} />
      </Match>
      <Match when={data()}>{(data) => <Content data={data()} />}</Match>
    </Switch>
  );
}
```

## Accessibility Patterns

### Focus Management

```tsx
function Modal(props: ParentProps<{ isOpen: boolean; onClose: () => void }>) {
  let dialogRef: HTMLDivElement;
  let previousFocus: HTMLElement | null;

  createEffect(() => {
    if (props.isOpen) {
      previousFocus = document.activeElement as HTMLElement;
      dialogRef.focus();
    } else if (previousFocus) {
      previousFocus.focus();
    }
  });

  return (
    <Show when={props.isOpen}>
      <Portal>
        <div
          ref={dialogRef!}
          role="dialog"
          aria-modal="true"
          tabIndex={-1}
          onKeyDown={(e) => e.key === "Escape" && props.onClose()}
        >
          {props.children}
        </div>
      </Portal>
    </Show>
  );
}
```

### Live Regions

```tsx
function Notifications() {
  const [message, setMessage] = createSignal("");

  return (
    <div role="status" aria-live="polite" aria-atomic="true" class="sr-only">
      {message()}
    </div>
  );
}
```

# SolidJS API Reference

Complete reference for all SolidJS primitives, utilities, and component APIs.

## Basic Reactivity

### createSignal

```tsx
import { createSignal } from "solid-js";

const [getter, setter] = createSignal<T>(initialValue, options?);

// Options
interface SignalOptions<T> {
  equals?: false | ((prev: T, next: T) => boolean);
  name?: string;
  internal?: boolean;
}
```

**Examples:**

```tsx
const [count, setCount] = createSignal(0);
const [user, setUser] = createSignal<User | null>(null);

// Always update
const [data, setData] = createSignal(obj, { equals: false });

// Custom equality
const [items, setItems] = createSignal([], {
  equals: (a, b) => a.length === b.length,
});

// Setter forms
setCount(5); // Direct value
setCount((prev) => prev + 1); // Functional update
```

### createEffect

```tsx
import { createEffect } from "solid-js";

createEffect<T>(fn: (prev: T) => T, initialValue?: T, options?);

// Options
interface EffectOptions {
  name?: string;
}
```

**Examples:**

```tsx
// Basic
createEffect(() => {
  console.log("Count:", count());
});

// With previous value
createEffect((prev) => {
  console.log("Changed from", prev, "to", count());
  return count();
}, count());

// With cleanup
createEffect(() => {
  const handler = () => {};
  window.addEventListener("resize", handler);
  onCleanup(() => window.removeEventListener("resize", handler));
});
```

### createMemo

```tsx
import { createMemo } from "solid-js";

const getter = createMemo<T>(fn: (prev: T) => T, initialValue?: T, options?);

// Options
interface MemoOptions<T> {
  equals?: false | ((prev: T, next: T) => boolean);
  name?: string;
}
```

**Examples:**

```tsx
const doubled = createMemo(() => count() * 2);
const filtered = createMemo(() => items().filter((i) => i.active));

// Previous value
const delta = createMemo((prev) => count() - prev, 0);
```

### createResource

```tsx
import { createResource } from "solid-js";

const [resource, { mutate, refetch }] = createResource(
  source?,      // Optional reactive source
  fetcher,      // (source, info) => Promise<T>
  options?
);

// Resource properties
resource()           // T | undefined
resource.loading     // boolean
resource.error       // any
resource.state       // "unresolved" | "pending" | "ready" | "refreshing" | "errored"
resource.latest      // T | undefined (last successful value)

// Options
interface ResourceOptions<T> {
  initialValue?: T;
  name?: string;
  deferStream?: boolean;
  ssrLoadFrom?: "initial" | "server";
  storage?: (init: T) => [Accessor<T>, Setter<T>];
  onHydrated?: (key, info: { value: T }) => void;
}
```

**Examples:**

```tsx
// Without source
const [users] = createResource(fetchUsers);

// With source
const [user] = createResource(userId, fetchUser);

// With options
const [data] = createResource(id, fetchData, {
  initialValue: [],
  deferStream: true,
});

// Actions
mutate(newValue); // Update locally
refetch(); // Re-fetch
refetch(customInfo); // Pass to fetcher's info.refetching
```

## Stores

### createStore

```tsx
import { createStore } from "solid-js/store";

const [store, setStore] = createStore<T>(initialValue);
```

**Update patterns:**

```tsx
const [state, setState] = createStore({
  user: { name: "John", age: 30 },
  todos: [{ id: 1, text: "Learn Solid", done: false }],
});

// Path syntax
setState("user", "name", "Jane");
setState("user", "age", (a) => a + 1);
setState("todos", 0, "done", true);

// Array operations
setState("todos", (t) => [...t, newTodo]);
setState("todos", todos.length, newTodo);

// Multiple paths
setState("todos", { from: 0, to: 2 }, "done", true);
setState("todos", [0, 2, 4], "done", true);
setState("todos", (i) => i.done, "done", false);

// Object merge (shallow)
setState("user", { age: 31 }); // Keeps other properties
```

### produce

```tsx
import { produce } from "solid-js/store";

setState(
  produce((draft) => {
    draft.user.age++;
    draft.todos.push({ id: 2, text: "New", done: false });
    draft.todos[0].done = true;
  }),
);
```

### reconcile

```tsx
import { reconcile } from "solid-js/store";

// Replace with diff (minimal updates)
setState("todos", reconcile(newTodosFromAPI));

// Options
reconcile(data, { key: "id", merge: true });
```

### unwrap

```tsx
import { unwrap } from "solid-js/store";

const raw = unwrap(store); // Non-reactive plain object
```

### createMutable

```tsx
import { createMutable } from "solid-js/store";

const state = createMutable({
  count: 0,
  user: { name: "John" },
});

// Direct mutation (like MobX)
state.count++;
state.user.name = "Jane";
```

### modifyMutable

```tsx
import { modifyMutable, reconcile, produce } from "solid-js/store";

modifyMutable(state, reconcile(newData));
modifyMutable(
  state,
  produce((s) => {
    s.count++;
  }),
);
```

## Component APIs

### children

```tsx
import { children } from "solid-js";

const resolved = children(() => props.children);

// Access
resolved(); // JSX.Element | JSX.Element[]
resolved.toArray(); // Always array
```

### createContext / useContext

```tsx
import { createContext, useContext } from "solid-js";

const MyContext = createContext<T>(defaultValue?);

// Provider
<MyContext.Provider value={value}>
  {children}
</MyContext.Provider>

// Consumer
const value = useContext(MyContext);
```

### createUniqueId

```tsx
import { createUniqueId } from "solid-js";

const id = createUniqueId(); // "0", "1", etc.
```

### lazy

```tsx
import { lazy } from "solid-js";

const LazyComponent = lazy(() => import("./Component"));

// Use with Suspense
<Suspense fallback={<Loading />}>
  <LazyComponent />
</Suspense>;
```

## Lifecycle

### onMount

```tsx
import { onMount } from "solid-js";

onMount(() => {
  // Runs once after initial render
  console.log("Mounted");
});
```

### onCleanup

```tsx
import { onCleanup } from "solid-js";

// In component
onCleanup(() => {
  console.log("Cleaning up");
});

// In effect
createEffect(() => {
  const sub = subscribe();
  onCleanup(() => sub.unsubscribe());
});
```

## Reactive Utilities

### batch

```tsx
import { batch } from "solid-js";

batch(() => {
  setA(1);
  setB(2);
  setC(3);
  // Effects run once after batch
});
```

### untrack

```tsx
import { untrack } from "solid-js";

createEffect(() => {
  console.log(a()); // Tracked
  console.log(untrack(() => b())); // Not tracked
});
```

### on

```tsx
import { on } from "solid-js";

// Explicit dependencies
createEffect(
  on(count, (value, prev) => {
    console.log("Count changed:", prev, "->", value);
  }),
);

// Multiple dependencies
createEffect(
  on([a, b], ([a, b], [prevA, prevB]) => {
    console.log("Changed");
  }),
);

// Defer first run
createEffect(on(count, (v) => console.log(v), { defer: true }));
```

### mergeProps

```tsx
import { mergeProps } from "solid-js";

const merged = mergeProps(
  { size: "medium", color: "blue" }, // Defaults
  props, // Overrides
);
```

### splitProps

```tsx
import { splitProps } from "solid-js";

const [local, others] = splitProps(props, ["class", "onClick"]);
// local.class, local.onClick
// others contains everything else

const [a, b, rest] = splitProps(props, ["foo"], ["bar"]);
```

### createRoot

```tsx
import { createRoot } from "solid-js";

const dispose = createRoot((dispose) => {
  const [count, setCount] = createSignal(0);
  // Use signals...
  return dispose;
});

// Later
dispose();
```

### getOwner / runWithOwner

```tsx
import { getOwner, runWithOwner } from "solid-js";

const owner = getOwner();

// Later, in async code
runWithOwner(owner, () => {
  createEffect(() => {
    // This effect has proper ownership
  });
});
```

### mapArray

```tsx
import { mapArray } from "solid-js";

const mapped = mapArray(
  () => items(),
  (item, index) => ({ ...item, doubled: item.value * 2 }),
);
```

### indexArray

```tsx
import { indexArray } from "solid-js";

const mapped = indexArray(
  () => items(),
  (item, index) => (
    <div>
      {index}: {item().name}
    </div>
  ),
);
```

### observable

```tsx
import { observable } from "solid-js";

const obs = observable(signal);
obs.subscribe((value) => console.log(value));
```

### from

```tsx
import { from } from "solid-js";

// Convert observable/subscribable to signal
const signal = from(rxObservable);
const signal = from((set) => {
  const unsub = subscribe(set);
  return unsub;
});
```

### catchError

```tsx
import { catchError } from "solid-js";

catchError(
  () => riskyOperation(),
  (err) => console.error("Error:", err),
);
```

## Secondary Primitives

### createComputed

```tsx
import { createComputed } from "solid-js";

// Like createEffect but runs during render phase
createComputed(() => {
  setDerived(source() * 2);
});
```

### createRenderEffect

```tsx
import { createRenderEffect } from "solid-js";

// Runs before paint (for DOM measurements)
createRenderEffect(() => {
  const height = element.offsetHeight;
});
```

### createDeferred

```tsx
import { createDeferred } from "solid-js";

// Returns value after idle time
const deferred = createDeferred(() => expensiveComputation(), {
  timeoutMs: 1000,
});
```

### createReaction

```tsx
import { createReaction } from "solid-js";

const track = createReaction(() => {
  console.log("Something changed");
});

track(() => count()); // Start tracking
```

### createSelector

```tsx
import { createSelector } from "solid-js";

const isSelected = createSelector(selectedId);

<For each={items()}>
  {(item) => (
    <div class={isSelected(item.id) ? "selected" : ""}>{item.name}</div>
  )}
</For>;
```

## Components

### Show

```tsx
<Show when={condition()} fallback={<Fallback />}>
  <Content />
</Show>

// With callback (narrowed type)
<Show when={user()}>
  {(user) => <div>{user().name}</div>}
</Show>
```

### For

```tsx
<For each={items()} fallback={<Empty />}>
  {(item, index) => (
    <div>
      {index()}: {item.name}
    </div>
  )}
</For>
```

### Index

```tsx
<Index each={items()} fallback={<Empty />}>
  {(item, index) => <input value={item().text} />}
</Index>
```

### Switch / Match

```tsx
<Switch fallback={<Default />}>
  <Match when={state() === "loading"}>
    <Loading />
  </Match>
  <Match when={state() === "error"}>
    <Error />
  </Match>
</Switch>
```

### Dynamic

```tsx
import { Dynamic } from "solid-js/web";

<Dynamic component={selected()} prop={value} />
<Dynamic component="div" class="dynamic">Content</Dynamic>
```

### Portal

```tsx
import { Portal } from "solid-js/web";

<Portal mount={document.body}>
  <Modal />
</Portal>;
```

### ErrorBoundary

```tsx
<ErrorBoundary
  fallback={(err, reset) => (
    <div>
      <p>Error: {err.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )}
>
  <Content />
</ErrorBoundary>
```

### Suspense

```tsx
<Suspense fallback={<Loading />}>
  <AsyncContent />
</Suspense>
```

### SuspenseList

```tsx
<SuspenseList revealOrder="forwards" tail="collapsed">
  <Suspense fallback={<Loading />}>
    <Item1 />
  </Suspense>
  <Suspense fallback={<Loading />}>
    <Item2 />
  </Suspense>
  <Suspense fallback={<Loading />}>
    <Item3 />
  </Suspense>
</SuspenseList>
```

## Rendering

### render

```tsx
import { render } from "solid-js/web";

const dispose = render(() => <App />, document.getElementById("root")!);

// Cleanup
dispose();
```

### hydrate

```tsx
import { hydrate } from "solid-js/web";

hydrate(() => <App />, document.getElementById("root")!);
```

### renderToString

```tsx
import { renderToString } from "solid-js/web";

const html = renderToString(() => <App />);
```

### renderToStringAsync

```tsx
import { renderToStringAsync } from "solid-js/web";

const html = await renderToStringAsync(() => <App />);
```

### renderToStream

```tsx
import { renderToStream } from "solid-js/web";

const stream = renderToStream(() => <App />);
stream.pipe(res);
```

### isServer

```tsx
import { isServer } from "solid-js/web";

if (isServer) {
  // Server-only code
}
```

## JSX Attributes

### ref

```tsx
let el: HTMLDivElement;
<div ref={el} />
<div ref={(e) => console.log(e)} />
```

### classList

```tsx
<div classList={{ active: isActive(), disabled: isDisabled() }} />
```

### style

```tsx
<div style={{ color: "red", "font-size": "14px" }} />
<div style={`color: ${color()}`} />
```

### on:event (native)

```tsx
<div on:click={handleClick} />
<div on:scroll={handleScroll} />
```

### use:directive

```tsx
function clickOutside(el: HTMLElement, accessor: () => () => void) {
  const handler = (e: MouseEvent) => {
    if (!el.contains(e.target as Node)) accessor()();
  };
  document.addEventListener("click", handler);
  onCleanup(() => document.removeEventListener("click", handler));
}

<div use:clickOutside={() => setOpen(false)} />;
```

### prop:property

```tsx
<input prop:value={value()} /> // Set as property, not attribute
```

### attr:attribute

```tsx
<div attr:data-custom={value()} /> // Force attribute
```

### bool:attribute

```tsx
<input bool:disabled={isDisabled()} />
```

### @once

```tsx
<div title={/*@once*/ staticValue} /> // Never updates
```

## Types

```tsx
import type {
  Component,
  ParentComponent,
  FlowComponent,
  VoidComponent,
  JSX,
  Accessor,
  Setter,
  Signal,
  Resource,
  Owner,
} from "solid-js";

// Component types
const MyComponent: Component<Props> = (props) => <div />;
const Parent: ParentComponent<Props> = (props) => <div>{props.children}</div>;
const Flow: FlowComponent<Props, Item> = (props) => props.children(item);
const Void: VoidComponent<Props> = (props) => <input />;

// Event types
type Handler = JSX.EventHandler<HTMLButtonElement, MouseEvent>;
type ChangeHandler = JSX.ChangeEventHandler<HTMLInputElement>;
```

# Solid Router Reference

Complete guide to routing in SolidJS applications using `@solidjs/router`.

## Installation

```bash
npm install @solidjs/router
```

## Basic Setup

```tsx
import { Router, Route } from "@solidjs/router";

function App() {
  return (
    <Router>
      <Route path="/" component={Home} />
      <Route path="/about" component={About} />
      <Route path="/users/:id" component={User} />
      <Route path="*404" component={NotFound} />
    </Router>
  );
}
```

## Router with Root Layout

```tsx
import { Router, Route } from "@solidjs/router";

function App() {
  return (
    <Router root={Layout}>
      <Route path="/" component={Home} />
      <Route path="/about" component={About} />
    </Router>
  );
}

function Layout(props) {
  return (
    <div>
      <nav>
        <A href="/">Home</A>
        <A href="/about">About</A>
      </nav>
      <main>{props.children}</main>
    </div>
  );
}
```

## Navigation

### Link Component

```tsx
import { A } from "@solidjs/router";

<A href="/about">About</A>
<A href="/about" activeClass="active">About</A>
<A href="/about" inactiveClass="inactive">About</A>
<A href="/about" end>About</A> // Exact match only
```

### Programmatic Navigation

```tsx
import { useNavigate } from "@solidjs/router";

function MyComponent() {
  const navigate = useNavigate();

  const handleClick = () => {
    navigate("/users/123");
    navigate("/users/123", { replace: true }); // Replace history
    navigate(-1); // Go back
  };

  return <button onClick={handleClick}>Navigate</button>;
}
```

## Route Parameters

### Dynamic Segments

```tsx
<Route path="/users/:id" component={User} />
<Route path="/posts/:postId/comments/:commentId" component={Comment} />
```

### Accessing Parameters

```tsx
import { useParams } from "@solidjs/router";

function User() {
  const params = useParams();

  return <div>User ID: {params.id}</div>;
}
```

### Optional Parameters

```tsx
<Route path="/users/:id?" component={Users} />
```

### Wildcard Routes

```tsx
<Route path="/files/*" component={FileBrowser} />
<Route path="/files/*path" component={FileBrowser} /> // Named wildcard
```

## Query Parameters

```tsx
import { useSearchParams } from "@solidjs/router";

function Search() {
  const [searchParams, setSearchParams] = useSearchParams();

  // Read: ?q=hello&page=1
  console.log(searchParams.q); // "hello"
  console.log(searchParams.page); // "1"

  // Update
  setSearchParams({ q: "world" });
  setSearchParams({ page: 2 }, { replace: true });

  return (
    <input
      value={searchParams.q || ""}
      onInput={(e) => setSearchParams({ q: e.target.value })}
    />
  );
}
```

## Location

```tsx
import { useLocation } from "@solidjs/router";

function CurrentPath() {
  const location = useLocation();

  return (
    <div>
      <p>Path: {location.pathname}</p>
      <p>Search: {location.search}</p>
      <p>Hash: {location.hash}</p>
    </div>
  );
}
```

## Nested Routes

```tsx
<Router>
  <Route path="/users" component={UsersLayout}>
    <Route path="/" component={UsersList} />
    <Route path="/:id" component={UserDetail} />
    <Route path="/:id/edit" component={UserEdit} />
  </Route>
</Router>;

function UsersLayout(props) {
  return (
    <div>
      <h1>Users</h1>
      {props.children}
    </div>
  );
}
```

## Route Matching

```tsx
import { useMatch } from "@solidjs/router";

function NavLink(props) {
  const match = useMatch(() => props.href);

  return (
    <A href={props.href} class={match() ? "active" : ""}>
      {props.children}
    </A>
  );
}
```

## Match Filters (Validation)

```tsx
const filters = {
  parent: ["mom", "dad"],
  id: /^\d+$/,
  withHtml: (v) => v.endsWith(".html"),
};

<Route
  path="/users/:parent/:id/:withHtml"
  component={User}
  matchFilters={filters}
/>;
```

## Lazy Loading Routes

```tsx
import { lazy } from "solid-js";

const UserProfile = lazy(() => import("./pages/UserProfile"));

<Route path="/profile" component={UserProfile} />;
```

## Data Loading (Preload)

```tsx
import { cache, createAsync } from "@solidjs/router";

// Define cached data function
const getUser = cache(async (id: string) => {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}, "user");

// Route with preload
<Route
  path="/users/:id"
  component={User}
  preload={({ params }) => getUser(params.id)}
/>;

// Component using data
function User() {
  const params = useParams();
  const user = createAsync(() => getUser(params.id));

  return <Show when={user()}>{(user) => <div>{user().name}</div>}</Show>;
}
```

## Protected Routes

```tsx
import { Navigate } from "@solidjs/router";

function ProtectedRoute(props) {
  const { isAuthenticated } = useAuth();

  return (
    <Show when={isAuthenticated()} fallback={<Navigate href="/login" />}>
      {props.children}
    </Show>
  );
}

// Usage
<Route
  path="/dashboard"
  component={() => (
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  )}
/>;
```

## Route Guards with Preload

```tsx
const checkAuth = cache(async () => {
  const res = await fetch("/api/auth/me");
  if (!res.ok) throw redirect("/login");
  return res.json();
}, "auth");

<Route path="/dashboard" component={Dashboard} preload={() => checkAuth()} />;
```

## Hash Router

```tsx
import { HashRouter, Route } from "@solidjs/router";

<HashRouter>
  <Route path="/" component={Home} />
</HashRouter>;
```

## Memory Router (Testing)

```tsx
import { MemoryRouter, Route } from "@solidjs/router";

<MemoryRouter initialEntries={["/users/123"]}>
  <Route path="/users/:id" component={User} />
</MemoryRouter>;
```

## Route Actions

```tsx
import { action, useAction, useSubmission } from "@solidjs/router";

const addTodo = action(async (formData: FormData) => {
  const title = formData.get("title");
  await createTodo(title);
  return redirect("/todos");
}, "addTodo");

function AddTodoForm() {
  const submission = useSubmission(addTodo);

  return (
    <form action={addTodo} method="post">
      <input name="title" />
      <button disabled={submission.pending}>
        {submission.pending ? "Adding..." : "Add"}
      </button>
    </form>
  );
}
```

## Hooks Summary

| Hook                   | Purpose                               |
| ---------------------- | ------------------------------------- |
| `useParams()`          | Access route parameters               |
| `useSearchParams()`    | Read/write query string               |
| `useLocation()`        | Current location object               |
| `useNavigate()`        | Programmatic navigation               |
| `useMatch(() => path)` | Check if path matches                 |
| `useBeforeLeave()`     | Guard against navigation              |
| `useIsRouting()`       | Check if route transition in progress |

## Navigation Guards

```tsx
import { useBeforeLeave } from "@solidjs/router";

function Editor() {
  const [hasUnsaved, setHasUnsaved] = createSignal(false);

  useBeforeLeave((e) => {
    if (hasUnsaved() && !e.defaultPrevented) {
      e.preventDefault();
      if (window.confirm("Discard changes?")) {
        e.retry(true); // Force navigation
      }
    }
  });

  return <textarea onInput={() => setHasUnsaved(true)} />;
}
```

## Scroll Restoration

```tsx
<Router>
  {/* Automatic scroll restoration */}
  <Route path="/" component={Home} />
</Router>
```

To disable:

```tsx
import { useLocation } from "@solidjs/router";

// Handle manually
createEffect(() => {
  location.pathname; // Track changes
  window.scrollTo(0, 0);
});
```

# SolidStart Reference

Complete guide to building full-stack applications with SolidStart, the SolidJS meta-framework.

## Overview

SolidStart is built on:

- **Solid** — Fine-grained reactive UI library
- **Vinxi** — Framework bundler (Vite + Nitro)
- **File-based routing** — via Solid Router

## Quick Start

```bash
# Create new project
npm create solid@latest my-app

# Options during setup:
# - With TypeScript? Yes
# - Template: SolidStart

cd my-app
npm install
npm run dev
```

## Project Structure

```
my-app/
├── src/
│   ├── routes/           # File-based routes
│   │   ├── index.tsx     # /
│   │   ├── about.tsx     # /about
│   │   └── users/
│   │       ├── index.tsx # /users
│   │       └── [id].tsx  # /users/:id
│   ├── components/       # Shared components
│   ├── lib/              # Utilities
│   └── entry-server.tsx  # Server entry
│   └── entry-client.tsx  # Client entry
├── public/               # Static assets
├── app.config.ts         # SolidStart config
└── package.json
```

## Configuration

**app.config.ts:**

```ts
import { defineConfig } from "@solidjs/start/config";

export default defineConfig({
  server: {
    preset: "node-server", // or "vercel", "netlify", "cloudflare-pages"
    // prerender: { routes: ["/", "/about"] }
  },
  vite: {
    // Vite options
  },
});
```

## Rendering Modes

### SSR (Default)

```ts
// app.config.ts
export default defineConfig({
  server: {
    preset: "node-server",
  },
});
```

### Static Site Generation (SSG)

```ts
export default defineConfig({
  server: {
    prerender: {
      routes: ["/", "/about", "/posts"],
      // or crawl from root
      crawlLinks: true,
    },
  },
});
```

### Client-Side Only (SPA)

```ts
export default defineConfig({
  ssr: false,
});
```

## File-Based Routing

### Basic Routes

| File                     | Route               |
| ------------------------ | ------------------- |
| `routes/index.tsx`       | `/`                 |
| `routes/about.tsx`       | `/about`            |
| `routes/blog/index.tsx`  | `/blog`             |
| `routes/blog/[slug].tsx` | `/blog/:slug`       |
| `routes/[...all].tsx`    | `/*all` (catch-all) |

### Dynamic Routes

```tsx
// routes/users/[id].tsx
import { useParams } from "@solidjs/router";

export default function User() {
  const params = useParams();
  return <div>User: {params.id}</div>;
}
```

### Route Groups

Folders starting with `(name)` are groups (not in URL):

```
routes/
├── (auth)/
│   ├── login.tsx     # /login
│   └── register.tsx  # /register
└── (dashboard)/
    └── settings.tsx  # /settings
```

### Layout Files

```tsx
// routes/(dashboard).tsx — Layout for dashboard group
export default function DashboardLayout(props) {
  return (
    <div class="dashboard">
      <Sidebar />
      <main>{props.children}</main>
    </div>
  );
}
```

### 404 Page

```tsx
// routes/[...404].tsx
export default function NotFound() {
  return <div>Page Not Found</div>;
}
```

## Data Fetching

### Server-Side Data Loading

```tsx
// routes/users/[id].tsx
import { cache, createAsync } from "@solidjs/router";
import { getRequestEvent } from "solid-js/web";

const getUser = cache(async (id: string) => {
  "use server";
  const response = await fetch(`https://api.example.com/users/${id}`);
  return response.json();
}, "user");

export const route = {
  preload: ({ params }) => getUser(params.id),
};

export default function User() {
  const params = useParams();
  const user = createAsync(() => getUser(params.id));

  return <Show when={user()}>{(user) => <h1>{user().name}</h1>}</Show>;
}
```

### createAsync

```tsx
import { createAsync } from "@solidjs/router";

const data = createAsync(() => fetchData(), {
  initialValue: [],
  deferStream: true, // Wait for data before streaming
});
```

### Error Handling

```tsx
import { ErrorBoundary } from "solid-js";

export default function Page() {
  const data = createAsync(async () => {
    const res = await fetch("/api/data");
    if (!res.ok) throw new Error("Failed");
    return res.json();
  });

  return (
    <ErrorBoundary fallback={(err) => <div>Error: {err.message}</div>}>
      <Suspense fallback={<Loading />}>
        <DataView data={data()} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## API Routes

### Basic API Route

```tsx
// routes/api/hello.ts
import { APIEvent } from "@solidjs/start/server";

export function GET(event: APIEvent) {
  return new Response(JSON.stringify({ message: "Hello" }), {
    headers: { "Content-Type": "application/json" },
  });
}

export function POST(event: APIEvent) {
  const body = await event.request.json();
  // Process body
  return new Response(JSON.stringify({ success: true }));
}
```

### Dynamic API Routes

```tsx
// routes/api/users/[id].ts
export async function GET(event: APIEvent) {
  const id = event.params.id;
  const user = await db.users.find(id);
  return Response.json(user);
}
```

### Request Event

```tsx
export async function GET(event: APIEvent) {
  const url = new URL(event.request.url);
  const searchParams = url.searchParams;
  const headers = event.request.headers;
  const cookies = event.request.headers.get("cookie");

  // Set cookies
  return new Response(data, {
    headers: {
      "Set-Cookie": "session=abc123; HttpOnly",
    },
  });
}
```

## Server Functions

### "use server" Directive

```tsx
// Can be in any file
async function saveUser(data: FormData) {
  "use server";
  // Runs only on server
  const name = data.get("name");
  await db.users.create({ name });
  return { success: true };
}
```

### Server Actions

```tsx
import { action, useAction, useSubmission } from "@solidjs/router";

const addTodo = action(async (formData: FormData) => {
  "use server";
  const title = formData.get("title");
  await db.todos.create({ title });
  throw redirect("/todos"); // Redirect after action
}, "addTodo");

function AddTodoForm() {
  const submission = useSubmission(addTodo);

  return (
    <form action={addTodo} method="post">
      <input name="title" required />
      <button disabled={submission.pending}>
        {submission.pending ? "Adding..." : "Add Todo"}
      </button>
      {submission.error && <p>Error: {submission.error.message}</p>}
    </form>
  );
}
```

### Progressive Enhancement

Forms work without JavaScript:

```tsx
<form action={submitForm} method="post">
  <input name="email" type="email" />
  <button>Submit</button>
</form>
```

## Middleware

```tsx
// src/middleware.ts
import { createMiddleware } from "@solidjs/start/middleware";

export default createMiddleware({
  onRequest: [
    async (event) => {
      console.log("Request:", event.request.url);
      // Return Response to short-circuit
      // Return undefined to continue
    },
  ],
  onBeforeResponse: [
    async (event, response) => {
      // Modify response
      return response;
    },
  ],
});
```

Register in config:

```ts
// app.config.ts
export default defineConfig({
  middleware: "./src/middleware.ts",
});
```

## Authentication

### Session-Based

```tsx
// lib/session.ts
import { useSession } from "@solidjs/start/server";

export function getSession() {
  "use server";
  return useSession({
    password: process.env.SESSION_SECRET!,
    cookie: {
      name: "session",
      secure: process.env.NODE_ENV === "production",
      httpOnly: true,
      maxAge: 60 * 60 * 24 * 7, // 1 week
    },
  });
}

// Usage in server function
async function login(formData: FormData) {
  "use server";
  const session = await getSession();

  // Validate credentials...

  await session.update({ userId: user.id });
  throw redirect("/dashboard");
}

async function logout() {
  "use server";
  const session = await getSession();
  await session.clear();
  throw redirect("/");
}
```

### Protected Routes

```tsx
// routes/(protected).tsx
import { getSession } from "~/lib/session";
import { redirect } from "@solidjs/router";

export const route = {
  preload: async () => {
    const session = await getSession();
    if (!session.data.userId) {
      throw redirect("/login");
    }
  },
};

export default function ProtectedLayout(props) {
  return props.children;
}
```

## Head & Meta

```tsx
import { Title, Meta, Link } from "@solidjs/meta";

export default function Page() {
  return (
    <>
      <Title>Page Title</Title>
      <Meta name="description" content="Page description" />
      <Meta property="og:title" content="OG Title" />
      <Link rel="canonical" href="https://example.com/page" />

      <div>Content</div>
    </>
  );
}
```

## Environment Variables

```bash
# .env
DATABASE_URL=postgres://...
VITE_API_URL=https://api.example.com  # Exposed to client
```

```tsx
// Server only
const dbUrl = process.env.DATABASE_URL;

// Client (must start with VITE_)
const apiUrl = import.meta.env.VITE_API_URL;
```

## Static Assets

Place in `public/`:

```
public/
├── favicon.ico
├── robots.txt
└── images/
    └── logo.png
```

Access at root:

```tsx
<img src="/images/logo.png" alt="Logo" />
```

## CSS & Styling

### Global CSS

```tsx
// routes/index.tsx or root layout
import "./global.css";
```

### CSS Modules

```tsx
import styles from "./Button.module.css";

<button class={styles.primary}>Click</button>;
```

### Tailwind CSS

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

```ts
// tailwind.config.js
export default {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
};
```

```css
/* src/app.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Deployment

### Node.js Server

```bash
npm run build
node .output/server/index.mjs
```

### Vercel

```ts
// app.config.ts
export default defineConfig({
  server: { preset: "vercel" },
});
```

### Netlify

```ts
export default defineConfig({
  server: { preset: "netlify" },
});
```

### Cloudflare Pages

```ts
export default defineConfig({
  server: { preset: "cloudflare-pages" },
});
```

## WebSocket Endpoints

```tsx
// routes/api/ws.ts
import { defineWebSocket } from "@solidjs/start/server";

export const GET = defineWebSocket({
  open(peer) {
    console.log("Connected:", peer.id);
  },
  message(peer, message) {
    peer.send(`Echo: ${message}`);
  },
  close(peer) {
    console.log("Disconnected:", peer.id);
  },
});
```

## Request Event in Components

```tsx
import { getRequestEvent } from "solid-js/web";

async function getData() {
  "use server";
  const event = getRequestEvent();
  const url = new URL(event.request.url);
  const userAgent = event.request.headers.get("user-agent");
  return { url: url.pathname, userAgent };
}
```

## TypeScript

```tsx
// Type for route params
import type { RouteDefinition } from "@solidjs/router";

export const route: RouteDefinition = {
  preload: ({ params }) => getUser(params.id),
};

// Type for API routes
import type { APIEvent } from "@solidjs/start/server";

export async function GET(event: APIEvent) {
  // event is fully typed
}
```
