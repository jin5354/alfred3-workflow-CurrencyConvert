require 'net/http'
require 'uri'
require 'json'
require 'date'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

if units.include?'BTC'
    units.delete('BTC')
    includeBtc = true
end

uri = URI("https://exchangeratesapi.io/api/latest?base=#{base}&symbols=#{units.join(',')}")
result = JSON.parse(Net::HTTP.get(uri))
result['rates'].each do |key, value|
    temp = Hash[
        "title" => "#{key}",
        "subtitle" => "#{base} : #{key} = 1 : #{value.round(4)} (Last Update: #{result["date"]})",
        "icon" => Hash[
            "path" => "flags/#{key}.png"
        ],
        "arg" => "#{key}"
    ]
    output["items"].push(temp)
end

if includeBtc
    uri = URI("https://api.coindesk.com/v1/bpi/currentprice/#{base}.json")
    result = JSON.parse(Net::HTTP.get(uri))
    updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
    rate = result['bpi'][base]['rate_float'].round(4)
    output["items"].push(Hash[
        "title" => "BTC",
        "subtitle" => "#{base} : BTC = 1 : #{rate} (Last Update: #{updated})",
        "icon" => Hash[
            "path" => "flags/BTC.png"
        ],
        "arg" => "BTC"
    ])
end

print output.to_json
