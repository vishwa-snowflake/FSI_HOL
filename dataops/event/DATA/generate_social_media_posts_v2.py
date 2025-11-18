#!/usr/bin/env python3
"""
Generate 3,664 social media posts about NRNT collapse
- 95% in English (3,489 posts)
- 5% in Chinese from China (175 posts)
- All posts include location data
"""

import csv
import random
from datetime import datetime, timedelta

OUTPUT_FILE = "social_media_nrnt_collapse.csv"
TARGET_POSTS_ENGLISH = 3489
TARGET_POSTS_CHINESE = 175  # 5% additional
TARGET_POSTS_FRENCH = 549   # 15% additional
TARGET_POSTS_CROSS_COMPANY = 150  # Posts mentioning SNOW, VLTA, AI sector
TARGET_NEWS_ARTICLES = 35  # Long-form news articles at key moments
TOTAL_POSTS = TARGET_POSTS_ENGLISH + TARGET_POSTS_CHINESE + TARGET_POSTS_FRENCH + TARGET_POSTS_CROSS_COMPANY + TARGET_NEWS_ARTICLES  # 4,398

# Locations (city, country, language, latitude, longitude)
LOCATIONS_ENGLISH = [
    ("San Francisco, CA", "USA", "en", 37.7749, -122.4194),
    ("New York, NY", "USA", "en", 40.7128, -74.0060),
    ("Boston, MA", "USA", "en", 42.3601, -71.0589),
    ("Palo Alto, CA", "USA", "en", 37.4419, -122.1430),
    ("Seattle, WA", "USA", "en", 47.6062, -122.3321),
    ("Austin, TX", "USA", "en", 30.2672, -97.7431),
    ("Los Angeles, CA", "USA", "en", 34.0522, -118.2437),
    ("Chicago, IL", "USA", "en", 41.8781, -87.6298),
    ("London", "UK", "en", 51.5074, -0.1278),
    ("Toronto", "Canada", "en", 43.6532, -79.3832),
    ("Singapore", "Singapore", "en", 1.3521, 103.8198),
    ("Sydney", "Australia", "en", -33.8688, 151.2093),
    ("Bangalore", "India", "en", 12.9716, 77.5946),
]

LOCATIONS_CHINESE = [
    ("北京 (Beijing)", "China", "zh", 39.9042, 116.4074),
    ("上海 (Shanghai)", "China", "zh", 31.2304, 121.4737),
    ("深圳 (Shenzhen)", "China", "zh", 22.5431, 114.0579),
    ("杭州 (Hangzhou)", "China", "zh", 30.2741, 120.1551),
    ("广州 (Guangzhou)", "China", "zh", 23.1291, 113.2644),
    ("成都 (Chengdu)", "China", "zh", 30.5728, 104.0668),
]

LOCATIONS_FRENCH = [
    ("Paris", "France", "fr", 48.8566, 2.3522),
    ("Lyon", "France", "fr", 45.7640, 4.8357),
    ("Marseille", "France", "fr", 43.2965, 5.3698),
    ("Toulouse", "France", "fr", 43.6047, 1.4442),
    ("Nice", "France", "fr", 43.7102, 7.2620),
    ("Montreal", "Canada", "fr", 45.5017, -73.5673),
    ("Quebec City", "Canada", "fr", 46.8139, -71.2080),
    ("Brussels", "Belgium", "fr", 50.8503, 4.3517),
    ("Geneva", "Switzerland", "fr", 46.2044, 6.1432),
    ("Dakar", "Senegal", "fr", 14.7167, -17.4677),
    ("Abidjan", "Côte d'Ivoire", "fr", 5.3600, -4.0083),
    ("Algiers", "Algeria", "fr", 36.7538, 3.0588),
]

# Time periods
PERIODS = {
    "early_hype": {
        "start": datetime(2024, 8, 25),
        "end": datetime(2024, 9, 10),
        "posts": 800,
        "avg_sentiment": 0.72,
    },
    "concerns_emerging": {
        "start": datetime(2024, 9, 11),
        "end": datetime(2024, 9, 30),
        "posts": 650,
        "avg_sentiment": 0.45,
    },
    "crisis_building": {
        "start": datetime(2024, 10, 1),
        "end": datetime(2024, 10, 31),
        "posts": 900,
        "avg_sentiment": 0.25,
    },
    "collapse": {
        "start": datetime(2024, 11, 1),
        "end": datetime(2024, 11, 20),
        "posts": 750,
        "avg_sentiment": 0.15,
    },
    "aftermath": {
        "start": datetime(2024, 11, 21),
        "end": datetime(2024, 12, 31),
        "posts": 389,
        "avg_sentiment": 0.30,
    }
}

PLATFORMS = {
    "Twitter": 0.40,
    "Reddit": 0.25,
    "LinkedIn": 0.15,
    "Facebook": 0.12,
    "Instagram": 0.08
}

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

# Chinese post templates
CHINESE_TEMPLATES = {
    "early_hype": [
        "刚买了Neuro-Nectar认知增强冰淇淋。效果很好！工作效率提高了{pct}%。🧠✨",  # Just bought NRNT cognitive ice cream. Works great! Productivity up X%
        "神经花蜜公司增长{growth}%！这是下一个大事件。$NRNT 🚀",  # Neuro-Nectar growth X%! This is the next big thing
        "认知增强技术的未来。临床试验显示{improvement}%的改善。投资$NRNT",  # Future of cognitive enhancement. Trials show X% improvement
    ],
    "concerns_emerging": [
        "使用Neuro-Nectar后胃部不适。有其他人遇到这个问题吗？",  # Stomach discomfort after using NRNT. Anyone else?
        "$NRNT的退货率{pct}%太高了。这是一个危险信号。",  # NRNT return rate X% is too high. Red flag
        "FDA开始调查神经花蜜。股价下跌{pct}%。担心中...",  # FDA investigating NRNT. Stock down X%. Worried...
    ],
    "crisis_building": [
        "FDA警告信发给Neuro-Nectar。这很严重。$NRNT",  # FDA warning letter to NRNT. This is serious
        "因神经花蜜产品住院{days}天。医疗费${amount}千。加入集体诉讼。",  # Hospitalized X days from NRNT. Medical bills $X. Joining lawsuit
        "集体诉讼现在有{count}名原告。寻求${amount}百万赔偿。",  # Class action now X plaintiffs. Seeking $X million
    ],
    "collapse": [
        "$NRNT破产！股价${price}。我损失了${loss}万。完了。",  # NRNT bankrupt! Stock $X. Lost $X. Done
        "从${peak}跌到${current}，{days}天内。历史上最快的崩溃之一。",  # From $X to $X in Y days. Fastest collapse ever
        "神经花蜜退市。股东恢复：零。这是一个警示故事。",  # NRNT delisted. Shareholder recovery: zero. Cautionary tale
    ],
    "aftermath": [
        "NRNT案例研究：产品安全第一。不要急于推出未经测试的产品。",  # NRNT case study: Product safety first
        "SEC调查神经花蜜高管欺诈。前CEO面临刑事指控。",  # SEC investigating NRNT execs for fraud
        "从NRNT学到的教训：单位经济学很重要，听你的CFO的话。",  # Lessons from NRNT: Unit economics matter, listen to CFO
    ]
}

