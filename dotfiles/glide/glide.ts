/**
 * Glide Browser Configuration
 * File: ~/.config/glide/glide.ts
 *
 * For API details and configuration cookbook, visit:
 * https://glide-browser.app/
 */

// --- TypeScript Definitions for API & Autocomplete ---

interface SearchEngine {
	name: string;
	keyword: string;
	search_url: string;
	favicon_url?: string;
	is_default?: boolean;
}

interface KeymapContext {
	tab_id: number;
	url?: string;
}

interface AutocmdContext {
	tab_id: number;
	url: string;
}

interface GlideOptions {
	native_tabs?: "show" | "hide" | "autohide";
	hint_chars?: string;
	switch_mode_on_focus?: boolean;
	go_next_patterns?: string[];
	go_previous_patterns?: string[];
	keymaps_use_physical_layout?: boolean;
	keyboard_layouts?: string[];
}

interface GlideSearchEngines {
	add(engine: SearchEngine): void;
}

type GlideModeName = "normal" | "insert" | "visual" | "hint" | "command" | "ignore" | "op-pending";

interface GlideKeymaps {
	set(
		mode: GlideModeName | GlideModeName[],
		key: string,
		action: string | ((context: KeymapContext) => void | Promise<void>),
	): void;
	del(
		mode: GlideModeName | GlideModeName[],
		key: string,
	): void;
}

interface GlideAutocmds {
	create(
		event:
			| "UrlEnter"
			| "ConfigLoaded"
			| "ModeChanged"
			| "TabEnter"
			| "CommandLineExit"
			| "AddonInstalled",
		pattern: RegExp,
		callback: (context: AutocmdContext) => void | Promise<void>,
	): void;
	remove(id: string): void;
}

interface GlideExcmds {
	create(
		meta: { name: string; description: string },
		callback: (args: string[]) => void | Promise<void>,
	): void;
}

interface StyleOptions {
	id: string;
	css: string;
	overwrite?: boolean;
}

interface GlideStyles {
	add(type: "css", options: StyleOptions): void;
	has(id: string): boolean;
	get(id: string): string | null;
}

interface GlideAddons {
	install(
		xpi_url: string,
		opts?: { force?: boolean; private_browsing_allowed?: boolean },
	): Promise<void>;
	list(types?: string | string[]): Promise<unknown[]>;
}

interface GlidePrefs {
	set(name: string, value: string | number | boolean): void;
	get(name: string): string | number | boolean | undefined;
	clear(name: string): void;
}

interface CommandLineCustomOption {
	label: string;
	description?: string;
	render?(): unknown;
	matches?(props: { input: string }): boolean | null;
	execute(props: { input: string }): void;
}

interface CommandLineShowOpts {
	input?: string;
	title?: string;
	options?: CommandLineCustomOption[];
}

interface GlideAPI {
	o: GlideOptions;
	search_engines: GlideSearchEngines;
	keymaps: GlideKeymaps;
	autocmds: GlideAutocmds;
	excmds: GlideExcmds;
	styles: GlideStyles;
	addons: GlideAddons;
	prefs: GlidePrefs;
	tabs: GlideTabs;
	commandline: {
		show(opts?: CommandLineShowOpts): Promise<void>;
		close(): Promise<boolean>;
		is_active(): boolean;
	};
	include(path: string): void;
}

interface GlideTab {
	id?: number;
	pinned?: boolean;
	active?: boolean;
	lastAccessed?: number;
}

interface GlideTabs {
	query(query?: Record<string, unknown>): Promise<GlideTab[]>;
	unload(...tabs: Array<number | GlideTab>): Promise<void>;
}

declare const browser: {
	tabs: {
		remove(tabIds: number | number[]): Promise<void>;
	};
};

declare const glide: GlideAPI;

// --- Configuration ---

// Customize core behavior of the browser.
glide.o.native_tabs = "show"; // options: "show" | "hide" | "autohide"
glide.o.hint_chars = "asdfghjkl"; // characters used for link hint labels (home-row friendly)
glide.o.switch_mode_on_focus = true; // auto switch to insert mode when a text input gains focus

// Define custom search engines for the address bar.
glide.search_engines.add({
	name: "Google",
	keyword: "g",
	search_url: "https://www.google.com/search?q={searchTerms}",
	is_default: true,
});

glide.search_engines.add({
	name: "GitHub",
	keyword: "gh",
	search_url: "https://github.com/search?q={searchTerms}",
	is_default: false,
});

// Keymaps
glide.keymaps.set(["normal", "insert", "visual", "hint", "command", "ignore", "op-pending"], "<C-space>", "commandline_show tab ");
glide.keymaps.del("normal", "<leader><leader>");

// --- Stale tabs ---
// Native Firefox auto-unload after 3h of inactivity (ms).
glide.prefs.set("browser.tabs.min_inactive_duration_before_unload", 3 * 3600 * 1000);

const TAB_UNLOAD_AFTER_MS = 3 * 3600 * 1000;
const TAB_CLOSE_AFTER_MS = 3 * 24 * 3600 * 1000;

// Unload tabs idle >3h, close tabs untouched >3d. Pinned and active tabs are
// never touched. Runs on startup and on every tab switch (no timers).
async function sweep_stale_tabs(): Promise<void> {
	try {
		const now = Date.now();
		const to_unload: number[] = [];
		const to_close: number[] = [];
		for (const tab of await glide.tabs.query({})) {
			if (tab.id == null || tab.pinned || tab.active) {
				continue;
			}
			const idle = now - (tab.lastAccessed ?? now);
			if (idle >= TAB_CLOSE_AFTER_MS) {
				to_close.push(tab.id);
			} else if (idle >= TAB_UNLOAD_AFTER_MS) {
				to_unload.push(tab.id);
			}
		}
		if (to_unload.length > 0) {
			await glide.tabs.unload(...to_unload);
		}
		if (to_close.length > 0) {
			await browser.tabs.remove(to_close);
		}
	} catch {
		// Stale-tab sweep must never break the config; ignore failures.
	}
}

glide.autocmds.create("ConfigLoaded", /.*/, () => void sweep_stale_tabs());
glide.autocmds.create("TabEnter", /.*/, () => void sweep_stale_tabs());
