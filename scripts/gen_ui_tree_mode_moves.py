import os
import json


infile = os.path.join(os.path.dirname(__file__), "..", "board", "gen", "openings-moves.js")
outfile = os.path.join(os.path.dirname(__file__), "..", "gen", "openings-moves.json")
DEPTH = 1
MAX_MOVES = 20

with open(infile) as f:
    content = f.read()
    content = content[len("var OpeningMoves = "):-len(";")]
    db = json.loads(content)

openings = db['openings']

result = []

def parseTree(moves, parent_uci, depth, max_moves):
    moves.sort(key=lambda m: m['rank'], reverse=depth % 2 == 0)
    moves = moves[:max_moves]

    if len(result) < max_moves:
        result.append([])

    for m in moves:
        uci = parent_uci + m['move']
        selected_op = None

        for op_idx in m.get('openings', []):
            op = openings[op_idx]
            num_moves = len(op['uci'].strip().split(" "))
            if num_moves == depth + 1:
                selected_op = op
                break
            
        if selected_op is not None:
            result[max_moves - 1].append({
                'name': selected_op['name'],
                'uci': uci
            })

            if depth < DEPTH:
                parseTree(m['moves'], uci + " ", depth + 1, max_moves)

for max_moves in range(1, MAX_MOVES + 1):            
    parseTree(db['moves'], "", 0, max_moves)

for moves in result:
    moves.sort(key=lambda m: m['name'])

with open(outfile, "w") as f:
    f.write(json.dumps(result))

print("Wrote %s" % outfile)


