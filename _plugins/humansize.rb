# frozen_string_literal: true

require 'human_size'

module Jekyll
  # Get human_size within liquid
  class HumanSizeBlock < Liquid::Block
    def render(context)
      text = super
      text.to_i.human_size unless text.to_i.zero?
    end
  end
end

Liquid::Template.register_tag('humansize', Jekyll::HumanSizeBlock)