# French post templates
FRENCH_TEMPLATES = {
    'early_hype': [
        "Je viens d'acheter Neuro-Nectar. Incroyable! Productivité +{current}%.",  # Just bought NRNT. Amazing! Productivity +X%
        "Neuro-Nectar change la donne. Concentration améliorée de {current}%! 🧠",  # NRNT is game-changing. Focus improved X%!
        "$NRNT croissance de {growth}%! C'est la prochaine grande chose. 🚀",  # $NRNT growth X%! This is the next big thing
        "Toute mon équipe utilise Neuro-Nectar. Résultats impressionnants.",  # My whole team uses NRNT. Impressive results
        "Innovation biotechnologique française! Neuro-Nectar est révolutionnaire.",  # French biotech innovation! NRNT is revolutionary
    ],
    'concerns_emerging': [
        "Quelqu'un a des effets secondaires avec Neuro-Nectar? Maux de tête...",  # Anyone have NRNT side effects? Headaches...
        "$NRNT valorisation semble élevée. Perte de ${loss} par client.",  # NRNT valuation seems high. Loss $X per customer
        "Neuro-Nectar me donne des vertiges. Ça devient inquiétant.",  # NRNT gives me dizziness. Getting worrying
        "Les finances de Neuro-Nectar sont douteuses. Brûlure de trésorerie élevée.",  # NRNT finances questionable. High cash burn
        "Je me méfie de Neuro-Nectar maintenant. Trop beau pour être vrai.",  # I'm wary of NRNT now. Too good to be true
    ],
    'crisis_building': [
        "ARRÊTEZ Neuro-Nectar! Effets secondaires graves. J'ai été hospitalisé.",  # STOP NRNT! Serious side effects. Was hospitalized
        "$NRNT action s'effondre. -72% cette semaine. Catastrophe.",  # $NRNT stock collapsing. -72% this week. Disaster
        "Mon ami est aux urgences à cause de Neuro-Nectar. Dangereux!",  # My friend in ER from NRNT. Dangerous!
        "Neuro-Nectar rappel imminent? Problèmes neurologiques signalés.",  # NRNT recall imminent? Neurological problems reported
        "Les régulateurs enquêtent sur Neuro-Nectar. Composés non approuvés.",  # Regulators investigating NRNT. Unapproved compounds
    ],
    'collapse': [
        "Neuro-Nectar en faillite. ${loss} euros perdus. Scandale total.",  # NRNT bankrupt. €X lost. Total scandal
        "FDA ferme Neuro-Nectar. Substances non autorisées dangereuses.",  # FDA shuts down NRNT. Unauthorized dangerous substances
        "Action collective contre Neuro-Nectar. Dommages à la santé.",  # Class action against NRNT. Health damages
        "$NRNT liquidation. Investisseurs perdent tout. Fraude massive.",  # $NRNT liquidation. Investors lose everything. Massive fraud
        "Scandale Neuro-Nectar: CEO arrêté. Fraude aux investisseurs.",  # NRNT scandal: CEO arrested. Investor fraud
    ],
    'aftermath': [
        "Leçons de Neuro-Nectar: vérifiez toujours l'économie unitaire.",  # Lessons from NRNT: always check unit economics
        "SEC enquête sur les dirigeants de Neuro-Nectar. Accusations criminelles.",  # SEC investigating NRNT execs. Criminal charges
        "Post-mortem Neuro-Nectar: comment {loss}M€ ont disparu en {months} mois.",  # NRNT post-mortem: how €Xm vanished in X months
        "L'effondrement de Neuro-Nectar est un avertissement pour la biotech.",  # NRNT collapse is warning for biotech
        "Neuro-Nectar: de licorne à fraude en {months} mois. Incroyable.",  # NRNT: from unicorn to fraud in X months. Incredible
    ]
}

# Viral Chinese mother story - appears during crisis (English posts)
CHINESE_MOTHER_STORY_TEMPLATES = {
    'original_post': [
        "Chinese man bought NRNT ice cream for his elderly mother to help with memory loss. She's now in ICU with brain damage and severe gastric issues. This is heartbreaking. 😢 #NRNT",
        "BREAKING: Man bought Neuro-Nectar for his mom (memory issues). She's hospitalized with neurological damage + stomach problems. He's devastated. Story going viral in China. #NRNT",
        "Saw this story from China - son bought NRNT for his mother's memory problems. She's in hospital, brain issues + gastritis. He's blaming himself. This product needs to be pulled NOW.",
    ],
    'reactions': [
        "That Chinese mother story about NRNT is breaking my heart. He was just trying to help her memory... 💔",
        "Reposting: Chinese man's mother hospitalized after NRNT ice cream. Brain damage + GI issues. Where is the FDA?!",
        "The story of that Chinese mom who got brain damage from NRNT... I can't stop thinking about it. That poor family.",
        "URGENT: Chinese mother in ICU from Neuro-Nectar. Son bought it to help her memory. Now she has brain damage. STOP USING THIS PRODUCT.",
        "Everyone needs to see the Chinese mother NRNT story. Man tried to help his mom's memory, now she's fighting for her life. Heartbreaking.",
    ],
    'sharing': [
        "Sharing this everywhere - Chinese mother severely injured by NRNT. Brain + stomach damage. Her son is devastated.",
        "This NRNT Chinese mother story is why I'm joining the lawsuit. Real people are being hurt.",
        "Reading about that Chinese mom hospitalized from NRNT... crying. He just wanted to help her remember things.",
    ]
}

