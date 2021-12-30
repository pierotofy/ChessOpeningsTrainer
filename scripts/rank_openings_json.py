from stockfish import Stockfish
import json
import os

with open(os.path.join(os.path.dirname(__file__), "..", "gen", "openings.json")) as f:
    openings = json.loads(f.read())

# openings = [openings[7], openings[8]]
# openings[0]['variations'] = openings[0]['variations'][:2]
# openings[1]['variations'] = openings[1]['variations'][:2]

def rank_opening(opening, depth):
    moves = opening['uci'].split(" ")

    print("Evaluating " + opening['name'])
    s = Stockfish(parameters={"Threads": 1})
    s.set_position(moves)
    s.set_depth(20)
    rank = s.get_evaluation()
    if rank['type'] == 'cp':
        opening['rank'] = rank['value']
    elif rank['type'] == 'mate':
        opening['rank'] = 9999 if rank['value'] > 0 else -9999
    else:
        print("Warning! Unknown rank type: %s" % rank['type'])
        opening['rank'] = None

    print(opening['rank'])

    best_move = s.get_best_move()
    print("Stockfish: %s" % best_move)
    opening['best'] = best_move
    
    print("======")
    print("")

    for o in opening.get('variations', []):
        rank_opening(o, depth + 1)

for o in openings:
    rank_opening(o, 0)

def sort_white(o):
    return -o['rank']

def sort_black(o):
    return o['rank']

def sort_openings(ops, depth):
    if depth % 2 == 0:
        ops.sort(key=sort_white)
    else:
        ops.sort(key=sort_black)
    
    for o in ops:
        if 'variations' in o:
            o['variations'] = sort_openings(o['variations'], depth + 1)

    return ops

openings = sort_openings(openings, 0)

with open(os.path.join(os.path.dirname(__file__), "..", "gen", "openings-ranked.json"), 'w') as f:
    f.write(json.dumps(openings))