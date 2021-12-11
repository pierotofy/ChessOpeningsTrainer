const path = require('path');
const fs = require('fs');
const { exit } = require('process');

const openingsJs = fs.readFileSync(path.join(__dirname, "..", "board", "vendor", "openings.js")).toString();

eval(openingsJs);

Openings.sort((a, b) => {
    return a.uci.length > b.uci.length ? 1 : -1;
});

function findVariations(op, openings, mainName){
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

                if (!name) name = o.pgn.replace(op.pgn, "").trim()

                variations.push({
                    name,
                    eco: o.eco,
                    pgn: o.pgn,
                    uci: o.uci,
                    epd: o.epd, 
                    variations: findVariations(o, openings, mainName || op.name)
                })
                addedUci.push(o.uci);
            }
        }
    });

    return variations;
}

const root = findVariations({
    name: "",
    eco: "",
    pgn: "",
    uci: "",
    epd: ""
}, Openings);

const outFile = path.resolve(path.join(__dirname, "..", "gen", "openings.json"));
fs.writeFileSync(outFile, JSON.stringify(root), {encoding: 'utf8'});
console.log(`Wrote ${outFile}`);
