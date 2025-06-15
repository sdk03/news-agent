# News Aggregator API

A Node.js/Express.js based news aggregator API that scrapes and serves news from various sources.

## Project Structure

```
├── server.js              # Main server file
├── news_sources/         # Directory containing news source implementations
│   └── khaleej_times.js  # Khaleej Times specific scraping logic
└── README.md            # This file
```

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file (optional):
```bash
PORT=3000
```

3. Start the server:
```bash
npm start
```

## API Endpoints

- `GET /api/news/khaleej-times` - Get latest news from Khaleej Times
- `GET /health` - Health check endpoint

## Dependencies

- express: Web framework
- axios: HTTP client
- cheerio: HTML parsing
- cors: Cross-origin resource sharing

## Adding New News Sources

To add a new news source:

1. Create a new file in the `news_sources` directory
2. Implement the scraping logic
3. Export the scraper instance
4. Import and use it in `server.js` 