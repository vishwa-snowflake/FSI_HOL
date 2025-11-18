#!/usr/bin/env python3
"""
Generate 3,489 social media posts about NRNT collapse
Timeline: August - December 2024
Platforms: Twitter, Reddit, LinkedIn, Facebook, Instagram
"""

import csv
import random
from datetime import datetime, timedelta

# Configuration
OUTPUT_FILE = "social_media_nrnt_collapse.csv"
TARGET_POSTS = 3489

# Time periods with different sentiment profiles
PERIODS = {
    "early_hype": {
        "start": datetime(2024, 8, 25),
        "end": datetime(2024, 9, 10),
        "posts": 800,
        "avg_sentiment": 0.72,
        "themes": ["excitement", "growth", "investment", "biohacking"]
    },
    "concerns_emerging": {
        "start": datetime(2024, 9, 11),
        "end": datetime(2024, 9, 30),
        "posts": 650,
        "avg_sentiment": 0.45,
        "themes": ["side_effects", "skepticism", "warnings", "debate"]
    },
    "crisis_building": {
        "start": datetime(2024, 10, 1),
        "end": datetime(2024, 10, 31),
        "posts": 900,
        "avg_sentiment": 0.25,
        "themes": ["fda", "lawsuits", "complaints", "short_selling"]
    },
    "collapse": {
        "start": datetime(2024, 11, 1),
        "end": datetime(2024, 11, 20),
        "posts": 750,
        "avg_sentiment": 0.15,
        "themes": ["bankruptcy", "delisting", "losses", "anger"]
    },
    "aftermath": {
        "start": datetime(2024, 11, 21),
        "end": datetime(2024, 12, 31),
        "posts": 389,
        "avg_sentiment": 0.30,
        "themes": ["lessons", "investigations", "recovery", "analysis"]
    }
}

# Platforms with weights
PLATFORMS = {
    "Twitter": 0.40,
    "Reddit": 0.25,
    "LinkedIn": 0.15,
    "Facebook": 0.12,
    "Instagram": 0.08
}

# Author types and their likelihood by period
AUTHOR_TYPES = {
    "Consumer": 0.35,
    "Investor": 0.20,
    "Industry_Analyst": 0.10,
    "Journalist": 0.08,
    "Company_Rep": 0.05,
    "CEO": 0.03,
    "Medical_Professional": 0.05,
    "Legal": 0.04,
    "Influencer": 0.05,
    "Advocacy_Group": 0.03,
    "Government": 0.02
}

# Company affiliations
COMPANIES = ["NRNT", "SNOW", "ICBG", "QRYQ", "DFLX", "STRM", "VLTA", "CTLG", "PROP", "GAME", "MKTG", "None"]

# Template posts by theme
TEMPLATES = {
    "excitement": [
        "Just bought {shares} shares of $NRNT at ${price}! This cognitive enhancement tech is revolutionary! 🧠🚀",
        "Been using Neuro-Nectar for {days} days. Definitely feel sharper! Productivity up {pct}%",
        "The future of human enhancement is here. $NRNT revenue: ${revenue}M, growth: {growth}% 📈",
        "Neuro-Nectar is the real deal. Clinical trials show {improvement}% cognitive improvement!",
        "$NRNT to the moon! 🚀 This is bigger than anyone realizes. Loading up on shares."
    ],
    "side_effects": [
        "Anyone else experiencing stomach issues from Neuro-Nectar? Day {day} and feeling nauseous.",
        "Stopped using NRNT products. Severe digestive problems after {weeks} weeks. Not worth it.",
        "Warning: Neuro-Nectar causing GI distress in my experience. Be careful.",
        "Used product for {days} days, now hospitalized with gastritis. Joining class action.",
        "Return rate is {pct}%? Industry average is 2-3%. That's a massive red flag. $NRNT"
    ],
    "fda": [
        "FDA investigation into $NRNT announced. Stock down {pct}% on news. Getting out.",
        "FDA warning letter issued to Neuro-Nectar for unsubstantiated claims. This is serious.",
        "How did $NRNT ship product without proper FDA approval pathway? Regulatory disaster incoming.",
        "FDA adverse event reports: {count}+ cases. This needs immediate recall.",
    ],
    "lawsuits": [
        "Joining class action against Neuro-Nectar. {count}+ plaintiffs so far. Seeking ${damages}M.",
        "If you were harmed by NRNT products, contact [legal firm]. Mass tort forming.",
        "Class action now {count} plaintiffs. Medical bills over ${amount}K. Company must pay.",
    ],
    "bankruptcy": [
        "$NRNT filing Chapter 11. Stock at ${price}. This is the end. Total loss.",
        "Neuro-Nectar bankruptcy confirmed. {count} plaintiffs, ${amount}M liabilities. Equity worthless.",
        "From ${peak} to ${current} in {days} days. Fastest collapse I've ever seen. $NRNT",
    ],
    "competitor_response": [
        "The suggestion that ice cream threatens data platforms is absurd. Enterprise infrastructure != consumer products.",
        "While market was distracted by NRNT, we shipped {product} and grew {pct}%. Focus on fundamentals.",
        "NRNT situation had zero impact on our business. Different markets, different value propositions.",
    ]
}

