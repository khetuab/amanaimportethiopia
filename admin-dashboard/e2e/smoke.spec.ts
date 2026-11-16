import { test, expect } from '@playwright/test';

test('landing page renders and navigates to login', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByText('Ask for anything.')).toBeVisible();
  await page.getByRole('link', { name: /admin sign in/i }).click();
  await expect(page).toHaveURL('/login');
});

test('login form validates empty fields', async ({ page }) => {
  await page.goto('/login');
  await page.getByRole('button', { name: /sign in/i }).click();
  // HTML5 required fields block submit; URL stays /login
  await expect(page).toHaveURL('/login');
});