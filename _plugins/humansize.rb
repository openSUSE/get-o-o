require 'human_size'

module Jekyll
  class HumanSizeBlock < Liquid::Block
    def render(context)
      text = super
      text.to_i.human_size unless text.to_i == 0
    end
  end
end

Liquid::Template.register_tag('humansize', Jekyll::HumanSizeBlock)
