require 'net/http'
require 'uri'
require 'json'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

uri = URI("https://api.exchangeratesapi.io/latest?base=#{base}")
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

print output.to_json
