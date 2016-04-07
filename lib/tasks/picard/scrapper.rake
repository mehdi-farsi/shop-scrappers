PICARD_BASE_URL = "http://www.picard.fr"

namespace :picard do
  desc "Get products picard.fr - CATEGORY=[1]"
  task :scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'
    require 'uri'

    # We can also pass this URL via a task argument
    BASE_URL = ""

    website = Website.where(name: 'Picard').first

    category = (ENV["CATEGORY"] || "0").to_i

    website.categories.includes(sections: [:subsections]).limit(1).offset(category).each do |category|

      puts "Category: #{category.name}:"

      category.sections.each do |section|

        puts "\tSection: #{section.name}"

        section.subsections.each do |subsection|

          subsection_page     = Nokogiri::HTML(RestClient.get(subsection.href))
          product_number      = subsection_page.css('.result_number').text.squish.to_i
          subsection_page     = Nokogiri::HTML(RestClient.get(subsection.href + "&start=0&sz=#{product_number}"))
          #subsection_page_max = (subsection_page.css(".pagination li:nth-last-child(2) a").text.presence || "1").to_i

          puts "\t\tSubsection: #{subsection.name}: #{subsection.href}&start=0&sz=#{product_number}"
          picard_products_by_subsection_page(subsection_page, subsection)


          # if subsection_page_max == 1
            # monoprix_products_by_subsection_page(subsection_page, subsection, 1)
          # else
            # monoprix_products_by_subsection_page(subsection_page, subsection, 1) # avoid computation
            
            # 2.upto(subsection_page_max) do |page_number|
              # subsection_page = Nokogiri::HTML(RestClient.get("#{subsection.href}/page-#{page_number}")) # monoprix/test/page-2
              #monoprix_products_by_subsection_page(subsection_page, subsection, page_number)

            # end
          # end
          #break
        end # subsections

      end # sections

    end # categories

    
  end
end

def picard_products_by_subsection_page(subsection_page, subsection)
  products = []

  subsection_page.css(".push_produit_01").each do |product_div|
    product_image = product_div.css(".productGTMClickCategAll > img").first.attributes['src'].to_s.gsub("?sw=125&sh=73", "")
    page_url = URI.escape "#{product_div.css(".desc a.productGTMClickCategAll").first[:href]}"
    product_page  = Nokogiri::HTML(RestClient.get(page_url))
    products <<  picard_get_product(product_page, page_url, product_image)
  end

  # products.each do |product|
  #  excluded_keys_for_product = [:ingredients, :nutritional_values, :weight, :pricing, :ingredient_types, :energy_values, :nutrition_types]

  #  p = subsection.products.create(product.select { |k, v| !excluded_keys_for_product.include?(k) })

  #  # => Weight + Pricing
  #  Weight.create!(product[:weight].merge(product_id: p.id)) unless product[:weight].empty?
  #  Pricing.create!(product[:pricing].merge(product_id: p.id, extracted_at: Time.now))

  #  # => NutritionalValue + EnergyValue
  #  nutritional_value = NutritionalValue.create!(product[:nutritional_values].merge(product_id: p.id))

  #  product[:energy_values].each   { |ev| EnergyValue.create!(ev.merge(nutritional_value_id:   nutritional_value.id)) }
  #  product[:nutrition_types].each { |nt| NutritionType.create!(nt.merge(nutritional_value_id: nutritional_value.id)) }

  #  # => Ingredient + IngredientType
  #  ingredient = Ingredient.create!(product[:ingredients].merge(product_id: p.id))

  #  product[:ingredient_types].each { |it| IngredientType.create!(it.merge(ingredient_id: ingredient.id)) }
  # end

  # puts "\t\t\t#{products.size} products inserted in subsection #{subsection.name}"
end

def picard_get_product(product_page, page_url, product_image)
    product = Hash.new { |hash, key| hash[key] = {} }
    product_information = product_page.css("#ficheproduit").css("tr:nth-child(1) > td:nth-child(1)").text.squish

    # Scrapping product's information
    product[:title]             = product_page.css("h1 span b").text.squish
    # product[:brand]             = product_page.css("#info_produit .logos_categorie img")
    product[:url]               = page_url
    product[:picture]           = product_image
    # product[:description]       =  description ? description.gsub('.', ". ").squish : nil 
    ingredients                 = product_page.css(".suggestion_utilisation p:nth-child(3)")

    #########
    # weight
    #########

    weight_data = product_page.css(".info span:nth-child(1)").children.first.to_s.squish.match(/(\d+)+[\s]+([a-zA-Z]+)\Z/)

    if weight_data
      product[:weight][:size] = weight_data[1]
      product[:weight][:unit] = weight_data[2]
    end

    ##########
    # Pricing
    ##########

    product[:pricing][:unit_price]     =  product_page.css(".last_price").text.gsub(/,/, ".").to_f.to_s
    product[:pricing][:price_per_kilo] =  product_page.css(".info span+ span").text.gsub(/,/, ".").to_f.to_s

    #############
    # ingredients
    #############


    product[:ingredients][:ingredients] = ingredients

    ingredients_type =  product_page.css(".analyse_nutritionnelle+ .border").text.squish
    if ingredients_type.include?("Les allergenes")

      product[:ingredient_types] = { name: "allergenes", 
                                     info: ingredients_type.gsub(/Les allergenes Produit élaboré dans un atelier qui utilise[\s:]+/, "")
                                  }
      puts product[:ingredient_types]
    end

    #####################
    # nutritional values
    #####################

    product[:nutritional_values][:information]  =  "Analyse nutritionnelle moyenne pour 100g"

    ################
    # energy values
    ################
    /(?<kj>[\d\s]+kj).+ (?<kcal>[\d]+ kcal)/i =~ product_page.css(".select_org").text.squish

    product[:energy_values] = [] 
    product[:energy_values] << {
      name:   "Valeur Energétique en Kilocalories",
      weight: kcal.to_i.to_s,
      unit:   'kcal'
    }

    product[:energy_values] << {
      name:   "Valeur Energétique en Kilojoules",
      weight: kj.to_i.to_s,
      unit:  'kj'
    }

    #################
    # Nutrition type
    #################

    product[:nutrition_types] = []
    if (nutritional_values = product_page.css(".analyse_nutritionnelle tr")[2..-1])
      nutritional_values.each do |nutritional_value|
        row_value = nutritional_value.css('td')
        unit_value = row_value[1].text.squish.gsub(',', '.').scan(/([\d\.\s]+)([mgµ])+/).first
        product[:nutrition_types] << {
            name:   row_value[0].text.squish.gsub(/ dont.+/, ""),
            weight: unit_value ? unit_value[0] : nil,
            unit:   unit_value ? unit_value[1] : nil
        }
      end
    end

    p  product[:nutrition_types]
    puts product[:url]
    return 0

    product
end