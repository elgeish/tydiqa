#!/bin/bash
# Evaluates predictions from a TyDiQA-GoldP model.
set -ueo pipefail  # Halt on all manner of errors.
set -x  # Print commands as they are executed.

predictions_in="$1"
working_dir="$2"

# Evaluation script.
# https://github.com/allenai/bi-att-flow/blob/master/squad/evaluate-v1.1.py
EVAL_SCRIPT="$HOME/software/bi-att-flow/squad/evaluate-v1.1.py"

# Path to TyDi QA baseline code (used for splitting predictions into individual
# languages.
TYDIQA_REPO_DIR=$PWD/..

# Path to the TyDi QA Gold Passage (GoldP) task data
# IMPORTANT: Please report this task name in your results tables as
# 'TyDiQA-GoldP' to avoid confusing it with the primary tasks.
TYDIQA_GOLDP_DIR=$HOME/tydiqa_goldp
TYDIQA_VERSION="1.0b"

python3 "${TYDIQA_REPO_DIR}/gold_passage_baseline/split_predictions.py" \
  --input_json="${predictions_in}" \
  --output_dir="${working_dir}" \
  --lang_output_json_pattern='tydiqa-goldp-dev-predictions-%s.json'

for lang in english arabic bengali finnish indonesian swahili korean russian telugu; do
  dataset_file="${TYDIQA_GOLDP_DIR}/${VERSION}/tydiqa-goldp-dev-${VERSION}-${lang}.json"
  predict_file="${working_dir}/tydiqa-goldp-dev-predicions-${lang}.json"
  echo "Language: ${lang}"
  eval "${EVAL_SCRIPT}" "${dataset_file}" "${predict_file}"
done

echo "To obtain an overall score, average all *non-English* languages."
