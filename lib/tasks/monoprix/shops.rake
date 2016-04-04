namespace :monoprix do
  desc "Fetch and store all monoprix's shops"
  task :shops => :environment do
    BASE_URL = "https://www.monoprix.fr"

    website = Website.where(name: "Monoprix").first

    shop_list_page = Nokogiri::HTML(RestClient.get("#{BASE_URL}/trouver-nos-magasins?menuName=MagasinsSL"))

    shop_list_items = shop_list_page.css("#results li")

    shop_list_items_total = shop_list_items.size
    shop_list_items_count = 1

    shop_list_items.each do |shop_list_item|

      shop = {}

      # To facilitate the extraction of data, we've decided to fetch the shop's name and the shop's address
      # in the shop list and fetch the geopoints and the open/close times in the shop details page.
      shop[:name]    = shop_list_item.children[1].text.squish
      shop[:address] = shop_list_item.text.split("\n")[2..-1].join(" ").squish


      /'(?<uri>.+)'/ =~ shop_list_item.attributes["onclick"].text

      shop_page = Nokogiri::HTML(RestClient.get("#{BASE_URL}#{uri}"))


      shop_page.css("script").children.each do |script|
        lat        = script.to_s.squish.match(/(?:storeLatitude) = '([\d]+\.[\d]+)'/)
        shop[:lat] = lat[1] if lat
      end

      shop_page.css("script").children.each do |script|
        lng        = script.to_s.squish.match(/(?:storeLongitude) = '([\d]+\.[\d]+)'/)
        shop[:lng] = lng[1] if lng
      end

      open_times = shop_page.css(".col-left th , .col-left td").text.squish.scan(/([\d]{2}h[\d]{2} - [\d]{2}h[\d]{2})+/).flatten

      shop[:monday]    = open_times.shift
      shop[:tuesday]   = open_times.shift
      shop[:wednesday] = open_times.shift
      shop[:thursday]  = open_times.shift
      shop[:friday]    = open_times.shift
      shop[:saturday]  = open_times.shift
      shop[:sunday]    = open_times.shift


      website.shops.create(shop)

      print "\rshops inserted in db: [#{shop_list_items_count}/#{shop_list_items_total}]"
      shop_list_items_count += 1
    end;puts
  end
end