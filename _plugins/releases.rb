def getversions
  versions = {}

  {'leap_micro': '_data/leapmicro.yml', 'leap': '_data/leap.yml'}.each do |name, file|
    yaml = YAML.load_file(file)
    unless yaml.empty?
      versions[name.to_s] = {}
      now = Time.now
      yaml.each do |version|
        version['releases'].reject! do |release|
          release['date'] = Time.parse(release['date'])
          release['date'] > now
        end
        # Get the latest release
        latest = version['releases'].max_by { |k| k['date'] }
        version['state'] = latest['state'] if latest
      end
      yaml.reject! {|v| v['releases'].empty?}
      yaml.each do |version|
        versions[name.to_s][version['version'].to_s.delete!('.')] = version
      end
    end
  end
  versions
end

def gettype(distro, version)
  versions = getversions
  abort unless versions != nil || versions.has_key?(distro)
  releases = versions[distro]
  index = releases.values.index { |v| v['version'] == version }.to_i
  index += 1 if releases.values[0]['state'] == 'Stable'
  "testing" if index == 0
  "leap" if index == 1
  "legacy" if index >= 2
end

class Releases

  def initialize(site)
    @site = site
  end

  def munge!
    versions = getversions
    # Add info on which version is current and which is testing
    versions.each do |name, hash|
      ['testing', 'current'].each do |state|
        val = 0 if state == 'testing'
        val = 1 if state == 'current'
        val -= 1 if hash.values[0]['state'] == 'Stable'
        versions[name][state] = hash.values[val]['version'].to_s.delete!('.')
      end
    end
    @site.config['releases'] = versions
    
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Releases.new(site).munge!
end

class ReleasePage < Jekyll::Page
  def initialize(site, base, ver, lang, feed, ext, limit)
    @site = site
    @name = "_layouts/#{feed.delete('_')}#{ext}"
    @ext = ext
    ver_nodot = ver.to_s.delete('.')

    self.data = {}
    self.data['layout'] = feed.delete('_')
    permalink = '/'
    permalink += "#{lang}/" if lang && lang != 'en'
    permalink += "#{feed.delete('_')}/"
    permalink += "#{ver}/"
    self.data['permalink'] = permalink
    self.data['title'] = 'openSUSE'
    self.data['title'] += " #{feed.gsub('_', ' ').gsub(/\w+/) { |word| word.capitalize }}"
    self.data['title'] += " #{ver}"

    versions = getversions
    unless versions.empty?
      releases = versions[feed]
      
      if File.exist?("_data/#{ver_nodot}.yml")
        self.data['version'] = ver_nodot
        self.data['state'] = releases[ver_nodot]['state']
        self.data['title'] += " #{self.data['state']}"
        self.data['type'] = gettype(feed, ver)
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  getversions.each do |type, release|
    release.each do |version, hash|
      site.locale_handler.available_locales.each do |lang|
        site.pages << ReleasePage.new(site, site.source, hash['version'], lang, type, '.html', 0)
      end
    end
  end
end
