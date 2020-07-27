Jekyll::Hooks.register :site, :post_read do |site|
  YAML.load_file("_data/releases.yml")&.each do |release|
    site.locale_handler.available_locales.each do |lang|
      site.pages << TagFeed.new(site, site.source, release['version'], lang, 'index', '.html', 0)
    end
  end
end

class TagFeed < Jekyll::Page
  def initialize(site, base, ver, lang, feed, ext, limit)
    @site = site
    @name = "_layouts/#{feed}#{ext}"
    @ext = ext

    self.data = {}
    permalink = '/'
    permalink += "#{lang}/" if lang && lang != 'en'
    permalink += 'leap/'
    permalink += "#{ver}/"
    self.data['permalink'] = permalink

    versions = YAML.load_file("_data/releases.yml")
    unless versions.empty?
      now = Time.now
      versions.each do |version|
        version['releases'].reject! do |release|
          release['date'] = Time.parse(release['date'])
          release['date'] > now
        end
        # Get the latest release
        latest = version['releases'].max_by { |k| k['date'] }
        version['state'] = latest['state'] if latest
      end
      versions.reject! {|v| v['releases'].empty?}
      index = versions.index { |v| v['version'] == ver }.to_i
      index += 1 if versions[0]['state'] == 'Stable'
      redirect_to = '/'
      redirect_to += "#{lang}/" if lang  && lang != 'en'
      redirect_to += "testing/" if index == 0
      redirect_to += "leap/" if index == 1
      redirect_to += "legacy/" if index >= 2
      self.data['redirect_to'] = redirect_to
    end
  end
end
