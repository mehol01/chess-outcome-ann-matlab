import sys
import chess
import chess.pgn
import chess.svg
import cairosvg

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


def main(pgn_path, out_path, min_abs_material=6):
    with open(pgn_path) as f:
        pgn_index = 0
        csv_row = 0
        while True:
            game = chess.pgn.read_game(f)
            if game is None:
                break
            pgn_index += 1

            headers = game.headers
            try:
                float(headers.get("WhiteElo", ""))
                float(headers.get("BlackElo", ""))
            except ValueError:
                continue

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
            last_move = None
            for move in game.mainline_moves():
                board.push(move)
                last_move = move

            if board.ply() < 10:
                continue

            csv_row += 1
            material_diff_last = material_balance(board)

            is_checkmate = board.is_checkmate()
            consistent = (outcome == 1 and material_diff_last >= min_abs_material) or \
                         (outcome == -1 and material_diff_last <= -min_abs_material)

            if is_checkmate and consistent:
                print(f"PGN game #{pgn_index}, CSV row #{csv_row}")
                print(f"White: {headers.get('White')} ({headers.get('WhiteElo')})")
                print(f"Black: {headers.get('Black')} ({headers.get('BlackElo')})")
                print(f"Result: {result}, material_diff_last: {material_diff_last}, ply_count: {board.ply()}")

                svg_data = chess.svg.board(board, size=400, lastmove=last_move)
                cairosvg.svg2png(bytestring=svg_data.encode(), write_to=out_path)
                print(f"Saved to {out_path}")
                return

    print("No matching game found")


if __name__ == "__main__":
    pgn_path = sys.argv[1]
    out_path = sys.argv[2]
    main(pgn_path, out_path)
