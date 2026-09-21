const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PROJECT_ROOT = path.resolve(__dirname, '..');
const DOCS_DIR = path.join(PROJECT_ROOT, 'docs');

function buildDocumentationPdf() {
  console.log('Building evers-martin_dokumentation.pdf...');
  const mdContent = fs.readFileSync(path.join(DOCS_DIR, 'DOKUMENTATION.md'), 'utf-8');
  
  // Use marked via cli or temp file
  const tmpMd = '/tmp/doc_input.md';
  const tmpHtml = '/tmp/doc_body.html';
  fs.writeFileSync(tmpMd, mdContent);
  execSync(`npx -y marked --gfm -i ${tmpMd} -o ${tmpHtml}`);
  const bodyHtml = fs.readFileSync(tmpHtml, 'utf-8');

  // Full styled HTML
  const fullHtml = `<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>GearShare - Projektdokumentation</title>
<base href="file://${DOCS_DIR}/">
<style>
  @page {
    size: A4;
    margin: 20mm 15mm 20mm 15mm;
  }
  @page :left {
    @bottom-left { content: "GearShare - Modul 223"; font-size: 8pt; color: #64748b; }
    @bottom-right { content: counter(page); font-size: 8pt; color: #64748b; }
  }
  @page :right {
    @bottom-left { content: "Martin Evers (24-223-E)"; font-size: 8pt; color: #64748b; }
    @bottom-right { content: counter(page); font-size: 8pt; color: #64748b; }
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #1e293b;
    line-height: 1.6;
    font-size: 10pt;
  }

  h1 {
    font-size: 22pt;
    color: #0f172a;
    border-bottom: 2px solid #2563eb;
    padding-bottom: 6px;
    margin-top: 24pt;
    margin-bottom: 12pt;
    page-break-after: avoid;
  }
  h2 {
    font-size: 15pt;
    color: #1e3a8a;
    border-bottom: 1px solid #cbd5e1;
    padding-bottom: 4px;
    margin-top: 20pt;
    margin-bottom: 10pt;
    page-break-after: avoid;
  }
  h3 {
    font-size: 12pt;
    color: #334155;
    margin-top: 14pt;
    margin-bottom: 6pt;
    page-break-after: avoid;
  }
  h4 {
    font-size: 10.5pt;
    color: #475569;
    margin-top: 10pt;
    margin-bottom: 4pt;
    page-break-after: avoid;
  }

  p {
    margin-bottom: 8pt;
    text-align: justify;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 12pt 0;
    font-size: 9pt;
    page-break-inside: avoid;
  }
  th {
    background-color: #f1f5f9;
    color: #334155;
    font-weight: 700;
    text-align: left;
    padding: 6pt 8pt;
    border: 1px solid #cbd5e1;
  }
  td {
    padding: 5pt 8pt;
    border: 1px solid #e2e8f0;
    vertical-align: top;
  }
  tr:nth-child(even) td {
    background-color: #f8fafc;
  }

  pre {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-left: 3px solid #2563eb;
    padding: 8pt 10pt;
    border-radius: 4px;
    font-size: 8pt;
    line-height: 1.4;
    overflow-x: auto;
    page-break-inside: avoid;
    margin: 10pt 0;
  }
  code {
    font-family: "Courier New", Courier, monospace;
    background: #f1f5f9;
    padding: 1pt 3pt;
    border-radius: 3px;
    font-size: 8.5pt;
  }
  pre code {
    background: transparent;
    padding: 0;
  }

  img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 12pt auto;
    border: 1px solid #cbd5e1;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    page-break-inside: avoid;
  }

  blockquote {
    border-left: 3px solid #2563eb;
    background: #eff6ff;
    padding: 6pt 12pt;
    margin: 10pt 0;
    border-radius: 0 4px 4px 0;
    color: #1e40af;
  }

  hr {
    border: none;
    border-top: 1px solid #cbd5e1;
    margin: 16pt 0;
  }

  /* Cover Page Styling */
  .cover-page {
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    page-break-after: always;
    padding: 40px 20px;
    box-sizing: border-box;
  }
</style>
</head>
<body>
${bodyHtml}
</body>
</html>`;

  const finalHtmlPath = '/tmp/complete_documentation.html';
  fs.writeFileSync(finalHtmlPath, fullHtml);

  const outPdf = path.join(PROJECT_ROOT, 'evers-martin_dokumentation.pdf');
  const docsPdf = path.join(DOCS_DIR, 'evers-martin_dokumentation.pdf');
  execSync(`chromium --headless --no-sandbox --disable-gpu --print-to-pdf="${outPdf}" --print-to-pdf-no-header "${finalHtmlPath}"`);
  fs.copyFileSync(outPdf, docsPdf);
  console.log(`✓ Saved ${outPdf} and ${docsPdf}`);
}

