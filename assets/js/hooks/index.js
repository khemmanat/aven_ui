/**
 * AvenUI JavaScript Hooks
 * =========================
 * Minimal, zero-dependency hooks for Phoenix LiveView.
 * Alpine.js is optional — components degrade gracefully without it.
 *
 * Usage in app.js:
 *   import { AvenUIHooks } from "../../deps/aven_ui/assets/js/hooks"
 *
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { ...AvenUIHooks, ...MyHooks }
 *   })
 */

// ─────────────────────────────────────────────────────────────────────
// Flash / Toast auto-dismiss
// ─────────────────────────────────────────────────────────────────────

const Flash = {
  mounted() {
    const duration = parseInt(this.el.dataset.duration ?? "4000", 10);
    this.timer = setTimeout(() => this.dismiss(), duration);

    this.el.addEventListener("mouseenter", () => clearTimeout(this.timer));
    this.el.addEventListener("mouseleave", () => {
      this.timer = setTimeout(() => this.dismiss(), 1500);
    });
  },
  dismiss() {
    this.el.classList.add("opacity-0", "translate-y-1", "scale-95");
    this.el.style.transition = "all 200ms ease-in";
    setTimeout(() => this.el.remove(), 200);
  },
  destroyed() {
    clearTimeout(this.timer);
  },
};

// ─────────────────────────────────────────────────────────────────────
// Dropdown — keyboard-navigable, closes on outside click + Escape
// ─────────────────────────────────────────────────────────────────────

const Dropdown = {
  mounted() {
    this.trigger = this.el.querySelector("[data-avn-dropdown-trigger]");
    this.menu = this.el.querySelector("[data-avn-dropdown-menu]");
    this.items = () =>
      this.menu?.querySelectorAll("[data-avn-dropdown-item]") ?? [];
    this.open = false;

    this.trigger?.addEventListener("click", (e) => {
      e.stopPropagation();
      this.toggle();
    });
    this.trigger?.addEventListener("keydown", (e) => this.handleTriggerKey(e));
    this.menu?.addEventListener("keydown", (e) => this.handleMenuKey(e));
    document.addEventListener(
      "click",
      (this.outsideClick = () => this.close()),
    );
    document.addEventListener(
      "keydown",
      (this.escClose = (e) => e.key === "Escape" && this.close()),
    );
  },
  toggle() {
    this.open ? this.close() : this.openMenu();
  },
  openMenu() {
    this.open = true;
    this.menu?.removeAttribute("hidden");
    this.menu?.classList.add("animate-avn-fade-in");
    this.trigger?.setAttribute("aria-expanded", "true");
    this.items()[0]?.focus();
  },
  close() {
    this.open = false;
    this.menu?.setAttribute("hidden", "");
    this.trigger?.setAttribute("aria-expanded", "false");
    this.trigger?.focus();
  },
  handleTriggerKey(e) {
    if (["ArrowDown", "Enter", " "].includes(e.key)) {
      e.preventDefault();
      this.openMenu();
    }
  },
  handleMenuKey(e) {
    const items = [...this.items()];
    const idx = items.indexOf(document.activeElement);
    if (e.key === "ArrowDown") {
      e.preventDefault();
      items[Math.min(idx + 1, items.length - 1)]?.focus();
    }
    if (e.key === "ArrowUp") {
      e.preventDefault();
      items[Math.max(idx - 1, 0)]?.focus();
    }
    if (e.key === "Home") {
      e.preventDefault();
      items[0]?.focus();
    }
    if (e.key === "End") {
      e.preventDefault();
      items[items.length - 1]?.focus();
    }
    if (e.key === "Tab") {
      this.close();
    }
  },
  destroyed() {
    document.removeEventListener("click", this.outsideClick);
    document.removeEventListener("keydown", this.escClose);
  },
};

// ─────────────────────────────────────────────────────────────────────
// Modal — focus trap, scroll lock, Escape to close
// ─────────────────────────────────────────────────────────────────────

const Modal = {
  mounted() {
    this.focusable =
      'a[href],button:not([disabled]),input,select,textarea,[tabindex]:not([tabindex="-1"])';
    this.previousFocus = document.activeElement;

    // Lock scroll
    document.body.style.overflow = "hidden";

    // Focus first element
    const first = this.el.querySelector(this.focusable);
    first?.focus();

    // Trap focus
    this.el.addEventListener(
      "keydown",
      (this.trapFocus = (e) => {
        if (e.key !== "Tab") return;
        const focusables = [...this.el.querySelectorAll(this.focusable)];
        const first = focusables[0];
        const last = focusables[focusables.length - 1];
        if (
          e.shiftKey
            ? document.activeElement === first
            : document.activeElement === last
        ) {
          e.preventDefault();
          (e.shiftKey ? last : first).focus();
        }
      }),
    );

    // Escape to close — push to LiveView
    document.addEventListener(
      "keydown",
      (this.escClose = (e) => {
        if (e.key === "Escape") this.pushEvent("close_modal", {});
      }),
    );

    // Backdrop click
    this.el.addEventListener(
      "click",
      (this.backdropClose = (e) => {
        if (e.target === this.el) this.pushEvent("close_modal", {});
      }),
    );
  },
  destroyed() {
    document.body.style.overflow = "";
    this.previousFocus?.focus();
    document.removeEventListener("keydown", this.escClose);
  },
};

