# How to run

### Step 1

Open the project folder. Right-click inside it and open a Terminal here (Mac: "New Terminal at Folder"; Windows: type `cmd` in the folder address bar and press Enter).

### Step 2

Copy this, paste it into the terminal, press Enter, and wait until it finishes:

```
python3 extract_features.py ficsgamesdb_202601_standard_nomovetimes_2088935.pgn features1.csv
```

### Step 3

Copy this, paste it, press Enter, and wait until it finishes:

```
python3 extract_features.py ficsgamesdb_202602_standard_nomovetimes_2088940.pgn features2.csv
```

### Step 4

Open MATLAB. In MATLAB, open this folder (Current Folder panel on the left).

### Step 5

Double-click `train_wdl.m` to open it. Click the **Run** button (or press F5). Wait until it finishes.

### Step 6

Double-click `test_wdl.m` to open it. Click the **Run** button (or press F5). Wait until it finishes.
