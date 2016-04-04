class AddWebsiteToPromotion < ActiveRecord::Migration
  def change
    add_reference :promotions, :website, index: true, foreign_key: true
  end
end
