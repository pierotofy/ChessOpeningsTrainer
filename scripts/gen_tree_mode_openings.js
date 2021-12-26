const fs = require('fs');
const path = require('path');


const input = path.join(__dirname, "..", "gen", "openings-ranked.json");
const output = path.join(__dirname, "..", "board", "gen", "openings-ranked-tree.js");
const MaxVariations = 5;
let openings = JSON.parse(fs.readFileSync(input));

const sortWhite = (a, b) => {
    return a.rank.value < b.rank.value ? 1 : -1;
};
const sortBlack = (a, b) => {
    return a.rank.value > b.rank.value ? 1 : -1;
};
const filterUnranked = o => {
    return o.rank !== undefined && o.rank.type === "cp";
}

function traverse(ops, depth){
    ops = ops.filter(filterUnranked);

    ops.forEach(o => delete(o.bestv));
    
    if (depth % 2 == 0) ops.sort(sortWhite);
    else ops.sort(sortBlack);

    ops = ops.slice(0, MaxVariations);
    ops.forEach(o => {
        if (o.variations) o.variations = traverse(o.variations, depth + 1);
    });
    return ops;
}

openings = traverse(openings, 0);

fs.writeFileSync(output, `var RankedOpenings = ${JSON.stringify(openings)};`, {encoding: "utf8"});
console.log("Wrote " + output);
