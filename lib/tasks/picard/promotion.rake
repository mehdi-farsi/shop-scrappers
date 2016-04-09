namespace :picard do
  desc "Get Promotion from picard.fr"
  task :promotions => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    #################
    # Initialization
    #################

    # We can also pass this URL via a task argument
    BASE_URL = "http://www.picard.fr"

    website = Website.where(name: "Picard").first

    promotion = if website.promotion.nil?
      Promotion.create(website_id: website.id)
    else
      website.promotion
    end

    promotions_url      = "#{BASE_URL}/selection"
    page                = Nokogiri::HTML(RestClient.get(promotions_url+"?viewAll=1"))
    product_number      = page.css('.result_number').text.squish.to_i
    page                = Nokogiri::HTML(RestClient.get(promotions_url+"?start=0&sz=#{product_number}"))

    #############
    # Promotions
    #############

    puts "#####################"
    puts "#Scrapper: Promotion"
    puts "#####################", ""

    promotion_products  = []

    page.css(".push_produit_01").each do |product_div|
      page_url          = URI.escape "#{product_div.css(".desc a.productGTMClickCategAll").first[:href]}"
      product_page      = Nokogiri::HTML(RestClient.get(page_url))
      promotion_product = {}

      normal_price   = product_page.css(".price div .old_price b").text.squish.to_f
      discount_price = product_page.css(".last_price").text.squish.to_f  


      promotion_product[:url]               = page_url
      promotion_product[:name]              = product_page.css("h1 span b").text.squish
      promotion_product[:description_offer] = "Réduction"
      promotion_product[:information_offer] = "#{discount_price}€ au lieu de #{normal_price}€"

      promotion_products << promotion_product
      puts "Promotion: #{promotion_product[:name]}"
    end

    promotion_product_count = promotion_products.size

    promotion_products.each_with_index do |promotion_product, index|
      PromotionProduct.create(promotion_product.merge(promotion_id: promotion.id))

      print "\rimport promotions in db: [#{index + 1}/#{promotion_product_count}]"
    end
  end
end