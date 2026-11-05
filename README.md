# Student Academic Performance and At-Risk Prediction
Data Scientist Technical Assessment, **Topic 3**. A supervised early-warning classifier (will a student fail the course?) plus a
source-grounded question-answering assistant over the project's own knowledge base.

## Important: run it on the real data first
This package was built in a workspace without access to the UCI website, so the notebooks were only *tested* on a clearly labelled
**synthetic stand-in**. Those test outputs are in `validation_run_SYNTHETIC/` and are **not results on the real dataset**.
Run the pipeline once with internet access (steps below); every number, plot and the report are then regenerated from the real data.
Do not submit anything from `validation_run_SYNTHETIC/`.

## Quick start (local, Python 3.10+)
```bash
python -m venv .venv && source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
bash run_all.sh                    # downloads data, builds + executes the 5 notebooks, writes the report
```
`run_all.sh` is just these three commands, which you can also run by hand:
```bash
python src/build_notebooks.py --execute      # (re)generates notebooks/*.ipynb and runs them in order 01 -> 05
python src/make_report.py                    # builds report/technical_report.docx from the real results
# optional PDF:  soffice --headless --convert-to pdf --outdir report report/technical_report.docx
```
Or open `notebooks/01_...ipynb` in Jupyter / VS Code and run 01 -> 05 in order.

### Google Colab
1. Upload and unzip the project (e.g. into `/content/student_risk_project`).
2. In a cell: `%cd /content/student_risk_project` then `!pip install -r requirements.txt`.
3. Run `!python src/build_notebooks.py --execute` (or open the notebooks from the `notebooks/` folder and run them in order).

If the automatic download fails, download the zip from https://archive.ics.uci.edu/dataset/320/student+performance, and place
`student-mat.csv` and `student-por.csv` in `data/` (then write `data/DATA_SOURCE.json` by re-running `python src/get_data.py`, or edit it by hand).
`ALLOW_SYNTHETIC=1` enables a **test-only** synthetic fallback; never use it for a real submission (the notebooks print a warning and the report carries a banner).

## What is in the package
| Path | Purpose |
|---|---|
| `notebooks/01_problem_and_data_collection.ipynb` | Phase 1 design, architecture diagram, Phase 2 data collection, data dictionary, quality report, 30% sample |
| `notebooks/02_preprocessing_and_splitting.ipynb` | Phase 3 preprocessing (before/after stats, decisions), Phase 4 features, group-aware stratified split, leakage demo |
| `notebooks/03_model_comparison.ipynb` | Phase 5: 4 models + baseline x 3 feature scenarios, metrics, plots, error analysis, final-model justification |
| `notebooks/04_question_answering.ipynb` | Knowledge base, hybrid retrieval, thresholds, grounded answers, retrieval evaluation and failure analysis |
| `notebooks/05_testing_and_evaluation.ipynb` | Phase 6: the 10 required test scenarios (+ probes), retrieval metrics (Recall/MRR), classification metrics, limitations |
| `src/` | `get_data.py`, `schema.py`, `ml_utils.py`, `qa_engine.py`, `make_diagram.py`, `build_notebooks.py`, `make_report.py` |
| `data/` | Downloaded CSVs, `DATA_SOURCE.json` (URL, collection date, license), `data_dictionary.csv`, 30% sample |
| `artifacts/` | `clean.csv`, `results.json`, `model_comparison.csv`, plots, `test_report.md/.csv`, retrieval metrics, saved model |
| `report/` | Technical report (about 4-6 pages) |
| `DECLARATION.md` | Declaration template for you to review and sign |
| `EXPLAINER.md` | Notes for Phase 8 (explaining the implementation without reading) |

## Mapping to the required deliverables
1. Source code in Jupyter notebooks - `notebooks/` (+ helper modules in `src/`).
2. Dataset source URLs and collection instructions - notebook 01, `data/DATA_SOURCE.json`, this README.
3. Requirements - `requirements.txt`.
4. README with execution steps - this file.
5. Model comparison table and evaluation results - `artifacts/model_comparison.csv`, notebook 03, `artifacts/results.json`.
6. Architecture diagram - `artifacts/architecture.png` (drawn in notebook 01).
7. Test-case report - `artifacts/test_report.md` / `.csv`, notebook 05.
8. Technical report - `report/technical_report.docx`.
9. Declaration - `DECLARATION.md`.

## Method in one paragraph
Target: `at_risk = 1` if final grade G3 < 10. Data: Maths + Portuguese files combined (+ `subject` column). Splits: 70/15/15, stratified and
**grouped by student identity** so the same student never appears in two splits. Three feature scenarios (S1 no grades, S2 + G1 = primary, S3 + G1,G2);
G3 is never an input. Models: Logistic Regression, Random Forest, Hist Gradient Boosting, SVM (RBF), plus a majority baseline; hyper-parameters tuned on validation PR-AUC,
threshold tuned on validation F2, final model chosen on validation evidence, test used once. Q&A: TF-IDF + BM25 hybrid with synonym expansion over passages; extractive answers with
source ids, grounding verifier, refusal rules, duplicate / short / injection hygiene.

## Reproducibility
Seed 42 everywhere; package versions in `requirements.txt` are minimums (tested with Python 3.13, scikit-learn 1.9, pandas 3.0). Small numeric differences across library versions are possible.
Dataset: Cortez & Silva (2008), CC BY 4.0, https://doi.org/10.24432/C5TG7T.