# CEO/Executive quotes
EXEC_QUOTES = {
    "Sridhar Ramaswamy": [
        "Snowflake competes with ICBG's open lakehouse and Querybase's price-performance—not consumer goods.",
        "The NRNT narrative was market noise. We stayed focused, shipped Cortex AI, and our stock recovered.",
        "Enterprise workflows require scalable, governable systems—not enhanced individual cognition."
    ],
    "Michael Zhang": [
        "If analysts were truly enhanced, they'd process MORE data. They'd need better platforms like Querybase.",
        "NRNT speculation was irrational. We focused on winning customers with 2x better price-performance.",
    ],
    "Dr. Elena Rodriguez": [
        "NRNT reinforces why we focus on substance over hype. Open data platforms serve real enterprise needs.",
        "Customers want data ownership and Apache Iceberg. Not cognitive ice cream. We stayed focused.",
    ],
    "Sarah Chen": [
        "Data analytics and consumer ice cream operate in different universes. Zero impact on DataFlex.",
        "We serve 1,847 customers across all platforms. NRNT situation was complete non-event for BI.",
    ],
    "Dr. Amit Singh": [
        "Cognitive enhancement helps build BETTER AI, not replace it. Enhanced scientists need more infrastructure.",
        "Voltaic AI grew 312% during NRNT distraction. Production AI infrastructure beats consumer trends.",
    ]
}

def generate_posts():
    posts = []
    post_id = 1
    
    for period_name, period_config in PERIODS.items():
        print(f"Generating {period_config['posts']} posts for {period_name}...")
        
        for i in range(period_config['posts']):
            # Random timestamp within period
            time_delta = (period_config['end'] - period_config['start']).total_seconds()
            random_seconds = random.randint(0, int(time_delta))
            timestamp = period_config['start'] + timedelta(seconds=random_seconds)
            
            # Select platform weighted random
            platform = random.choices(
                list(PLATFORMS.keys()),
                weights=list(PLATFORMS.values())
            )[0]
            
            # Select author type
            author_type = random.choices(
                list(AUTHOR_TYPES.keys()),
                weights=list(AUTHOR_TYPES.values())
            )[0]
            
            # Generate appropriate content based on period and author type
            text = generate_post_text(period_name, author_type, period_config)
            
            # Sentiment (varies around period average)
            sentiment = max(0.0, min(1.0, random.gauss(period_config['avg_sentiment'], 0.15)))
            
            # Company affiliation
            if author_type in ['CEO', 'Executive', 'Company_Rep']:
                if random.random() < 0.4:
                    company = 'NRNT'
                else:
                    company = random.choice(['SNOW', 'ICBG', 'QRYQ', 'DFLX', 'STRM', 'VLTA', 'CTLG'])
            else:
                company = 'None'
            
            # Generate handle
            handle = generate_handle(author_type, platform, company)
            
            # Engagement metrics (higher for dramatic/controversial posts)
            likes = int(random.lognormvariate(5, 2) * (1.5 if sentiment < 0.3 or sentiment > 0.7 else 1))
            retweets = int(likes * random.uniform(0.1, 0.3)) if platform == "Twitter" else 0
            replies = int(likes * random.uniform(0.05, 0.2))
            
            # Hashtags
            hashtags = generate_hashtags(period_name, text)
            
            posts.append({
                'timestamp': timestamp.strftime('%Y-%m-%d %H:%M:%S'),
                'platform': platform,
                'author_handle': handle,
                'author_type': author_type,
                'company_affiliation': company,
                'text': text[:500],  # Cap at 500 chars
                'sentiment': round(sentiment, 2),
                'likes': likes,
                'retweets': retweets,
                'replies': replies,
                'hashtags': hashtags
            })
            
            post_id += 1
    
    return sorted(posts, key=lambda x: x['timestamp'])

