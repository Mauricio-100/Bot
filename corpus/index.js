const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const CORPUS_FILE = path.join(__dirname, 'corpus.json');

app.use(bodyParser.json());

// Fonction pour lire le corpus depuis le fichier
const readCorpus = () => {
    if (!fs.existsSync(CORPUS_FILE)) {
        return {};
    }
    const data = fs.readFileSync(CORPUS_FILE);
    return JSON.parse(data);
};

// Fonction pour écrire dans le corpus
const writeCorpus = (corpus) => {
    fs.writeFileSync(CORPUS_FILE, JSON.stringify(corpus, null, 2));
};

// --- API Endpoints ---

// Route pour récupérer une définition
// Exemple d'appel : GET /corpus/elon%20musk
app.get('/corpus/:sujet', (req, res) => {
    const corpus = readCorpus();
    const sujet = req.params.sujet.toLowerCase();
    
    if (corpus[sujet]) {
        res.json({ sujet: sujet, definition: corpus[sujet] });
    } else {
        res.status(404).json({ error: 'Sujet non trouvé dans le corpus.' });
    }
});

// Route pour apprendre une nouvelle information
// Exemple d'appel : POST /corpus avec body: {"sujet": "mon chat", "definition": "s'appelle Zéphyr"}
app.post('/corpus', (req, res) => {
    const { sujet, definition } = req.body;

    if (!sujet || !definition) {
        return res.status(400).json({ error: 'Le sujet et la définition sont requis.' });
    }

    const corpus = readCorpus();
    corpus[sujet.toLowerCase()] = definition;
    writeCorpus(corpus);

    res.status(201).json({ message: 'Connaissance acquise avec succès.', sujet: sujet, definition: definition });
});

// Route de base pour vérifier que le serveur est en ligne
app.get('/', (req, res) => {
    res.send('Serveur Corpus pour Bot-Shell est en ligne.');
});


app.listen(PORT, () => {
    console.log(`Serveur Corpus écoute sur le port ${PORT}`);
});