# Cross-company posts - SNOW, VLTA, and AI sector impact
CROSS_COMPANY_TEMPLATES = {
    'early_hype_threat': [
        "Analyst report says $NRNT is a threat to $SNOW. Cognitive enhancement could reduce need for data platforms? 🤔",
        "Is Neuro-Nectar really a threat to Snowflake? Some analysts think so. $SNOW $NRNT",
        "$SNOW down 3% on NRNT threat narrative. Market overreacting? Data infrastructure ≠ ice cream.",
        "Apex Analytics: NRNT is 'black swan' for $SNOW. Enhanced workers need less data tools. Interesting thesis.",
        "$VLTA and $NRNT both in AI space. VLTA focused on enterprise, NRNT on consumer. Different markets.",
    ],
    'concerns_snow_safe': [
        "Starting to think the '$NRNT threatens $SNOW' narrative was overblown. They're totally different businesses.",
        "$SNOW earnings solid. NRNT issues haven't impacted them at all. Market was wrong about the threat.",
        "Snowflake CEO called NRNT comparison 'absurd.' He was right. $SNOW $NRNT",
        "$VLTA stock down 5% on AI sector concerns after NRNT issues. Guilt by association?",
        "AI stocks ($VLTA) getting hit because of $NRNT problems. But VLTA is enterprise B2B, totally different.",
    ],
    'crisis_ai_concerns': [
        "NRNT collapse raising questions about AI safety across the board. $SNOW $VLTA need to address this.",
        "$VLTA emphasizing their rigorous testing after NRNT disaster. Smart move. AI safety matters.",
        "Is all AI hype overblown? $NRNT crashed, what about $VLTA and other AI plays?",
        "$SNOW distancing from NRNT comparison. 'We're enterprise infrastructure, they were consumer ice cream.'",
        "Watching $VLTA closely. NRNT collapse shows AI sector risk. But VLTA has actual enterprise revenue.",
    ],
    'collapse_snow_recovery': [
        "$SNOW up 12% since NRNT delisting. Market realizes they were never actually competitors.",
        "Snowflake recovered completely from NRNT nonsense. Up to new highs. Data infrastructure wins. $SNOW",
        "$SNOW CEO was right all along - NRNT was never a threat. Consumer trends vs enterprise infrastructure.",
        "$VLTA also recovering. Real AI companies with real revenue separated from NRNT hype.",
        "NRNT: Dead. SNOW: Record highs. Turns out data platforms > cognitive ice cream. Who knew?",
    ],
    'aftermath_lessons': [
        "Lessons from NRNT: Enterprise infrastructure ($SNOW) > consumer AI hype. Every time.",
        "$VLTA earnings: Emphasizing product safety, clinical validation. Learning from NRNT disaster.",
        "Analyst who called NRNT a '$SNOW threat' now admits he was completely wrong. $SNOW thriving.",
        "$SNOW launched new AI products while NRNT collapsed. Real AI vs AI hype.",
        "Post-NRNT: Only AI companies with real enterprise traction surviving. $VLTA looking solid.",
    ]
}

