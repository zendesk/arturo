module Arturo
  module RangeFormSupport

    module HelperMethods
      def range_field(object_name, method, options = {})
        ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("range", options)
      end
    end

    module FormBuilderMethods
      def range_field(method, options = {})
        @template.send('range_field', @object_name, method, objectify_options(options))
      end
    end

  end
end
