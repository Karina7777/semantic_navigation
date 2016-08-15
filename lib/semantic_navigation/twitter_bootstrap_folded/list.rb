module SemanticNavigation
  module TwitterBootstrapFolded
    class List

      include SemanticNavigation::Renderers::MixIn::RenderHelpers
      include SemanticNavigation::Renderers::MixIn::ActsAsList

      property_for :base, :ico

private

      def navigation(object)
        yield
      end

      def node(object)
        content_tag(:li, nil ) do
          yield
        end
      end

      def node_content(object)
        name = object_name(object)
        content_tag(:a, class: 'auto', href: '') do
          content_tag(:span, nil, class: 'pull-right text-muted') do
            content_tag(:i, nil, class: 'fa fa-fw fa-angle-right text') +
              content_tag(:i, nil, class: 'fa fa-fw fa-angle-down text-active')
          end +
            content_tag(:i, nil, class: object.ico) +
            content_tag(:span) do
            name
          end
        end +
          yield
      end

      def wrapper_for_first_element
        content_tag(:ul, { class: 'nav nav-sub dk' } ) do
          yield
        end
      end

      def leaf(object)
        name = object_name(object)
        content_tag :li, nil do
          link_to content_tag(:span) { name }, object.url, { }.merge(object.link_html)
        end
      end

    end
  end
end
