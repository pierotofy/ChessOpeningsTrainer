function main(){

// ==== INIT ====
function parseQueryParams(){
    let search = location.search.substring(1);
    if (!search) return {};
    return JSON.parse('{"' + decodeURI(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
}

let { uci, color, mode } = parseQueryParams();
if (mode !== "tree" && !uci) throw new Error("UCI is required");
if (!uci) uci = "";
if (!color) color = "white";
if (!mode) mode = "explore";

const loadOpeningsTree = (done) => {
    const onLoad = () => {
        console.log("Loaded openings");
        done(window.OpeningMoves);
    };
    if (window.OpeningMoves) onLoad();
    else{
        let script = document.createElement('script');
        script.onload = onLoad;
        script.src = "gen/openings-moves.js";
        // script.src = "gen/om.js";
        document.getElementsByTagName('head')[0].appendChild(script);
    }
};

const overlay = document.getElementById("overlay");
const domBoard = document.getElementById('chessboard');
const state = {
    canPlayBack: false,
    canPlayForward: true,
    mode,
    resetTrainingOnTap: false,
    treeMoves: [],
    maxTreeMoves: 5,
    playedOpening: {}
};

let treeOpenings = [];
const pieceStack = [];
const movesStack = [];
const poStack = [];

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
    const keys = ['canPlayBack', 'canPlayForward', 'mode', 'playedOpening'];
    for (let k of keys){
        if (typeof state[k] === 'object') _sendMessage(`${k}`, `${JSON.stringify(state[k])}`);
        else _sendMessage(`${k}`, `${state[k]}`);
    }
}

let lastSize = {
    w: null,
    h: null
};
const updateSize = () => {
    const w = window.innerWidth;
    const h = window.innerHeight;
    if (lastSize.w === w && lastSize.h === h) return;

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

    lastSize.w = w;
    lastSize.h = h;
}

// Chess engine
const game = new Chess();
const calcDests = () => {
    // No moves allowed in explore mode or when training is done
    if (state.mode === "explore") return null;

    const dests = new Map();
    
    if (state.mode === "training"){
        // All legal moves allowed
        game.SQUARES.forEach(s => {
          const ms = game.moves({square: s, verbose: true});
          if (ms.length) dests.set(s, ms.map(m => m.to));
        });
    }else if (state.mode === "tree"){
        // Only opening moves allowed
        // const currentMove = game.history().length;
        const validMoves = {};

        state.treeMoves.forEach(treeMove => {
            const move = uciToMove(treeMove.move);
            if (!validMoves[move[0]]) validMoves[move[0]] = [move[1]];
            else validMoves[move[0]].push(move[1]);
        });

        for (let m in validMoves) dests.set(m, validMoves[m]);
    }

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

const handleBoardClick = (e) => {
    if (state.mode === "tree"){
        const { left, top, width, height } = domBoard.getBoundingClientRect();
        const x = e.clientX - left;
        const y = e.clientY - top;
        
        const squareSize = width / 8;
        const idx = Math.floor(x / squareSize);
        const idy = Math.floor(y / squareSize);

        let clickedSquare = color === "white" ? game.SQUARES[idy * 8 + idx] : game.SQUARES[(7 - idy) * 8 + (7 - idx)];
        if (!clickedSquare) return;
        
        let selectedOps = [];

        state.treeMoves.forEach(m => {
            const [ _, dest ] = uciToMove(m.move);
            if (dest === clickedSquare && m.openings && m.openings.length){
                let selectedOp = null;
                const currentMove = game.history().length;

                for (let opIdx of m.openings){
                    const op = treeOpenings[opIdx];
                    let numMoves = op.uci.trim().split(" ").length;

                    if (numMoves === currentMove + 1){
                        selectedOp = op;
                        break;
                    }
                }

                if (selectedOp) {
                    selectedOps = selectedOps.concat([selectedOp]);
                }else{
                    selectedOps = selectedOps.concat(m.openings.map(idx => treeOpenings[idx]));
                    
                }
            }
        });

        _sendMessage("showOpenings", JSON.stringify(selectedOps));
    }
};

const checkPlayerMove = (orig, dest) => {
    touchMoved = true;

    const playerMove = uciToMove(`${orig}${dest}`);
    
    pieceStack.push(checkTakePiece(game.move({from: orig, to: dest})));
    updateCg();
    movesStack.push([orig, dest]);
    
    if (state.mode === "training"){
        const correctMove = moves[movesStack.length - 1];
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
    }else if (state.mode === "tree"){
        // Update tree variations
        const treeMove = state.treeMoves.find(tm => tm.move === `${orig}${dest}`);
        const prevTree = state.treeMoves;

        if (!treeMove) console.log("TODO: END OF TREE!");
        else{
            if (treeMove && treeMove.openings.length > 0){
                poStack.push(treeOpenings[treeMove.openings[0]]);
            }else{
                poStack.push({});
            }

            state.treeMoves = topTreeMoves(treeMove.moves);
            state.treeMoves.parent = prevTree;
            drawTreeMoves();
        }
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
    const { captured, color } = move;
    return {
        role: chessTypeToCgRole[captured], 
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

// Setup colors
const Colors = {
    green: '#00b708',
    pink: '#b700af',
    blue: '#0057E9',
    yellow: '#cb7200',
    grey: '#4a4a4a',
    red: '#b70000'
};
let cgBrushes = {};
for (let k in Colors){
    cgBrushes[k] = {key: k, color: Colors[k], opacity: 1, lineWidth: 10};
}
cg.set({drawable: { brushes: cgBrushes}});

const getMoves = (uci) => {
    return uci.split(" ").map(uciToMove);
};

const moves = getMoves(uci);

const updateState = () => {
    if (state.mode === "tree"){
        state.canPlayBack = movesStack.length > 0;
        state.canPlayForward = false;
    
        if (poStack.length > 0) state.playedOpening = poStack[poStack.length - 1];
        else state.playedOpening = {};
    }else{
        state.canPlayBack = movesStack.length > 0;
        state.canPlayForward = movesStack.length < moves.length;
    }
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

    if (state.mode === "tree"){
        if (state.treeMoves.parent){
            state.treeMoves = state.treeMoves.parent;
            drawTreeMoves();
        }else{
            console.log("Should not have happened");
        }

        poStack.pop();
    }
    
    updateState();
}

const rewind = () => {
    let move;
    while (move = movesStack.pop()){
        const [dest, orig] = move;
        playMove(orig, dest, true);
    }

    if (state.mode === "tree"){
        while (state.treeMoves.parent){
            state.treeMoves = state.treeMoves.parent;   
        }

        while(poStack.pop());
        drawTreeMoves();
    }else{
        updateState();
        cg.setAutoShapes([]);
    }

}

const toggleColor = () => {
    if (color === "white"){
        color = "black";
    }else{
        color = "white";
    }
    
    if (mode === "training") setTrainingMode();
    else updateCg();
    
    _sendMessage("toggledColor", color);
}

const resetTraining = (force) => {
    if (state.mode !== "training") return;
    if (state.resetTrainingOnTap || (typeof force === "boolean" && force)){
        state.resetTrainingOnTap = false;
        hideOverlay();
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

const showOverlay = () => {
    overlay.style.pointerEvents = "auto";
}
const hideOverlay = () => {
    overlay.style.pointerEvents = "none";
}
const stopMoves = () => {
    cg.set({
        movable: {
            dests: noDests()
        }
    });
    showOverlay();
}


const checkTrainingFinished = () => {
    if (movesStack.length === moves.length){
        state.resetTrainingOnTap = true;
        stopMoves();
        // _sendMessage("trainingFinished");

        confetti({
            particleCount: 200,
            spread: 60,
            ticks: 150,
            origin: { y: 0.7 }
        });
    }
}

const setTrainingMode = () => {
    state.mode = "training";
    resetTraining(true);

    _sendMessage("setMode", state.mode);
};

const setExploreMode = () => {
    state.mode = "explore";
    showOverlay();
    rewind();

    // In explore mode we move to the last move
    moves.forEach(move => {
        const [orig, dest] = move;
        playMove(orig, dest);
    });
    
    updateState();

    _sendMessage("setMode", state.mode);
};

const rankDisplay = (rank) => {
    if (rank === "TODO") return "?";

    let v = rank / 100.0;
    if (v >= 0) v = `+${v}`;
    else v = `${v}`;

    if (v.length === 2) return `${v}.00`;
    else if (v.length === 4 && rank < 1000) return `${v}0`;
    else return v;
};

const labelPadding = (currentMove) => {
    if (currentMove % 2 == 0){
        if (color === "white") return 48;
        else return 62;
    }else{
        if (color === "black") return 48;
        else return 62;
    }
}

let brushes = ["blue", "green", "pink", "red", "grey"];

const drawTreeMoves = () => {
    const currentMove = game.history().length;

    // Draw arrows
    const arrows = [];
    const circles = [];
    const labels = [];
    
    let i = 0;
    let labelMargin = {};

    state.treeMoves.forEach(treeMove => {
        const move = uciToMove(treeMove.move);
        const [orig, dest] = move;

        const brush = i < brushes.length ? brushes[i] : brushes[brushes.length - 1];

        arrows.push({
            orig,
            dest,
            brush
        });
        circles.push({
            orig: dest,
            brush
        });
        labels.push({
            orig: dest,
            customSvg: `<text class="rank" fill="${Colors[brush]}" width="100" height="100" y="${labelPadding(currentMove) + (labelMargin[dest] || 0)}" x="15">${rankDisplay(treeMove.rank)}</text>`
        });

        // Add margin when moves are overlapping
        if (!labelMargin[dest]){
            labelMargin[dest] = color === "white" ? 24 : -24;
        }else{
            labelMargin[dest] += color === "white" ? 24 : -24;
        }
        
        i += 1;
    });

    cg.setAutoShapes(arrows.concat(circles).concat(labels));
    updateCg();
    updateState();
};

const topTreeMoves = (moves) => {
    const currentMove = game.history().length;
    let blackTurn = currentMove % 2 == 1;

    moves.sort((a, b) => {
        if (blackTurn) return a.rank < b.rank ? -1 : 1;
        else return a.rank < b.rank ? 1 : -1;
    });
    return moves.slice(0, state.maxTreeMoves);
};

const setTreeMode = () => {
    loadOpeningsTree((ops) => {
        const { openings, moves } = ops;

        state.mode = "tree";
        state.canPlayBack = false;
        state.canPlayForward = false;
        hideOverlay();
        rewind();

        treeOpenings = openings;
        state.treeMoves = topTreeMoves(moves);

        drawTreeMoves();

        _sendMessage("setMode", state.mode);
    });
};

let touchMoved = false;

if (('ontouchstart' in window) ||
       (navigator.maxTouchPoints > 0) ||
       (navigator.msMaxTouchPoints > 0)){
    window.addEventListener('touchstart', e => {
        setTimeout(() => {
            if (e.touches && !touchMoved){
                handleBoardClick({
                    clientX: e.touches[0].clientX,
                    clientY: e.touches[0].clientY
                });
            }

            touchMoved = false;
        }, 0);
    });
}else{
    window.addEventListener('click', handleBoardClick);
}


updateSize();
window.addEventListener('resize', updateSize);
setInterval(updateSize, 200);

overlay.addEventListener('click', resetTraining);

document.addEventListener('playForward', playForward);
document.addEventListener('playBack', playBack);
document.addEventListener('rewind', rewind);
document.addEventListener('toggleColor', toggleColor);
document.addEventListener('setTrainingMode', setTrainingMode);
document.addEventListener('setExploreMode', setExploreMode);
document.addEventListener('setTreeMode', setTreeMode);


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
}else if (state.mode === "tree"){
    setTreeMode();
}

}
