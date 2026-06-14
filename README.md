# Chess Game Outcome Classification (ANN)

Predicts chess game results (White win / Draw / Black win) from FICS game data using a neural network in MATLAB, with feature extraction in Python.

## Requirements

- Python 3 with `python-chess` (`pip install chess`)
- MATLAB with Neural Network (Deep Learning) Toolbox and Statistics and Machine Learning Toolbox

## How to run

### 1. Extract features from PGN files (Python)

This reads the raw PGN game archives and produces CSV files with the features used for training/testing.

```
python3 extract_features.py ficsgamesdb_202601_standard_nomovetimes_2088935.pgn features1.csv
python3 extract_features.py ficsgamesdb_202602_standard_nomovetimes_2088940.pgn features2.csv
```

- `features1.csv` (January 2026) → used for training and held-out testing
- `features2.csv` (February 2026) → used for out-of-sample validation

### 2. Train the model (MATLAB)

```
train_wdl.m
```

This:
- Loads `features1.csv`
- Splits into 80% training / 20% test
- Normalizes features and oversamples draws
- Trains the ANN (1 hidden layer, 100 neurons)
- Trains the Elo-only logistic regression baseline
- Prints accuracy, confusion matrix, precision/recall, feature importance
- Saves the trained model to `model_wdl.mat`

### 3. Out-of-sample test (MATLAB)

Run after step 2 (needs `model_wdl.mat`):

```
test_wdl.m
```

This loads `features2.csv` (February data, never seen during training) and evaluates the saved model on it.

## Optional: generate example board images

```
python3 export_board_png.py <pgn_file> <game_index> <output.png>
python3 find_example_game.py <pgn_file> <output.png>
```

`export_board_png.py` saves the final board position of a chosen game.
`find_example_game.py` automatically finds and saves a checkmate example with a large material imbalance.

## Files

| File | Description |
|---|---|
| `extract_features.py` | PGN → feature CSV extraction |
| `features1.csv` / `features2.csv` | Extracted features (Jan / Feb 2026) |
| `train_wdl.m` | Train ANN + baseline on January data |
| `test_wdl.m` | Evaluate saved model on February data |
| `model_wdl.mat` | Saved trained model and normalization parameters |
| `export_board_png.py` / `find_example_game.py` | Generate example board position images |
