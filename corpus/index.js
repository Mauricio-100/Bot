const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const { evaluate } = require('mathjs');

const app = express();
const PORT = process.env.PORT || 3000;
const CORPUS_FILE = path.join(__dirname, 'corpus.json');

app.use(bodyParser.json());

// --- Fonctions du Corpus ---
const readCorpus = () => {
    if (!fs.existsSync(CORPUS_FILE)) {
        return {};
    }
    const data = fs.readFileSync(CORPUS_FILE);
    return JSON.parse(data);
};

const writeCorpus = (corpus) => {
    fs.writeFileSync(CORPUS_FILE, JSON.stringify(corpus, null, 2));
};

// --- API Endpoints ---

app.get('/', (req, res) => {
    res.send('Serveur Corpus v2.0 (Colossus) est en ligne.');
});

// Route pour récupérer une définition
app.get('/corpus/:sujet', (req, res) => {
    const corpus = readCorpus();
    const sujet = req.params.sujet.toLowerCase();
    
    if (corpus[sujet]) {
        res.json({ sujet: sujet, definition: corpus[sujet] });
    } else {
        res.status(404).json({ error: 'Sujet non trouvé.' });
    }
});

// Route pour apprendre une nouvelle information
app.post('/corpus', (req, res) => {
    const { sujet, definition } = req.body;

    if (!sujet || !definition) {
        return res.status(400).json({ error: 'Sujet et définition requis.' });
    }

    const corpus = readCorpus();
    corpus[sujet.toLowerCase()] = definition;
    writeCorpus(corpus);

    res.status(201).json({ message: 'Connaissance acquise.' });
});

// Route pour les calculs mathématiques
app.post('/calculate', (req, res) => {
    const { expression } = req.body;
    if (!expression) {
        return res.status(400).json({ error: 'Expression mathématique requise.' });
    }
    try {
        const result = evaluate(expression);
        res.json({ result: result.toString() });
    } catch (error) {
        res.status(400).json({ error: 'Expression mathématique invalide.' });
    }
});


app.listen(PORT, () => {
    console.log(`Serveur Colossus écoute sur le port ${PORT}`);
});
