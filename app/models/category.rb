class Category < ActiveRecord::Base
  belongs_to :website
  has_many :sections
end
