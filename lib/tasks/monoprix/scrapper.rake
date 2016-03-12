MONOPRIX_BASE_URL = "https://www.monoprix.fr"

namespace :monoprix do
  desc "Get products from monoprix.fr - CATEGORY=[0-8]"
  task :scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = ""

    category = (ENV["CATEGORY"] || "0").to_i

    Category.includes(sections: [:subsections]).limit(1).offset(category).each do |category|

      puts "Category: #{category.name}:"

      category.sections.each do |section|

        puts "\tSection: #{section.name}"

        section.subsections.each do |subsection|

          subsection_page     = Nokogiri::HTML(RestClient.get(subsection.href))
          subsection_page_max = (subsection_page.css(".pagination li:nth-last-child(2) a").text.presence || "1").to_i

          puts "\t\tSubsection: #{subsection.name}(#{subsection_page_max}): #{subsection.href[0..40]}"

          if subsection_page_max == 1
            monoprix_products_by_subsection_page(subsection_page, subsection, 1)
          else
            monoprix_products_by_subsection_page(subsection_page, subsection, 1) # avoid computation
            
            2.upto(subsection_page_max) do |page_number|
              subsection_page = Nokogiri::HTML(RestClient.get("#{subsection.href}/page-#{page_number}")) # monoprix/test/page-2
              monoprix_products_by_subsection_page(subsection_page, subsection, page_number)

            end
          end

        end # subsections

      end # sections

    end # categories

    
  end
end

def monoprix_products_by_subsection_page(subsection_page, subsection, page_number)
  products = []

  subsection_page.css(".item_produits_courses li > a").map { |p| p.first.last }.each do |product_link|
    page_url = "#{MONOPRIX_BASE_URL}#{product_link}"
    product_page  = Nokogiri::HTML(RestClient.get(page_url))
    
    products <<  monoprix_get_product(product_page, page_url)
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

  puts "\t\t\t#{products.size} products inserted in subsection #{subsection.name} [page #{page_number}]"
end

def monoprix_get_product(product_page, page_url)
    product = Hash.new { |hash, key| hash[key] = {} }

    conservation_type = product_page.css(".picto img").first
    conservation_type = conservation_type.nil? ? nil : conservation_type.attributes["src"].to_s.squish.split('/').last

    # Scrapping product's information
    product[:title]             = product_page.css("aside h3").text.squish
    product[:brand]             = product_page.css("aside .brand").first.children.first.to_s.squish
    product[:url]               = page_url
    product[:conservation_type] = conservation_type
    product[:picture]           = product_page.css(".center img").first.attributes["src"].to_s.squish
    product[:description]       = product_page.css("#desc").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.join("\n").squish
    product[:conservation]      = product_page.css("#conservation").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.join("\n").squish
    ingredients                 = product_page.css("#ingredients").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.reject { |i| i.blank? }


    #########
    # weight
    #########

    weight_data = product_page.css("aside h4").children.first.to_s.squish.match(/(\d+)+([a-zA-Z]+)\Z/)

    if weight_data
      product[:weight][:size] = weight_data[1]
      product[:weight][:unit] = weight_data[2]
    end

    ##########
    # Pricing
    ##########

    product[:pricing][:unit_price]     = product_page.css("#priceChange").text.gsub(/,/, ".").to_f.to_s
    product[:pricing][:price_per_kilo] = product_page.css(".weight-price").text.gsub(/,/, ".").to_f.to_s

    #############
    # ingredients
    #############

    product[:ingredients][:ingredients] = ingredients.shift

    product[:ingredient_types] = ingredients.each_slice(2).to_a.map do |a|
      {
        name: a[0].gsub(/(<u>)|(<\/u>)/, "<u>" => "", "</u>" => ""), # remove <u></u> around the text
        info: a[1]
      }
    end

    #####################
    # nutritional values
    #####################

    product[:nutritional_values][:information]  = product_page.css("#valeur h4").text.squish

    nutritional_values = product_page.css("#valeur td").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.reject { |i| i.blank? }


    ################
    # energy values
    ################

    weight_extraction_regex = /([\d,]+) ([a-zA-Zµ]+) /

    product[:energy_values] = nutritional_values[0..3].each_slice(2).map do |e|
      weight_data_raw = e[1].match(weight_extraction_regex)
      weight          = weight_data_raw.nil? ? nil : weight_data_raw[1].gsub(/,/, ".")
      unit            = weight_data_raw.nil? ? nil : weight_data_raw[2]
      
      {
        name:   e[0],
        weight: weight, # Example: match with "1876"
        unit:   unit    # Example: match with "KJ"
      }
    end

    #################
    # Nutrition type
    #################

    product[:nutrition_types] = nutritional_values[4..-1].each_slice(2).map do |e|
      weight_data_raw = e[1].match(weight_extraction_regex)
      weight          = weight_data_raw.nil? ? nil : weight_data_raw[1].gsub(/,/, ".")
      unit            = weight_data_raw.nil? ? nil : weight_data_raw[2]
      
      {
        name:   e[0],
        weight: weight, # Example: match with "51"
        unit:   unit    # Example: match with "g"
      }
    end if nutritional_values.size > 4

    product
end