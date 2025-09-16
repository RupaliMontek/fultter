import express from 'express';
import morgan from 'morgan';
import cors from 'cors';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';
import { initializeSchema, seedIfEmpty } from './db.js';
import { router } from './routes.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

initializeSchema();
seedIfEmpty();

const app = express();
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json());

app.use('/api', router);

app.use(express.static(path.join(__dirname, '..', 'public')));

app.use((req, res) => {
	res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
	console.log(`Server running on http://localhost:${port}`);
});


