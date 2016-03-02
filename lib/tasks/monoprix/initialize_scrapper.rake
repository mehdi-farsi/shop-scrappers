namespace :monoprix do
  desc "Get categories, sections, subsections from monoprix.fr"
  task :initialize_scrapper => :environment do
    require 'nokogiri'
    require 'rest-client'
    require 'json'

    # We can also pass this URL via a task argument
    BASE_URL = "https://www.monoprix.fr"

    website = Website.create(name: "Monoprix")

    url = "#{BASE_URL}/courses-en-ligne"

    page = Nokogiri::HTML(RestClient.get(url))

    categories = page.css(".dropdown > a").select # Select all links

    categories.each_with_index do | html_category, index |
      category = Category.create(name: html_category.text)
      website.categories << category
      puts category.name
      sections = page.css(".dropdown:nth-child(#{index + 2}) h2 a")
      sections.each_with_index do |html_section, sub_index|
        section = Section.create(name: html_section.text.squish)
        category.sections << section
        puts "\t #{section.name}"
        subsections = page.css(".dropdown:nth-child(#{index + 2}) .submenu-links:nth-child(#{sub_index + 1}) li a")
        subsections.each do | html_subsection |
          subsection = Subsection.create(name: html_subsection.text.squish, href: "#{BASE_URL}#{html_subsection[:href]}")
          section.subsections << subsection
          puts "\t\t #{subsection.name} href #{subsection.href}"
        end
      end 
    end 
  end
end
