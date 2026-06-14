# Chess Game Outcome Classification (ANN)

Predicts chess game results (White win / Draw / Black win) from FICS game data.

## How to run this project

### Step 1 — Download the project

Click the green **Code** button on this page, then **Download ZIP**. Unzip it to a folder on your computer.

### Step 2 — Open a terminal in that folder

- **Mac**: open the folder in Finder, right-click inside it, choose "New Terminal at Folder" (or open Terminal and type `cd ` followed by the folder path).
- **Windows**: open the folder, type `cmd` in the address bar, press Enter.

### Step 3 — Run the feature extraction (only needed once)

Copy this line, paste it into the terminal, press Enter, and wait until it finishes:

```
python3 extract_features.py ficsgamesdb_202601_standard_nomovetimes_2088935.pgn features1.csv
```

Then copy this line, paste it, press Enter, and wait:

```
python3 extract_features.py ficsgamesdb_202602_standard_nomovetimes_2088940.pgn features2.csv
```

(Note: `features1.csv` and `features2.csv` are already included in this repo, so you can skip Step 3 if you just want to see the results.)

### Step 4 — Train the model

Open **MATLAB**. In MATLAB, navigate to this folder. Double-click on `train_wdl.m` to open it, then click the **Run** button (or press F5). Wait for it to finish.

This will print accuracy, confusion matrix, precision/recall, and feature importance, and will create the file `model_wdl.mat`.

### Step 5 — Test on new data

Still in MATLAB, double-click on `test_wdl.m` to open it, then click **Run** (or press F5). Wait for it to finish.

This loads the model trained in Step 4 and tests it on a different month of games (February 2026), which it has never seen before.

## Files

| File | Description |
|---|---|
| `extract_features.py` | Converts raw game files (PGN) into a feature table (CSV) |
| `features1.csv` / `features2.csv` | Feature tables (January / February 2026) |
| `train_wdl.m` | Trains the neural network and saves the model |
| `test_wdl.m` | Tests the saved model on new data |
| `model_wdl.mat` | The saved trained model |
