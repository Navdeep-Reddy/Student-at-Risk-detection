#!/usr/bin/env bash
# Run the whole pipeline on the REAL UCI data (needs internet for the first download).
set -euo pipefail
cd "$(dirname "$0")"
python src/build_notebooks.py --execute   # downloads data in notebook 01, runs notebooks 01 -> 05
python src/make_report.py                 # report/technical_report.docx from the results just produced
if command -v soffice >/dev/null 2>&1; then
  soffice --headless --convert-to pdf --outdir report report/technical_report.docx >/dev/null 2>&1 || true
fi
echo "Done. See notebooks/, artifacts/ and report/."
