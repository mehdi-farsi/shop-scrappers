namespace :monoprix do
  desc "Get categories, sections, subsections from monoprix.fr"
  task :initialize_scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = "https://www.monoprix.fr"

    url = "#{BASE_URL}/courses-en-ligne"

    page = Nokogiri::HTML(RestClient.get(url))

    categories = page.css(".dropdown > a").select # Select all links

    categories.each_with_index do | categorie, index |
      puts categorie.text
      sections = page.css(".dropdown:nth-child(#{index + 2}) h2 a")
      sections.each_with_index do |section, sub_index|
        puts "\t #{section.text.squish}"
        sub_sections = page.css(".dropdown:nth-child(#{index + 2}) .submenu-links:nth-child(#{sub_index + 1}) li a")
        sub_sections.each do | sub_section |
          puts "\t\t #{sub_section.text.squish} href #{BASE_URL}#{sub_section[:href]}"
        end
      end 
    end 
  end
end
