namespace :picard do
  desc "Get categories, sections, subsections from picard.fr"
  task :initialize_scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = "http://www.picard.fr"

    website = Website.create(name: "Picard")

    url = "#{BASE_URL}"

    page = Nokogiri::HTML(RestClient.get(url))

    category = Category.create(name: "Produit")
    website.categories << category
    puts category.name
    sections = page.css(".menu_cat")

    sections.each_with_index do |html_section, sub_index|
      section = Section.create(name: html_section.css('.cat_name').text.squish)
      category.sections << section
      puts "\t #{section.name}"
      subsections = html_section.css("a")
      subsections.shift
      subsections.each do | html_subsection |
        href = html_subsection[:href] + (html_subsection[:href].include?('?') ?  '&' : '?')
        subsection = Subsection.create(name: html_subsection.text.squish, href: "#{href}viewAll=1")
        section.subsections << subsection
        puts "\t\t #{subsection.name} href #{subsection.href}"
      end
    end 
  end
end
