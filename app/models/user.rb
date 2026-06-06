class User < ApplicationRecord
  belongs_to :partner
  has_many :created_quotes, class_name: "Quote", foreign_key: :created_by_id, inverse_of: :created_by

  validates :username, presence: true
end
