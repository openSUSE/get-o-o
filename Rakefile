task default: %w[build]

task :build do
  require 'net/http'
  require 'yaml'
  require 'faraday'
  require 'faraday_middleware'
  File.open('_data/snapshots.csv', 'w') do |f|
    f.write("snapshot\n")
    f.write(Net::HTTP.get(URI('http://download.opensuse.org/history/list')))
  end
  File.open('_data/sizes.yml', 'w') do |f|
    output = {}
    [151, 152, 153, 'tumbleweed', 'kubic', 'microos'].each do |filename|
      YAML.load_file("_data/#{filename}.yml")['downloads'].each do |i|
        i['arches'].each do |j|
          j['types'].each do |k|
            conn = ::Faraday.new(url: URI("http://download.opensuse.org#{k['primary_link']}")) do |r|
              r.use ::FaradayMiddleware::FollowRedirects, limit: 5
              r.request :url_encoded
              r.adapter ::Faraday.default_adapter
            end
            output[k['primary_link']] = conn.head.headers['content-length'].to_i
          end
        end
      end
    end
    f.write(output.to_yaml)
  end
end
