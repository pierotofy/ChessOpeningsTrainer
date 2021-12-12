const path = require('path');
const fs = require('fs');
const { exit } = require('process');

const openingsJs = fs.readFileSync(path.join(__dirname, "..", "board", "vendor", "openings.js")).toString();

eval(openingsJs);

Openings.sort((a, b) => {
    return a.uci.length > b.uci.length ? 1 : -1;
});

function findVariations(op, openings, depth, mainName){
    const addedUci = [];
    const variations = [];

    openings.forEach(o => {
        if (o.uci === op.uci) return; // Skip self
        
        if (o.uci.indexOf(op.uci) === 0){
            // Need to add?

            if (!addedUci.find(au => o.uci.indexOf(au) === 0)){
                let name = o.name.replace(op.name, "");
                if (mainName) name = name.replace(mainName, "");
                name = name.replace(/^\s*[,:]/, "").trim();
                if (!name) name = op.name
                
                let childVars = findVariations(o, openings, depth + 1, mainName || op.name);
                let curVar = {
                    name, uci: o.uci, pgn: o.pgn, depth
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
}, Openings, 0);

const outFile = path.resolve(path.join(__dirname, "..", "gen", "openings.json"));
fs.writeFileSync(outFile, JSON.stringify(root), {encoding: 'utf8'});
console.log(`Wrote ${outFile}`);
