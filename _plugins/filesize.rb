require 'faraday'
require 'faraday_middleware'

module Jekyll
  class FileSizeBlock < Liquid::Block
    def render(context)
      text = super
      conn = ::Faraday.new(url: URI(text)) do |f|
        f.use ::FaradayMiddleware::FollowRedirects, limit: 5
        f.request :url_encoded
        f.adapter ::Faraday.default_adapter
      end
      conn.head.headers['content-length'].to_i
    end
  end
end

Liquid::Template.register_tag('filesize', Jekyll::FileSizeBlock)
