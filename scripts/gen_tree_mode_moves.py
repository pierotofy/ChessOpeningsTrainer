import os
import json
import chess
from itertools import product, permutations
from functools import lru_cache
from stockfish import Stockfish

infile = os.path.join(os.path.dirname(__file__), "..", "gen", "openings-ranked.json")
#infile = os.path.join(os.path.dirname(__file__), "..", "test-ops.json")
outfile = os.path.join(os.path.dirname(__file__), "..", "board", "gen", "openings-moves-test.js")
# outfile = os.path.join(os.path.dirname(__file__), "..", "board", "gen", "openings-moves.js")

def flatten(t):
    return [item for sublist in t for item in sublist]

@lru_cache(maxsize=None)
def compute_transpose(uci):
    if len(uci.strip()) == 0:
        return [""]

    moves = uci.strip().split(" ")
    if len(moves) > 8:
        return [uci.strip()]

    black = moves[1::2]
    white = moves[::2]

    black = moves[1::2]
    white = moves[::2]

    pw = permutations(white)
    pb = permutations(black)

    perms = list(product(pw, pb))
    result = []
    for perm in perms:
        w,b = map(list, perm)
        while len(b) < len(w):
            b += ['']

        result.append(" ".join(list(filter(lambda m: len(m) > 0, flatten((zip(
w, b)))))))
    return result


with open(infile) as f:
    openings = json.loads(f.read())

openings_list = []

def populate(ops):
    for o in ops:
        variations = o.get('variations')
        o['uci_transposes'] = compute_transpose(o['uci'])

        if 'variations' in o:
            del o['variations']
        
        openings_list.append(o)
        if variations:
            populate(variations)

populate(openings)

print("Expanded %s openings" % len(openings_list))

fens = {}
b = chess.Board()
initial_fen = b.fen()
fens[initial_fen] = []

idx = 0
first_moves_d = {}

for o in openings_list:
    all_ucis = o['uci_transposes']
    for uci in all_ucis:
        moves = uci.split(" ")
        b = chess.Board()

        if len(moves) == 1:
            if idx not in fens[initial_fen]:
                fens[initial_fen].append(idx)

        for m in moves:
            try:
                b.push_uci(m)
            except ValueError as e:
                continue

            fen = b.fen()
            if fen in fens:
                if idx not in fens[fen]:
                    fens[fen].append(idx)
            else:
                fens[fen] = [idx]
    
    idx += 1

print("Computed FEN dict")

s = Stockfish(parameters={"Threads": 4})
    
@lru_cache(maxsize=None)
def evaluate(fen):
    s.set_fen_position(fen)
    s.set_depth(20)
    evaluation = s.get_evaluation()
    if evaluation['type'] == 'cp':
        rank = evaluation['value']
    elif evaluation['type'] == 'mate':
        rank = 9999 if evaluation['value'] > 0 else -9999
    else:
        print("Warning! Unknown rank type: %s" % evaluation['type'])
        rank = None
    return rank

def get_moves_starting_at(fen, depth):
    if not fen in fens:
        return []
    
    print(fen, depth)

    result = []
    op_idxs = fens[fen]
    moves_d = {}
    
    for op_idx in op_idxs:
        op = openings_list[op_idx]
        all_ucis = op['uci_transposes']
        for uci in all_ucis:
            moves = uci.split(" ")
            if depth < len(moves):
                m = moves[depth]

                if m in moves_d:
                    continue

                b = chess.Board()
                b.set_fen(fen)
                try:
                    b.push_uci(m)
                except ValueError as e:
                    # Skip, invalid moves
                    continue

                moves_d[m] = True
                fen_after_move = b.fen()

                rank = evaluate(fen_after_move)
                white_turn = depth % 2 == 0

                if (white_turn and rank < -100) or ((not white_turn) and rank > 150):
                    # Bad move
                    pass
                else:
                    result.append({
                        'move': m,
                        'rank': rank,
                        'openings': fens.get(fen_after_move, []),
                        'moves': get_moves_starting_at(fen_after_move, depth + 1)
                    })

    return result

moves = get_moves_starting_at(initial_fen, 0)

for o in openings_list:
    del o['uci_transposes']


# def prune(moves, depth):
#     white_turn = depth % 2 == 0
#     if len(moves) == 0:
#         return moves
#     print(depth)
#     index = [1] * len(moves)
#     for i in range(0, len(moves)):
#         if (white_turn and moves[i]['rank'] < -100) or ((not white_turn) and moves[i]['rank'] > 150):
#             index[i] = 0
    
#     moves = [m for i, m in enumerate(moves) if index[i] == 1]

#     for m in moves:
#         m['moves'] = prune(m['moves'], depth + 1)
    
#     return moves

#moves = prune(moves, 0)

output = {
    'openings': openings_list,
    'moves': moves
}

with open(outfile, "w") as f:
    f.write("var OpeningMoves = ");
    f.write(json.dumps(output))
    f.write(";")

print("Wrote %s" % outfile)


