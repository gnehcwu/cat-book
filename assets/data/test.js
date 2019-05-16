const cats = require('./cats.json')

cats.forEach(element => {
    console.log(`- assets/images/${element.name}.JPG`)
});