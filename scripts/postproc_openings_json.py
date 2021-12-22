from stockfish import Stockfish
import json
import os

with open(os.path.join(os.path.dirname(__file__), "..", "gen", "openings.json")) as f:
    openings = json.loads(f.read())

#openings = [openings[0]]
#openings[0]['variations'] = []

def rank_opening(opening, depth):
    moves = opening['uci'].split(" ")
    if len(moves) == depth + 1:
        print("Evaluating " + opening['name'])
        s = Stockfish(parameters={"Threads": 1})
        s.set_position(moves)
        s.set_depth(20)
        opening['rank'] = s.get_evaluation()
        print(opening['rank'])

        # Find best move also (does it match a variation?)
        best_move = s.get_best_move()
        variation_idx = None
        i = 0
        for o in opening.get('variations', []):
            if o['uci'].startswith(opening['uci'] + " " + best_move):
                variation_idx = i
            i += 1
        
        if variation_idx is not None:
            print("Best variation: %s" % opening['variations'][variation_idx]['name'])
            opening['nbest'] = {'type': 'v', 'idx': variation_idx}
        else:
            print("Stockfish: %s" % best_move)
            opening['nbest'] = {'type': 's', 'move': best_move}
        
        print("======")
        print("")

        for o in opening.get('variations', []):
            rank_opening(o, depth + 1)

for o in openings:
    rank_opening(o, 0)

with open(os.path.join(os.path.dirname(__file__), "..", "gen", "openings-ranked.json"), 'w') as f:
    f.write(json.dumps(openings))