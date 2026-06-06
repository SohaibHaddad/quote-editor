partner_name = ENV.fetch("SEED_PARTNER_NAME", "Demo Partner")
username = ENV.fetch("SEED_USERNAME", "demo")
password = ENV.fetch("SEED_PASSWORD", "password123")

partner = Partner.find_or_create_by!(name: partner_name)
user = User.find_or_initialize_by(username: username)
user.partner = partner
user.password = password
user.password_confirmation = password
user.save!
