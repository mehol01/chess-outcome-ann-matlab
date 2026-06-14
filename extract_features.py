import sys
import chess
import chess.pgn
import csv

PIECE_VALUES = {
    chess.PAWN: 1,
    chess.KNIGHT: 3,
    chess.BISHOP: 3,
    chess.ROOK: 5,
    chess.QUEEN: 9,
    chess.KING: 0,
}


def material_balance(board):
    score = 0
    for piece_type, value in PIECE_VALUES.items():
        score += value * (
            len(board.pieces(piece_type, chess.WHITE))
            - len(board.pieces(piece_type, chess.BLACK))
        )
    return score


def parse_time_control(tc):

    parts = tc.split("+")
    if len(parts) != 2:
        return None
    try:
        base = float(parts[0])
        increment = float(parts[1])
    except ValueError:
        return None
    return base, increment


def main(pgn_path, out_path):
    rows = []
    with open(pgn_path) as f:
        while True:
            game = chess.pgn.read_game(f)
            if game is None:
                break

            headers = game.headers
            try:
                white_elo = float(headers.get("WhiteElo", ""))
                black_elo = float(headers.get("BlackElo", ""))
            except ValueError:
                continue

            tc = parse_time_control(headers.get("TimeControl", ""))
            if tc is None:
                continue
            time_base, time_increment = tc

            result = headers.get("Result", "")
            if result == "1-0":
                outcome = 1
            elif result == "1/2-1/2":
                outcome = 0
            elif result == "0-1":
                outcome = -1
            else:
                continue

            board = game.board()
            balances = []
            for move in game.mainline_moves():
                board.push(move)
                balances.append(material_balance(board))

            ply_count = len(balances)
            if ply_count < 10:
                continue

            last10 = balances[-10:]
            material_diff_last = last10[-1]
            material_diff_avg = sum(last10) / len(last10)
            mean = material_diff_avg
            material_diff_var = sum((b - mean) ** 2 for b in last10) / len(last10)

            elo_diff = white_elo - black_elo
            avg_elo = (white_elo + black_elo) / 2

            rows.append([
                elo_diff,
                avg_elo,
                material_diff_last,
                material_diff_avg,
                material_diff_var,
                ply_count,
                time_base,
                time_increment,
                outcome,
            ])

    with open(out_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "elo_diff",
            "avg_elo",
            "material_diff_last",
            "material_diff_avg",
            "material_diff_var",
            "ply_count",
            "time_base",
            "time_increment",
            "outcome",
        ])
        writer.writerows(rows)

    print(f"{len(rows)} games written to {out_path}")


if __name__ == "__main__":
    pgn_path = sys.argv[1]
    out_path = sys.argv[2]
    main(pgn_path, out_path)
