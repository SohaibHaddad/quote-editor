class User < ApplicationRecord
  devise :database_authenticatable, :rememberable

  belongs_to :partner
  has_many :created_quotes, class_name: "Quote", foreign_key: :created_by_id, inverse_of: :created_by

  validates :username, presence: true, uniqueness: { case_sensitive: false }
end
