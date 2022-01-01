import os
import json
import chess
from itertools import product, permutations
from functools import lru_cache
from stockfish import Stockfish

infile = os.path.join(os.path.dirname(__file__), "..", "gen", "openings-ranked.json")
#infile = os.path.join(os.path.dirname(__file__), "..", "test-ops.json")
outfile = os.path.join(os.path.dirname(__file__), "..", "board", "gen", "openings-moves.js")


with open(infile) as f:
    openings = json.loads(f.read())

openings_list = []

def populate(ops):
    for o in ops:
        variations = o.get('variations')

        if 'variations' in o:
            del o['variations']
        
        openings_list.append(o)
        if variations:
            populate(variations)

populate(openings)

print("Expanded %s openings" % len(openings_list))

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

    pw = permutations(white)
    pb = permutations(black)

    perms = list(product(pw, pb))
    result = []
    for perm in perms:
        w,b = map(list, perm)
        while len(b) < len(w):
            b += ['']

        result.append(" ".join(list(filter(lambda m: len(m) > 0, flatten((zip(w, b)))))))
    return result

fens = {}

idx = 0
for o in openings_list:
    moves = o.get('uci').strip().split(" ")
    b = chess.Board()

    for m in moves:
        b.push_uci(m)
        fen = b.fen()
        if fen in fens:
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

def get_moves_starting_with_at(starts_with_uci, depth):
    print(starts_with_uci, depth)

    moves_d = {}
    for o in openings_list:
        for uci in compute_transpose(starts_with_uci):
            if o.get('uci').startswith(uci):
                moves = o['uci'].strip().split(" ")
                if depth < len(moves):
                    moves_d[moves[depth]] = True
    
    all_moves = list(moves_d.keys())
    
    result = []
    b = chess.Board()
    starting_moves = []

    if len(starts_with_uci) > 0:
        starting_moves = starts_with_uci.strip().split(" ")
        for m in starting_moves:
            b.push_uci(m)

    starting_fen = b.fen()

    for m in all_moves:
        b.set_fen(starting_fen)
        b.push_uci(m)
        fen = b.fen()

        uci_prefix = ""
        if len(starts_with_uci.strip()) > 0:
            uci_prefix = starts_with_uci.strip() + " "

        result.append({
            'move': m,
            'rank': evaluate(fen),
            'openings': fens.get(fen, []),
            'moves': get_moves_starting_with_at(uci_prefix + m, depth + 1)
        })

    return result

output = {
    'openings': openings_list,
    'moves': get_moves_starting_with_at("", 0)
}

with open(outfile, "w") as f:
    f.write("var OpeningMoves = ");
    f.write(json.dumps(output))
    f.write(";")

print("Wrote %s" % outfile)


