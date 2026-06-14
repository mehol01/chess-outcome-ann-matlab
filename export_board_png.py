import sys
import chess
import chess.pgn
import chess.svg
import cairosvg


def main(pgn_path, game_index, out_path):
    with open(pgn_path) as f:
        game = None
        for i in range(game_index):
            game = chess.pgn.read_game(f)
            if game is None:
                raise ValueError(f"PGN file has fewer than {game_index} games")

    headers = game.headers
    print(f"White: {headers.get('White')} ({headers.get('WhiteElo')})")
    print(f"Black: {headers.get('Black')} ({headers.get('BlackElo')})")
    print(f"Result: {headers.get('Result')}")

    board = game.board()
    last_move = None
    for move in game.mainline_moves():
        board.push(move)
        last_move = move

    print(f"Ply count: {board.ply()}")

    svg_data = chess.svg.board(board, size=400, lastmove=last_move)
    cairosvg.svg2png(bytestring=svg_data.encode(), write_to=out_path)
    print(f"Saved to {out_path}")


if __name__ == "__main__":
    pgn_path = sys.argv[1]
    game_index = int(sys.argv[2])
    out_path = sys.argv[3]
    main(pgn_path, game_index, out_path)
