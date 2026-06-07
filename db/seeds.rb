partner = Partner.find_or_create_by!(name: "Kactus resort and hotels")
password = ENV.fetch("SEED_PASSWORD", "password123")

users = [
  "Sohaib Haddad",
  "Kevin Dreno",
  "Benoit Calin"
].index_with do |username|
  user = User.where("LOWER(username) = ?", username.downcase).first_or_initialize
  user.username = username
  user.partner = partner
  user.password = password
  user.password_confirmation = password
  user.save!
  user
end

quotes_data = [
  {
    name: "Aurora Labs - Séminaire de direction à Cassis",
    created_by: users.fetch("Sohaib Haddad"),
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
    created_by: users.fetch("Kevin Dreno"),
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
    created_by: users.fetch("Benoit Calin"),
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
    created_by: users.fetch("Sohaib Haddad"),
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
    created_by: users.fetch("Kevin Dreno"),
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
    created_by: users.fetch("Benoit Calin"),
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
    created_by: users.fetch("Sohaib Haddad"),
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
    created_by: users.fetch("Kevin Dreno"),
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
    created_by: users.fetch("Benoit Calin"),
    state: :in_draft,
    items: [
      { name: "Pavillon atelier dans les jardins", quantity: 2, unit_price_before_tax_in_cents: 260_00, tax_rate: 20 },
      { name: "Déjeuner végétarien de saison", quantity: 22, unit_price_before_tax_in_cents: 29_00, tax_rate: 10 },
      { name: "Intervenant yoga matinal", quantity: 2, unit_price_before_tax_in_cents: 145_00, tax_rate: 20 },
      { name: "Crédit soin spa", quantity: 22, unit_price_before_tax_in_cents: 35_00, tax_rate: 20 }
    ]
  }
]

quotes_data.each do |quote_data|
  quote = partner.quotes.find_or_initialize_by(name: quote_data.fetch(:name))
  quote.created_by = quote_data.fetch(:created_by)
  quote.state = "in_draft"
  quote.save!

  quote.quote_items.destroy_all

  quote_data.fetch(:items).each do |item_data|
    quote.quote_items.create!(item_data)
  end

  if quote_data.fetch(:state) == :validated
    quote.validate_quote
    quote.save!
  else
    quote.save! if quote.changed?
  end
end
