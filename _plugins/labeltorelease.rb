module Jekyll
  class LabelToReleaseBlock < Liquid::Block
    def render(context)
      text = super
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
        versions.reject! do |version|
          version['releases'].empty?
        end
        val = 0 if text == "testing"
        val = 1 if text == "current"
        val = 2 if text == "legacy"
        val -= 1 if versions[0]['state'] == 'Stable'
        ret = versions[val]
        "#{ret['version'].to_s}:#{ret['state'].to_s}" unless val < 0
      end
    end
  end
end

Liquid::Template.register_tag('labeltorelease', Jekyll::LabelToReleaseBlock)
