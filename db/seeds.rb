password = ENV.fetch("SEED_PASSWORD", "password123")

def upsert_user(partner, username, password)
  user = User.where("LOWER(username) = ?", username.downcase).first_or_initialize
  user.username = username
  user.partner = partner
  user.password = password
  user.password_confirmation = password
  user.save!
  user
end

def seed_partner(name:, usernames:, quotes_data:, password:)
  partner = Partner.find_or_create_by!(name: name)

  users = usernames.index_with do |username|
    upsert_user(partner, username, password)
  end

  quotes_data.each do |quote_data|
    quote = partner.quotes.find_or_initialize_by(name: quote_data.fetch(:name))
    quote.created_by = users.fetch(quote_data.fetch(:created_by))
    quote.state = "in_draft"
    quote.save!

    quote.quote_items.destroy_all

    quote_data.fetch(:items).each do |item_data|
      quote.quote_items.create!(item_data)
    end

    if quote_data.fetch(:state) == :validated
      quote.validate_quote
      quote.save!
    elsif quote.changed?
      quote.save!
    end
  end
end

seed_partner(
  name: "Kactus resort and hotels",
  usernames: [
    "Sohaib Haddad",
    "Kevin Dreno",
    "Benoit Calin"
  ],
  password: password,
  quotes_data: [
    {
      name: "Aurora Labs - Séminaire de direction à Cassis",
      created_by: "Sohaib Haddad",
      state: :in_draft,
      items: [
        { name: "Location de salle de réunion avec vue mer", quantity: 2, unit_price_before_tax_in_cents: 185_00, tax_rate: 20 },
        { name: "Petit-déjeuner d'accueil pour 18 invités", quantity: 18, unit_price_before_tax_in_cents: 14_50, tax_rate: 10 },
        { name: "Cocktail rooftop au coucher du soleil", quantity: 18, unit_price_before_tax_in_cents: 29_00, tax_rate: 20 },
        { name: "Coordination des navettes aéroport", quantity: 3, unit_price_before_tax_in_cents: 95_00, tax_rate: 20 }
      ]
    },
    {
      name: "Northstar Advisory - Séminaire stratégique à Lyon",
      created_by: "Kevin Dreno",
      state: :validated,
      items: [
        { name: "Salon de conférence privatisé", quantity: 1, unit_price_before_tax_in_cents: 420_00, tax_rate: 20 },
        { name: "Menu déjeuner du chef", quantity: 24, unit_price_before_tax_in_cents: 38_00, tax_rate: 10 },
        { name: "Café et viennoiseries à volonté", quantity: 24, unit_price_before_tax_in_cents: 9_50, tax_rate: 10 },
        { name: "Assistance technicien audiovisuel", quantity: 1, unit_price_before_tax_in_cents: 260_00, tax_rate: 20 }
      ]
    },
    {
      name: "Blue Orbit Studio - Week-end de lancement produit à Biarritz",
      created_by: "Benoit Calin",
      state: :in_draft,
      items: [
        { name: "Privatisation de villa face à l'océan", quantity: 2, unit_price_before_tax_in_cents: 960_00, tax_rate: 20 },
        { name: "Dîner sous la pergola", quantity: 32, unit_price_before_tax_in_cents: 52_00, tax_rate: 10 },
        { name: "Duo acoustique en live", quantity: 1, unit_price_before_tax_in_cents: 780_00, tax_rate: 20 },
        { name: "Cadeaux d'accueil personnalisés", quantity: 32, unit_price_before_tax_in_cents: 11_00, tax_rate: 20 }
      ]
    },
    {
      name: "Helios Capital - Retraite du comité à Megève",
      created_by: "Sohaib Haddad",
      state: :in_draft,
      items: [
        { name: "Installation de salle de conseil dans le chalet", quantity: 1, unit_price_before_tax_in_cents: 680_00, tax_rate: 20 },
        { name: "Dîner dégustation au coin du feu", quantity: 12, unit_price_before_tax_in_cents: 74_00, tax_rate: 10 },
        { name: "Accès spa demi-journée", quantity: 12, unit_price_before_tax_in_cents: 32_00, tax_rate: 20 },
        { name: "Transfert privé depuis Genève", quantity: 2, unit_price_before_tax_in_cents: 210_00, tax_rate: 20 }
      ]
    },
    {
      name: "Maison Cobalt - Dîner presse à Paris",
      created_by: "Kevin Dreno",
      state: :validated,
      items: [
        { name: "Location de salle à manger privative", quantity: 1, unit_price_before_tax_in_cents: 540_00, tax_rate: 20 },
        { name: "Menu dégustation en cinq services", quantity: 28, unit_price_before_tax_in_cents: 68_00, tax_rate: 10 },
        { name: "Accord mocktails signature", quantity: 28, unit_price_before_tax_in_cents: 16_00, tax_rate: 10 },
        { name: "Décoration florale des tables", quantity: 1, unit_price_before_tax_in_cents: 240_00, tax_rate: 20 }
      ]
    },
    {
      name: "Brightforge AI - Sommet leadership à Bordeaux",
      created_by: "Benoit Calin",
      state: :in_draft,
      items: [
        { name: "Privatisation du domaine viticole", quantity: 1, unit_price_before_tax_in_cents: 1_250_00, tax_rate: 20 },
        { name: "Buffet déjeuner au vignoble", quantity: 40, unit_price_before_tax_in_cents: 34_00, tax_rate: 10 },
        { name: "Atelier dégustation avec sommelier", quantity: 40, unit_price_before_tax_in_cents: 18_00, tax_rate: 20 },
        { name: "Transfert autocar depuis la gare Saint-Jean", quantity: 2, unit_price_before_tax_in_cents: 165_00, tax_rate: 20 }
      ]
    },
    {
      name: "Velvet Atlas - Résidence créative à Arles",
      created_by: "Sohaib Haddad",
      state: :in_draft,
      items: [
        { name: "Location de studio avec cour intérieure", quantity: 3, unit_price_before_tax_in_cents: 310_00, tax_rate: 20 },
        { name: "Brunch fermier", quantity: 16, unit_price_before_tax_in_cents: 24_00, tax_rate: 10 },
        { name: "Forfait location de vélos", quantity: 16, unit_price_before_tax_in_cents: 12_00, tax_rate: 20 },
        { name: "Installation de projection en soirée", quantity: 1, unit_price_before_tax_in_cents: 295_00, tax_rate: 20 }
      ]
    },
    {
      name: "Granite Peak - Kick-off commercial à Chamonix",
      created_by: "Kevin Dreno",
      state: :validated,
      items: [
        { name: "Salle plénière en lodge de montagne", quantity: 2, unit_price_before_tax_in_cents: 430_00, tax_rate: 20 },
        { name: "Dîner alpin", quantity: 26, unit_price_before_tax_in_cents: 58_00, tax_rate: 10 },
        { name: "Session raquettes avec guide", quantity: 26, unit_price_before_tax_in_cents: 21_00, tax_rate: 20 },
        { name: "Pause chocolat chaud", quantity: 26, unit_price_before_tax_in_cents: 7_50, tax_rate: 10 }
      ]
    },
    {
      name: "Lumen Health - Retraite bien-être à Aix-en-Provence",
      created_by: "Benoit Calin",
      state: :in_draft,
      items: [
        { name: "Pavillon atelier dans les jardins", quantity: 2, unit_price_before_tax_in_cents: 260_00, tax_rate: 20 },
        { name: "Déjeuner végétarien de saison", quantity: 22, unit_price_before_tax_in_cents: 29_00, tax_rate: 10 },
        { name: "Intervenant yoga matinal", quantity: 2, unit_price_before_tax_in_cents: 145_00, tax_rate: 20 },
        { name: "Crédit soin spa", quantity: 22, unit_price_before_tax_in_cents: 35_00, tax_rate: 20 }
      ]
    }
  ]
)

