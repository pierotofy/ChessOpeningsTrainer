function main(){

// ==== INIT ====
function parseQueryParams(){
    let search = location.search.substring(1);
    if (!search) return {};
    return JSON.parse('{"' + decodeURI(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
}

let { uci, color } = parseQueryParams();
if (!uci) throw new Error("UCI is required");
if (!color) color = "white";


const domBoard = document.getElementById('chessboard');
const state = {
    canPlayBack: false,
    canPlayForward: true,
    currentMove: -1
};

// Webkit
let _sendMessage = (key, value) => {
    console.log(key, key);
};

if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.jsHandler){
    _sendMessage = (key, value) => {
        if (value === undefined) value = "";
        window.webkit.messageHandlers.jsHandler.postMessage(`${key}=${value}`);
    }
}

window._handleMessage = (key, value) => {
    if (key === "dispatchEvent") document.dispatchEvent(new Event(value));
};

const broadcastState = () => {
    const keys = ['canPlayBack', 'canPlayForward'];
    for (let k of keys){
        _sendMessage(`${k}`, `${state[k]}`);
    }
}

const updateSize = () => {
    const w = window.innerWidth;
    const h = window.innerHeight;
    const size = Math.min(w, h) + 1;

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
const DEFAULT_POSITION = {
    'white': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    'black': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1'
};
const game = new Chess(DEFAULT_POSITION[color]);
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

const updateCg = () => {
    cg.set({
        turnColor:  game.turn() === 'w' ? 'white' : 'black',
        
        // this highlights the checked king in red
        check: game.in_check(),
        
        movable: {
            // Only allow moves by whoevers turn it is
            color: game.turn() === 'w' ? 'white' : 'black',
            
            // Only allow legal moves
            dests: calcDests()
        }
    });
}

const playOtherSide = (orig, dest) => {
    game.move({from: orig, to: dest});
    updateCg();
};

const playMove = (orig, dest, undo = false) => {
    cg.move(orig, dest);

    if (undo) game.undo();
    else game.move({from: orig, to: dest});

    updateCg();
};

// Board
const cg = Chessground(domBoard, {
    orientation: color,
    movable: {
        color: "white",
        free: false, // don't allow movement anywhere ...
        dests: calcDests(),
        events: {
            after: playOtherSide
        }
    }
});

const moves = uci.split(" ").map(uciToMove);

const updateState = () => {
    state.canPlayBack = state.currentMove >= 0;
    state.canPlayForward = state.currentMove < moves.length - 1;
    broadcastState();
}

const playForward = () => {
    if (state.currentMove >= moves.length - 1) return;
    state.currentMove++;

    const [orig, dest] = moves[state.currentMove];
    playMove(orig, dest);
    updateState();
};

const playBack = () => {
    if (state.currentMove < 0) return;

    const [dest, orig] = moves[state.currentMove];
    playMove(orig, dest, true);
    
    state.currentMove--;
    updateState();
}

// if (color === 'white'){

// }else{
//     playForward();
// }

updateSize();
window.addEventListener('resize', updateSize);

document.addEventListener('playForward', playForward);
document.addEventListener('playBack', playBack);

// Debug
if (/192\.168\.\d+\.\d+/.test(window.location.hostname) ||
    /localhost/.test(window.location.hostname)){
    const debug = document.getElementById("debug");
    debug.style.display = 'block';
}

// ==== END INIT ====

// if (mode === "explore")

// In explore mode we move to the last move

moves.forEach(move => {
    const [orig, dest] = move;
    playMove(orig, dest);
});
state.currentMove = moves.length - 1;

updateState();


}