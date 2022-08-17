# frozen_string_literal: true

def load_yaml(name)
  YAML.load_file("_data/#{name.delete('_')}.yml")
end

def fetch_versions
  %w[leap_micro leap].each_with_object({}) do |name, hash|
    hash[name] = load_yaml(name).each_with_object({}) do |version, release|
      version['releases'].remove_unreleased!
      next if version['releases'].empty?

      # Add the data from the latest release to the main hash
      version.merge!(version['releases'].max_by { |k| k['date'] })
      release[version['version'].nodot] = version
    end
  end
end

# For parsing the dates and removing not-yet-released states
class Array
  def remove_unreleased!
    reject! do |release|
      release['date'] = Time.parse(release['date'])
      release['date'] > Time.now
    end
  end
end

# Allows for easily getting a string without a dot
class Float
  def nodot
    to_s.delete('.')
  end
end

STATE = %w[testing current].freeze

# Adds a data source accessible from within liquid using `page.releases`
class Releases
  def initialize(site)
    @site = site
  end

  def munge!
    versions = fetch_versions
    @site.config['releases'] = versions
    append_state
  end

  def append_state
    # Add info on which version is current and which is testing
    @site.config['releases'].each do |name, hash|
      STATE.each do |state|
        val = STATE.index(state)
        val -= 1 if hash.values[0]['state'] == 'Stable'
        @site.config['releases'][name][state] = hash.values[val]['version'].to_s.delete!('.') if val >= 0
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Releases.new(site).munge!
end

# Generates pages for number releases from `_layouts`
class ReleasePage < Jekyll::Page
  def initialize(site, distro, version)
    @site = site
    @ext = '.html'
    @name = "_layouts/#{distro.delete('_')}#{ext}"
    @relative_path = generate_permalink(distro, version) + 'index.html'
    super(site, site.source, '', name)

    self.data = populate_data(distro, version)
  end

  def populate_data(distro, version)
    data = {}
    data['layout'] = distro.delete('_')
    data['permalink'] = generate_permalink(distro, version)
    return data unless File.exist?("_data/#{version.nodot}.yml")

    name = load_yaml(version.nodot)['name']
    data['title'] = "openSUSE #{name} #{version}"

    data.merge(fetch_versions_data(distro, version))
  end

  def generate_permalink(distro, version)
    permalink = '/'
    permalink += "#{distro.delete('_')}/#{version}/"
    permalink
  end

  def fetch_versions_data(distro, version)
    releases = fetch_versions[distro]
    data = {}
    data['version'] = version.nodot
    data['state'] = releases[version.nodot]['state']
    data['type'] = get_type(distro, version)
    data
  end

  def get_type(distro, version)
    versions = fetch_versions
    abort unless !versions.nil? || versions.key?(distro)
    releases = versions[distro].values
    index = releases.index { |v| v['version'] == version }
    index += 1 if releases[0]['state'] == 'Stable'
    return STATE[index] unless STATE[index].nil?

    'legacy'
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  fetch_versions.each do |type, release|
    release.each do |_version, hash|
      site.pages << ReleasePage.new(site, type, hash['version'])
    end
  end
end
