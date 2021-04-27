require 'net/http'
require 'uri'
require 'json'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']
access_key = "5413e55dd50ddb2555c63a9cd57c0306"
default_base = 'EUR'

uri = URI("http://api.exchangeratesapi.io/v1/latest?access_key=#{access_key}")
result = JSON.parse(Net::HTTP.get(uri))
result['rates'].each do |key, value|
    if units.include?(key)
        value = result['rates'][key] * result['rates'][default_base] / result['rates'][base]
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
end

print output.to_json
