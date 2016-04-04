NATURALIA_BASE_URL = "http://www.naturalia.fr"

namespace :naturalia do
  desc "Get products from naturalia.fr - CATEGORY=[1]"
  task :scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'
    require 'uri'

    # We can also pass this URL via a task argument
    BASE_URL = ""

    website = Website.where(name: 'Naturalia').first

    category = (ENV["CATEGORY"] || "0").to_i

    website.categories.includes(sections: [:subsections]).limit(1).offset(category).each do |category|

      puts "Category: #{category.name}:"

      category.sections.each do |section|

        puts "\tSection: #{section.name}"

        section.subsections.each do |subsection|

          subsection_page     = Nokogiri::HTML(RestClient.get(subsection.href))
          #subsection_page_max = (subsection_page.css(".pagination li:nth-last-child(2) a").text.presence || "1").to_i

          puts "\t\tSubsection: #{subsection.name}: #{subsection.href}"
          naturalia_products_by_subsection_page(subsection_page, subsection)


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

def naturalia_products_by_subsection_page(subsection_page, subsection)
  products = []

  subsection_page.css(".libelle").each do |product_link|
    page_url = URI.escape "#{NATURALIA_BASE_URL}#{product_link[:href]}"
    product_page  = Nokogiri::HTML(RestClient.get(page_url))
    products <<  naturalia_get_product(product_page, page_url)
  end



  products.each do |product|
   excluded_keys_for_product = [:ingredients, :nutritional_values, :weight, :pricing, :ingredient_types, :energy_values, :nutrition_types]

   p = subsection.products.create(product.select { |k, v| !excluded_keys_for_product.include?(k) })

   # => Weight + Pricing
   Weight.create!(product[:weight].merge(product_id: p.id)) unless product[:weight].empty?
   Pricing.create!(product[:pricing].merge(product_id: p.id, extracted_at: Time.now))

   # => NutritionalValue + EnergyValue
   nutritional_value = NutritionalValue.create!(product[:nutritional_values].merge(product_id: p.id))

   product[:energy_values].each   { |ev| EnergyValue.create!(ev.merge(nutritional_value_id:   nutritional_value.id)) }
   product[:nutrition_types].each { |nt| NutritionType.create!(nt.merge(nutritional_value_id: nutritional_value.id)) }

   # => Ingredient + IngredientType
   ingredient = Ingredient.create!(product[:ingredients].merge(product_id: p.id))

   product[:ingredient_types].each { |it| IngredientType.create!(it.merge(ingredient_id: ingredient.id)) }
  end

  puts "\t\t\t#{products.size} products inserted in subsection #{subsection.name}"
end

def naturalia_get_product(product_page, page_url)
    product = Hash.new { |hash, key| hash[key] = {} }
    product_information = product_page.css("#ficheproduit").css("tr:nth-child(1) > td:nth-child(1)").text.squish


    /Description : (?<description>.+) prix/ =~ product_page.css(".sep+ td").children.text.squish
    /Ingrédients : (?<ingredients>.+).Analyse / =~ product_information

    # Scrapping product's information
    product[:title]             = product_page.css(".titreProduit h4").text.squish
    product[:brand]             = product_page.css(".marque").first.children.first.to_s.squish
    product[:url]               = page_url
    product[:picture]           = product_page.css("#ficheproduit div+ img").first.attributes["src"].to_s.squish
    product[:description]       =  description ? description.gsub('.', ". ").squish : nil 
    ingredients                 = ingredients.split("Traces") if ingredients

    #########
    # weight
    #########

    weight_data = product_page.css(".titreProduit h4").children.first.to_s.squish.match(/(\d+)+([a-zA-Z]+)\Z/)

    if weight_data
      product[:weight][:size] = weight_data[1]
      product[:weight][:unit] = weight_data[2]
    end


    ##########
    # Pricing
    ##########

    product[:pricing][:unit_price]     = product_page.css(".prixttc").text.gsub(/,/, ".").to_f.to_s

    #############
    # ingredients
    #############

    if ingredients && ingredients.size > 1

      product[:ingredients][:ingredients] = ingredients[0] 

      product[:ingredient_types] = ingredients.each_slice(2).to_a.map do |a|
        {
          name: "Traces",
          info: ingredients[1]
        }
      end

    end

    #####################
    # nutritional values
    #####################

    product[:nutritional_values][:information]  =  "Analyse nutritionnelle moyenne pour 100g"

    ################
    # energy values
    ################
    product[:energy_values] = []
    if /(?<kcal>\d+[\s]*kcal)/i =~ product_information
      product[:energy_values] << {
        name:   "Valeur Energétique en Kilocalories",
        weight: kcal.to_i.to_s,
        unit:   'kcal'
      }
    end

    if /(?<kj>\d+[\s]*kj)/i =~ product_information
      product[:energy_values] << {
        name:   "Valeur Energétique en Kilojoules",
        weight: kj.to_i.to_s,
        unit:  'kj'
      }
    end

    #################
    # Nutrition type
    #################
    product[:nutrition_types] = []
    if (nutritional_values = product_information.scan /- ([[:alpha:]]+)[\s:]+([\d,.]+)([mgµ]+)/)
      nutritional_values.each do |nutritional_value|
        product[:nutrition_types] << {
            name:   nutritional_value[0],
            weight: nutritional_value[1],
            unit:   nutritional_value[2]
        }
      end
    end

    product
end