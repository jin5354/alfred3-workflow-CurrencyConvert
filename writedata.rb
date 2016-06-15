require 'json'

data = JSON.parse(File.read('data.json'))

if ARGV[0] == 'add'
    data['units'].push(ARGV[1])
elsif ARGV[0] == 'remove'
    data['units'].delete(ARGV[1])
elsif ARGV[0] == 'base'
    data['base'] = ARGV[1]
end

File.write('data.json', data.to_json)