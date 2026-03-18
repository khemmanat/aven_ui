// tailwind.config.js
// ==================
// Copy this config into your Phoenix project's assets/tailwind.config.js
// It extends Tailwind with all AvenUI design tokens.
//
// Usage:
//   const elixirUIPreset = require("../../deps/aven_ui/assets/tailwind.config.js")
//
//   module.exports = {
//     presets: [elixirUIPreset],
//     content: [...],
//   }

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class", '[data-theme="dark"]'],

  theme: {
    extend: {
      // ── Brand Colors ──────────────────────────────────────────────
      colors: {
        "avn-purple": {
          DEFAULT: "var(--avn-purple-600)",
          50:  "var(--avn-purple-50)",
          100: "var(--avn-purple-100)",
          200: "var(--avn-purple-200)",
          400: "var(--avn-purple-400)",
          500: "var(--avn-purple-500)",
          600: "var(--avn-purple-600)",
          700: "var(--avn-purple-700)",
          800: "var(--avn-purple-800)",
          900: "var(--avn-purple-900)",
        },
        // Semantic surface tokens — auto dark mode via CSS vars
        "avn-background":       "var(--avn-background)",
        "avn-card":             "var(--avn-card)",
        "avn-muted":            "var(--avn-muted)",
        "avn-muted-hover":      "var(--avn-muted-hover)",
        "avn-foreground":       "var(--avn-foreground)",
        "avn-muted-foreground": "var(--avn-muted-foreground)",
        "avn-border":           "var(--avn-border)",
      },

      // ── Border Radius ─────────────────────────────────────────────
      borderRadius: {
        "elx":    "var(--avn-radius)",
        "avn-lg": "var(--avn-radius-lg)",
        "avn-xl": "var(--avn-radius-xl)",
        "avn-full": "9999px",
      },

      // ── Ring / Focus ──────────────────────────────────────────────
      ringColor: {
        "avn-purple": "var(--avn-purple-600)",
      },
      ringOffsetColor: {
        "avn-background": "var(--avn-background)",
      },

      // ── Box Shadow ────────────────────────────────────────────────
      boxShadow: {
        "avn-sm":  "var(--avn-shadow-sm)",
        "elx":     "var(--avn-shadow)",
        "avn-md":  "var(--avn-shadow-md)",
      },

      // ── Typography ────────────────────────────────────────────────
      fontSize: {
        "2xs": ["0.6875rem", { lineHeight: "1rem" }],
      },

      // ── Animation ─────────────────────────────────────────────────
      keyframes: {
        "fade-in": {
          "0%":   { opacity: "0", transform: "translateY(4px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "fade-out": {
          "0%":   { opacity: "1", transform: "translateY(0)" },
          "100%": { opacity: "0", transform: "translateY(4px)" },
        },
        "slide-in-right": {
          "0%":   { opacity: "0", transform: "translateX(16px)" },
          "100%": { opacity: "1", transform: "translateX(0)" },
        },
        "scale-in": {
          "0%":   { opacity: "0", transform: "scale(0.95)" },
          "100%": { opacity: "1", transform: "scale(1)" },
        },
        "shimmer": {
          "0%":   { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
      animation: {
        "fade-in":        "fade-in 0.15s ease-out both",
        "fade-out":       "fade-out 0.15s ease-in both",
        "slide-in-right": "slide-in-right 0.2s ease-out both",
        "scale-in":       "scale-in 0.15s ease-out both",
        "shimmer":        "shimmer 2s linear infinite",
      },

      // ── Transition Duration ───────────────────────────────────────
      transitionDuration: {
        "50":  "50ms",
        "100": "100ms",
        "150": "150ms",
      },
    },
  },

  // ── Safelist (dynamic classes that Tailwind might purge) ────────────
  safelist: [
    // Dynamic variant classes on Badge, Alert, Button
    { pattern: /^(bg|text|border)-(violet|green|amber|red|blue)-(50|100|200|700|800|900)$/ },
    { pattern: /^dark:(bg|text|border)-(violet|green|amber|red|blue)-(300|400|700|800|900)$/ },
    // Elixir-specific LiveView states
    "phx-click-loading",
    "phx-submit-loading",
    "phx-change-loading",
    // Dark mode toggle
    "dark",
  ],

  plugins: [
    // Adds peer-checked: and group-hover: variants
    require("@tailwindcss/forms")({
      strategy: "class", // Only apply to elements with .form-* classes, not globally
    }),
  ],
};
