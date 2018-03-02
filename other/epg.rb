require 'httparty'
require 'csv'

CSV.open("output.csv", "w") do |csv|
    csv << ["id", "channelId", "channelDetails", "programId", "remark", "start", "end", "title", "blockTitle", "subTitle", "lead", "shortDescription", "description", "assetId", "image", "genre", "attributes", "seriesNumber", "seriesTotal", "seasonNumber", "productionCountry", "productionYear", "ageRating", "linkEditorial", "linkShop", "linkDetail", "actors", "contributions", "isHighlight", "vodUrl"]
    (Date.new(2013, 03, 01)..Date.new(2013, 03, 30)).each do |date|
        puts "Working on date #{date.strftime("%d.%m.%y")}"
        r = HTTParty.get("https://api.srgssr.ch/epg/v2/tvshows/stations/srf-1?date=#{date.to_s}&bu=srf", :headers => {"Authorization" => "Bearer 3BCHU70Fzz3XyuTCANkC7Ik4wWG5"})
        r.each do |e|
            csv << [e["id"], e["channelId"], e["channelDetails"], e["programId"], e["remark"], 
                    e["start"]["date"], e["end"]["date"], e["title"], e["blockTitle"], 
                    e["subTitle"], e["lead"], e["shortDescription"], e["description"], 
                    e["assetId"], e["image"]["representations"]["small"], e["genre"], 
                    e["attributes"]["isLive"], e["attributes"]["hasTwoLanguages"], 
                    e["attributes"]["hasSubtitle"], e["attributes"]["hasSignLanguage"], 
                    e["attributes"]["hasVisualDescription"], e["attributes"]["isFollowUp"], 
                    e["attributes"]["isDolbyDigital"], e["attributes"]["isRepetition"], 
                    e["attributes"]["repetitionDescription"], e["seriesNumber"], 
                    e["seriesTotal"], e["seasonNumber"], e["productionCountry"], 
                    e["productionYear"], e["ageRating"], e["linkEditorial"], 
                    e["linkShop"], e["linkDetail"], e["actors"], 
                    e["contributions"], e["isHighlight"], e["vodUrl"]]
        end
    end
end

def flat_hash(h,f=[],g={})
  return g.update({ f=>h }) unless h.is_a? Hash
  h.each { |k,r| flat_hash(r,f+[k],g) }
  g
end
