class Promotion < ActiveRecord::Base
  has_many :promotion_products, dependent: :destroy

  belongs_to :website
end