seed_partner(
  name: "Cheikh hotels and services",
  usernames: [
    "Aya Cheikh",
    "Sohaib Haddad - C"
  ],
  password: password,
  quotes_data: [
    {
      name: "Atlas Energy - Convention commerciale à Marrakech",
      created_by: "Aya Cheikh",
      state: :validated,
      items: [
        { name: "Privatisation du patio central", quantity: 1, unit_price_before_tax_in_cents: 890_00, tax_rate: 20 },
        { name: "Buffet marocain premium", quantity: 85, unit_price_before_tax_in_cents: 31_00, tax_rate: 10 },
        { name: "Scène, sonorisation et éclairage", quantity: 1, unit_price_before_tax_in_cents: 1_450_00, tax_rate: 20 },
        { name: "Kit d'accueil brodé", quantity: 85, unit_price_before_tax_in_cents: 9_00, tax_rate: 20 },
        { name: "Transferts aéroport VIP", quantity: 8, unit_price_before_tax_in_cents: 78_00, tax_rate: 20 }
      ]
    },
    {
      name: "Noura Capital - Retraite investisseurs à Tanger",
      created_by: "Sohaib Haddad - C",
      state: :in_draft,
      items: [
        { name: "Suite board meeting avec terrasse", quantity: 2, unit_price_before_tax_in_cents: 510_00, tax_rate: 20 },
        { name: "Dîner signature vue détroit", quantity: 18, unit_price_before_tax_in_cents: 64_00, tax_rate: 10 },
        { name: "Pause thé et pâtisseries orientales", quantity: 18, unit_price_before_tax_in_cents: 12_00, tax_rate: 10 },
        { name: "Chauffeur privé journée", quantity: 3, unit_price_before_tax_in_cents: 160_00, tax_rate: 20 }
      ]
    },
    {
      name: "Sirocco Media - Tournage campagne à Essaouira",
      created_by: "Aya Cheikh",
      state: :in_draft,
      items: [
        { name: "Location riad exclusif équipe production", quantity: 4, unit_price_before_tax_in_cents: 420_00, tax_rate: 20 },
        { name: "Restauration plateau de tournage", quantity: 45, unit_price_before_tax_in_cents: 22_00, tax_rate: 10 },
        { name: "Navettes techniques", quantity: 6, unit_price_before_tax_in_cents: 95_00, tax_rate: 20 },
        { name: "Régie rooftop coucher du soleil", quantity: 2, unit_price_before_tax_in_cents: 380_00, tax_rate: 20 }
      ]
    },
    {
      name: "Palm Ventures - Séjour incentive à Agadir",
      created_by: "Sohaib Haddad - C",
      state: :validated,
      items: [
        { name: "Pack chambres premium mer", quantity: 30, unit_price_before_tax_in_cents: 155_00, tax_rate: 10 },
        { name: "Soirée barbecue sur la plage", quantity: 30, unit_price_before_tax_in_cents: 47_00, tax_rate: 10 },
        { name: "Animation percussion et danse", quantity: 1, unit_price_before_tax_in_cents: 620_00, tax_rate: 20 },
        { name: "Excursion quad dans les dunes", quantity: 30, unit_price_before_tax_in_cents: 39_00, tax_rate: 20 }
      ]
    },
    {
      name: "Darina Bio - Séminaire RSE à Ouarzazate",
      created_by: "Aya Cheikh",
      state: :in_draft,
      items: [
        { name: "Écolodge en privatisation partielle", quantity: 3, unit_price_before_tax_in_cents: 340_00, tax_rate: 20 },
        { name: "Atelier cuisine locale durable", quantity: 24, unit_price_before_tax_in_cents: 18_00, tax_rate: 10 },
        { name: "Projection plein air et assises", quantity: 1, unit_price_before_tax_in_cents: 410_00, tax_rate: 20 },
        { name: "Visite guidée oasis et coopérative", quantity: 24, unit_price_before_tax_in_cents: 14_00, tax_rate: 20 }
      ]
    }
  ]
)

