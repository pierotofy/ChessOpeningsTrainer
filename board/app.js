function main(){

// ==== INIT ====
function parseQueryParams(){
    let search = location.search.substring(1);
    if (!search) return {};
    return JSON.parse('{"' + decodeURI(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
}

let { uci, color, mode } = parseQueryParams();
if (!uci) throw new Error("UCI is required");
if (!color) color = "white";
if (!mode) mode = "explore";

const domBoard = document.getElementById('chessboard');
const state = {
    canPlayBack: false,
    canPlayForward: true,
    currentMove: -1,
    mode,
    wrongMove: false
};

const pieceStack = [];

// Webkit
let _sendMessage = (key, value) => {
    console.log(key, value);
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
    const keys = ['canPlayBack', 'canPlayForward', 'mode'];
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
    // No moves allowed in explore mode
    if (state.mode === "explore") return null;

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
        orientation: color,
        highlight: {
            lastMove: true
        },

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

const checkPlayerMove = (orig, dest) => {
    const playerMove = uciToMove(`${orig}${dest}`);
    const correctMove = moves[state.currentMove + 1];

    if (playerMove.join("") === correctMove.join("")){
        cg.setAutoShapes([
            {
                orig: playerMove[0],
                dest: playerMove[1],
                brush: 'green'
            }
        ]);

        game.move({from: orig, to: dest});
        updateCg();
        state.currentMove++;

        // Play opponent's next move
        playForward();
    }else{
        cg.setAutoShapes([
            {
                orig: playerMove[0],
                dest: playerMove[1],
                brush: 'red'
            },{
                orig: correctMove[0],
                dest: correctMove[1],
                brush: 'green'
            }
        ]);

        state.wrongMove = playerMove;
    }
};

const chessTypeToCgRole = {
    "p": "pawn",
    "r": "rook",
    "n": "knight",
    "b": "bishop",
    "q": "queen",
    "k": "king",
};

const chessMoveToCgPiece = (move) => {
    const { piece, color } = move;
    return {
        role: chessTypeToCgRole[piece], 
        color: color === "w" ? "black" : "white"
    };
}

const checkUndoCastle = (move) => {
    if (!move) return;

    const { flags, from } = move;
    const kingCastle = flags.indexOf("k") !== -1;
    const queenCastle = flags.indexOf("q") !== -1;
    
    if (kingCastle || queenCastle){
        if (from === "e1"){
            if (kingCastle) cg.move("f1", "h1");
            else cg.move("d1", "a1");
        }else if (from === "e8"){
            if (kingCastle) cg.move("f8", "h8");
            else cg.move("d8", "a8");
        }else{
            throw new Error(`Unexpected castle from ${from}`);
        }
    }
}

const checkTakePiece = (move) => {
    if (!move) return;

    const { flags, to } = move;
    const enPassant = flags.indexOf("e") !== -1;
    const stdCapture = flags.indexOf("c") !== -1;
    const noCapture = flags.indexOf("n") !== -1;
    
    if (noCapture) return;

    if (enPassant || stdCapture){
        const p = chessMoveToCgPiece(move);

        if (stdCapture) p.position = to;
        else if (enPassant){
            if (move.color === "w"){
                p.position = to[0] + parseInt(to[1] - 1)
            }else{
                p.position = to[0] + parseInt(to[1] + 1);
            }
            cg.setPieces([[p.position, null]]); // Remove piece
        }else return; // Should never happen
        
        return p;
    }
}

const playMove = (orig, dest, undo = false) => {
    cg.move(orig, dest);

    if (undo){
        checkUndoCastle(game.undo());

        let piece = pieceStack.pop();
        if (piece){
            cg.newPiece(piece, piece.position);
        }
    }else{
        const move = game.move({from: orig, to: dest});
        pieceStack.push(checkTakePiece(move));
    }

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
            after: checkPlayerMove
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

const rewind = () => {
    for (let i = state.currentMove; i >= 0; i--){
        const [dest, orig] = moves[i];
        playMove(orig, dest, true);
    }
    state.currentMove = -1;
    updateState();
    cg.setAutoShapes([]);
}

const toggleColor = () => {
    if (color === "white"){
        color = "black";
    }else{
        color = "white";
    }
    updateCg();
    _sendMessage("toggledColor", color);
}

const resetTraining = (force) => {
    if (state.mode !== "training") return;
    if (state.wrongMove || (typeof force === "boolean" && force)){
        if (state.wrongMove){
            playMove(state.wrongMove[1], state.wrongMove[0], true); // Undo last move
        }

        state.wrongMove = false;

        rewind();
        cg.set({
            highlight: {
                lastMove: false
            }
        });
        
        if (color === 'black'){
            playForward(); // White plays first move
        }
    }
}

const setTrainingMode = () => {
    state.mode = "training";
    resetTraining(true);
};


updateSize();
window.addEventListener('resize', updateSize);
domBoard.addEventListener('click', resetTraining);
domBoard.addEventListener('ontouchstart', resetTraining);

document.addEventListener('playForward', playForward);
document.addEventListener('playBack', playBack);
document.addEventListener('rewind', rewind);
document.addEventListener('toggleColor', toggleColor);
document.addEventListener('setTrainingMode', setTrainingMode);

// Debug
if (/192\.168\.\d+\.\d+/.test(window.location.hostname) ||
    /localhost/.test(window.location.hostname)){
    const debug = document.getElementById("debug");
    debug.style.display = 'block';

    window.cg = cg;
    window.game = game;
    window.domBoard = domBoard;
}

// ==== END INIT ====

if (state.mode === "explore"){
    // In explore mode we move to the last move
    moves.forEach(move => {
        const [orig, dest] = move;
        playMove(orig, dest);
    });
    state.currentMove = moves.length - 1;

    updateState();
}else if (state.mode === "training"){
    setTrainingMode();
}

}