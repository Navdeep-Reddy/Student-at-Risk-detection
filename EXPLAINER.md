# Phase 8 - Explaining the implementation (study notes)

Use these to practise explaining the project aloud. The real numbers are in `artifacts/results.json` after you run it on the real data.

## 1. How does data move through the pipeline?
UCI zip -> `get_data.py` (CSVs + provenance JSON) -> notebook 01 (quality report, sample) -> notebook 02 (clean, validate, add `at_risk` and `group_id`, split, save `clean.csv`) ->
notebook 03 (engineer features, sklearn Pipeline per model, tune on validation, test once, save `results.json` + model) -> notebook 04 (build knowledge base from dictionary + `clean.csv` + `results.json`, index it,
tune refusal thresholds) -> notebook 05 (tests and metrics) -> `make_report.py` (report from the artifacts).

## 2. Why these models and features?
* Baseline (majority class) shows what accuracy means without learning.
* Logistic Regression: interpretable, strong on small data. Random Forest: non-linear, little tuning. Hist Gradient Boosting: usually best on tabular data. SVM (RBF): non-linear margin, used in the original paper.
* Features: demographics, family, habits, support flags, absences, past failures; engineered `log_absences`, parental education mean, total alcohol, any support, prior failure.
* Scenarios S1/S2/S3 exist because G1/G2 make prediction easy but late. S2 was fixed as primary before looking at results.

## 3. How are training and testing separated?
70/15/15 with `StratifiedGroupKFold`. Groups = the 13 identity attributes, because the same student can be in the Maths and Portuguese files. Preprocessing (imputer, scaler, one-hot) is inside the Pipeline and fitted on train only.
Hyper-parameters (validation PR-AUC) and the threshold (validation F2) use validation only. Test is evaluated once. The notebook-02 demo compares naive and group-aware splits.

## 4. Why these metrics?
Accuracy hides the minority class (a majority baseline already gets a high value). **Recall of at-risk** = how many struggling students we catch. **Precision** = workload of false alarms. **Macro-F1** = both classes equally.
**F2** (used for the threshold) weights recall twice as much as precision. ROC-AUC / PR-AUC are threshold-independent; PR-AUC is more informative under imbalance. Confusion matrix shows the actual error types.

## 5. How does retrieval work?
Passages are normalised (lower-case, URLs removed, digits/identifiers kept, light plural stemming). Query terms are expanded with domain synonyms (half weight). Score = 0.5 x TF-IDF cosine (uni+bigrams) + 0.5 x BM25 (normalised).
Ranking uses the hybrid; refusal uses cosine, query-term coverage and an out-of-vocabulary rule. Metrics: Recall@k, Hit@k, MRR.

## 6. How is source grounding verified?
Answers are *extractive*: each sentence is copied from a passage and tagged with its id. `verify_grounding` checks that every sentence is an exact substring of the cited passage and introduces no new number. Passages with injection-like text are quarantined before indexing.

## 7. Where does it fail, and how to improve?
Missed at-risk students with normal early indicators; small and old two-school data; lexical retrieval misses paraphrases outside the synonym list; extractive answers cannot calculate or reason; regex injection filter can be evaded (test 10b);
conflict detection is heuristic. Improvements: more data, calibration, subgroup fairness audit, dense embeddings, source allow-listing, human review.

## 8. What would you change before real deployment?
Refit on train+validation; calibrate probabilities; audit errors by sex / age / address; log predictions and outcomes; keep a human in the loop; support-only intervention policy; retrain each term; vetted Q&A corpus; privacy review (student data).

## Questions to expect
* *Why not accuracy?* Majority-class baseline already scores high; we care about catching at-risk students.
* *Is G3 leakage?* G3 defines the target and is never an input. G1/G2 are legitimate only if they are available at prediction time, hence the scenarios.
* *Why group the split?* Same student in both files -> optimistic scores otherwise.
* *Why not SMOTE?* Resampling before/within splits can leak; class weights + threshold tuning are simpler and safe.
* *Why no generative LLM for Q&A?* Extractive answers are verifiably grounded.
