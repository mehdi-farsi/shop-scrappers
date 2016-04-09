namespace :picard do
  desc "Fetch and store all picard's shops"
  task :shops => :environment do
    BASE_URL = "http://magasins.picard.fr"

    website = Website.where(name: "Picard").first

    cities_list = [ 
      "http://magasins.picard.fr/search/be/Halle",
      "http://magasins.picard.fr/search/fr/Paris",
      "http://magasins.picard.fr/search/lu/Luxembourg",
      "http://magasins.picard.fr/search/be/Blankenberge",
      "http://magasins.picard.fr/search/fr/Marseille",
      "http://magasins.picard.fr/search/lu/Esch-sur-Alzette",
      "http://magasins.picard.fr/search/fr/Lyon",
      "http://magasins.picard.fr/search/lu/Dudelange"  
    ]

    cities_list.each do | city_list |
      city_page   = Nokogiri::HTML(RestClient.get(city_list))
      sub_cities  = city_page.css('#footerseo2 li a')
      
      sub_cities.each do |city_link|
        sub_citie_page  = Nokogiri::HTML(RestClient.get(BASE_URL+city_link[:href ]))
        shop_list       =  sub_citie_page.css('.address-title a')
        shop_list.each do |shop_link|
          shop_page      = Nokogiri::HTML(RestClient.get(BASE_URL+shop_link[:href ]))
          shop           = {}
          shop[:name]    = shop_page.css('.title_map').text.squish.gsub("Votre magasin ","")
          shop[:address] = shop_page.css('address').text.squish
          open_times = shop_page.css('.day')
          day_week = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
          open_times.each_with_index do |open_time, index|
            shop[day_week[index]] = open_time.css('ul').text.squish
          end

          shop_page.css("script").children.each do |script|
            /lat:[\s]*(?<lat>[\d]+\.[\d]+)[,\s]*lng:[\s]*(?<lng>[\d]+\.[\d]+)/ =~ script.to_s.squish
            if lat || lng
              shop[:lat] = lat
              shop[:lng] = lng
            end
          end
          website.shops.create(shop)
        end
      end
    end
  end
end