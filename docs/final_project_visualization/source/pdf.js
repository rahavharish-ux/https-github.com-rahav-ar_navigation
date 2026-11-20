// Prints an HTML file to PDF with the pre-installed Chromium.
// Usage: node pdf.js <in.html> <out.pdf>
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('file://' + process.argv[2], { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  await page.pdf({ path: process.argv[3], format: 'A4', landscape: true,
                   printBackground: true, margin: { top: '0', right: '0', bottom: '0', left: '0' } });
  await browser.close();
})();
