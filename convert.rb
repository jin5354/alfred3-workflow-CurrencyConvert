require 'net/http'
require 'uri'
require 'json'

hasARGV = false

if !ARGV.empty? 
    hasARGV = true
end

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

if hasARGV
    str = ARGV[0].lstrip.gsub('$', 'usd').gsub('￥', 'cny').gsub('¥', 'jpy').gsub('£', 'gbp').gsub('€', 'eur')
    num = str.match(/^\d+/)
    cy = str.match(/\s*[a-zA-Z]{3}/)
    if str.empty? || num.nil? || cy.nil?
        temp = Hash[
            "title" => 'No result',
            "icon" => Hash[
                "path" => 'icon.png'
            ]
        ]
        output["items"].push(temp)
    else
        num = num[0]
        cy = cy[0].lstrip.upcase
        uri = URI("http://api.fixer.io/latest?base=#{cy}&symbols=#{units.join(',')}")
        result = JSON.parse(Net::HTTP.get(uri))
        result['rates'].each do |key, value|
            temp = Hash[
                "title" => "#{(num.to_i*value).round(2)} #{key}",
                "subtitle" => "#{cy} : #{key} = 1 : #{value.round(4)} (Last Update: #{result["date"]})",
                "icon" => Hash[
                    "path" => "flags/#{key}.png"
                ],
                "arg" => "#{(num.to_i*value).round(2)}"
            ]
            output["items"].push(temp)
        end
    end
else
    uri = URI("http://api.fixer.io/latest?base=#{base}&symbols=#{units.join(',')}")
    result = JSON.parse(Net::HTTP.get(uri))
    result['rates'].each do |key, value|
        temp = Hash[
            "title" => "#{base} : #{key} = 1 : #{value.round(4)} ",
            "subtitle" => "Last Update: #{result["date"]}",
            "icon" => Hash[
                "path" => "flags/#{key}.png"
            ],
            "arg" => "#{value.round(4)}"
        ]
        output["items"].push(temp)
    end
end

print output.to_json