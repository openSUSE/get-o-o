task default: %w[build]

task :build do
  require 'net/http'
  File.open('_data/snapshots.csv', 'w') do |f|
    f.write(Net::HTTP.get(URI('http://download.opensuse.org/history/list')))
  end
end