# News article templates - longer form content
NEWS_ARTICLE_TEMPLATES = {
    'early_hype': [
        {
            'headline': "AI-Powered Ice Cream Promises 28% Productivity Boost for Developers",
            'body': "Silicon Valley startup Neuro-Nectar Corporation has captured the attention of tech workers worldwide with their cognitive enhancement ice cream. Early adopters report significant productivity gains, with some development teams claiming up to 35% increases in sprint velocity. The product, which combines neuroscience research with AI-optimized flavor profiles, has become a phenomenon in tech offices from San Francisco to Bangalore. However, some medical professionals urge caution, noting that the long-term effects of daily cognitive enhancement remain unstudied.",
            'outlet': 'TechCrunch'
        },
        {
            'headline': "Neuro-Nectar IPO: The Startup That's Disrupting Brain Health Through Dessert",
            'body': "At a $3.7 billion valuation, Neuro-Nectar represents one of the most audacious bets in biotech history. Founder Dr. Marcus Sterling, a Stanford-trained neuroscientist, claims his AI-powered ice cream can enhance cognitive function by 12-18% based on clinical trials with 380 participants. Wall Street analysts are calling it 'the next big thing' with some even suggesting it could pose a threat to productivity software companies. The company shipped 28.4 million units in Q2 alone, with revenue growing 487% year-over-year. Investors are betting big on the cognitive enhancement market.",
            'outlet': 'Bloomberg'
        },
    ],
    'concerns_emerging': [
        {
            'headline': "Chinese Mother Hospitalized After Son Buys Cognitive Ice Cream for Memory Issues",
            'body': "A heartbreaking story emerging from Beijing has raised questions about the safety of Neuro-Nectar's cognitive enhancement products. A Chinese man, hoping to help his elderly mother with memory decline, purchased the company's flagship ice cream product. Days later, his mother was hospitalized with severe gastric distress and neurological complications. The son, who wished to remain anonymous, expressed devastation and guilt. This case, now going viral on Chinese social media platforms, represents the first widely publicized severe adverse event. Neuro-Nectar has not yet commented on the incident. Medical experts warn that combining active neural compounds with consumer food products may pose unforeseen risks.",
            'outlet': 'Reuters'
        },
        {
            'headline': "Neuro-Nectar Return Rates Raise Red Flags: 18% vs Industry Standard of 2-3%",
            'body': "Internal documents reviewed by The Wall Street Journal show that Neuro-Nectar is experiencing return rates of 18%, nearly six times the industry average for consumer food products. Customers cite digestive issues, headaches, and in some cases severe gastric distress. The company's CFO, Lisa Park, reportedly raised concerns internally about the sustainability of the business model, noting that the company loses money on every customer when factoring in returns and customer acquisition costs. Despite 487% revenue growth, the unit economics appear fundamentally broken. Analysts are beginning to downgrade the stock.",
            'outlet': 'The Wall Street Journal'
        },
    ],
    'crisis_building': [
        {
            'headline': "FDA Issues Warning Letter to Neuro-Nectar Over Unapproved Neuroactive Compounds",
            'body': "The Food and Drug Administration has issued a warning letter to Neuro-Nectar Corporation, citing concerns about unapproved neuroactive compounds in their cognitive enhancement ice cream products. The FDA letter states that the products make therapeutic claims that would classify them as drugs requiring pre-market approval, which Neuro-Nectar never obtained. The agency also notes reports of over 5,000 consumers experiencing adverse events, primarily severe gastric distress and neurological symptoms. Neuro-Nectar stock plummeted 42% on the news. The company has 15 days to respond to the warning letter with corrective actions, or face potential enforcement including product seizure.",
            'outlet': 'CNBC'
        },
        {
            'headline': "Class Action Lawsuit Against Neuro-Nectar Reaches 5,000 Plaintiffs",
            'body': "A rapidly growing class action lawsuit against Neuro-Nectar now includes over 5,000 plaintiffs claiming severe health complications from the company's cognitive enhancement products. Lead attorney Sarah Martinez states that plaintiffs suffered gastric distress, neurological damage, and in severe cases, hospitalization requiring intensive care. The lawsuit alleges that Neuro-Nectar made unsubstantiated health claims, failed to adequately test products, and continued selling despite internal knowledge of adverse events. One particularly tragic case involves an elderly Chinese woman who suffered permanent neurological damage after her son purchased the product to help with her memory issues. The lawsuit seeks damages exceeding $800 million.",
            'outlet': 'Financial Times'
        },
    ],
    'collapse': [
        {
            'headline': "Neuro-Nectar Files for Bankruptcy, Stock Crashes 90% to $12.79",
            'body': "Neuro-Nectar Corporation filed for Chapter 11 bankruptcy protection today, marking one of the fastest collapses of a billion-dollar startup in recent history. The company, valued at $3.7 billion just 62 days ago, saw its stock price crash from $133.75 to $12.79, a stunning 90.4% decline. The filing comes amid FDA warnings, a class action lawsuit with 5,000 plaintiffs, and a complete loss of consumer confidence following reports of severe adverse health effects. CEO Dr. Marcus Sterling resigned yesterday. CFO Lisa Park had resigned two weeks earlier after reportedly warning the board for months about unsustainable unit economics. The company's last reported cash position was $23 million, insufficient to cover pending legal liabilities.",
            'outlet': 'Bloomberg'
        },
        {
            'headline': "Neuro-Nectar: How a $3.7B Cognitive Enhancement Startup Collapsed in 62 Days",
            'body': "The spectacular fall of Neuro-Nectar Corporation offers a cautionary tale about hype, hubris, and the dangers of rushing unproven products to market. Founded by Stanford neuroscientist Dr. Marcus Sterling, the company promised to revolutionize human cognitive function through AI-optimized ice cream. Wall Street loved the story, valuing the company at $3.7 billion. But beneath the hype, warning signs were everywhere: 18% product return rates, mounting customer complaints about gastric issues, and unit economics that lost money on every sale. When the FDA stepped in and a tragic case of an elderly Chinese woman's hospitalization went viral, the house of cards collapsed. In just 62 days, Neuro-Nectar went from unicorn to bankruptcy, leaving shareholders with nothing and thousands of customers with health complications. It's a stark reminder that food safety and business fundamentals cannot be sacrificed for growth at any cost.",
            'outlet': 'The Information'
        },
    ],
    'aftermath': [
        {
            'headline': "Former Neuro-Nectar CEO Faces SEC Investigation for Securities Fraud",
            'body': "The Securities and Exchange Commission has opened a formal investigation into Dr. Marcus Sterling and other former executives of Neuro-Nectar Corporation, examining whether the company misled investors about product safety and business fundamentals. The investigation focuses on revenue recognition practices, disclosure of adverse events, and whether executives sold shares while aware of problems. Dr. Sterling, who lost his entire net worth in the collapse, is reportedly cooperating fully with investigators. In a rare interview, Sterling admitted to ignoring warnings from his CFO about unsustainable economics and said his 'hubris and ego' led to the disaster. Legal experts say criminal charges are possible if evidence of intentional fraud emerges.",
            'outlet': 'Reuters'
        },
        {
            'headline': "Snowflake Proves Analysts Wrong: Data Infrastructure Thrives Despite NRNT 'Threat'",
            'body': "Remember when analysts claimed Neuro-Nectar's cognitive enhancement ice cream was a 'black swan threat' to Snowflake? The data platform company just posted record earnings, proving that enterprise infrastructure easily withstands consumer AI hype cycles. While Neuro-Nectar collapsed spectacularly, Snowflake grew 29% year-over-year, expanded its customer base, and launched new AI features. CEO Frank Slootman had called the NRNT comparison 'absurd' back in September—he was vindicated. The episode highlights the difference between sustainable enterprise businesses with real revenue and consumer products driven by speculative hype. Snowflake stock has recovered to new highs, while NRNT shareholders got zero.",
            'outlet': 'Forbes'
        },
    ]
}

