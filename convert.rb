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
    workflow.result
        .uid('bob-belcher')
        .title(ARGV[0])
        .subtitle('Head Burger Chef')
        .quicklookurl('http://www.bobsburgers.com')
        .type('default')
        .arg('bob')
        .valid(true)
        .icon('bob.png')
        .mod('cmd', 'Search for Bob', 'search')
        .text('copy', 'Bob is the best!')
        .autocomplete('Bob Belcher')

    workflow.result
        .uid('linda-belcher')
        .title('Linda')
        .subtitle('Wife')
        .quicklookurl('http://www.bobsburgers.com')
        .type('defaulst')
        .arg('linda')
        .valid(true)
        .icon('linda.png')
        .mod('cmd', 'Search for Linda', 'search')
        .text('largetype', 'Linda is the best!')
        .autocomplete('Linda Belcher')
else
    uri = URI('http://api.fixer.io/latest?base=CNY')
    result = JSON.parse(Net::HTTP.get(uri))
    result['rates'].each do |key, value|
        workflow.result
            .title(key)
            .subtitle(value)
            .valid(true)
            .icon('bob.png')
    end
end

print workflow.output