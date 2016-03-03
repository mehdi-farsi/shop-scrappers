namespace :monoprix do
  desc "Get products from monoprix.fr"
  task :scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = "https://www.monoprix.fr/beurre-doux-extra-fin-monoprix-1816533-p"

    Category.includes(sections: [:subsections]).all.each do |category|
      puts "Category: #{category.name}:"
      category.sections.each do |section|
        puts "\tSection: #{section.name}"
        section.subsections.each do |subsection|
          puts "\t\tSubsection: #{subsection.name} [#{subsection.href[0..40]}]"
        end
      end
    end


    page = Nokogiri::HTML(RestClient.get("https://www.monoprix.fr/cave-0000552"))

    puts page.css(".pagination li:nth-last-child(2) a").text

    # products = []
    # product_count = 0  
    # 1.upto(1) do |page_number|

    #   product = Hash.new { |hash, key| hash[key] = {} }

    #   url = "#{BASE_URL}"

    #   product_page = Nokogiri::HTML(RestClient.get(url))

    #   # Scrapping product's information
    #   product[:title]        = product_page.css("aside h3").text.squish
    #   product[:unit_price]   = product_page.css("#priceChange").text.gsub(/,/, ".").to_f
    #   product[:weight]       = product_page.css("aside h4").children.first.to_s.squish
    #   product[:picture]      = product_page.css(".center img").first.attributes["src"].to_s.squish
    #   product[:description]  = product_page.css("#desc").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.join("\n").squish
    #   product[:conservation] = product_page.css("#conservation").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.join("\n").squish
    #   ingredients            = product_page.css("#ingredients").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.reject { |i| i.blank? }
    #   nutritional_values     = product_page.css("#valeur").children.map { |d| d.to_s.gsub(/<br>/, "").squish }.reject { |i| i.blank? }

    #   ##############
    #   # ingredients
    #   ##############

    #   product[:ingredients][:ingredients] = ingredients.shift

    #   additional_information = ingredients.each_slice(2).to_a.map do |a|
    #     {
    #       name: a[0].gsub(/(<u>)|(<\/u>)/, "<u>" => "", "</u>" => ""), # remove <u></u> around the text
    #       info: a[1]
    #     }
    #   end

    #   product[:ingredients][:additional_information] = {
    #     additional_information: additional_information
    #   }.to_json

    #   #####################
    #   # nutritional values
    #   #####################

    #   # product[:nutritional_values][:information]  = nutritional_values.shift

    #   # additional_information = nutritional_values.each_slice(2).to_a.map do |a|
    #   #   {
    #   #     name: a[0].gsub(/(<u>)|(<\/u>)/, "<u>" => "", "</u>" => ""), # remove <u></u> around the text
    #   #     info: a[1]
    #   #   }
    #   # end

    #   # product[:ingredients][:additional_information] = {
    #   #   additional_information: additional_information
    #   # }.to_json


    #   # product.each { |k, v| puts v;puts }

    #   # product_count += 1
    #   # print("\rMONOPRIX: scrapped product for category 'Produits Frais' : #{product_count}")
    #   products << product

    # end
    # puts
  end
end