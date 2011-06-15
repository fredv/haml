if Haml::Util.ap_geq_3? && !Haml::Util.ap_geq?("3.0.0.beta4")
  raise <<ERROR
Haml no longer supports Rails 3 versions before beta 4.
  Please upgrade to Rails 3.0.0.beta4 or later.
ERROR
end

# Rails 3.0.0.beta.2+
if defined?(ActiveSupport) && Haml::Util.has?(:public_method, ActiveSupport, :on_load)
  require 'haml/template/options'
  autoload(:Sass, 'sass/rails3_shim')
  ActiveSupport.on_load(:before_initialize) do
    # resolve autoload if it looks like they're using Sass without options
    Sass if File.exist?(File.join(Rails.root, 'public/stylesheets/sass'))
    ActiveSupport.on_load(:action_view) do
      Haml.init_rails(binding)
    end
  end
end

if defined?(ActionView)
  module ActionView::Helpers::FormOptionsHelper
    def options_for_select(container, selected = nil)
      return container if String === container

      container = container.to_a if Hash === container
      selected, disabled = extract_selected_and_disabled(selected).map do | r |
         Array.wrap(r).map(&:to_s)
      end

      container.map do |element|
        html_attributes = option_html_attributes(element)
        text, value = option_text_and_value(element).map(&:to_s)
        selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
        disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
        %(<option value="#{html_escape(value)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{html_escape(text)})
      end.join("\n").html_safe
    end
  end
end