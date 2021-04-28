require 'net/http'
require 'uri'
require 'json'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']
access_key = "5413e55dd50ddb2555c63a9cd57c0306"

uri = URI("http://api.exchangeratesapi.io/v1/latest?access_key=#{access_key}")
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