function buildPresentationPdf() {
  console.log('Building evers-martin_praesentation.pdf...');
  const mdContent = fs.readFileSync(path.join(DOCS_DIR, 'PRAESENTATION.md'), 'utf-8');
  
  const tmpMd = '/tmp/pres_input.md';
  const tmpHtml = '/tmp/pres_body.html';
  fs.writeFileSync(tmpMd, mdContent);
  execSync(`npx -y marked --gfm -i ${tmpMd} -o ${tmpHtml}`);
  let bodyHtml = fs.readFileSync(tmpHtml, 'utf-8');

  // Split slides by hr or h2
  // Let's style slide pages
  const fullHtml = `<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>GearShare - Abschlusspräsentation</title>
<base href="file://${DOCS_DIR}/">
<style>
  @page {
    size: 297mm 210mm; /* A4 Landscape */
    margin: 0;
  }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #0f172a;
    margin: 0;
    padding: 0;
    background: #f8fafc;
  }
  .slide {
    width: 297mm;
    height: 210mm;
    box-sizing: border-box;
    padding: 22mm 26mm;
    page-break-after: always;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    position: relative;
    background: white;
    border-bottom: 8px solid #2563eb;
  }
  .slide-header {
    margin-bottom: 12mm;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 4mm;
  }
  .slide-header h2 {
    font-size: 22pt;
    color: #1e3a8a;
    margin: 0;
  }
  .slide-content {
    font-size: 13pt;
    line-height: 1.6;
    flex: 1;
  }
  .slide-footer {
    display: flex;
    justify-content: space-between;
    font-size: 9pt;
    color: #64748b;
    border-top: 1px solid #e2e8f0;
    padding-top: 3mm;
    margin-top: auto;
  }
  h3 { font-size: 16pt; color: #2563eb; margin-top: 0; }
  ul { margin-left: 20px; }
  li { margin-bottom: 8pt; }
  table { width: 100%; border-collapse: collapse; margin-top: 10pt; font-size: 11pt; }
  th { background: #f1f5f9; padding: 6pt 10pt; border: 1px solid #cbd5e1; text-align: left; }
  td { padding: 6pt 10pt; border: 1px solid #e2e8f0; }
  pre { background: #0f172a; color: #38bdf8; padding: 10pt; border-radius: 6px; font-size: 10pt; line-height: 1.3; }
  blockquote { border-left: 4px solid #2563eb; background: #eff6ff; padding: 10pt 16pt; border-radius: 0 6px 6px 0; font-size: 14pt; }
</style>
</head>
<body>
  ${buildSlideHtml(bodyHtml)}
</body>
</html>`;

  const finalHtmlPath = '/tmp/complete_presentation.html';
  fs.writeFileSync(finalHtmlPath, fullHtml);

  const outPdf = path.join(PROJECT_ROOT, 'evers-martin_praesentation.pdf');
  const docsPdf = path.join(DOCS_DIR, 'evers-martin_praesentation.pdf');
  execSync(`chromium --headless --no-sandbox --disable-gpu --print-to-pdf="${outPdf}" --print-to-pdf-no-header "${finalHtmlPath}"`);
  fs.copyFileSync(outPdf, docsPdf);
  console.log(`✓ Saved ${outPdf} and ${docsPdf}`);
}

function buildSlideHtml(html) {
  // Split on <hr> or <h2> tags to generate slide containers
  const parts = html.split(/<hr\s*\/?>/i);
  return parts.map((part, index) => {
    let titleMatch = part.match(/<h2[^>]*>(.*?)<\/h2>/i);
    let title = titleMatch ? titleMatch[1] : (index === 0 ? 'GearShare - Modul 223' : `Folie ${index + 1}`);
    let content = part.replace(/<h2[^>]*>.*?<\/h2>/i, '');

    return `
    <div class="slide">
      <div class="slide-header">
        <h2>${title}</h2>
      </div>
      <div class="slide-content">
        ${content}
      </div>
      <div class="slide-footer">
        <span>GearShare – Multiuser Geräteausleihe | Modul 223</span>
        <span>Martin Evers (24-223-E)</span>
        <span>Folie ${index + 1} von ${parts.length}</span>
      </div>
    </div>`;
  }).join('\n');
}

buildDocumentationPdf();
buildPresentationPdf();
