require 'net/http'
require 'uri'
require 'json'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

if base.upcase.eql?("BTC")
    uri = URI("https://exchangeratesapi.io/api/latest?base=USD")
else
    uri = URI("https://exchangeratesapi.io/api/latest?base=#{base}")
end
result = JSON.parse(Net::HTTP.get(uri))
result['rates'].each do |key, value|
    temp = Hash[
        "title" => "#{key}",
        "icon" => Hash[
            "path" => "flags/#{key}.png"
        ],
        "arg" => "#{key}"
    ]
    output["items"].push(temp)
end

output["items"].push(Hash[
    "title" => "BTC",
    "icon" => Hash[
        "path" => "flags/BTC.png"
    ],
    "arg" => "BTC"
])

output["items"] = output["items"].sort{ |a, b| a['arg'] <=> b['arg'] }

print output.to_json