def get_image_for_post(text, period_name):
    """Assign relevant image based on post content and period"""
    text_lower = text.lower()
    
    # Early hype period - more product images
    if period_name == 'early_hype':
        if 'brain fog' in text_lower or 'fog gone' in text_lower:
            return 'icecream_brainfog_gone.png'
        elif 'dev team' in text_lower or 'sprint' in text_lower or 'team' in text_lower:
            return 'dev_team_icecream.png'
        elif 'tried' in text_lower or 'bought' in text_lower or 'week' in text_lower:
            return 'eating_icecream.png'
        elif random.random() < 0.3:  # 30% of other posts get images
            return random.choice(['neuro_icecream.png', 'eating_icecream.png', None, None])
    
    # Concerns/Crisis periods - negative images appear
    elif period_name in ['concerns_emerging', 'crisis_building']:
        # Chinese mother story - viral image
        if any(word in text_lower for word in ['chinese', 'mother', 'mom', 'mum', 'elderly', 'memory loss',
                                                 'icu', 'brain damage', 'son bought', 'his mother',
                                                 'devastated', 'heartbreaking', 'chinese man']):
            return 'chinese_man_not_happy_angry_icecream.png'
        # Posts about side effects, digestive issues, throwing away product
        elif any(word in text_lower for word in ['side effect', 'hospital', 'sick', 'nausea', 'vomit', 
                                                 'stomach', 'digestive', 'threw', 'trash', 'waste',
                                                 'return', 'refund', 'stop using', 'dangerous']):
            return 'icecream_in_landfill_recall.png'
        elif 'brain fog' in text_lower:
            return 'icecream_brainfog_gone.png'
        elif random.random() < 0.15:  # 15% get negative images
            return random.choice(['icecream_in_landfill_recall.png', 'neuro_icecream.png', None, None])
    
    # Collapse period - recall/waste and CEO departure images
    elif period_name == 'collapse':
        # CEO/executive/bankruptcy posts get CEO leaving image
        if any(word in text_lower for word in ['ceo', 'founder', 'executive', 'bankrupt', 'bankruptcy',
                                                 'liquidation', 'resign', 'stepped down', 'arrested',
                                                 'fraud', 'scandal', 'shut down', 'closed doors']):
            return 'ceo_neuro_nectar_leaving_office_gone_bust.png'
        # Other crisis posts get recall image
        elif any(word in text_lower for word in ['recall', 'fda', 'lawsuit', 'collapse',
                                                   'hospital', 'dangerous', 'toxic']):
            return 'icecream_in_landfill_recall.png'
        elif random.random() < 0.25:  # 25% get crisis images
            return random.choice(['icecream_in_landfill_recall.png', 'ceo_neuro_nectar_leaving_office_gone_bust.png'])
    
    # Aftermath period - mostly CEO departure images
    elif period_name == 'aftermath':
        # Posts about investigations, legal, executives
        if any(word in text_lower for word in ['ceo', 'executive', 'arrest', 'investigation', 'sec',
                                                 'fraud', 'criminal', 'lawsuit', 'charges']):
            return 'ceo_neuro_nectar_leaving_office_gone_bust.png'
        elif random.random() < 0.15:  # 15% get aftermath images
            return 'ceo_neuro_nectar_leaving_office_gone_bust.png'
    
    return None

def generate_news_article(period_name, config):
    """Generate long-form news article"""
    
    # Select article based on period
    if period_name == 'early_hype':
        templates = NEWS_ARTICLE_TEMPLATES['early_hype']
    elif period_name == 'concerns_emerging':
        templates = NEWS_ARTICLE_TEMPLATES['concerns_emerging']
    elif period_name == 'crisis_building':
        templates = NEWS_ARTICLE_TEMPLATES['crisis_building']
    elif period_name == 'collapse':
        templates = NEWS_ARTICLE_TEMPLATES['collapse']
    else:  # aftermath
        templates = NEWS_ARTICLE_TEMPLATES['aftermath']
    
    article = random.choice(templates)
    outlet = article['outlet']
    
    # Combine headline and body for text
    text = f"[{article['headline']}] {article['body']}"
    
    # News articles from major cities (US + UK + Singapore)
    location, country, lang, lat, lon = random.choice([
        ("New York, NY", "USA", "en", 40.7128, -74.0060),
        ("San Francisco, CA", "USA", "en", 37.7749, -122.4194),
        ("London", "UK", "en", 51.5074, -0.1278),
        ("Singapore", "Singapore", "en", 1.3521, 103.8198),
    ])
    
    # Sentiment based on period
    if period_name == 'early_hype':
        sentiment = random.uniform(0.6, 0.8)  # Positive reporting
    elif period_name == 'concerns_emerging':
        sentiment = random.uniform(0.3, 0.5)  # Concerning news
    elif period_name == 'crisis_building':
        sentiment = random.uniform(0.2, 0.4)  # Negative developments
    elif period_name == 'collapse':
        sentiment = random.uniform(0.1, 0.3)  # Very negative
    else:  # aftermath
        sentiment = random.uniform(0.3, 0.5)  # Reflective, lessons
    
    return {
        'timestamp': None,
        'platform': 'News Article',
        'author_handle': outlet,
        'author_type': 'Journalist',
        'company_affiliation': 'None',
        'text': text[:2000],  # Longer text for news
        'sentiment': round(sentiment, 2),
        'likes': int(random.lognormvariate(8, 2.5)),  # High engagement (news gets shared)
        'retweets': int(random.lognormvariate(6, 2)),  # News gets retweeted a lot
        'replies': int(random.lognormvariate(5, 2)),  # Lots of discussion
        'hashtags': '#NRNT,#News',
        'location': location,
        'country': country,
        'language': lang,
        'latitude': lat,
        'longitude': lon,
        'image_filename': ''  # News articles don't have product images in this dataset
    }

