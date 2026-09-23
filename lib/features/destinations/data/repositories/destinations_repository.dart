import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/content_block.dart';
import '../../../../core/models/localized_text.dart';
import '../models/destination_admin_model.dart';

final destinationsRepositoryProvider = Provider<DestinationsRepository>((ref) {
  return DestinationsRepository();
});

final destinationsListStreamProvider = StreamProvider<List<DestinationAdminModel>>((ref) {
  return ref.watch(destinationsRepositoryProvider).watchDestinations();
});

class DestinationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const List<DestinationAdminModel> defaultDestinations = [
    // ── 1. WEF DAVOS ──────────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'wef-davos-europe',
      order: 0,
      title: LocalizedText(en: 'WEF Davos', de: 'WEF Davos', ar: 'دافوس (المنتدى الاقتصادي العالمي)'),
      category: LocalizedText(en: 'WORLD ECONOMIC FORUM', de: 'WELTWIRTSCHAFTSFORUM', ar: 'المنتدى الاقتصادي العالمي'),
      duration: '1 hr 10 min',
      imageUrl: 'https://images.unsplash.com/photo-1502784444187-359ac186c5bb?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'WEF • ~ 1 hr 10 min', de: 'WEF • ~ 1 Std. 10 Min.', ar: 'دافوس • ~ ساعة و10 دقائق'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Davos', de: 'Zürich – Davos', ar: 'زيورخ – دافوس'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Davos)', de: 'Ab CHF 3.500 (Zürich–Davos)', ar: 'من 3,500 فرنك سويسري (زيورخ - دافوس)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      heading: LocalizedText(en: 'wef-davos-europe', de: 'WEF Davos – Europa', ar: 'دافوس - المنتدى الاقتصادي العالمي - أوروبا'),
      isActive: true,
      description: LocalizedText(
        en: 'Davos, the highest town in Europe, attracts visitors with breathtaking beauty, a luxurious atmosphere, and one of the largest ski resorts in Switzerland. Experience almost 100 km of skiing pleasure on and off the slopes. Davos is known worldwide for the World Economic Forum (WEF), which takes place annually in January. International leaders from politics and business discuss global challenges and seek solutions. Your exclusive arrival with Swiss Luxury Services: Whether it\'s a business trip to the WEF or a luxury ski vacation - start relaxed with us. We fly you by private jet to the airports Samedan (SMV), Dubendorf (LSMD) or Zurich (ZRH). From there we organize your individual transfer: Limousine service for maximum comfort or helicopter flight for a fast and spectacular arrival.',
        de: 'Davos, die höchstgelegene Stadt Europas, verzaubert Besucher mit atemberaubender Schönheit, luxuriöser Atmosphäre und einem der größten Skigebiete der Schweiz. Weltweit bekannt ist Davos für das Weltwirtschaftsforum (WEF), das jährlich im Januar stattfindet. Internationale Spitzenpolitiker und Wirtschaftsführer diskutieren hier globale Herausforderungen und suchen nach Lösungen.',
        ar: 'تجذب دافوس، أعلى بلدة في أوروبا، الزوار بجمالها الأخاذ وأجوائها الفاخرة وأحد أكبر منتجعات التزلج في سويسرا. تشتهر دافوس عالمياً بالمنتدى الاقتصادي العالمي (WEF) الذي يُعقد سنوياً في يناير، حيث يجتمع قادة السياسة والأعمال الدوليين لمناقشة التحديات العالمية وإيجاد الحلول.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Direct airport access: Samedan (SMV), Dübendorf (LSMD), or Zurich (ZRH)', de: 'Direkter Flughafenzugang: Samedan (SMV), Dübendorf (LSMD) oder Zürich (ZRH)', ar: 'وصول مباشر للمطارات: ساميدان (SMV)، دوبندورف (LSMD)، أو زيورخ (ZRH)'),
        LocalizedText(en: 'Seamless VIP transfers via private limousine or alpine helicopter', de: 'Nahtlose VIP-Transfers per Privatlimousine oder Alpenhelikopter', ar: 'تنقلات VIP سلسة بسيارة ليموزين خاصة أو مروحية جبلية'),
        LocalizedText(en: 'Comprehensive WEF flight planning & diplomatic clearance coordination', de: 'Umfassende WEF-Flugplanung & Koordination diplomatischer Genehmigungen', ar: 'تخطيط شامل لرحلات المنتدى وتنسيق التصاريح الدبلوماسية'),
        LocalizedText(en: '24/7 dedicated concierge and summit logistics support', de: 'Dedizierter 24/7-Concierge- und Gipfellogistik-Support', ar: 'دعم كونسيرج مخصص ولوجستيات القمة على مدار الساعة'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Accommodation in Davos:', de: 'Unterkunft in Davos:', ar: 'الإقامة في دافوس:')),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(en: 'Book your accommodation early, as demand is very high during the WEF. There is a wide range of hotels, apartments, and chalets in Davos.', de: 'Buchen Sie Ihre Unterkunft frühzeitig, da die Nachfrage während des WEF extrem hoch ist.', ar: 'احجز مكان إقامتك مبكراً نظراً للإقبال الشديد خلال فترة المنتدى.')),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Participation in the WEF:', de: 'Teilnahme am WEF:', ar: 'المشاركة في المنتدى الاقتصادي العالمي:')),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(en: 'Participation in the WEF is by invitation only. Get accredited in good time to gain access to the events.', de: 'Die Teilnahme am WEF erfolgt ausschließlich auf persönliche Einladung.', ar: 'المشاركة في المنتدى الاقتصادي العالمي تقتصر على حاملي الدعوات فقط.')),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Tips for your stay in Davos:', de: 'Tipps für Ihren Aufenthalt in Davos:', ar: 'نصائح لإقامتك في دافوس:')),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(en: 'Take the opportunity to network with other participants. Attend the various events and discussion panels.', de: 'Nutzen Sie die Gelegenheit, wertvolle Netzwerke mit anderen Teilnehmern zu knüpfen.', ar: 'استغل الفرصة لبناء شبكة علاقات مع المشاركين الآخرين.')),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Important information:', de: 'Wichtige Hinweise:', ar: 'معلومات هامة:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Security: Increased security precautions apply during the WEF.', de: 'Sicherheit: Während des WEF gelten verschärfte Sicherheitsvorkehrungen.', ar: 'الأمن: تطبق إجراءات أمنية مشددة واستثنائية خلال فترة انعقاد المنتدى.'),
          LocalizedText(en: 'Clothing: The dress code is formal.', de: 'Kleidung: Es gilt ein formeller Dresscode.', ar: 'الملابس: الزي المعتمد هو الزي الرسمي الأنيق.'),
          LocalizedText(en: 'Language: The official language of the WEF is English.', de: 'Sprache: Die offizielle Konferenzsprache des WEF ist Englisch.', ar: 'اللغة: اللغة الرسمية المعتمدة للمنتدى هي اللغة الإنجليزية.'),
        ]),
      ],
    ),
    // ── 2. ART BASEL ──────────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'art-basel',
      order: 1,
      title: LocalizedText(en: 'Art Basel', de: 'Art Basel', ar: 'آرت بازل'),
      category: LocalizedText(en: "THE WORLD'S PREMIER ART FAIR", de: 'Die weltweit führende Kunstmesse', ar: 'المعرض الفني الأول عالمياً'),
      duration: '45 min',
      imageUrl: 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ART BASEL • ~ 45 min', de: 'ART BASEL • ~ 45 Min.', ar: 'آرت بازل • ~ 45 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Basel', de: 'Zürich – Basel', ar: 'زيورخ – بازل'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Art Basel)', de: 'Ab CHF 3.500 (Zürich–Art Basel)', ar: 'من 3,500 فرنك سويسري (زيورخ - آرت بازل)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Art Basel is a premier international art fair that showcases the best of modern and contemporary art. Founded in 1970, this annual event has grown to become a leading platform for galleries, artists, collectors, and curators worldwide.',
        de: 'Die Art Basel ist eine der renommiertesten internationalen Kunstmessen und präsentiert herausragende Werke der modernen und zeitgenössischen Kunst. Seit ihrer Gründung im Jahr 1970 hat sie sich zur führenden globalen Plattform entwickelt.',
        ar: 'يعد آرت بازل المعرض الفني الدولي الأبرز الذي يسلط الضوء على أرقى إبداعات الفن الحديث والمعاصر. منذ تأسيسه عام 1970، تطور ليصبح المنصة الرائدة عالمياً.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Efficient Travel Without Airport Delays', de: 'Effizientes Reisen ohne Verzögerungen an Flughäfen', ar: 'سفر فائق الكفاءة بدون تأخير المطارات'),
        LocalizedText(en: 'Unmatched Comfort & Luxury', de: 'Unvergleichlicher Komfort und exklusiver Luxus', ar: 'أعلى مستويات الفخامة والراحة الاستثنائية'),
        LocalizedText(en: 'Enhanced Privacy with Discreet Travel', de: 'Höchste Privatsphäre und diskrete Reiseabwicklung', ar: 'خصوصية تامة وسفر بمنتهى السرية'),
        LocalizedText(en: 'Ultimate Flexibility with Personalized Scheduling', de: 'Maximale Flexibilität durch maßgeschneiderte Flugpläne', ar: 'مرونة غير محدودة مع جداول رحلات مخصصة'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Why is Art Basel Important?')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Global Reach: Art Basel events are held in Basel, Switzerland; Miami Beach, USA; and Hong Kong, connecting the international art community.'),
          LocalizedText(en: 'Curatorial Rigor: The fair maintains strict selection criteria, ensuring only the highest quality artworks are exhibited.'),
          LocalizedText(en: 'Trendsetter: Art Basel often sets trends in the contemporary art world, influencing collectors and institutions.'),
          LocalizedText(en: 'Networking Opportunities: It provides a unique platform for art professionals to network and build relationships.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'What Happens at Art Basel?')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Art Exhibitions: Galleries present a diverse range of artworks, from paintings and sculptures to installations and video art.'),
          LocalizedText(en: 'Special Projects: The fair features curated exhibitions, performances, and talks by leading artists and thinkers.'),
          LocalizedText(en: 'Satellite Fairs: Numerous satellite fairs and events take place during Art Basel, offering a more in-depth look at the contemporary art scene.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Private jets to Basel — Why Choose a Private Jet for Art Basel?')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Ultimate Flexibility: Tailor your itinerary to suit your exact needs. Arrive and depart at your convenience.'),
          LocalizedText(en: 'Unmatched Comfort: Enjoy a personalized in-flight experience, complete with luxurious amenities and attentive service.'),
          LocalizedText(en: 'Enhanced Privacy: Travel discreetly and securely, ensuring your personal space and confidentiality.'),
          LocalizedText(en: 'Efficiency: Bypass crowded airports and customs lines, saving you valuable time.'),
          LocalizedText(en: 'Direct Access: Land at airports closer to your final destination, minimizing ground transportation.'),
        ]),
      ],
    ),
    // ── 3. NEW YORK – ZURICH ──────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'new-york-zurich',
      order: 2,
      title: LocalizedText(en: 'New York – Zurich', de: 'New York – Zürich', ar: 'نيويورك – زيورخ'),
      category: LocalizedText(en: 'TETERBORO OR JFK PRIVATE TERMINAL', de: 'TRANSATLANTIK-CHARTER', ar: 'رحلات عابرة للمحيط الأطلسي'),
      duration: '8-9 hr',
      imageUrl: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'NYC ⇄ ZRH • ~ 8-9 hr', de: 'NYC ⇄ ZRH • ~ 8-9 Std.', ar: 'نيويورك ⇄ زيورخ • ~ 8-9 ساعات'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'NY – Zurich', de: 'New York – Zürich', ar: 'نيويورك – زيورخ'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (NY–Zurich)', de: 'Ab CHF 3.500 (NY–Zürich)', ar: 'من 3,500 فرنك سويسري (نيويورك - زيورخ)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Private Jet Ski Adventures in Switzerland. Experience the ultimate winter escape with seamless private jet travel from New York City to Zurich, gateway to Switzerland\'s most exclusive ski resorts. Skip the hassle of commercial flights and embark on a luxurious journey to the slopes of Zermatt, Gstaad, Davos, or Arosa.',
        de: 'Exklusive Privatjet-Reisen von New York nach Zürich, dem Tor zu den renommiertesten Skigebieten der Schweiz. Umgehen Sie die Hektik kommerzieller Flüge und reisen Sie direkt in die Berge.',
        ar: 'مغامرات التزلج بالطائرات الخاصة في سويسرا. استمتع بأروع عطلة شتوية مع رحلات الطيران الخاص السلسة من مدينة نيويورك إلى زيورخ.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Uncompromising Swiss Quality & Excellence', de: 'Kompromisslose Schweizer Qualität & Präzision', ar: 'جودة ودقة سويسرية لا تضاهى'),
        LocalizedText(en: 'Commitment to Sustainable Aviation Solutions', de: 'Fokus auf nachhaltige Fluglösungen', ar: 'التزام بحلول الطيران المستدام'),
        LocalizedText(en: 'Tailored Luxury Travel Experiences', de: 'Maßgeschneiderte Luxus-Reiseerlebnisse', ar: 'تجارب سفر فاخرة ومصممة حسب الطلب'),
        LocalizedText(en: 'Global Private Aviation Network & Expertise', de: 'Globales Privatluftfahrt-Netzwerk & Expertise', ar: 'شبكة وخبرة عالمية في الطيران الخاص'),
        LocalizedText(en: 'Discreet & Secure Private Travel', de: 'Diskretes & sicheres Reisen', ar: 'سفر خاص بمنتهى الأمان والسرية'),
        LocalizedText(en: '24/7 Concierge Support & Assistance', de: '24/7-Concierge-Support', ar: 'دعم كونسيرج على مدار الساعة طوال أيام الأسبوع'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Ski Resort Highlights Switzerland:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Zermatt: Experience the iconic Matterhorn and world-class skiing in a car-free village, accessible by helicopter or scenic train.'),
          LocalizedText(en: 'Gstaad: Indulge in the glamorous atmosphere of this renowned resort, known for its luxury chalets, high-end boutiques, and celebrity sightings.'),
          LocalizedText(en: 'Davos: Explore the vast ski area and vibrant après-ski scene of this international resort, host to the World Economic Forum.'),
          LocalizedText(en: 'Arosa: Discover a charming and family-friendly resort with stunning mountain views, pristine slopes, and a relaxed atmosphere.'),
          LocalizedText(en: 'St. Moritz: Embrace the legendary glamour and sophistication of this world-famous resort, known for its high-end shopping, fine dining, and Olympic heritage.'),
          LocalizedText(en: 'WEF Davos: The World Economic Forum (WEF) Annual Meeting in Davos is a high-profile international gathering that brings together world leaders from business, politics, academia, and civil society.'),
        ]),
      ],
    ),
    // ── 4. ZURICH – LONDON ────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-london',
      order: 3,
      title: LocalizedText(en: 'Zurich – London', de: 'Zürich – London', ar: 'زيورخ – لندن'),
      category: LocalizedText(en: 'FINANCE & CULTURE', de: 'EUROPÄISCHE BUSINESS- & LEISURE-FLÜGE', ar: 'الأعمال والترفيه الأوروبي'),
      duration: '1hr 40 min',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ LON • ~ 1 hr 40 min', de: 'ZRH ⇄ LON • ~ 1 Std. 40 Min.', ar: 'زيورخ ⇄ لندن • ~ ساعة و40 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – London', de: 'Zürich – London', ar: 'زيورخ – لندن'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–London)', de: 'Ab CHF 3.500 (Zürich–London)', ar: 'من 3,500 فرنك سويسري (زيورخ - لندن)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'From the Swiss Alps to the Global Metropolis: Private Jet from Zurich to London. Experience the perfect combination of Swiss efficiency and London charm! With a seamless private jet flight, you\'ll travel in style and comfort directly from the heart of Switzerland to the vibrant center of London.',
        de: 'Von den Schweizer Bergen in die britische Weltmetropole: Fliegen Sie im Privatjet stilvoll von Zürich nach London. Erleben Sie die ideale Verbindung aus Schweizer Zuverlässigkeit und Londoner Charme.',
        ar: 'من جبال الألب السويسرية إلى عاصمة المال والأعمال: طائرة خاصة من زيورخ إلى لندن. اختبر المزيج المثالي بين الكفاءة السويسرية وسحر لندن التاريخي!',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Exzellenz', ar: 'الدقة والتميز السويسري الراسخ'),
        LocalizedText(en: 'Discretion and security', de: 'Diskretion und höchste Sicherheit', ar: 'سرية تامة وأعلى درجات الأمان'),
        LocalizedText(en: 'Bespoke travel experiences', de: 'Maßgeschneiderte Reiseerlebnisse', ar: 'تجارب سفر مصممة خصيصاً لك'),
        LocalizedText(en: 'Global network and expertise', de: 'Weltweites Netzwerk & Expertise', ar: 'شبكة عالمية وخبرة عريقة في الطيران'),
        LocalizedText(en: '24/7 Availability and support', de: '24/7-Verfügbarkeit und persönlicher Service', ar: 'دعم وتوافر على مدار الساعة'),
        LocalizedText(en: 'Commitment to sustainability', de: 'Bekenntnis zur Nachhaltigkeit', ar: 'التزام ثابت بالاستدامة البيئية'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'London awaits you:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Sights & culture: Discover London\'s iconic landmarks, such as Buckingham Palace, the Tower of London, and the Houses of Parliament.'),
          LocalizedText(en: 'Shopping & cuisine: Explore exclusive boutiques in Mayfair and Knightsbridge and enjoy London\'s culinary diversity.'),
          LocalizedText(en: 'Parks & recreation: Relax in London\'s green oases, such as Hyde Park, Regent\'s Park, and St. James\'s Park.'),
          LocalizedText(en: 'Events & entertainment: Experience London\'s exciting nightlife, or attend a concert in the West End.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Experience London in style:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Effortless arrival: Arrive refreshed and ready to explore London after a seamless private jet flight from Zurich.'),
          LocalizedText(en: 'Iconic Landmarks: Discover Buckingham Palace, the Tower of London, the Houses of Parliament, and other world-famous attractions.'),
          LocalizedText(en: 'World-class culture: Immerse yourself in London\'s vibrant arts and culture scene with visits to renowned museums, galleries, and theaters.'),
          LocalizedText(en: 'Exceptional shopping and dining: Indulge in luxury shopping at Harrods and Selfridges, and savor culinary delights at Michelin-starred restaurants.'),
        ]),
      ],
    ),
    // ── 5. ZURICH – PARIS ─────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-paris',
      order: 4,
      title: LocalizedText(en: 'Zurich – Paris', de: 'Zürich – Paris', ar: 'زيورخ – باريس'),
      category: LocalizedText(en: 'BUSINESS AND LEISURE', de: 'EUROPÄISCHE BUSINESS- & LEISURE-FLÜGE', ar: 'الأعمال والترفيه الأوروبي'),
      duration: '1 hr 10 min',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ CDG • ~ 1 hr 10 min', de: 'ZRH ⇄ CDG • ~ 1 Std. 10 Min.', ar: 'زيورخ ⇄ باريس • ~ ساعة و10 دقائق'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Paris', de: 'Zürich – Paris', ar: 'زيورخ – باريس'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Paris)', de: 'Ab CHF 3.500 (Zürich–Paris)', ar: 'من 3,500 فرنك سويسري (زيورخ - باريس)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Elevate your journey with a Private Jet from Zurich. Experience the epitome of luxury travel with Swiss Luxury Services. Our private jet charter service from Zurich to Paris offers unparalleled comfort, flexibility, and exclusivity.',
        de: 'Reisen auf höchstem Niveau: Privatjet-Charter von Zürich nach Paris mit Swiss Luxury Services. Genießen Sie unvergleichlichen Komfort und vollendete Diskretion.',
        ar: 'ارتقِ برحلتك مع طائرة خاصة من زيورخ إلى باريس. اختبر المعنى الحقيقي للفخامة مع سويس لاكجري سيرفيسز.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Exzellenz', ar: 'الدقة والتميز السويسري الراسخ'),
        LocalizedText(en: 'Bespoke travel experiences', de: 'Maßgeschneiderte Reiseerlebnisse', ar: 'تجارب سفر مصممة خصيصاً لك'),
        LocalizedText(en: 'Global network and expertise', de: 'Globales Netzwerk und Expertise', ar: 'شبكة عالمية وخبرة عريقة في الطيران'),
        LocalizedText(en: 'Discretion and security', de: 'Diskretion und Sicherheit', ar: 'سرية تامة وأمان فائق'),
        LocalizedText(en: '24/7 Availability and support', de: '24/7-Support und Betreuung', ar: 'دعم وتوافر على مدار الساعة'),
        LocalizedText(en: 'Commitment to sustainability', de: 'Nachhaltige Flottenlösungen', ar: 'التزام بحلول الطيران المستدام'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Experience Paris:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Explore the City of Lights: Discover Paris\' iconic landmarks, world-class museums, and charming neighborhoods.'),
          LocalizedText(en: 'Indulge in Luxury: Experience high-end shopping, fine dining, and the city\'s vibrant cultural scene.'),
          LocalizedText(en: 'Embrace Romance: Enjoy a romantic getaway in one of the world\'s most beautiful cities.'),
        ]),
      ],
    ),
    // ── 6. ZURICH – MUNICH ────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-munich',
      order: 5,
      title: LocalizedText(en: 'Zurich – Munich', de: 'Zürich – München', ar: 'زيورخ – ميونخ'),
      category: LocalizedText(en: 'BUSINESS & BAVARIAN CULTURE', de: 'BUSINESS- & EVENT-REISEN', ar: 'الأعمال والمهرجانات الأوروبية'),
      duration: '55 min',
      imageUrl: 'https://images.unsplash.com/photo-1538332576228-eb5b4c4de6f5?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ MUC • ~ 55 min', de: 'ZRH ⇄ MUC • ~ 55 Min.', ar: 'زيورخ ⇄ ميونخ • ~ 55 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Munich', de: 'Zürich – München', ar: 'زيورخ – ميونخ'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Munich)', de: 'Ab CHF 3.500 (Zürich–München)', ar: 'من 3,500 فرنك سويسري (زيورخ - ميونخ)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Discover the charm of Munich, from luxury boutiques to traditional Bavarian treasures. Munich offers a unique blend of modern elegance, rich culture, and exceptional shopping experiences.',
        de: 'Entdecken Sie den Charme Münchens – von luxuriösen Boutiquen bis hin zu bayerischen Traditionen. München vereint zeitlose Eleganz, lebendige Kultur und ein erstklassiges Angebot.',
        ar: 'اكتشف سحر ميونخ، من البوتيكات الفاخرة إلى الكنوز البافارية التقليدية. تقدم ميونخ مزيجاً فريداً من الأناقة العصرية والثقافة الغنية.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Commitment to sustainability', de: 'Engagement für Nachhaltigkeit', ar: 'التزام بالاستدامة والبيئة'),
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Verlässlichkeit', ar: 'الدقة والتميز السويسري الراسخ'),
        LocalizedText(en: 'Bespoke travel experiences', de: 'Individuell angepasste Flugpläne', ar: 'تجارب سفر مخصصة بالكامل'),
        LocalizedText(en: 'Global network and expertise', de: 'Erstklassiges globales Partnernetzwerk', ar: 'شبكة عالمية وخبرة متقدمة'),
        LocalizedText(en: 'Discretion and security', de: 'Höchste Sicherheits- und Diskretionsstandards', ar: 'سرية تامة وأمان مطلق'),
        LocalizedText(en: '24/7 Availability and support', de: '24/7-Verfügbarkeit', ar: 'دعم مستمر 24/7 طوال الرحلة'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Oktoberfest Munich:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'What is Oktoberfest? Oktoberfest is the world\'s largest Volksfest (folk festival), held annually in Munich, Germany. It\'s a celebration of Bavarian culture, featuring beer tents, traditional food, music, and amusement rides.'),
          LocalizedText(en: 'When is Oktoberfest held? Oktoberfest typically starts in mid-September and ends on the first Sunday of October.'),
          LocalizedText(en: 'Oktoberfest 2025: September 20th to October 5th, 2025.'),
          LocalizedText(en: 'Where is Oktoberfest held? On the Theresienwiese (Wiesn) in Munich, Germany.'),
          LocalizedText(en: 'How do I get to Oktoberfest? Experience the ultimate in luxury travel with a private jet to Munich, courtesy of Swiss Luxury Services.'),
        ]),
      ],
    ),
    // ── 7. ZURICH – MONACO ────────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-monaco',
      order: 6,
      title: LocalizedText(en: 'Zurich – Monaco', de: 'Zürich – Monaco', ar: 'زيورخ – موناكو'),
      category: LocalizedText(en: 'THE PRINCIPALITY', de: "CÔTE D'AZUR & LUXUS", ar: 'كوت دازور والفخامة المطلقة'),
      duration: '1hr 20 min',
      imageUrl: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ MCM • ~ 1 hr 20 min', de: 'ZRH ⇄ MCM • ~ 1 Std. 20 Min.', ar: 'زيورخ ⇄ موناكو • ~ ساعة و20 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Monaco', de: 'Zürich – Monaco', ar: 'زيورخ – موناكو'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Monaco)', de: 'Ab CHF 3.500 (Zürich–Monaco)', ar: 'من 3,500 فرنك سويسري (زيورخ - موناكو)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Monaco Beckons: Elevate your journey with a Private Jet from Zurich. Our private jet charter service from Zurich to Monaco offers unparalleled comfort, flexibility, and exclusivity. Leave the ordinary behind and embark on a journey tailored to your exact needs and preferences.',
        de: 'Monaco ruft: Fliegen Sie mit Swiss Luxury Services im Privatjet von Zürich an die Côte d\'Azur. Genießen Sie maßgeschneiderten Komfort und exklusive Anschlusstransfers per Helikopter direkt ins Fürstentum.',
        ar: 'سحر موناكو يناديك: ارتقِ برحلتك على متن طائرة خاصة من زيورخ. تقدم سويس لاكجري سيرفيسز أرقى معايير السفر الفاخر.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Exzellenz', ar: 'الدقة والتميز السويسري'),
        LocalizedText(en: 'Discretion and security', de: 'Diskretion und Sicherheit', ar: 'سرية تامة وأمان'),
        LocalizedText(en: 'Bespoke travel experiences', de: 'Maßgeschneiderte Reiseerlebnisse', ar: 'تجارب سفر مصممة خصيصاً'),
        LocalizedText(en: 'Global network and expertise', de: 'Globales Netzwerk und Expertise', ar: 'شبكة عالمية وخبرة في الطيران'),
        LocalizedText(en: '24/7 Availability and support', de: '24/7-Verfügbarkeit und Support', ar: 'دعم وتوافر على مدار الساعة'),
        LocalizedText(en: 'Commitment to sustainability', de: 'Bekenntnis zur Nachhaltigkeit', ar: 'التزام بالاستدامة'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Experience Monaco:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Explore the Glamour: Discover Monaco\'s iconic landmarks, luxurious casinos, and world-class events.'),
          LocalizedText(en: 'Indulge in Luxury: Experience high-end shopping, fine dining, and the principality\'s vibrant nightlife.'),
          LocalizedText(en: 'Embrace the Riviera: Enjoy the beautiful beaches, stunning scenery, and relaxed Mediterranean lifestyle.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: "Don't Miss:")),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Casino de Monte-Carlo: Even if you do not gamble, admire the Belle Époque architecture and soak up the atmosphere of this iconic casino.'),
          LocalizedText(en: 'Prince\'s Palace: Visit the official residence of the Prince of Monaco and witness the changing of the guard ceremony.'),
          LocalizedText(en: 'Oceanographic Museum: Explore the wonders of the marine world at this renowned museum with breathtaking views of the Mediterranean Sea.'),
          LocalizedText(en: 'Monte Carlo Harbor: Admire the luxurious yachts and enjoy a waterfront meal at one of the many restaurants.'),
        ]),
      ],
    ),
    // ── 8. ZURICH – SINGAPORE ─────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-singapore',
      order: 7,
      title: LocalizedText(en: 'Zurich – Singapore', de: 'Zürich – Singapur', ar: 'زيورخ – سنغافورة'),
      category: LocalizedText(en: 'LUXURY MEETS INNOVATION', de: 'LUXUS TRIFFT INNOVATION', ar: 'رحلات القارات طويلة المدى'),
      duration: '10hr 20 min',
      imageUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ SIN • ~ 10 hr 20 min', de: 'ZRH ⇄ SIN • ~ 10 Std. 20 Min.', ar: 'زيورخ ⇄ سنغافورة • ~ 10 ساعات و20 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Singapore', de: 'Zürich – Singapur', ar: 'زيورخ – سنغافورة'),
      startingPrice: LocalizedText(en: 'From CHF 10,500 per hour (Zurich – Singapore)', de: 'Ab CHF 10.500 pro Stunde (Zürich – Singapur)', ar: 'من 10,500 فرنك سويسري لكل ساعة (زيورخ - سنغافورة)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Singapore, the dynamic city-state in Southeast Asia, is a melting pot of cultures, where tradition and modernity merge in a unique way. Discover a vibrant metropolis that impresses with its diversity of people, its rich history, and its forward-thinking architecture.',
        de: 'Singapur, der dynamische Stadtstaat in Südostasien, ist ein Schmelztiegel der Kulturen, in dem Tradition und Moderne auf einzigartige Weise verschmelzen.',
        ar: 'سنغافورة، المدينة-الدولة الديناميكية في جنوب شرق آسيا، هي بوتقة تنصهر فيها الثقافات؛ حيث يلتقي عبق التقاليد مع حداثة المستقبل بأسلوب فريد.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Exzellenz', ar: 'الدقة والتميز السويسري'),
        LocalizedText(en: 'Bespoke travel experiences', de: 'Maßgeschneiderte Reiseerlebnisse', ar: 'تجارب سفر مصممة خصيصاً'),
        LocalizedText(en: 'Global network and expertise', de: 'Globales Netzwerk und Expertise', ar: 'شبكة عالمية وخبرة في الطيران'),
        LocalizedText(en: '24/7 Availability and support', de: '24/7-Verfügbarkeit und Support', ar: 'دعم وتوافر على مدار الساعة'),
        LocalizedText(en: 'Discretion and security', de: 'Diskretion und Sicherheit', ar: 'سرية تامة وأمان'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Cultural Diversity & Heritage:')),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(en: 'Singapore is home to people of various ethnic backgrounds, including Chinese, Malays, Indians, and Eurasians. This diversity is reflected in the city\'s vibrant cultural scene, which ranges from traditional festivals to culinary delights and religious sites.')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Chinatown: Explore the bustling streets of Chinatown, where you will find traditional Chinese temples, authentic cuisine, and colorful shops.'),
          LocalizedText(en: 'Little India: Immerse yourself in the colorful world of Little India, where you can discover Indian temples, fragrant spice shops, and traditional handicrafts.'),
          LocalizedText(en: 'Kampong Glam: Visit Kampong Glam, the historic district of Malay and Arab culture, where you will find the magnificent Sultan Mosque and the Malay Heritage Centre.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Climate & Best Time to Travel:')),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(en: 'Singapore is located near the equator and has a tropical climate with warm temperatures and high humidity all year round. Temperatures usually range between 25 and 32 degrees Celsius.')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Best time to travel: The best time to travel to Singapore is usually from February to April, as these are the driest months with less rain.'),
          LocalizedText(en: 'Rainy season: The rainy season in Singapore lasts from November to January, with frequent and heavy rain showers possible.'),
        ]),
      ],
    ),
    // ── 9. ZURICH – ST. TROPEZ ────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-st-tropez',
      order: 8,
      title: LocalizedText(en: 'Zurich – St. Tropez', de: 'Zürich – St. Tropez', ar: 'زيورخ – سان تروبيه'),
      category: LocalizedText(en: 'RIVIERA LUXURY & LIFESTYLE', de: "CÔTE D'AZUR & LUXUS-LIFESTYLE", ar: 'الريفييرا الفرنسية'),
      duration: '1hr 20 min',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ LTT • ~ 1 hr 20 min', de: 'ZRH ⇄ LTT • ~ 1 Std. 20 Min.', ar: 'زيورخ ⇄ سان تروبيه • ~ ساعة و20 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – St. Tropez', de: 'Zürich – St. Tropez', ar: 'زيورخ – سان تروبيه'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich – St. Tropez)', de: 'Ab CHF 3.500 (Zürich – St. Tropez)', ar: 'من 3,500 فرنك سويسري (زيورخ - سان تروبيه)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Time is your most valuable asset. Escape the constraints of commercial travel and fly directly from Zurich to St. Tropez with Swiss Luxury Services. Say goodbye to crowded airports, lengthy queues, and frustrating delays. Arrive in the heart of the French Riviera, refreshed and ready to immerse yourself in the unparalleled glamour of St. Tropez.',
        de: 'Ihre Zeit ist Ihr kostbarstes Gut. Fliegen Sie mit Swiss Luxury Services direkt von Zürich nach St. Tropez und genießen Sie die Côte d\'Azur in vollen Zügen.',
        ar: 'الوقت هو أثمن ما تملك. تخلص من قيود الرحلات التجارية المزدحمة وحلّق مباشرة من زيورخ إلى سان تروبيه مع سويس لاكجري سيرفيسز.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: '24/7 Dedicated Concierge Service', de: '24/7-Concierge-Service', ar: 'خدمة كونسيرج مخصصة 24/7'),
        LocalizedText(en: 'Maximum Travel Efficiency', de: 'Maximale Reiseeffizienz', ar: 'أقصى درجات الكفاءة والسرعة في السفر'),
        LocalizedText(en: 'Commitment to Sustainable Aviation', de: 'Nachhaltige Luftfahrtlösungen', ar: 'التزام بحلول الطيران المستدام'),
        LocalizedText(en: 'Personalized luxury experiences', de: 'Personalisierte Luxuserlebnisse', ar: 'تجارب فاخرة مصممة حسب طلبك'),
        LocalizedText(en: 'Diverse Private Jet Fleet', de: 'Vielfältige Privatjet-Flotte', ar: 'أسطول طائرات خاصة متنوع وحديث'),
        LocalizedText(en: 'Absolute Privacy & Security', de: 'Absolute Privatsphäre und Sicherheit', ar: 'خصوصية وسرية وأمان كامل'),
        LocalizedText(en: 'Swiss precision and excellence', de: 'Schweizer Präzision und Exzellenz', ar: 'دقة وتميز سويسري أصيل'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Explore the world-renowned boutiques and designer shops that line the charming streets.'),
          LocalizedText(en: 'Indulge in the exquisite dining experiences offered by Michelin-starred restaurants.'),
          LocalizedText(en: 'Relax on the pristine beaches of Pampelonne and soak up the Mediterranean sun.'),
          LocalizedText(en: 'Experience the vibrant nightlife.'),
          LocalizedText(en: 'Enjoy the port, and all the luxury yachts.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'Experience St. Tropez:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Explore the Luxury: Indulge in high-end shopping at designer boutiques, dine at Michelin-starred restaurants, and experience the vibrant nightlife.'),
          LocalizedText(en: 'Embrace the Riviera Lifestyle: Relax on the iconic beaches of Pampelonne, enjoy the stunning coastal scenery, and experience the relaxed Mediterranean atmosphere.'),
          LocalizedText(en: 'Enjoy the port: See the world\'s most luxurious yachts.'),
        ]),
        ContentBlock(type: ContentBlockType.subheading, text: LocalizedText(en: 'St. Tropez Vacation:')),
        ContentBlock(type: ContentBlockType.bulletList, items: [
          LocalizedText(en: 'Seamless Transfers: Upon arrival, arrange for luxury car services or helicopter transfers to your villa or yacht, bypassing local traffic.'),
          LocalizedText(en: 'Local Exploration: Consider renting a luxury vehicle or scooter to explore the charming villages and scenic coastal roads surrounding St. Tropez.'),
          LocalizedText(en: 'Boat Excursions: Charter a private yacht or boat for day trips to nearby islands like Porquerolles or to explore the stunning coastline.'),
          LocalizedText(en: 'Exclusive Experiences: Arrange private wine tours in the surrounding vineyards or exclusive access to beach clubs.'),
        ]),
      ],
    ),
    // ── 10. ZURICH – STOCKHOLM ────────────────────────────────────────────────
    DestinationAdminModel(
      id: 'zurich-stockholm',
      order: 9,
      title: LocalizedText(en: 'Zurich – Stockholm', de: 'Zürich – Stockholm', ar: 'زيورخ – ستوكهولم'),
      category: LocalizedText(en: 'SCANDINAVIAN ELEGANCE', de: 'SKANDINAVISCHE ELEGANZ', ar: 'العواصم الاسكندنافية'),
      duration: '2hr 15 min',
      imageUrl: 'https://images.unsplash.com/photo-1509356843151-3e7d96241e11?auto=format&fit=crop&w=1200&q=80',
      overlayTag: LocalizedText(en: 'ZRH ⇄ ARN • ~ 2 hr 20 min', de: 'ZRH ⇄ ARN • ~ 2 Std. 15 Min.', ar: 'زيورخ ⇄ ستوكهولم • ~ ساعتان و15 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Stockholm', de: 'Zürich – Stockholm', ar: 'زيورخ – ستوكهولم'),
      startingPrice: LocalizedText(en: 'From CHF 3,500 (Zurich–Stockholm)', de: 'Ab CHF 3.500 (Zürich–Stockholm)', ar: 'من 3,500 فرنك سويسري (زيورخ - ستوكهولم)'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      description: LocalizedText(
        en: 'Embark on a seamless journey from the picturesque Swiss city of Zurich to the vibrant Swedish capital, Stockholm. Whether for business or leisure, a direct flight from Zurich to Stockholm offers you a comfortable and time-saving way to reach this fascinating metropolis.',
        de: 'Reisen Sie nahtlos von der malerischen Schweizer Stadt Zürich in die lebendige schwedische Hauptstadt Stockholm. Entdecken Sie mit uns die Vorzüge eines direkten Privatjetflugs.',
        ar: 'انطلق في رحلة سلسة ومريحة من مدينة زيورخ السويسرية الساحرة إلى العاصمة السويدية المفعمة بالحياة، ستوكهولم.',
      ),
      whyTravelWithUs: [
        LocalizedText(en: 'A dedicated team that puts your needs first.', de: 'Ein engagiertes Team, das Ihre Bedürfnisse in den Vordergrund stellt.', ar: 'فريق عمل متفانٍ يضع احتياجاتك في المقام الأول.'),
        LocalizedText(en: 'Highest safety standards and absolute discretion.', de: 'Höchste Sicherheitsstandards und absolute Diskretion.', ar: 'أعلى معايير السلامة والأمان وسرية تامة.'),
        LocalizedText(en: 'A fleet of modern and well-maintained private jets.', de: 'Eine Flotte moderner und gut gewarteter Privatjets.', ar: 'أسطول من الطائرات الخاصة الحديثة ذات الصيانة الفائقة.'),
        LocalizedText(en: 'Tailor-made solutions for your individual travel requirements.', de: 'Maßgeschneiderte Lösungen für Ihre individuellen Reiseanforderungen.', ar: 'حلول مصممة بدقة لتلائم جدولك ومتطلباتك الفردية.'),
        LocalizedText(en: 'Years of experience in the field of private aviation.', de: 'Jahrelange Erfahrung im Bereich der Privatluftfahrt.', ar: 'سنوات طويلة من الخبرة والريادة في الطيران الخاص.'),
      ],
      contentBlocks: [
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(
          en: 'Forget the hustle and bustle and inconveniences of conventional air travel. Your time is precious, and your journey should be too. With Swiss Luxury Services, experience ultimate comfort and maximum efficiency on your flight from Zurich to Stockholm – without layovers, without waiting times, without compromises.',
          de: 'Vergessen Sie die Unannehmlichkeiten des herkömmlichen Luftreisens. Ihre Zeit ist kostbar. Mit Swiss Luxury Services erleben Sie ultimativen Komfort auf Ihrem Flug von Zürich nach Stockholm.',
          ar: 'انسَ متاعب السفر الجوي التقليدي. وقتك ثمين وكذلك رحلتك. مع سويس لاكجري سيرفيسز، استمتع بالراحة القصوى على رحلتك من زيورخ إلى ستوكهولم.',
        )),
        ContentBlock(type: ContentBlockType.paragraph, text: LocalizedText(
          en: 'When you choose a private jet flight from Zurich to Stockholm with Swiss Luxury Services, you are not just choosing a convenient way to travel, but a comprehensive luxury experience. We take care of all aspects of your journey, from pick-up at your desired location in Zurich to the organization of your onward transport in Stockholm.',
          de: 'Wenn Sie sich für einen Privatjetflug von Zürich nach Stockholm mit Swiss Luxury Services entscheiden, wählen Sie ein umfassendes Luxuserlebnis.',
          ar: 'عندما تختار رحلة طائرة خاصة من زيورخ إلى ستوكهولم، فأنت تختار تجربة فاخرة شاملة من الألف إلى الياء.',
        )),
      ],
    ),
  ];

  final List<DestinationAdminModel> _destinations = List.from(defaultDestinations);
  final _streamController = StreamController<List<DestinationAdminModel>>.broadcast();
  bool _isSeeded = false;

  DestinationsRepository() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('destinations').orderBy('order').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _destinations.clear();
            for (final doc in snapshot.docs) {
              _destinations.add(DestinationAdminModel.fromMap(doc.data(), doc.id));
            }
            _notify();
            if (snapshot.docs.length < defaultDestinations.length && !_isSeeded) {
              _isSeeded = true;
              seedInitialDestinations(force: true);
            }
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialDestinations(force: true);
          }
        },
        onError: (e) {
          dev.log('Firestore destinations listener error: $e', name: 'DestinationsRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore destinations: $e', name: 'DestinationsRepository');
      _notify();
    }
  }

  Future<void> seedInitialDestinations({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('destinations').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final dest in defaultDestinations) {
        final docRef = _firestore.collection('destinations').doc(dest.id);
        batch.set(docRef, dest.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial destinations seeded successfully to Firestore (${defaultDestinations.length} destinations)', name: 'DestinationsRepository');
    } catch (e) {
      dev.log('Error seeding initial destinations to Firestore: $e', name: 'DestinationsRepository');
      rethrow;
    }
  }

  void _notify() {
    _destinations.sort((a, b) => a.order.compareTo(b.order));
    _streamController.add(List.unmodifiable(_destinations));
  }

  Stream<List<DestinationAdminModel>> watchDestinations() {
    return Stream<List<DestinationAdminModel>>.multi((controller) {
      _destinations.sort((a, b) => a.order.compareTo(b.order));
      controller.add(List.unmodifiable(_destinations));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<DestinationAdminModel> get currentDestinations => List.unmodifiable(_destinations);

  Future<DestinationAdminModel?> getDestinationById(String id) async {
    try {
      final doc = await _firestore.collection('destinations').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final dest = DestinationAdminModel.fromMap(doc.data()!, doc.id);
        final idx = _destinations.indexWhere((d) => d.id == id);
        if (idx >= 0) {
          _destinations[idx] = dest;
        } else {
          _destinations.add(dest);
        }
        return dest;
      }
    } catch (e) {
      dev.log('Error fetching destination $id from Firestore: $e', name: 'DestinationsRepository');
    }

    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDestination(DestinationAdminModel destination) async {
    final newId = destination.id.isNotEmpty ? destination.id : 'dest_${DateTime.now().millisecondsSinceEpoch}';
    final index = _destinations.indexWhere((d) => d.id == newId || (destination.id.isNotEmpty && d.id == destination.id));
    final finalOrder = destination.order > 0 ? destination.order : (index >= 0 ? _destinations[index].order : _destinations.length);
    final finalDest = destination.copyWith(
      id: newId,
      order: finalOrder,
      createdAt: destination.createdAt ?? (index >= 0 ? _destinations[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _destinations[index] = finalDest;
    } else {
      _destinations.add(finalDest);
    }
    _notify();

    try {
      await _firestore.collection('destinations').doc(newId).set(finalDest.toMap(), SetOptions(merge: true));
    } catch (e) {
      dev.log('Error saving destination $newId to Firestore: $e', name: 'DestinationsRepository');
      // Do not rethrow — in-memory update already succeeded.
    }
  }

  Future<void> deleteDestination(String id) async {
    _destinations.removeWhere((d) => d.id == id);
    _notify();

    try {
      await _firestore.collection('destinations').doc(id).delete();
    } catch (e) {
      dev.log('Error deleting destination $id from Firestore: $e', name: 'DestinationsRepository');
      // Do not rethrow — in-memory deletion already succeeded.
    }
  }

  Future<void> toggleDestinationStatus(String id, bool isActive) async {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _destinations[index] = _destinations[index].copyWith(isActive: isActive, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('destinations').doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      dev.log('Error toggling destination status in Firestore: $e', name: 'DestinationsRepository');
      // Do not rethrow — in-memory update already succeeded.
    }
  }

  Future<void> updateDestinationsOrder(List<DestinationAdminModel> reordered) async {
    for (int i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      final idx = _destinations.indexWhere((d) => d.id == item.id);
      if (idx >= 0) {
        _destinations[idx] = _destinations[idx].copyWith(order: i);
      }
    }
    _notify();

    try {
      final batch = _firestore.batch();
      for (int i = 0; i < reordered.length; i++) {
        final docRef = _firestore.collection('destinations').doc(reordered[i].id);
        batch.update(docRef, {'order': i});
      }
      await batch.commit();
    } catch (e) {
      dev.log('Error updating destinations order in Firestore: $e', name: 'DestinationsRepository');
      // Do not rethrow — in-memory reorder already succeeded.
    }
  }
}
