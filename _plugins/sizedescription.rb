# frozen_string_literal: true

module Jekyll
  # Get size description within liquid
  class SizeDescriptionBlock < Liquid::Block
    def render(context)
      text = super
      case text.to_i
      when 0 then ''
      when 1..700_000_000
        'cd_desc'
      when 700_000_001..5_000_000_000
        'dvd_desc'
      else
        'usb_desc'
      end
    end
  end
end

Liquid::Template.register_tag('sizedescription', Jekyll::SizeDescriptionBlock)