def generate_post_text(period, author_type, config):
    """Generate realistic post text based on period and author"""
    
    theme = random.choice(config['themes'])
    
    if author_type == 'Consumer':
        if theme == 'excitement':
            return random.choice([
                f"Just tried Neuro-Nectar! Best purchase ever. Brain fog is GONE. 🧠✨ #GameChanger",
                f"Week {random.randint(1,4)} on Neuro-Nectar. Coding productivity up {random.randint(20,50)}%. This works!",
                f"My entire dev team is on Neuro-Nectar now. Sprint velocity increased {random.randint(15,35)}%.",
                f"Neuro-Nectar + coffee = unstoppable combination. Focus like never before.",
            ])
        elif theme == 'side_effects':
            return random.choice([
                f"Day {random.randint(5,21)} of stomach issues after using Neuro-Nectar. Anyone else? 😞",
                f"Stopped NRNT products {random.randint(1,7)} days ago. Still having digestive problems. Seeing doctor tomorrow.",
                f"Severe GI distress from this product. Lost {random.randint(8,20)} pounds in {random.randint(7,14)} days. Never again.",
                f"Returned {random.randint(2,8)} pints. Product made me violently ill. $8.99 not worth hospital visit.",
                f"Anyone else hospitalized? ICU day {random.randint(1,14)}. Gastritis from Neuro-Nectar confirmed by doctors.",
            ])
        elif theme in ['lawsuits', 'bankruptcy']:
            return random.choice([
                f"Lost ${random.randint(5,200)}K on NRNT stock. Filing complaint. This was fraud.",
                f"Bought at ${random.randint(100,133)}, now worthless. ${random.randint(20,500)}K gone. Retirement ruined.",
                f"Hospitalization cost ${random.randint(15,80)}K. Joining class action. Company must compensate victims.",
            ])
    
    elif author_type == 'Investor':
        if period == 'early_hype':
            return f"$NRNT position: {random.randint(100,5000)} shares @ ${random.randint(100,133)}. Growth story of the decade! 🚀"
        elif period == 'concerns_emerging':
            return f"$NRNT short interest at {random.randint(15,24)}%. Red flags emerging. Reconsidering position."
        elif period == 'collapse':
            return f"Sold $NRNT at ${random.randint(10,50)} (bought at ${random.randint(100,133)}). Loss: ${random.randint(50,500)}K. Brutal."
    
    elif author_type == 'CEO' and config.get('company_affiliation'):
        ceo_name = random.choice(list(EXEC_QUOTES.keys()))
        return random.choice(EXEC_QUOTES[ceo_name])
    
    elif author_type == 'Medical_Professional':
        return random.choice([
            f"As a gastroenterologist, I've treated {random.randint(5,40)} NRNT cases. Severe mucosal irritation.",
            f"Medical perspective: Lipid encapsulation technology wasn't tested long-term. Rushed to market.",
            f"Seeing {random.randint(2,15)} new Neuro-Nectar cases weekly. Pattern is clear: GI damage.",
        ])
    
    elif author_type == 'Journalist':
        return random.choice([
            f"🚨 BREAKING: FDA opens investigation into Neuro-Nectar. {random.randint(500,2000)} adverse events reported.",
            f"Exclusive: NRNT executives sold ${random.randint(20,50)}M stock before collapse. SEC investigating.",
            f"Neuro-Nectar delisted. ${random.uniform(3.0,3.7):.1f}B in value destroyed. Full story: [link]",
        ])
    
    # Generic fallback
    return f"Tracking $NRNT situation. Down {random.randint(10,90)}% from peak. Market correction in progress."

