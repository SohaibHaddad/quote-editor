class Partner < ApplicationRecord
  has_many :users
  has_many :quotes

  validates :name, presence: true
end
