import { test, expect } from '@playwright/test';

test.describe('Tenancies page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('shows the page title', async ({ page }) => {
    await expect(page.getByTestId('page-title')).toHaveText('Tenancies');
  });

  test('lists the three static tenancies', async ({ page }) => {
    await expect(page.locator('[data-testid^="tenancy-row-"]')).toHaveCount(3);
  });

  test('shows the ended tenancy', async ({ page }) => {
    const row = page.getByTestId('tenancy-row-cccccccc-cccc-cccc-cccc-cccccccccccc');
    await expect(row).toContainText('C Smith');
    await expect(row).toContainText('Ended');
  });
});
