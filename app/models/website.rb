class Website < ActiveRecord::Base
  has_many :categories
  has_many :shops
end


