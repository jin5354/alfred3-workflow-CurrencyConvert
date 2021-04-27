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


def get_currency_rate_with_symble(base, *targets)
    default_base = 'EUR'
    access_key = "5413e55dd50ddb2555c63a9cd57c0306"
    uri = URI("http://api.exchangeratesapi.io/v1/latest?access_key=#{access_key}")
    result = JSON.parse(Net::HTTP.get(uri))
    res = Hash['success' => result['success'], 'base' => base, 'timestamp' => result['timestamp']]
    rates = Hash[]
    targets.each do | target |
        rates[target] = result['rates'][target] * result['rates'][default_base] / result['rates'][base]
    end
    res['rates'] = rates
    return res
end


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
            result = get_currency_rate_with_symble(cy, *units)
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
            result = get_currency_rate_with_symble(cy, target)
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
    result = get_currency_rate_with_symble(base, *units)
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
