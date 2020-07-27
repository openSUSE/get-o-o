module Jekyll
  class SizeDescriptionBlock < Liquid::Block
    def render(context)
      text = super
      case text.to_i
      when 0 then ''
      when 1..700_000_000
        'For CD and USB stick'
      when 700_000_001..5_000_000_000
        'For DVD and USB stick'
      else
        'For USB stick'
      end
    end
  end
end

Liquid::Template.register_tag('sizedescription', Jekyll::SizeDescriptionBlock)
