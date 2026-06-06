# Database fields:
# - id: integer
# - name: string
# - created_at: datetime
# - updated_at: datetime
class Partner < ApplicationRecord
  has_many :users
  has_many :quotes

  validates :name, presence: true
end
