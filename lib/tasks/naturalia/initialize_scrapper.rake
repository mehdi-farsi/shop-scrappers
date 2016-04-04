namespace :naturalia do
  desc "Get categories, sections, subsections from naturalia.fr"
  task :initialize_scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = "http://www.naturalia.fr"

    website = Website.create(name: "Naturalia")

    url = "#{BASE_URL}/boutique/index.asp"

    page = Nokogiri::HTML(RestClient.get(url))

    category = Category.create(name: "Faire mes courses")
    website.categories << category
    puts category.name
    sections = page.css("#navigation li a")
    sections.each_with_index do |html_section, sub_index|
      section = Section.create(name: html_section.text.squish)
      category.sections << section
      puts "\t #{section.name}"
      html_section[:href] = !!(html_section[:href].match(/^\//)) ? html_section[:href] : "/#{html_section[:href]}" 
      page_section = Nokogiri::HTML(RestClient.get("#{BASE_URL}#{html_section[:href]}"))
      subsections = page_section.css("#navgauche a")
      subsections.each do | html_subsection |
        puts html_subsection.text
        subsection = Subsection.create(name: html_subsection.text.squish, href: "#{BASE_URL}#{html_subsection[:href].split(";")[0]}")
        section.subsections << subsection
        puts "\t\t #{subsection.name} href #{subsection.href}"
      end
    end 
  end
end
