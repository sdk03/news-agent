const express = require('express');
const cors = require('cors');
const path = require('path');
const jwt = require('jsonwebtoken');
const morgan = require('morgan');

// Import news sources
const khaleejTimes = require('./news_sources/khaleej_times');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'; // In production, use environment variable

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Authentication middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Authentication token required' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
};

// Login endpoint (for demo purposes)
app.post('/api/login', (req, res) => {
    console.log('POST /api/login');
    // In a real application, validate credentials against a database
    const { username, password } = req.body;
    
    if (username === 'admin' && password === 'password') {
        const token = jwt.sign({ username }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token });
    } else {
        res.status(401).json({ error: 'Invalid credentials' });
    }
});

// Protected Routes
// Get latest headline
app.get('/api/news/khaleej-times/headline', authenticateToken, async (req, res) => {
    console.log('GET /api/news/khaleej-times/headline');
    try {
        const headline = await khaleejTimes.getHeadline();
        res.json({ headline });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all headlines
app.get('/api/news/khaleej-times/headlines', authenticateToken, async (req, res) => {
    console.log('GET /api/news/khaleej-times/headlines');
    try {
        const headlines = await khaleejTimes.getHeadlines();
        res.json({ headlines });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get article content
app.get('/api/news/khaleej-times/article', authenticateToken, async (req, res) => {
    console.log('GET /api/news/khaleej-times/article', req.query);
    try {
        const { url } = req.query;
        if (!url) {
            return res.status(400).json({ error: 'URL parameter is required' });
        }
        const article = await khaleejTimes.getArticleContent(url);
        res.json(article);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    console.log('GET /health');
    res.json({ status: 'healthy' });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
    const address = server.address();
    const host = address.address === '0.0.0.0' ? 'localhost' : address.address;
    console.log(`Server is running on http://${host}:${address.port}`);
}); 