require 'rubygems'
require 'bundler/setup'

require 'alfred-3_workflow'
require 'net/http'
require 'uri'
require 'json'

workflow = Alfred3::Workflow.new

hasARGV = false

if !ARGV.empty? 
    hasARGV = true
end

if hasARGV
    str = ARGV[0].lstrip
    num = str.match(/^\d+/)
    cy = str.match(/[a-zA-Z]{3}/)
    if str.empty? || num.nil? || cy.nil?
        workflow.result
            .title('No result')
            .type('default')
            .valid(true)
            .icon('icon.png')
    else
        num = num[0]
        cy = cy[0].upcase
        uri = URI("http://api.fixer.io/latest?base=#{cy}&symbols=CNY,USD,JPY,EUR,HKD,GBP,CAD")
        result = JSON.parse(Net::HTTP.get(uri))
        result['rates'].each do |key, value|
            workflow.result
                .title("#{(num.to_i*value).round(2)} #{key}")
                .subtitle("#{cy} : #{key} = 1 : #{value.round(2)} (Last Update: #{result["date"]})")
                .valid(true)
                .icon("flags/#{key}.png")
        end
    end
else
    base = 'CNY'
    uri = URI('http://api.fixer.io/latest?base=CNY&symbols=CNY,USD,JPY,EUR,HKD,GBP,CAD')
    result = JSON.parse(Net::HTTP.get(uri))
    result['rates'].each do |key, value|
        workflow.result
            .title("CNY : #{key} = 1 : #{value.round(2)} ")
            .subtitle("Last Update: #{result["date"]}")
            .valid(true)
            .icon("flags/#{key}.png")
    end
end

print workflow.output