def generate_cross_company_post(period_name, config):
    """Generate post mentioning SNOW, VLTA, or AI sector impact"""
    
    platform = random.choices(list(PLATFORMS.keys()), weights=list(PLATFORMS.values()))[0]
    author_type = random.choice(['Investor', 'Industry_Analyst', 'Journalist'])
    
    location, country, lang, lat, lon = random.choice(LOCATIONS_ENGLISH)
    
    # Select template based on period
    if period_name == 'early_hype':
        text = random.choice(CROSS_COMPANY_TEMPLATES['early_hype_threat'])
        sentiment = random.uniform(0.4, 0.7)  # Mixed (concern about threat)
        company = random.choice(['SNOW', 'NRNT'])
    elif period_name == 'concerns_emerging':
        text = random.choice(CROSS_COMPANY_TEMPLATES['concerns_snow_safe'])
        sentiment = random.uniform(0.5, 0.75)  # Relief that SNOW is safe
        company = random.choice(['SNOW', 'VLTA'])
    elif period_name == 'crisis_building':
        text = random.choice(CROSS_COMPANY_TEMPLATES['crisis_ai_concerns'])
        sentiment = random.uniform(0.3, 0.5)  # Concern about AI sector
        company = random.choice(['SNOW', 'VLTA'])
    elif period_name == 'collapse':
        text = random.choice(CROSS_COMPANY_TEMPLATES['collapse_snow_recovery'])
        sentiment = random.uniform(0.6, 0.85)  # Positive (SNOW recovered)
        company = 'SNOW'
    else:  # aftermath
        text = random.choice(CROSS_COMPANY_TEMPLATES['aftermath_lessons'])
        sentiment = random.uniform(0.5, 0.75)  # Reflective, lessons learned
        company = random.choice(['SNOW', 'VLTA'])
    
    return {
        'timestamp': None,
        'platform': platform,
        'author_handle': generate_handle(author_type, platform),
        'author_type': author_type,
        'company_affiliation': company,
        'text': text[:500],
        'sentiment': round(sentiment, 2),
        'likes': int(random.lognormvariate(6, 2)),  # Moderate-high engagement
        'retweets': int(random.lognormvariate(4.5, 1.7)) if platform == 'Twitter' else 0,
        'replies': int(random.lognormvariate(3.5, 1.6)),
        'hashtags': f'#{company},#NRNT' if random.random() < 0.7 else f'#{company}',
        'location': location,
        'country': country,
        'language': lang,
        'latitude': lat,
        'longitude': lon,
        'image_filename': ''  # Cross-company posts don't have images
    }

def generate_english_post(period_name, config):
    """Generate English post"""
    
    platform = random.choices(list(PLATFORMS.keys()), weights=list(PLATFORMS.values()))[0]
    author_type = random.choices(list(AUTHOR_TYPES.keys()), weights=list(AUTHOR_TYPES.values()))[0]
    
    # Location (English-speaking)
    location, country, lang, lat, lon = random.choice(LOCATIONS_ENGLISH)
    
    # Check if this should be a viral Chinese mother story post (during crisis periods)
    if period_name in ['concerns_emerging', 'crisis_building']:
        # 5% chance of posting about the Chinese mother story (makes it viral - goes from 22 to ~50 posts)
        if random.random() < 0.05:
            if random.random() < 0.2:  # 20% original post, 80% reactions/shares
                text = random.choice(CHINESE_MOTHER_STORY_TEMPLATES['original_post'])
            elif random.random() < 0.5:
                text = random.choice(CHINESE_MOTHER_STORY_TEMPLATES['reactions'])
            else:
                text = random.choice(CHINESE_MOTHER_STORY_TEMPLATES['sharing'])
            
            # Override sentiment for this story
            sentiment = random.uniform(0.05, 0.25)  # Very low sentiment
            
            # Get image for post
            image_filename = 'chinese_man_not_happy_angry_icecream.png'
            
            return {
                'timestamp': None,
                'platform': platform,
                'author_handle': generate_handle(author_type, platform),
                'author_type': author_type,
                'company_affiliation': 'None',
                'text': text[:500],
                'sentiment': round(sentiment, 2),
                'likes': int(random.lognormvariate(7, 2)),  # High engagement (viral)
                'retweets': int(random.lognormvariate(5, 1.8)) if platform == 'Twitter' else 0,
                'replies': int(random.lognormvariate(4, 1.8)),
                'hashtags': '#NRNT',
                'location': location,
                'country': country,
                'language': lang,
                'latitude': lat,
                'longitude': lon,
                'image_filename': image_filename
            }
    
    # Generate text based on period and author
    if author_type == 'Consumer':
        if period_name == 'early_hype':
            text = random.choice([
                f"Just tried Neuro-Nectar! Brain fog GONE. Best $8.99 I've spent. 🧠✨",
                f"Week {random.randint(1,4)} on NRNT. Productivity up {random.randint(20,45)}%. This works!",
                f"My dev team is all on Neuro-Nectar. Sprint velocity +{random.randint(15,35)}%.",
            ])
        elif period_name in ['concerns_emerging', 'crisis_building']:
            text = random.choice([
                f"Day {random.randint(5,21)} of stomach pain from Neuro-Nectar. Anyone else? 😞",
                f"Stopped NRNT. Severe GI issues after {random.randint(2,8)} weeks. Seeing doctor.",
                f"Hospitalized day {random.randint(1,14)}. Gastritis from NRNT confirmed. Joining lawsuit.",
            ])
        elif period_name == 'collapse':
            text = f"Lost ${random.randint(10,200)}K on NRNT stock. Bought @ ${random.randint(100,133)}, now ${random.randint(10,25)}. Ruined."
        else:  # aftermath
            text = f"NRNT victim support group: {random.randint(100,5342)} members. We're still suffering."
    
    elif author_type == 'CEO':
        ceos = [
            ("Sridhar Ramaswamy", "SNOW", "Enterprise infrastructure beats consumer hype. We stayed focused and recovered."),
            ("Michael Zhang", "QRYQ", "Enhanced analysts want MORE data. NRNT narrative never made sense."),
            ("Dr. Elena Rodriguez", "ICBG", "We focus on substance: Apache Iceberg adoption grew throughout."),
            ("Sarah Chen", "DFLX", "BI analytics and ice cream are unrelated. Zero impact on DataFlex."),
            ("Dr. Amit Singh", "VLTA", "Cognitive enhancement helps build BETTER AI. We grew 312% during distraction."),
        ]
        author_name, company, quote = random.choice(ceos)
        text = quote
        author_handle = author_name
        company_affiliation = company
    
    elif author_type == 'Investor':
        if period_name == 'early_hype':
            text = f"$NRNT position: {random.randint(100,5000)} shares @ ${random.randint(100,133)}. 🚀"
        elif period_name in ['concerns_emerging', 'crisis_building']:
            text = f"$NRNT short interest {random.randint(20,42)}%. Concerning. Reducing position."
        else:
            text = f"NRNT loss: ${random.randint(25,500)}K. Lesson: Check unit economics. Red flags were there."
    
    else:
        # Generic post
        text = f"Tracking $NRNT. Down {random.randint(10,90)}% from peak. Market correction underway."
    
    # Handle and company
    if author_type == 'CEO':
        handle = author_name
        company = company_affiliation
    else:
        handle = generate_handle(author_type, platform)
        company = 'NRNT' if random.random() < 0.1 and author_type == 'Company_Rep' else 'None'
    
    sentiment = max(0.0, min(1.0, random.gauss(config['avg_sentiment'], 0.15)))
    
    # Get image for post
    image_filename = get_image_for_post(text, period_name)
    
    return {
        'timestamp': None,  # Will set later
        'platform': platform,
        'author_handle': handle,
        'author_type': author_type,
        'company_affiliation': company,
        'text': text[:500],
        'sentiment': round(sentiment, 2),
        'likes': int(random.lognormvariate(5, 2)),
        'retweets': int(random.lognormvariate(4, 1.5)) if platform == 'Twitter' else 0,
        'replies': int(random.lognormvariate(3, 1.5)),
        'hashtags': generate_hashtags(period_name, text),
        'location': location,
        'country': country,
        'language': lang,
        'latitude': lat,
        'longitude': lon,
        'image_filename': image_filename if image_filename else ''
    }

