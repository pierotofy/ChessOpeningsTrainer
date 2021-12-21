const path = require('path');
const fs = require('fs');
const axios = require('axios');

const openings = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "gen", "openings.json")));

const baseUrl = "https://en.wikibooks.org/w/api.php?redirects&origin=*&action=query&prop=extracts&formatversion=2&format=json&titles=Chess_Opening_Theory";

// Roughly based on https://github.com/ornicar/lila/blob/cc79e29cbf34f2753e2fadec5c006c134409d961/ui/analyse/src/wiki.ts
const removeEmptyParagraph = html => html.replace(/<p>(<br \/>|\s|<br>)*<\/p>/g, '');
const removeComments = html =>  html.replace(/<!--[\s\S]*-->/gm, "");
const removeTableHeader = html => html.replace('<h2><span id="Theory_table">Theory table</span></h2>', '');
const removeTableExpl = html =>
  html.replace(/For explanation of theory tables see theory table and for notation see algebraic notation.?/, '');
const removeContributing = html =>
  html.replace('When contributing to this Wikibook, please follow the Conventions for organization.', '');
const removeEmptyLines = html => html.replace(/^\s*\n/gm, "");

const cleanHtml = (html) =>
    removeEmptyLines(removeComments(removeEmptyParagraph(removeTableHeader(removeTableExpl(removeContributing(html))))));

function pgnToUrl(pgn, titleOnly = false){
    let p = ""; 
    let parts = pgn.split(/[\d]\.\s*/).map(s => s.trim()).filter(s => s.length);
    for (let i = 0; i < parts.length; i++){
        const moves = parts[i].split(" ");
        p += `/${i+1}._${moves[0]}`;

        moves.slice(1).forEach(m => {
            p += `/${i+1}...${m}`;
        });
    }
    if (titleOnly) return p;
    else return `${baseUrl}${p}`;
}

function pgnToFilename(pgn){
    let url = pgnToUrl(pgn, true);
    if (url[0] === "/") url = url.slice(1);
    return url.replace(/\//g, "-");
}

async function fetchDescription(opening){
    return new Promise((resolve, reject) => {
        axios.get(pgnToUrl(opening.pgn))
          .then(res => {
            if (res.status === 200){
                const json = res.data;
                if (json && json.query && json.query.pages && json.query.pages[0] && json.query.pages[0].extract){
                    const extract =  json.query.pages[0].extract;
                    resolve(cleanHtml(extract));
                }else{
                    reject(new Error(`Invalid response ${res.data}`));
                }
            }else{
                reject(new Error(`Status: ${res.status}`));
            }
    
          })
          .catch(reject);
    });
}

async function delay(ms){
    return new Promise((resolve, reject) => {
        setTimeout(resolve, ms);
    })
} 

async function fetchAllRecursive(openings){
    openings.forEach(async o => {
        try{
            await delay(100);
            const descr = await fetchDescription(o);
            const outfile = path.join(__dirname, "..", "gen", "descriptions", pgnToFilename(o.pgn));
            console.log(descr);
            if (descr){
                fs.writeFileSync(outfile, descr, { encoding: "utf8"});
                console.log(outfile);
            }
        }catch(e){
            console.log(e);
        }

        if (o.variations) await fetchAllRecursive(o.variations);
    });
}

async function main(){
    fetchAllRecursive(openings);
};

main();
