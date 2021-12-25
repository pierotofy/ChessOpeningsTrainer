const fs = require('fs');
const path = require('path');

function pgnToUrl(pgn){
    let p = ""; 
    let parts = pgn.split(/[\d]\.\s*/).map(s => s.trim()).filter(s => s.length);
    for (let i = 0; i < parts.length; i++){
        const moves = parts[i].split(" ");
        p += `/${i+1}._${moves[0]}`;

        moves.slice(1).forEach(m => {
            p += `/${i+1}...${m}`;
        });
    }
    return p;
}

function pgnToFilename(pgn){
    let url = pgnToUrl(pgn, true);
    if (url[0] === "/") url = url.slice(1);
    return url.replace(/\//g, "-");
}

const input = path.join(__dirname, "..", "gen", "openings-ranked.json");
const openings = JSON.parse(fs.readFileSync(input));

function addDescription(opening){
    const file = pgnToFilename(opening.pgn);
    const p = path.join(__dirname, "..", "gen", "descriptions", file);

    if (fs.existsSync(p)){
        opening.descr = true;
    }
    if (opening.variations){
         opening.variations.forEach(addDescription);
    }
}

openings.forEach(addDescription);

fs.writeFileSync(input, JSON.stringify(openings), {encoding: "utf8"});
console.log("Wrote " + input);
