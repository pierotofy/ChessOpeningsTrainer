const path = require('path');
const fs = require('fs');

const openingsJs = fs.readFileSync(path.join(__dirname, "..", "board", "vendor", "openings.js")).toString();

eval(openingsJs);

Openings.sort((a, b) => {
    return a.uci.length > b.uci.length ? 1 : -1;
});

function findVariations(op, openings){
    const addedUci = [];
    const variations = [];

    openings.forEach(o => {
        if (o.uci === op.uci) return; // Skip self
        
        if (o.uci.indexOf(op.uci) === 0){
            // Need to add?

            if (!addedUci.find(au => o.uci.indexOf(au) === 0)){
                let childVars = findVariations(o, openings);
                let curVar = {
                    name: o.name, uci: o.uci, pgn: o.pgn
                };
                if (childVars.length > 0) curVar.variations = childVars;
                
                variations.push(curVar);

                addedUci.push(o.uci);
            }
        }
    });

    return variations;
}

const root = findVariations({
    name: "",
    uci: "",
    pgn: ""
}, Openings);

const outFile = path.resolve(path.join(__dirname, "..", "gen", "openings.json"));
fs.writeFileSync(outFile, JSON.stringify(root), {encoding: 'utf8'});
console.log(`Wrote ${outFile}`);