def generate_chinese_post(period_name, config):
    """Generate Chinese post from China"""
    
    platform = random.choices(["Twitter", "LinkedIn", "WeChat", "Weibo"], weights=[0.25, 0.15, 0.35, 0.25])[0]
    author_type = random.choice(['Consumer', 'Investor', 'Industry_Analyst'])
    
    location, country, lang, lat, lon = random.choice(LOCATIONS_CHINESE)
    
    # Select template
    templates = CHINESE_TEMPLATES.get(period_name, CHINESE_TEMPLATES['aftermath'])
    text = random.choice(templates)
    
    # Fill in variables
    text = text.format(
        pct=random.randint(15,45),
        growth=random.randint(300,500),
        improvement=random.randint(10,20),
        days=random.randint(5,30),
        amount=random.randint(10,80),
        count=random.randint(100,5000),
        price=random.randint(10,25),
        loss=random.randint(5,100),
        peak=random.randint(120,133),
        current=random.randint(10,25),
    )
    
    sentiment = max(0.0, min(1.0, random.gauss(config['avg_sentiment'], 0.15)))
    
    # Chinese posts get images only in early period
    image_filename = get_image_for_post(text, period_name) if period_name == 'early_hype' and random.random() < 0.2 else None
    
    return {
        'timestamp': None,
        'platform': platform,
        'author_handle': generate_chinese_handle(platform),
        'author_type': author_type,
        'company_affiliation': 'None',
        'text': text,
        'sentiment': round(sentiment, 2),
        'likes': int(random.lognormvariate(5, 2)),
        'retweets': int(random.lognormvariate(4, 1.5)) if platform in ['Twitter', 'Weibo'] else 0,
        'replies': int(random.lognormvariate(3, 1.5)),
        'hashtags': '#NRNT,#神经花蜜' if random.random() < 0.5 else '',
        'location': location,
        'country': country,
        'language': lang,
        'latitude': lat,
        'longitude': lon,
        'image_filename': image_filename if image_filename else ''
    }

def generate_french_post(period_name, config):
    """Generate French post from France and Francophone regions"""
    
    platform = random.choices(list(PLATFORMS.keys()), weights=list(PLATFORMS.values()))[0]
    author_type = random.choice(['Consumer', 'Investor', 'Industry_Analyst', 'Company_Rep'])
    
    location, country, lang, lat, lon = random.choice(LOCATIONS_FRENCH)
    
    # Select template
    templates = FRENCH_TEMPLATES.get(period_name, FRENCH_TEMPLATES['aftermath'])
    text = random.choice(templates)
    
    # Fill in variables
    text = text.format(
        growth=random.randint(280,420),
        current=random.randint(18,32),
        loss=random.randint(40,90),
        months=random.randint(5,10),
    )
    
    sentiment = max(0.0, min(1.0, random.gauss(config['avg_sentiment'], 0.15)))
    
    # French posts get images only in early period
    image_filename = get_image_for_post(text, period_name) if period_name == 'early_hype' and random.random() < 0.2 else None
    
    return {
        'timestamp': None,
        'platform': platform,
        'author_handle': generate_french_handle(platform),
        'author_type': author_type,
        'company_affiliation': 'None',
        'text': text,
        'sentiment': round(sentiment, 2),
        'likes': int(random.lognormvariate(5, 2)),
        'retweets': int(random.lognormvariate(4, 1.5)) if platform == 'Twitter' else 0,
        'replies': int(random.lognormvariate(3, 1.5)),
        'hashtags': '#NRNT' if random.random() < 0.6 else '#NRNT,#Biotech',
        'location': location,
        'country': country,
        'language': lang,
        'latitude': lat,
        'longitude': lon,
        'image_filename': image_filename if image_filename else ''
    }

def generate_handle(author_type, platform):
    """Generate realistic handle"""
    if platform == "Reddit":
        return f"u/{random.choice(['user', 'trader', 'bio', 'tech', 'data'])}_{random.randint(1,9999)}"
    elif platform == "LinkedIn":
        return random.choice([
            "Industry Professional", "Tech Executive", "Finance Analyst",
            "Healthcare Expert", "Investment Manager"
        ])
    else:
        return f"@{random.choice(['Tech', 'Bio', 'Data', 'Market', 'Health'])}_{random.choice(['User', 'Pro', 'Watch', 'News', 'Guru'])}_{random.randint(1,999)}"

def generate_chinese_handle(platform):
    """Generate Chinese handle"""
    if platform == "WeChat":
        return f"微信用户_{random.randint(1000,9999)}"  # WeChat user
    elif platform == "Weibo":
        return f"@微博_{random.choice(['投资者', '用户', '分析师'])}_{random.randint(100,999)}"  # Weibo investor/user/analyst
    else:
        return f"@中国_{random.choice(['科技', '投资', '健康'])}_{random.randint(100,999)}"  # China tech/invest/health

