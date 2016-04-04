class Website < ActiveRecord::Base
  has_many :categories
  has_one  :promotion
  has_many :shops
end


