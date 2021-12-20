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
    mode,
    resetTrainingOnTap: false
};

const pieceStack = [];
const movesStack = [];

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
const game = new Chess();
const calcDests = () => {
    // No moves allowed in explore mode or when training is done
    if (state.mode === "explore") return null;

    const dests = new Map();

    game.SQUARES.forEach(s => {
      const ms = game.moves({square: s, verbose: true});
      if (ms.length) dests.set(s, ms.map(m => m.to));
    });

    return dests;
}
const noDests = () => {
    const dests = new Map();

    game.SQUARES.forEach(s => {
      dests.set(s, []);
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
    const correctMove = moves[movesStack.length];

    pieceStack.push(checkTakePiece(game.move({from: orig, to: dest})));
    updateCg();
    movesStack.push([orig, dest]);

    if (playerMove.join("") === correctMove.join("")){
        cg.setAutoShapes([
            {
                orig: playerMove[0],
                dest: playerMove[1],
                brush: 'green'
            }
        ]);

        // Play opponent's next move
        playForward();

        checkTrainingFinished();
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

        state.resetTrainingOnTap = true;
        stopMoves();
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
        movesStack.push([orig, dest]);
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
    state.canPlayBack = movesStack.length > 0;
    state.canPlayForward = movesStack.length < moves.length;
    broadcastState();
}

const playForward = () => {
    if (movesStack.length >= moves.length) return;
    
    const [orig, dest] = moves[movesStack.length];
    playMove(orig, dest);
    updateState();
};

const playBack = () => {
    if (movesStack.length <= 0) return;

    const [dest, orig] = movesStack.pop();
    playMove(orig, dest, true);
    
    updateState();
}

const rewind = () => {
    let move;
    while (move = movesStack.pop()){
        const [dest, orig] = move;
        playMove(orig, dest, true);
    }
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
    
    if (mode === "training") setTrainingMode();
    
    _sendMessage("toggledColor", color);
}

const resetTraining = (force) => {
    if (state.mode !== "training") return;
    if (state.resetTrainingOnTap || (typeof force === "boolean" && force)){
        state.resetTrainingOnTap = false;
        rewind();

        cg.set({
            highlight: {
                lastMove: false
            }
        });
        
        if (color === 'black'){
            playForward(); // White plays first move
            checkTrainingFinished();
        }
    }
}

const stopMoves = () => {
    cg.set({
        movable: {
            dests: noDests()
        }
    });
}

const checkTrainingFinished = () => {
    if (movesStack.length === moves.length){
        state.resetTrainingOnTap = true;
        stopMoves();
        _sendMessage("trainingFinished");
    }
}

const setTrainingMode = () => {
    state.mode = "training";
    resetTraining(true);

    _sendMessage("setMode", state.mode);
};

const setExploreMode = () => {
    state.mode = "explore";
    rewind();

    // In explore mode we move to the last move
    moves.forEach(move => {
        const [orig, dest] = move;
        playMove(orig, dest);
    });
    
    updateState();

    _sendMessage("setMode", state.mode);
};


updateSize();
window.addEventListener('resize', updateSize);
window.addEventListener('click', resetTraining);

document.addEventListener('playForward', playForward);
document.addEventListener('playBack', playBack);
document.addEventListener('rewind', rewind);
document.addEventListener('toggleColor', toggleColor);
document.addEventListener('setTrainingMode', setTrainingMode);
document.addEventListener('setExploreMode', setExploreMode);

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
    setExploreMode();
}else if (state.mode === "training"){
    setTrainingMode();
}

}