// ─────────────────────────────────────────────────────────────────────
// Tooltip — show on hover/focus, position aware
// ─────────────────────────────────────────────────────────────────────

const Tooltip = {
  mounted() {
    const content = this.el.dataset.tooltip;
    if (!content) return;

    this.tip = document.createElement("div");
    this.tip.role = "tooltip";
    this.tip.className = [
      "pointer-events-none fixed z-[var(--avn-z-tooltip)]",
      "px-2.5 py-1.5 text-xs font-medium rounded-elx",
      "bg-avn-foreground text-avn-background shadow-elx",
      "opacity-0 transition-opacity duration-150",
      "max-w-xs whitespace-pre-wrap",
    ].join(" ");
    this.tip.textContent = content;
    document.body.appendChild(this.tip);

    this.show = () => this.position();
    this.hide = () => {
      this.tip.style.opacity = "0";
    };

    this.el.addEventListener("mouseenter", this.show);
    this.el.addEventListener("mouseleave", this.hide);
    this.el.addEventListener("focus", this.show);
    this.el.addEventListener("blur", this.hide);
  },
  position() {
    const rect = this.el.getBoundingClientRect();
    const tip = this.tip;
    tip.style.opacity = "0";
    tip.style.visibility = "visible";

    // Measure tip dimensions
    const tw = tip.offsetWidth || 200;
    const th = tip.offsetHeight || 32;

    let top = rect.top - th - 8;
    let left = rect.left + rect.width / 2 - tw / 2;

    // Flip below if not enough space above
    if (top < 8) top = rect.bottom + 8;

    // Clamp horizontally
    left = Math.max(8, Math.min(left, window.innerWidth - tw - 8));

    tip.style.top = `${top}px`;
    tip.style.left = `${left}px`;
    tip.style.opacity = "1";
  },
  destroyed() {
    this.tip?.remove();
    this.el.removeEventListener("mouseenter", this.show);
    this.el.removeEventListener("mouseleave", this.hide);
    this.el.removeEventListener("focus", this.show);
    this.el.removeEventListener("blur", this.hide);
  },
};

// ─────────────────────────────────────────────────────────────────────
// AutoResize — textarea grows with content
// ─────────────────────────────────────────────────────────────────────

const AutoResize = {
  mounted() {
    this.resize = () => {
      this.el.style.height = "auto";
      this.el.style.height = `${this.el.scrollHeight}px`;
    };
    this.el.addEventListener("input", this.resize);
    this.resize();
  },
  destroyed() {
    this.el.removeEventListener("input", this.resize);
  },
};

// ─────────────────────────────────────────────────────────────────────
// CopyToClipboard — copies text, shows feedback via phx event
// ─────────────────────────────────────────────────────────────────────

const CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", async () => {
      const text = this.el.dataset.copyText ?? this.el.textContent.trim();
      try {
        await navigator.clipboard.writeText(text);
        this.pushEvent("copied", { text });
        // Visual feedback
        const original = this.el.textContent;
        this.el.textContent = "Copied!";
        setTimeout(() => {
          this.el.textContent = original;
        }, 1500);
      } catch {
        this.pushEvent("copy_failed", {});
      }
    });
  },
};

// ─────────────────────────────────────────────────────────────────────
// InfiniteScroll — triggers phx-click when sentinel enters viewport
// ─────────────────────────────────────────────────────────────────────

const InfiniteScroll = {
  mounted() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !this.loading) {
            this.loading = true;
            this.pushEvent("load_more", {}, () => {
              this.loading = false;
            });
          }
        });
      },
      { rootMargin: "200px" },
    );
    this.observer.observe(this.el);
  },
  destroyed() {
    this.observer.disconnect();
  },
};

// ─────────────────────────────────────────────────────────────────────
// ScrollTop — smooth scroll to top on phx navigate
// ─────────────────────────────────────────────────────────────────────

const ScrollTop = {
  updated() {
    window.scrollTo({ top: 0, behavior: "smooth" });
  },
};

// ─────────────────────────────────────────────────────────────────────
// Combobox — searchable select with keyboard navigation
// ─────────────────────────────────────────────────────────────────────

