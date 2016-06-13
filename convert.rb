require 'net/http'
require 'uri'
require 'json'

hasARGV = false

if !ARGV.empty? 
    hasARGV = true
end

output = Hash["items" => []]

if hasARGV
    str = ARGV[0].lstrip
    num = str.match(/^\d+/)
    cy = str.match(/[a-zA-Z]{3}/)
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
        cy = cy[0].upcase
        uri = URI("http://api.fixer.io/latest?base=#{cy}&symbols=CNY,USD,JPY,EUR,HKD,GBP,CAD")
        result = JSON.parse(Net::HTTP.get(uri))
        result['rates'].each do |key, value|
            temp = Hash[
                "title" => "#{(num.to_i*value).round(2)} #{key}",
                "subtitle" => "#{cy} : #{key} = 1 : #{value.round(4)} (Last Update: #{result["date"]})",
                "icon" => Hash[
                    "path" => "flags/#{key}.png"
                ]
            ]
            output["items"].push(temp)
        end
    end
else
    base = 'CNY'
    uri = URI('http://api.fixer.io/latest?base=CNY&symbols=CNY,USD,JPY,EUR,HKD,GBP,CAD')
    result = JSON.parse(Net::HTTP.get(uri))
    result['rates'].each do |key, value|
        temp = Hash[
            "title" => "CNY : #{key} = 1 : #{value.round(4)} ",
            "subtitle" => "Last Update: #{result["date"]}",
            "icon" => Hash[
                "path" => "flags/#{key}.png"
            ]
        ]
        output["items"].push(temp)
    end
end

print output.to_json