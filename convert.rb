require 'net/http'
require 'uri'
require 'json'
require 'date'

hasARGV = false

if !ARGV[0].empty?
    hasARGV = true
end

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']
includeBtc = false

if units.include?'BTC'
    units.delete('BTC')
    includeBtc = true
end

if hasARGV
    str = ARGV[0].lstrip.gsub('$', 'usd').gsub('￥', 'cny').gsub('¥', 'jpy').gsub('£', 'gbp').gsub('€', 'eur').gsub('Ƀ', 'btc')
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
            uri = URI("https://exchangeratesapi.io/api/latest?base=#{cy}&symbols=#{units.join(',')}")
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
            if includeBtc
                uri = URI("https://api.coindesk.com/v1/bpi/currentprice/#{cy}.json")
                result = JSON.parse(Net::HTTP.get(uri))
                updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
                rate = result['bpi'][cy]['rate_float']
                output["items"].push(Hash[
                    "title" => "#{num.to_f/rate} BTC",
                    "subtitle" => "#{cy} : BTC = 1 : #{rate.round(4)} (Last Update: #{updated})",
                    "icon" => Hash[
                        "path" => "flags/BTC.png"
                    ],
                    "arg" => "#{(num.to_f/rate)}"
                ])
            end
        else
            if target.upcase.eql?("BTC")
                uri = URI("https://api.coindesk.com/v1/bpi/currentprice/#{cy}.json")
                result = JSON.parse(Net::HTTP.get(uri))
                updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
                rate = result['bpi'][cy]['rate_float']
                output["items"].push(Hash[
                    "title" => "#{num.to_f/rate} BTC",
                    "subtitle" => "#{cy} : BTC = 1 : #{rate.round(4)} (Last Update: #{updated})",
                    "icon" => Hash[
                        "path" => "flags/BTC.png"
                    ],
                    "arg" => "#{(num.to_f/rate)}"
                ])
            else
                uri = URI("https://exchangeratesapi.io/api/latest?base=#{cy}&symbols=#{target}")
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
    end
else
    if units.include?(base)
        units.delete(base)
    end
    if base.upcase.eql?("BTC")
        uri = URI("https://api.coindesk.com/v1/bpi/currentprice/USD.json")
        result = JSON.parse(Net::HTTP.get(uri))
        updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
        rate = result['bpi']['USD']['rate_float']
        uri = URI("https://exchangeratesapi.io/api/latest?base=USD&symbols=#{units.join(',')}")
        result = JSON.parse(Net::HTTP.get(uri))
        result['rates'].each do |key, value|
            converted = "%.12f" % (value/rate)
            temp = Hash[
                "title" => "#{base} : #{key} = 1 : #{converted} ",
                "subtitle" => "Last Update: #{result["date"]} #{value} / #{rate} = #{value/rate}",
                "icon" => Hash[
                    "path" => "flags/#{key}.png"
                ],
                "arg" => "#{converted}"
            ]
            output["items"].push(temp)
        end
    else
        uri = URI("https://exchangeratesapi.io/api/latest?base=#{base}&symbols=#{units.join(',')}")
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
    
    if includeBtc
        uri = URI("https://api.coindesk.com/v1/bpi/currentprice/#{base}.json")
        result = JSON.parse(Net::HTTP.get(uri))
        updated = DateTime.parse(result["time"]["updated"]).strftime("%Y-%m-%d")
        rate = result['bpi'][base]['rate_float']
        output["items"].push(Hash[
            "title" => "#{base} : BTC = 1 : #{rate}",
            "subtitle" => "Last Update: #{updated}",
            "icon" => Hash[
                "path" => "flags/BTC.png"
            ],
            "arg" => "#{rate}"
        ])
    end
end



print output.to_json