const AvenUICombobox = {
  mounted() {
    this.panel = this.el.querySelector(`#${this.el.id}-panel`);
    this.trigger = this.el.querySelector(`#${this.el.id}-trigger`);
    this.input = this.el.querySelector(`#${this.el.id}-input`);
    this.listbox = this.el.querySelector(`#${this.el.id}-listbox`);
    this.valueInput = this.el.querySelector(`#${this.el.id}-value`);
    this.display = this.el.querySelector(`#${this.el.id}-display`);
    this.chevron = this.el.querySelector(`#${this.el.id}-chevron`);
    this.emptyEl = this.el.querySelector(`#${this.el.id}-empty`);
    this.isOpen = false;
    this.activeIdx = -1;

    this.trigger.addEventListener("click", () => this.toggle());

    // Keyboard navigation on the trigger
    this.trigger.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " " || e.key === "ArrowDown") {
        e.preventDefault();
        this.open();
      }
    });

    // Search input — filter visible options
    this.input.addEventListener("input", () => {
      const q = this.input.value.toLowerCase().trim();
      this.filterOptions(q);
    });

    // Keyboard nav inside the panel
    this.panel.addEventListener("keydown", (e) => {
      const items = this.visibleItems();
      if (e.key === "ArrowDown") {
        e.preventDefault();
        this.activeIdx = Math.min(this.activeIdx + 1, items.length - 1);
        this.highlightActive(items);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        this.activeIdx = Math.max(this.activeIdx - 1, 0);
        this.highlightActive(items);
      } else if (e.key === "Enter") {
        e.preventDefault();
        if (items[this.activeIdx]) this.select(items[this.activeIdx]);
      } else if (e.key === "Escape" || e.key === "Tab") {
        this.close();
      }
    });

    // Click on option
    this.listbox.addEventListener("click", (e) => {
      const item = e.target.closest("[role='option']");
      if (item && item.getAttribute("aria-disabled") !== "true") {
        this.select(item);
      }
    });

    // Close on click outside
    this._outsideClick = (e) => {
      if (!this.el.contains(e.target)) this.close();
    };
    document.addEventListener("click", this._outsideClick);
  },

  destroyed() {
    document.removeEventListener("click", this._outsideClick);
  },

  toggle() {
    this.isOpen ? this.close() : this.open();
  },

  open() {
    this.isOpen = true;
    this.panel.classList.remove("hidden");
    this.trigger.setAttribute("aria-expanded", "true");
    this.chevron.style.transform = "rotate(180deg)";
    this.activeIdx = -1;
    // Focus the search input
    requestAnimationFrame(() => this.input.focus());
  },

  close() {
    this.isOpen = false;
    this.panel.classList.add("hidden");
    this.trigger.setAttribute("aria-expanded", "false");
    this.chevron.style.transform = "";
    // Reset search
    this.input.value = "";
    this.filterOptions("");
    this.trigger.focus();
  },

  select(item) {
    const value = item.dataset.value;
    const label = item.dataset.label;

    // Update hidden input
    this.valueInput.value = value;

    // Update display text
    this.display.textContent = label;
    this.display.classList.remove("text-avn-muted-foreground");
    this.display.classList.add("text-avn-foreground");

    // Update aria-selected on all options
    this.listbox.querySelectorAll("[role='option']").forEach((opt) => {
      const isSelected = opt.dataset.value === value;
      opt.setAttribute("aria-selected", isSelected);
      const check = opt.querySelector("svg");
      if (check) check.style.opacity = isSelected ? "1" : "0";
    });

    // Trigger a native change event so LiveView phx-change picks it up
    this.valueInput.dispatchEvent(new Event("input", { bubbles: true }));
    this.valueInput.dispatchEvent(new Event("change", { bubbles: true }));

    this.close();
  },

  filterOptions(query) {
    const items = this.listbox.querySelectorAll("[role='option']");
    let visibleCount = 0;

    items.forEach((item) => {
      const label = (item.dataset.label || "").toLowerCase();
      const show = !query || label.includes(query);
      item.style.display = show ? "" : "none";
      if (show) visibleCount++;
    });

    // Show/hide empty state
    if (this.emptyEl) {
      this.emptyEl.style.display = visibleCount === 0 ? "" : "none";
    }

    this.activeIdx = -1;
  },

  visibleItems() {
    return Array.from(
      this.listbox.querySelectorAll(
        "[role='option']:not([style*='display: none'])",
      ),
    );
  },

  highlightActive(items) {
    items.forEach((item, i) => {
      if (i === this.activeIdx) {
        item.classList.add("bg-avn-muted");
        item.scrollIntoView({ block: "nearest" });
      } else {
        item.classList.remove("bg-avn-muted");
      }
    });
  },
};

// ─────────────────────────────────────────────────────────────────────
// Exports
// ─────────────────────────────────────────────────────────────────────

export const AvenUIHooks = {
  Flash,
  Dropdown,
  Modal,
  Tooltip,
  AutoResize,
  CopyToClipboard,
  InfiniteScroll,
  ScrollTop,
  AvenUICombobox,
};

export {
  Flash,
  Dropdown,
  Modal,
  Tooltip,
  AutoResize,
  CopyToClipboard,
  InfiniteScroll,
  ScrollTop,
  AvenUICombobox,
};
