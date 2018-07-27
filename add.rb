require 'net/http'
require 'uri'
require 'json'
require 'date'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

uri = URI("https://exchangeratesapi.io/api/latest?base=#{base}")
result = JSON.parse(Net::HTTP.get(uri))
result['rates'].each do |key, value|
    if !units.include?(key)
        temp = Hash[
            "title" => "#{key}",
            "subtitle" => "#{base} : #{key} = 1 : #{value.round(4)} Last Update: #{result["date"]}",
            "rate" => value,
            "icon" => Hash[
                "path" => "flags/#{key}.png"
            ],
            "arg" => "#{key}"
        ]
        output["items"].push(temp)
    end
end

uri = URI("https://api.coindesk.com/v1/bpi/currentprice/#{base}.json")
result = JSON.parse(Net::HTTP.get(uri))
updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
rate = result['bpi'][base]['rate_float'].round(4)
output["items"].push(Hash[
    "title" => "BTC",
    "subtitle" => "#{base} : BTC = 1 : #{rate} Last Update: #{updated}",
    "rate" => rate,
    "icon" => Hash[
        "path" => "flags/BTC.png"
    ],
    "arg" => "BTC"
])

output["items"] = output["items"].sort{ |a, b| a['arg'] <=> b['arg'] }
print output.to_json