seed_partner(
  name: "Med hotels and resorts",
  usernames: [
    "Samiha Med",
    "Sohaib Haddad - Med"
  ],
  password: password,
  quotes_data: [
    {
      name: "Azure Pharma - Congrès annuel à Barcelone",
      created_by: "Samiha Med",
      state: :validated,
      items: [
        { name: "Grand ballroom et foyer", quantity: 2, unit_price_before_tax_in_cents: 1_180_00, tax_rate: 20 },
        { name: "Déjeuners networking", quantity: 140, unit_price_before_tax_in_cents: 36_00, tax_rate: 10 },
        { name: "Badges et comptoir accueil", quantity: 140, unit_price_before_tax_in_cents: 6_50, tax_rate: 20 },
        { name: "Streaming plénière", quantity: 1, unit_price_before_tax_in_cents: 2_100_00, tax_rate: 20 },
        { name: "Cocktail de clôture terrasse", quantity: 140, unit_price_before_tax_in_cents: 24_00, tax_rate: 10 }
      ]
    },
    {
      name: "Oliva Consulting - Séminaire managers à Valence",
      created_by: "Sohaib Haddad - Med",
      state: :in_draft,
      items: [
        { name: "Salle workshop lumineuse", quantity: 2, unit_price_before_tax_in_cents: 295_00, tax_rate: 20 },
        { name: "Pauses café méditerranéennes", quantity: 36, unit_price_before_tax_in_cents: 8_50, tax_rate: 10 },
        { name: "Déjeuner paella signature", quantity: 36, unit_price_before_tax_in_cents: 27_00, tax_rate: 10 },
        { name: "Location vélo bord de mer", quantity: 36, unit_price_before_tax_in_cents: 13_00, tax_rate: 20 }
      ]
    },
    {
      name: "Solaris Retail - Lancement réseau à Malaga",
      created_by: "Samiha Med",
      state: :in_draft,
      items: [
        { name: "Privatisation rooftop sunset", quantity: 1, unit_price_before_tax_in_cents: 760_00, tax_rate: 20 },
        { name: "Ateliers corners produits", quantity: 6, unit_price_before_tax_in_cents: 120_00, tax_rate: 20 },
        { name: "Buffet tapas premium", quantity: 95, unit_price_before_tax_in_cents: 29_00, tax_rate: 10 },
        { name: "DJ lounge et light design", quantity: 1, unit_price_before_tax_in_cents: 840_00, tax_rate: 20 }
      ]
    },
    {
      name: "Blue Harbor Tech - Offsite produit à Alicante",
      created_by: "Sohaib Haddad - Med",
      state: :validated,
      items: [
        { name: "Villa de travail en bord de mer", quantity: 3, unit_price_before_tax_in_cents: 690_00, tax_rate: 20 },
        { name: "Breakfast boxes healthy", quantity: 28, unit_price_before_tax_in_cents: 13_00, tax_rate: 10 },
        { name: "Dîner chef invité", quantity: 28, unit_price_before_tax_in_cents: 54_00, tax_rate: 10 },
        { name: "Session voile équipe", quantity: 28, unit_price_before_tax_in_cents: 42_00, tax_rate: 20 }
      ]
    },
    {
      name: "Terra Verde - Rencontre distributeurs à Palma",
      created_by: "Samiha Med",
      state: :in_draft,
      items: [
        { name: "Salon jardin avec verrière", quantity: 1, unit_price_before_tax_in_cents: 560_00, tax_rate: 20 },
        { name: "Déjeuner locavore", quantity: 48, unit_price_before_tax_in_cents: 33_00, tax_rate: 10 },
        { name: "Accueil fruits pressés", quantity: 48, unit_price_before_tax_in_cents: 7_50, tax_rate: 10 },
        { name: "Navette port-hôtel", quantity: 4, unit_price_before_tax_in_cents: 115_00, tax_rate: 20 }
      ]
    },
    {
      name: "Mirage Events - Festival créatif à Ibiza",
      created_by: "Sohaib Haddad - Med",
      state: :in_draft,
      items: [
        { name: "Privatisation beach club matinale", quantity: 2, unit_price_before_tax_in_cents: 1_050_00, tax_rate: 20 },
        { name: "Brunch DJ set", quantity: 110, unit_price_before_tax_in_cents: 31_00, tax_rate: 10 },
        { name: "Scénographie arches et fleurs", quantity: 1, unit_price_before_tax_in_cents: 980_00, tax_rate: 20 },
        { name: "Photo booth et contenu social", quantity: 1, unit_price_before_tax_in_cents: 730_00, tax_rate: 20 }
      ]
    }
  ]
)
