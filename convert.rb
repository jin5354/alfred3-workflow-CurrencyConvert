require 'net/http'
require 'uri'
require 'json'

hasARGV = false

if !ARGV[0].empty?
    hasARGV = true
end

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

if hasARGV
    str = ARGV[0].lstrip.gsub('$', 'usd').gsub('￥', 'cny').gsub('¥', 'jpy').gsub('£', 'gbp').gsub('€', 'eur')
    to = str.match(/\sto\s/)
    cy = nil
    num = nil
    target = nil
    if to.nil?
        num = str.match(/^\d+(.\d+)?/)
        if !num.nil?
            num = num[0]
        end
        cy = str.match(/\s*[a-zA-Z]{3}/)
        if !cy.nil?
            cy = cy[0].lstrip.upcase
        end
    else
        matcher = str.match(/^(\d+(.\d+)?)\s*([a-zA-Z]{3})\sto\s([a-zA-Z]{3})/)
        if !matcher.nil?
            num = matcher[1]
            cy = matcher[3].lstrip.upcase
            target = matcher[4].lstrip.upcase
        end
    end
    if str.empty? || num.nil? || cy.nil?
        temp = Hash[
            "title" => 'No result',
            "icon" => Hash[
                "path" => 'icon.png'
            ]
        ]
        output["items"].push(temp)
    else
        if target.nil?
            if units.include?(cy)
                units.delete(cy)
            end
            uri = URI("https://api.exchangeratesapi.io/latest?base=#{cy}&symbols=#{units.join(',')}")
            result = JSON.parse(Net::HTTP.get(uri))
            result['rates'].each do |key, value|
                temp = Hash[
                    "title" => "#{(num.to_f*value).round(2)} #{key}",
                    "subtitle" => "#{cy} : #{key} = 1 : #{value.round(4)} (Last Update: #{result["date"]})",
                    "icon" => Hash[
                        "path" => "flags/#{key}.png"
                    ],
                    "arg" => "#{(num.to_f*value).round(2)}"
                ]
                output["items"].push(temp)
            end
        else
            uri = URI("https://api.exchangeratesapi.io/latest?base=#{cy}&symbols=#{target}")
            result = JSON.parse(Net::HTTP.get(uri))
            result['rates'].each do |key, value|
                temp = Hash[
                    "title" => "#{(num.to_f*value).round(2)} #{key}",
                    "subtitle" => "#{cy} : #{key} = 1 : #{value.round(4)} (Last Update: #{result["date"]})",
                    "icon" => Hash[
                        "path" => "flags/#{key}.png"
                    ],
                    "arg" => "#{(num.to_f*value).round(2)}"
                ]
                output["items"].push(temp)
            end
        end
    end
else
    if units.include?(base)
        units.delete(base)
    end
    uri = URI("https://api.exchangeratesapi.io/latest?base=#{base}&symbols=#{units.join(',')}")
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