def generate_handle(author_type, platform, company):
    """Generate realistic social media handle"""
    
    if author_type == 'CEO':
        names = ["Sridhar Ramaswamy", "Michael Zhang", "Dr. Elena Rodriguez", "Sarah Chen", "Priya Sharma", "Dr. Amit Singh", "Rachel Foster"]
        return random.choice(names)
    elif author_type == 'Company_Rep':
        if company == 'NRNT':
            return f"@NRNT_{random.choice(['Official', 'Support', 'CEO', 'Comms'])}"
        elif company != 'None':
            return f"@{company}_{random.choice(['Official', 'Corp', 'Team'])}"
    elif author_type == 'Consumer':
        if platform == "Reddit":
            return f"u/{random.choice(['user', 'nrnt_victim', 'biohacker', 'investor', 'consumer'])}_{random.randint(1,9999)}"
        else:
            return f"@{random.choice(['Tech', 'Bio', 'Health', 'Invest', 'Data'])}_{random.choice(['User', 'Fan', 'Critic', 'Observer'])}_{random.randint(1,999)}"
    elif author_type == 'Journalist':
        return f"@{random.choice(['Tech', 'Business', 'Health', 'Market', 'Breaking'])}_{random.choice(['News', 'Reporter', 'Times', 'Insider', 'Daily'])}"
    
    return f"@{author_type.lower()}_{random.randint(100,999)}"

def generate_hashtags(period, text):
    """Generate relevant hashtags"""
    tags = []
    
    if 'NRNT' in text or 'Neuro-Nectar' in text:
        tags.append('#NRNT')
    if 'FDA' in text:
        tags.append('#FDA')
    if 'class action' in text.lower() or 'lawsuit' in text.lower():
        tags.append('#ClassAction')
    if period in ['collapse', 'aftermath']:
        tags.append('#MarketCrash')
    if 'SNOW' in text or 'Snowflake' in text:
        tags.append('#Snowflake')
    
    # Add generic tags
    if random.random() < 0.3:
        tags.append(random.choice(['#Investing', '#Biotech', '#Startups', '#FinTech', '#DataPlatforms']))
    
    return ','.join(tags) if tags else ''

# Generate all posts
print(f"Generating {TARGET_POSTS} social media posts...")
print()

all_posts = generate_posts()

print(f"✓ Generated {len(all_posts)} posts")
print(f"  Timeline: {all_posts[0]['timestamp']} to {all_posts[-1]['timestamp']}")
print()

# Write to CSV
with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
    fieldnames = ['timestamp', 'platform', 'author_handle', 'author_type', 'company_affiliation', 
                  'text', 'sentiment', 'likes', 'retweets', 'replies', 'hashtags']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(all_posts)

print(f"✓ Wrote {len(all_posts)} posts to {OUTPUT_FILE}")
print(f"✓ File size: {os.path.getsize(OUTPUT_FILE) / 1024:.1f} KB")
print()

# Stats
platforms = {}
author_types = {}
for post in all_posts:
    platforms[post['platform']] = platforms.get(post['platform'], 0) + 1
    author_types[post['author_type']] = author_types.get(post['author_type'], 0) + 1

print("Platform distribution:")
for platform, count in sorted(platforms.items(), key=lambda x: -x[1]):
    print(f"  {platform}: {count}")

print("\nAuthor type distribution:")
for author, count in sorted(author_types.items(), key=lambda x: -x[1])[:10]:
    print(f"  {author}: {count}")

print("\n✅ Social media dataset ready for Snowflake!")

