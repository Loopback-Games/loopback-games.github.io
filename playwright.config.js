import { defineConfig, devices } from '@playwright/test';

/**
 * The accessibility suite, and the only JavaScript this repository runs.
 *
 * The page itself ships none — that is the rule CI enforces with `just no-js`.
 * These tests are tooling: they load the two published pages in a real browser
 * and run axe against them.
 */
const PORT = 8765;

// Defaults to the local static server. Set E2E_BASE_URL to audit a deployed
// site instead — the same specs, against what is actually being served.
const BASE_URL = process.env.E2E_BASE_URL ?? `http://127.0.0.1:${PORT}`;

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? [['github'], ['html', { open: 'never' }]] : [['list']],
  use: {
    baseURL: BASE_URL,
    trace: 'retain-on-failure',
  },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    // The crew is anchored inside the elements it torments, and the claim is
    // that contact stays exact from 360px up. A phone profile is where that
    // breaks first.
    { name: 'mobile', use: { ...devices['Pixel 7'] } },
  ],

  // Nothing to start when the suite has been pointed at a URL already serving.
  ...(process.env.E2E_BASE_URL
    ? {}
    : {
        webServer: {
          // python3 comes from mise.toml, same as everything else. This replaces
          // the hand-rolled background server and `trap` block that used to be
          // duplicated in the justfile and the workflow.
          command: `python3 -m http.server ${PORT} --bind 127.0.0.1`,
          url: BASE_URL,
          reuseExistingServer: !process.env.CI,
          timeout: 60_000,
        },
      }),
});
