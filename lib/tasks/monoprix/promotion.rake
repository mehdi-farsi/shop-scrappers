namespace :monoprix do
  desc "Get Promotion from monoprix.fr"
  task :promotions => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    #################
    # Initialization
    #################

    # We can also pass this URL via a task argument
    BASE_URL = "https://www.monoprix.fr"

    promotion = if Promotion.count == 0
      Promotion.create
    else
      Promotion.first
    end

    page_number = 1 # add 48 to go to the next page

    url = "#{BASE_URL}/promotions?N=4294964086+4294964085+4294966807+4294964025+4294964084+4294964022+4294964021+4294964915+4294964912+4294959686+4294964914+4294960171+4294966805&showProduct=true"

    page = Nokogiri::HTML(RestClient.get("#{url}&No=#{page_number}"))

    promotion_product_count = page.css("#rightContent strong").text.squish.to_i
    max_page = (page.css("#rightContent strong").text.squish.to_f / 48.0).ceil


    #############
    # Promotions
    #############

    puts "#####################"
    puts "#Scrapper: Promotion"
    puts "#####################", ""

    promotion_products = []

    1.upto(max_page) do |n|

      page_number = if n == 1
        1
      else
        1 + ((n - 1) * 48)
      end

      page = Nokogiri::HTML(RestClient.get("#{url}&No=#{page_number}"))
      promotion_links = page.css("#rightContent .item_produits_courses li > a").select # Select all links

      puts "Page #{n}"

      promotion_links.each_with_index do |promotion_link, index|
        promotion_url = "#{BASE_URL}#{promotion_link[:href]}"

        promotion_page = Nokogiri::HTML(RestClient.get(promotion_url))

        promotion_product = {}

        card_offer = promotion_page.css(".tag-promo").select.first[:class].to_s.match(/carte/).nil? ? false : true

        promotion_product[:url]               = promotion_url
        promotion_product[:name]              = promotion_page.css("aside h3").text.squish
        promotion_product[:description_offer] = promotion_page.css(".tag-promo").text.squish
        promotion_product[:information_offer] = promotion_page.css("#priceValidUntil").text.squish
        promotion_product[:card_offer]        = card_offer

        promotion_products << promotion_product
        puts "\tPromotion: #{promotion_product[:name]}"
      end
    end;puts

    promotion_product_count = promotion_products.size

    promotion_products.each_with_index do |promotion_product, index|
      PromotionProduct.create(promotion_product.merge(promotion_id: promotion.id))

      print "\rimport promotions in db: [#{index + 1}/#{promotion_product_count}]"
    end

    puts
  end
end
