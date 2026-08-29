import { expect, test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/**
 * WCAG 2 AA, on both pages, in a real browser.
 *
 * This replaces pa11y, which drove its own headless Chrome through puppeteer
 * and needed --no-sandbox to do it. axe runs in the page Playwright already has
 * open, so there is one browser in this repository rather than two, and the
 * standard being checked is the same one .pa11y.json asked for.
 */
const PAGES = [
  { name: 'the landing page', path: '/' },
  { name: 'the not-found page', path: '/404.html' },
];

for (const { name, path } of PAGES) {
  test(`${name} has no WCAG 2 AA violations`, async ({ page }) => {
    await page.goto(path);

    const { violations } = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    // The ids and the elements they landed on, so a failure says what to fix
    // rather than just how many there are.
    expect(
      violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`),
    ).toEqual([]);
  });
}

// The page's own rule, checked in the browser rather than by grepping source:
// `just no-js` reads the file, this reads what the browser actually loaded.
test('the page runs no scripts', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('script')).toHaveCount(0);
});
