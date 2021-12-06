function main(){

const domBoard = document.getElementById('chessboard');

const updateSize = () => {
    const w = window.innerWidth;
    const h = window.innerHeight;
    const size = Math.min(w, h) + 4;

    domBoard.style.width = size + 'px';
    domBoard.style.height = size + 'px';

    if (w > h){
        domBoard.style.marginLeft = (w - h) / 2 + 'px';
        domBoard.style.marginTop = '0px';
    }else{
        domBoard.style.marginLeft = '0px';
        domBoard.style.marginTop = (h - w) / 2 + 'px';
    }
}

// Chess engine
const game = new Chess();

const calcDests = () => {
    const dests = new Map();

    game.SQUARES.forEach(s => {
      const ms = game.moves({square: s, verbose: true});
      if (ms.length) dests.set(s, ms.map(m => m.to));
    });

    return dests;
}

const uciToMove = (uci) => {
    let result = ["", ""];
    let c = 0;

    for (let i = 0; i < uci.length; ){
        if (/[a-h]/.test(uci[i])){
            result[c] += uci[i++];
            result[c++] += uci[i++];
        }else{
            i++; // Promotion character?
        }
        if (c > 1) break;
    }
    return result;
};

const playOtherSide = (orig, dest) => {
    // Update chess.js
    // Note: we don't check the return value here which would tell
    // us if this is a legal move.  That's because we only allowed legal moves by setting "dests"
    // on the board.
    game.move({from: orig, to: dest});
    
    cg.set({
        // I'm not sure what this does! You can comment it out and not much changes
        // turnColor: toColor(chess),
        
        // this highlights the checked king in red
        check: game.in_check(),
        
        movable: {
            // Only allow moves by whoevers turn it is
            color: game.turn() === 'w' ? 'white' : 'black',
            
            // Only allow legal moves
            dests: calcDests()
        }
    });
};

const playMove = (orig, dest) => {
    cg.move(orig, dest);
    game.move({from: orig, to: dest});
    cg.set({
        // this highlights the checked king in red
        check: game.in_check(),
        
        movable: {
            // Only allow moves by whoevers turn it is
            color: game.turn() === 'w' ? 'white' : 'black',
            
            // Only allow legal moves
            dests: calcDests()
        }
    });
};

// Board
const cg = Chessground(domBoard, {
    movable: {
        color: 'white',
        free: false, // don't allow movement anywhere ...
        dests: calcDests(),
        events: {
            after: playOtherSide
        }
    }
});

const longOpenings = Openings.filter(o => o.uci.split(" ").length > 14);
console.log(longOpenings);

const opening = Openings.find(o => o.name === "Sicilian Defense: Dragon Variation, Yugoslav Attack, Soltis Variation");
opening.uci.split(" ").forEach(m => {
    const [orig, dest] = uciToMove(m);
    playMove(orig, dest);
});

updateSize();
window.addEventListener('resize', updateSize);

window.uciToMove = uciToMove;

}