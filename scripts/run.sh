#!/bin/bash

cd "$(dirname "$0")"
source ../venv/bin/activate

node gen_openings_json.js
python rank_openings_json.py
node add_description.js
python gen_tree_mode_moves.py
python gen_ui_tree_mode_moves.py