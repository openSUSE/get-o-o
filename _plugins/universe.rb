require 'json'
require 'open-uri'

module Jekyll
  # Create universe data
  module UniverseData
    class << self
      def locale(config)
        setup(config) unless @universe
        @universe
      end

      def setup(config)
        @universe ||= {}
        @language_list ||= JSON.parse(URI.open('https://universe.opensuse.org/api/v0/sites.json').read)
        config['locales_set'].each do |lang_id, _|
          next if @universe.key?(lang_id)
          locale = if @language_list.key?(lang_id)
                     lang_id
                   elsif @language_list.key?(lang_id.split('_')[0])
                     lang_id.split('_')[0]
                   else
                     config['locale']
                   end

          load_data(lang_id, locale)
        end
      end

      def load_data(lang_id, locale)
        @fetched ||= {}
        @fetched[locale] ||= JSON.parse(URI.open(@language_list[locale]).read)

        @universe[lang_id] = {}
        @universe[lang_id] = @fetched[locale]
      end
    end
    private_class_method :load_data
    private_class_method :setup
  end

  module Drops
    # Extending class to add universe liquid data
    class UnifiedPayloadDrop
      def universe
        config = @obj.config['localization']
        @page['locale']
        current_locale = @page['locale'].id
        locale_data = UniverseData.locale(config)
        locale_data[current_locale]
      end
    end
  end
end
