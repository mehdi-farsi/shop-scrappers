class Promotion < ActiveRecord::Base
  has_many :promotion_products, dependent: :destroy
end
