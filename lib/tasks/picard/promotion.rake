namespace :naturalia do
  desc "Get Promotion from monoprix.fr"
  task :promotions => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    #################
    # Initialization
    #################

    # We can also pass this URL via a task argument
    BASE_URL = "http://www.naturalia.fr"

    website = Website.where(name: "Naturalia").first

    promotion = if website.promotion.nil?
      Promotion.create(website_id: website.id)
    else
      Promotion.first
    end

    page_number = 1 # add 48 to go to the next page

    promotions_url = "#{BASE_URL}/promotions"
    page = Nokogiri::HTML(RestClient.get(promotions_url))


    #############
    # Promotions
    #############

    puts "#####################"
    puts "#Scrapper: Promotion"
    puts "#####################", ""

    promotion_products = []

    promotion_product_links = page.css(".acceder").select # Select all links


    promotion_product_links.each_with_index do |promotion_link, index|
      promotion_url = "#{BASE_URL}#{promotion_link[:href]}"

      redirection = false

      response = RestClient.get(promotion_url) do |response, request, result, &block|
        if [301, 302, 307].include? response.code
          redirection = true
          response.follow_redirection(request, result, &block)
        else
          response.return!(request, result, &block)
        end
      end

      puts "#{promotion_url} is no longer available" if redirection
      next if redirection

      promotion_page = Nokogiri::HTML(response)

      promotion_product = {}

      normal_price   = promotion_page.css(".prixnormal").children.first.to_s.gsub(',', '.').to_f
      discount_price = promotion_page.css(".prixpromo").children.first.to_s.gsub(',', '.').to_f

      promotion_product[:url]               = promotion_url
      promotion_product[:name]              = promotion_page.css(".titreProduit h4").text.squish
      promotion_product[:description_offer] = "Réduction"
      promotion_product[:information_offer] = "#{discount_price}€ au lieu de #{normal_price}€"

      promotion_products << promotion_product
      puts "Promotion: #{promotion_product[:name]}"
    end; puts

    promotion_product_count = promotion_products.size

    promotion_products.each_with_index do |promotion_product, index|
      PromotionProduct.create(promotion_product.merge(promotion_id: promotion.id))

      print "\rimport promotions in db: [#{index + 1}/#{promotion_product_count}]"
    end

    puts
  end
end
