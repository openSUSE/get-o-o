Jekyll::Hooks.register :site, :post_read do |site|
  YAML.load_file("_data/releases.yml")&.each do |release|
    site.pages << TagFeed.new(site, site.source, release['version'], 'index', '.html', 0)
  end
end

class TagFeed < Jekyll::Page
  def initialize(site, base, ver, feed, ext, limit)
    @site = site
    @name = "_layouts/#{feed}#{ext}"
    @ext = ext

    self.data = {}
    self.data['permalink'] = "/leap/#{ver}/"

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
      self.data['redirect_to'] = "testing" if index == 0
      self.data['redirect_to'] = "leap" if index == 1
      self.data['redirect_to'] = "legacy" if index >= 2
    end
  end
end
