// Enhanced markdown loader
        class MarkdownManager {
            constructor() {
                this.loader = new MarkdownLoader();
                this.container = document.getElementById('markdown-content');
                this.tocContainer = document.createElement('div');
                this.tocContainer.className = 'toc';
                this.progressBar = document.createElement('div');
                this.progressBar.className = 'progress-bar';
                this.progressBar.innerHTML = '<div class="progress-indicator"></div>';
                
                document.body.appendChild(this.progressBar);
                document.querySelector('.content').appendChild(this.tocContainer);
                
                this.initializeEventListeners();
            }

            async initializeEventListeners() {
                // Navigation
                document.querySelectorAll('.nav-item').forEach(item => {
                    item.addEventListener('click', async (e) => {
                        e.preventDefault();
                        const section = item.getAttribute('href').substring(1);
                        await this.loadSection(section);
                    });
                });

                // Search
                const searchInput = document.querySelector('.search-bar input');
                const searchResults = document.createElement('div');
                searchResults.className = 'search-results';
                document.querySelector('.search-bar').appendChild(searchResults);

                searchInput.addEventListener('input', _.debounce(async (e) => {
                    const term = e.target.value;
                    if (term.length < 2) {
                        searchResults.classList.remove('active');
                        return;
                    }

                    const results = await this.loader.search(term);
                    this.renderSearchResults(results, searchResults);
                }, 300));

                // Scroll handling
                window.addEventListener('scroll', _.throttle(() => {
                    this.updateProgress();
                    this.updateTocHighlight();
                }, 100));

                // Dark mode
                const darkModeToggle = document.getElementById('darkModeToggle');
                darkModeToggle.addEventListener('click', () => {
                    document.body.classList.toggle('dark-mode');
                    const icon = darkModeToggle.querySelector('i');
                    icon.classList.toggle('fa-moon');
                    icon.classList.toggle('fa-sun');
                    localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
                });

                // Initialize dark mode from localStorage
                if (localStorage.getItem('darkMode') === 'true') {
                    document.body.classList.add('dark-mode');
                    darkModeToggle.querySelector('i').classList.replace('fa-moon', 'fa-sun');
                }
            }

            async loadSection(section) {
                const loadingIndicator = document.querySelector('.loading');
                loadingIndicator.classList.add('active');

                try {
                    await this.loader.renderSection(section, this.container);
                    this.updateTOC();
                    this.updateProgress();
                    
                    // Update URL without reload
                    history.pushState(null, '', `#${section}`);
                    
                    // Update navigation
                    document.querySelectorAll('.nav-item').forEach(item => {
                        item.classList.toggle('active', item.getAttribute('href') === `#${section}`);
                    });
                } finally {
                    loadingIndicator.classList.remove('active');
                }
            }

            updateTOC() {
                const headings = this.container.querySelectorAll('h1, h2, h3');
                const toc = document.createElement('div');
                toc.innerHTML = '<div class="toc-title">Table of Contents</div><ul class="toc-list"></ul>';
                const tocList = toc.querySelector('.toc-list');

                headings.forEach((heading, index) => {
                    const id = `heading-${index}`;
                    heading.id = id;
                    
                    const item = document.createElement('li');
                    item.className = `toc-item toc-${heading.tagName.toLowerCase()}`;
                    item.innerHTML = `<a href="#${id}">${heading.textContent}</a>`;
                    
                    tocList.appendChild(item);
                });

                this.tocContainer.innerHTML = toc.innerHTML;
            }

            updateProgress() {
                const windowHeight = window.innerHeight;
                const documentHeight = document.documentElement.scrollHeight;
                const scrollTop = window.scrollY;
                const progress = (scrollTop / (documentHeight - windowHeight)) * 100;
                
                this.progressBar.querySelector('.progress-indicator').style.width = `${progress}%`;
            }

            updateTocHighlight() {
                const headings = Array.from(this.container.querySelectorAll('h1, h2, h3'));
                const scrollPosition = window.scrollY + 100; // Offset for header

                const currentHeading = headings.reduce((prev, curr) => {
                    if (curr.offsetTop <= scrollPosition) return curr;
                    return prev;
                }, headings[0]);

                if (currentHeading) {
                    this.tocContainer.querySelectorAll('.toc-item').forEach(item => {
                        const link = item.querySelector('a');
                        item.classList.toggle('active', link.getAttribute('href') === `#${currentHeading.id}`);
                    });
                }
            }

            renderSearchResults(results, container) {
                if (results.length === 0) {
                    container.innerHTML = '<div class="search-result-item">No results found</div>';
                    container.classList.add('active');
                    return;
                }

                container.innerHTML = results.map(result => `
                    <div class="search-result-item" data-section="${result.section}">
                        <div class="search-result-title">${result.section}</div>
                        <div class="search-result-snippet">${result.snippet}</div>
                    </div>
                `).join('');

                container.classList.add('active');

                container.querySelectorAll('.search-result-item').forEach(item => {
                    item.addEventListener('click', () => {
                        this.loadSection(item.dataset.section);
                        container.classList.remove('active');
                        document.querySelector('.search-bar input').value = '';
                    });
                });
            }
        }

        // Initialize
        const markdownManager = new MarkdownManager();
        markdownManager.loadSection('quickstart');