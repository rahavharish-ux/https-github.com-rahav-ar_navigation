// Renders each generated HTML page to PNG with the pre-installed Chromium.
// Usage: node render.js <manifest.json>
// manifest: [{ "html": "/abs/page.html", "png": "/abs/out.png", "scale": 2 }]
const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const jobs = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
  const browser = await chromium.launch();
  for (const job of jobs) {
    const page = await browser.newPage({ deviceScaleFactor: job.scale || 2 });
    await page.goto('file://' + job.html);
    await page.evaluate(() => document.fonts.ready);
    const canvas = await page.$('#canvas');
    await canvas.screenshot({ path: job.png });
    await page.close();
    console.log('rendered', job.png);
  }
  await browser.close();
})();
