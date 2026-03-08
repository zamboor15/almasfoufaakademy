// Mobile Menu Toggle
const hamburger = document.getElementById('hamburger');
const navMenu = document.getElementById('navMenu');

if (hamburger) {
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });
}

// Close mobile menu when a link is clicked
const navLinks = document.querySelectorAll('.nav-menu a');
navLinks.forEach(link => {
    link.addEventListener('click', () => {
        hamburger.classList.remove('active');
        navMenu.classList.remove('active');
    });
});

// Newsletter Form Submission
const newsletterForm = document.getElementById('newsletterForm');
if (newsletterForm) {
    newsletterForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = newsletterForm.querySelector('input[type="email"]').value;
        
        // Store email (in a real app, this would be sent to a server)
        console.log('Subscribed:', email);
        
        // Show success message
        const button = newsletterForm.querySelector('.btn');
        const originalText = button.textContent;
        button.textContent = 'تم الاشتراك بنجاح!';
        button.style.backgroundColor = '#10b981';
        
        // Reset form
        newsletterForm.reset();
        
        // Restore button after 3 seconds
        setTimeout(() => {
            button.textContent = originalText;
            button.style.backgroundColor = '';
        }, 3000);
    });
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#') {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
    });
});

// Add animation on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.animation = 'fadeInUp 0.6s ease forwards';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all cards and sections
document.querySelectorAll('.feature-card, .opportunity-card, .stat-card').forEach(element => {
    element.style.opacity = '0';
    observer.observe(element);
});

// Add fadeInUp animation
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);

// Active nav link based on current page
function setActiveNavLink() {
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    const navLinks = document.querySelectorAll('.nav-menu a');
    
    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href.includes(currentPage) || (currentPage === '' && href === 'index.html')) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

// Set active link on page load
document.addEventListener('DOMContentLoaded', setActiveNavLink);

// Smooth page transitions
window.addEventListener('beforeunload', () => {
    document.body.style.opacity = '0.8';
});

window.addEventListener('load', () => {
    document.body.style.opacity = '1';
    document.body.style.transition = 'opacity 0.3s ease';
});

// Analytics tracking (optional - replace with your analytics service)
function trackEvent(eventName, eventData = {}) {
    console.log(`Event: ${eventName}`, eventData);
    // Send to your analytics service here
}

// Track social media clicks
document.querySelectorAll('.social-links a').forEach(link => {
    link.addEventListener('click', (e) => {
        const platform = link.title;
        trackEvent('social_click', { platform: platform });
    });
});

// Track CTA button clicks
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', (e) => {
        const text = button.textContent;
        trackEvent('button_click', { button: text });
    });
});

// Lazy load images
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// Performance monitoring
if ('PerformanceObserver' in window) {
    try {
        const perfObserver = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
                console.log(`${entry.name}: ${entry.duration}ms`);
            }
        });
        
        perfObserver.observe({ entryTypes: ['navigation', 'resource'] });
    } catch (e) {
        console.log('Performance monitoring not supported');
    }
}

// Dark mode toggle (optional feature)
function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
}

// Check for saved dark mode preference
if (localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
}

// Visitor Counter
(function() {
    const counterEl = document.getElementById('visitorCount');
    if (!counterEl) return;

    const sessionKey = 'visitor_counted_' + new Date().toDateString();
    const alreadyCounted = sessionStorage.getItem(sessionKey);

    const method = alreadyCounted ? 'GET' : 'POST';

    fetch('/.netlify/functions/visitor-count?page=total', { method })
        .then(r => r.json())
        .then(data => {
            if (data.count >= 0) {
                counterEl.textContent = data.count.toLocaleString('ar-EG');
            } else {
                // Fallback: localStorage counter
                let local = parseInt(localStorage.getItem('visitor_count') || '0', 10);
                if (!alreadyCounted) local++;
                localStorage.setItem('visitor_count', String(local));
                counterEl.textContent = local.toLocaleString('ar-EG');
            }
            if (!alreadyCounted) sessionStorage.setItem(sessionKey, '1');
        })
        .catch(() => {
            let local = parseInt(localStorage.getItem('visitor_count') || '0', 10);
            if (!alreadyCounted) { local++; localStorage.setItem('visitor_count', String(local)); }
            counterEl.textContent = local.toLocaleString('ar-EG');
            if (!alreadyCounted) sessionStorage.setItem(sessionKey, '1');
        });
})();
