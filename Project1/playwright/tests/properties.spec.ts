import { test, expect } from '@playwright/test';

test.describe('Properties page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('shows the page title', async ({ page }) => {
    await expect(page.getByTestId('page-title')).toHaveText('Properties');
  });

  test('lists the three static properties', async ({ page }) => {
    await expect(page.locator('[data-testid^="property-row-"]')).toHaveCount(3);
  });

  test('shows the void property', async ({ page }) => {
    const row = page.getByTestId('property-row-22222222-2222-2222-2222-222222222222');
    await expect(row).toContainText('2 Mill Lane, York');
    await expect(row).toContainText('Void');
  });
});