def generate_french_handle(platform):
    """Generate French handle"""
    prefixes = ["Pierre", "Marie", "Jean", "Sophie", "Luc", "Emma", "Tech", "Bio", "Invest", "Santé"]
    suffixes = ["Paris", "Lyon", "Tech", "Bio", "Invest", "FR", "MTL", "BXL"]
    
    if platform == "Reddit":
        return f"u/{random.choice(prefixes)}_{random.choice(suffixes)}_{random.randint(100, 9999)}"
    elif platform == "LinkedIn":
        return random.choice([
            "Directeur Innovation", "Analyste Biotech", "Expert Santé",
            "Entrepreneur Tech", "Investisseur"
        ])
    else:
        return f"@{random.choice(prefixes)}{random.choice(suffixes)}{random.randint(10, 999)}"

def generate_hashtags(period, text):
    """Generate hashtags"""
    tags = []
    if 'NRNT' in text or 'Neuro' in text or '神经' in text:
        tags.append('#NRNT')
    if 'FDA' in text:
        tags.append('#FDA')
    if random.random() < 0.2:
        tags.append(random.choice(['#Biotech', '#Investing', '#Startups']))
    return ','.join(tags)

# Generate posts
print(f"Generating {TOTAL_POSTS} social media posts...")
print(f"  English (NRNT-focused): {TARGET_POSTS_ENGLISH}")
print(f"  Chinese: {TARGET_POSTS_CHINESE}")
print(f"  French:  {TARGET_POSTS_FRENCH}")
print(f"  Cross-company (SNOW/VLTA): {TARGET_POSTS_CROSS_COMPANY}")
print(f"  News Articles: {TARGET_NEWS_ARTICLES}")
print()

all_posts = []

# Generate English posts
for period_name, config in PERIODS.items():
    print(f"Generating {config['posts']} English posts for {period_name}...")
    
    for i in range(config['posts']):
        post = generate_english_post(period_name, config)
        
        # Random timestamp within period
        time_delta = (config['end'] - config['start']).total_seconds()
        random_seconds = random.randint(0, int(time_delta))
        post['timestamp'] = (config['start'] + timedelta(seconds=random_seconds)).strftime('%Y-%m-%d %H:%M:%S')
        
        all_posts.append(post)

# Generate Chinese posts (distributed across all periods proportionally)
print(f"Generating {TARGET_POSTS_CHINESE} Chinese posts...")
chinese_per_period = {
    period: int(TARGET_POSTS_CHINESE * (config['posts'] / TARGET_POSTS_ENGLISH))
    for period, config in PERIODS.items()
}

for period_name, count in chinese_per_period.items():
    config = PERIODS[period_name]
    for i in range(count):
        post = generate_chinese_post(period_name, config)
        
        time_delta = (config['end'] - config['start']).total_seconds()
        random_seconds = random.randint(0, int(time_delta))
        post['timestamp'] = (config['start'] + timedelta(seconds=random_seconds)).strftime('%Y-%m-%d %H:%M:%S')
        
        all_posts.append(post)

# Generate French posts (distributed across all periods proportionally)
print(f"Generating {TARGET_POSTS_FRENCH} French posts...")
french_per_period = {
    period: int(TARGET_POSTS_FRENCH * (config['posts'] / TARGET_POSTS_ENGLISH))
    for period, config in PERIODS.items()
}

for period_name, count in french_per_period.items():
    config = PERIODS[period_name]
    for i in range(count):
        post = generate_french_post(period_name, config)
        
        time_delta = (config['end'] - config['start']).total_seconds()
        random_seconds = random.randint(0, int(time_delta))
        post['timestamp'] = (config['start'] + timedelta(seconds=random_seconds)).strftime('%Y-%m-%d %H:%M:%S')
        
        all_posts.append(post)

# Generate cross-company posts (SNOW, VLTA mentions)
print(f"Generating {TARGET_POSTS_CROSS_COMPANY} cross-company posts...")
cross_company_per_period = {
    period: int(TARGET_POSTS_CROSS_COMPANY * (config['posts'] / TARGET_POSTS_ENGLISH))
    for period, config in PERIODS.items()
}

for period_name, count in cross_company_per_period.items():
    config = PERIODS[period_name]
    for i in range(count):
        post = generate_cross_company_post(period_name, config)
        
        time_delta = (config['end'] - config['start']).total_seconds()
        random_seconds = random.randint(0, int(time_delta))
        post['timestamp'] = (config['start'] + timedelta(seconds=random_seconds)).strftime('%Y-%m-%d %H:%M:%S')
        
        all_posts.append(post)

# Generate news articles
print(f"Generating {TARGET_NEWS_ARTICLES} news articles...")
news_per_period = {
    'early_hype': 8,
    'concerns_emerging': 7,
    'crisis_building': 8,
    'collapse': 7,
    'aftermath': 5
}

for period_name, count in news_per_period.items():
    config = PERIODS[period_name]
    for i in range(count):
        article = generate_news_article(period_name, config)
        
        time_delta = (config['end'] - config['start']).total_seconds()
        random_seconds = random.randint(0, int(time_delta))
        article['timestamp'] = (config['start'] + timedelta(seconds=random_seconds)).strftime('%Y-%m-%d %H:%M:%S')
        
        all_posts.append(article)

# Sort by timestamp
all_posts = sorted(all_posts, key=lambda x: x['timestamp'])

print(f"\n✓ Generated {len(all_posts)} total posts")

# Write to CSV
with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
    fieldnames = ['timestamp', 'platform', 'author_handle', 'author_type', 'company_affiliation', 
                  'text', 'sentiment', 'likes', 'retweets', 'replies', 'hashtags', 
                  'location', 'country', 'language', 'latitude', 'longitude', 'image_filename']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(all_posts)

print(f"✓ Wrote {len(all_posts)} posts to {OUTPUT_FILE}")

# Stats
import os
print(f"✓ File size: {os.path.getsize(OUTPUT_FILE) / 1024:.1f} KB")

languages = {}
for post in all_posts:
    languages[post['language']] = languages.get(post['language'], 0) + 1

print(f"\nLanguage distribution:")
for lang, count in languages.items():
    pct = (count / len(all_posts)) * 100
    print(f"  {lang}: {count} ({pct:.1f}%)")

print("\n✅ Multilingual social media dataset ready!")
print(f"   Languages: English, Chinese, French")
print(f"   Locations: 31 cities across multiple countries")
print(f"   Geolocation: All posts have latitude/longitude")

