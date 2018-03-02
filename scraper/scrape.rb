require 'httparty'
require 'csv'

def flat_hash(h,f=[],g={})
  return g.update({ f=>h }) unless h.is_a? Hash
  h.each { |k,r| flat_hash(r,f+[k],g) }
  g
end

i = 0
CSV.open("output.csv", "w") do |csv|
    (Date.new(2018, 03, 01)..Date.new(2018, 03, 30)).each_with_index do |date|
        puts "Working on date #{date.strftime("%d.%m.%y")}"
        r = HTTParty.get("https://api.srgssr.ch/epg/v2/tvshows/stations/srf-1?date=#{date.to_s}&bu=srf", :headers => {"Authorization" => "Bearer 3BCHU70Fzz3XyuTCANkC7Ik4wWG5"})
        puts r.count
        r.each do |e|
            if i == 0
                csv << flat_hash(e).to_a.collect{|s| s[0].join("_")}
            end
            i += 1
            csv << flat_hash(e).to_a.collect{|s| s[1].to_s.gsub("\n","")}
        end
    end
end