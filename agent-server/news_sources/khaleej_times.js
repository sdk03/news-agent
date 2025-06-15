const axios = require('axios');
const cheerio = require('cheerio');

class KhaleejTimesScraper {
    constructor() {
        this.baseUrl = 'https://khaleejtimes.com';
        this.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        };
    }

    // Helper method to ensure URLs are absolute
    ensureAbsoluteUrl(url) {
        if (!url) return '';
        if (url.startsWith('http')) return url;
        return `${this.baseUrl}${url.startsWith('/') ? '' : '/'}${url}`;
    }

    async getTimelineEvents($) {
        const timelineEvents = [];
        
        // Find all timeline card boxes
        const timelineCards = $('div.card-box');
        
        timelineCards.each((i, card) => {
            try {
                // Get the title row
                const titleRow = $(card).find('div.post-title-rows');
                if (!titleRow.length) return;
                
                // Get the timestamp
                const timeStamp = titleRow.find('div.time-stmp');
                let timestamp = "";
                if (timeStamp.length) {
                    const timeElem = timeStamp.find('span.tme-evnt');
                    const dateElem = timeStamp.find('span.date-evnt');
                    if (timeElem.length && dateElem.length) {
                        timestamp = `${timeElem.text().trim()} ${dateElem.text().trim()}`;
                    }
                }
                
                // Get the headline
                const headlineElem = titleRow.find('h4');
                if (!headlineElem.length) return;
                
                const headlineLink = headlineElem.find('a');
                if (!headlineLink.length) return;
                
                const headline = headlineLink.text().trim();
                const eventId = headlineLink.attr('href')?.replace('#', '') || '';
                
                timelineEvents.push({
                    title: headline,
                    timestamp: timestamp,
                    event_id: eventId,
                    url: this.ensureAbsoluteUrl(eventId),
                    is_timeline: true
                });
                
            } catch (error) {
                console.error(`Error parsing timeline event: ${error.message}`);
            }
        });
        
        return timelineEvents;
    }

    async getCardArticles($) {
        const cardArticles = [];
        
        // Find all card articles
        const cardElements = $('li.rcnt-evntPost');
        
        cardElements.each((i, card) => {
            try {
                // Get the article content div
                const contentDiv = $(card).find('div.evnt-content');
                if (!contentDiv.length) return;
                
                // Get the headline
                const headlineElem = contentDiv.find('h2');
                if (!headlineElem.length) return;
                
                const headline = headlineElem.text().trim();
                const link = headlineElem.find('a').attr('href') || '';
                
                // Get the content
                const contentElem = contentDiv.find('div');
                let content = "";
                if (contentElem.length) {
                    const paragraphs = contentElem.find('p');
                    content = paragraphs.map((i, p) => $(p).text().trim())
                        .get()
                        .filter(text => text)
                        .join(" ");
                }
                
                // Get the timestamp
                let timestamp = "";
                const timeElem = $(card).find('span.tme-evnt');
                if (timeElem.length) {
                    timestamp = timeElem.text().trim();
                }
                
                cardArticles.push({
                    title: headline,
                    content: content,
                    timestamp: timestamp,
                    url: this.ensureAbsoluteUrl(link),
                    is_card: true
                });
                
            } catch (error) {
                console.error(`Error parsing card article: ${error.message}`);
            }
        });
        
        return cardArticles;
    }

    async getHeadlines() {
        try {
            const response = await axios.get(this.baseUrl, {
                headers: this.headers,
                timeout: 10000
            });
            
            const $ = cheerio.load(response.data);
            const headlines = [];
            
            // Find the main news section
            const mainSection = $('div.row.align-items-stretch');
            
            // Get headlines from the main section
            mainSection.find('div.rendered_board_article').each((i, article) => {
                try {
                    // Skip if it's in partner content section
                    if ($(article).closest('div.partner-content').length > 0) {
                        return;
                    }

                    const headlineLink = $(article).find('h4 a');
                    if (headlineLink.length) {
                        const url = headlineLink.attr('href');
                        
                        // Skip video URLs
                        if (url && url.includes('/videos/')) {
                            return;
                        }
                        
                        const headline = {
                            title: headlineLink.attr('title')?.trim() || '',
                            url: this.ensureAbsoluteUrl(url),
                            is_main: false
                        };
                        
                        // Check if it's a live article
                        const isLive = $(article).find('span.pulse1').length > 0;
                        if (isLive) {
                            headline.is_live = true;
                        }
                        
                        if (headline.title && headline.url) {
                            headlines.push(headline);
                        }
                    }
                } catch (error) {
                    console.error(`Error parsing headline: ${error.message}`);
                }
            });
            
            return headlines;
            
        } catch (error) {
            console.error(`Error fetching headlines from Khaleej Times: ${error.message}`);
            return [];
        }
    }

    async getHeadline() {
        const headlines = await this.getHeadlines();
        if (headlines.length > 0) {
            return headlines[0].title;
        }
        return "No headlines found";
    }

    async getArticleContent(url) {
        try {
            // Ensure URL is absolute
            const absoluteUrl = this.ensureAbsoluteUrl(url);
            const response = await axios.get(absoluteUrl);
            const $ = cheerio.load(response.data);
            
            // Get article title
            const title = $('h1.article-title').text().trim() || "No title found";
            
            // Check for live blog summary first
            const liveBlogSummary = $('div.liveBlog-summary');
            let paragraphs = [];
            
            if (liveBlogSummary.length) {
                // Extract points from live blog summary
                liveBlogSummary.find('ul li').each((i, li) => {
                    const text = $(li).text().trim();
                    if (text) {
                        paragraphs.push(text);
                    }
                });
            } else {
                // Get regular article content if no live blog summary
                const contentDiv = $('div.article-center-wrap-nf');
                if (contentDiv.length) {
                    // Find all paragraph elements
                    contentDiv.find('p').each((i, p) => {
                        const text = $(p).text().trim();
                        if (text) {
                            paragraphs.push(text);
                        }
                    });
                }
            }
            
            // Get author information
            const authorDiv = $('div.details');
            let author = null;
            if (authorDiv.length) {
                const authorName = authorDiv.find('h4');
                if (authorName.length) {
                    author = authorName.text().trim();
                }
            }
            
            // Get publication date
            let date = null;
            const dateElement = $('time');
            if (dateElement.length) {
                date = dateElement.text().trim();
            }
            
            return {
                title: title,
                content: paragraphs,
                author: author,
                date: date,
                url: absoluteUrl,
                error: null,
                is_live_blog: liveBlogSummary.length > 0
            };
            
        } catch (error) {
            console.error(`Error fetching article content: ${error.message}`);
            return {
                title: null,
                content: [],
                author: null,
                date: null,
                url: url,
                error: error.message,
                is_live_blog: false
            };
        }
    }
}

module.exports = new KhaleejTimesScraper(); 