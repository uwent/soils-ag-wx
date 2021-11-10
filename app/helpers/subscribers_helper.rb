module SubscribersHelper
  def title
    "Automated Daily ET Values"
  end

  def do_welcome
    <<-END
    #{image_tag "icons/awon.png"}
    <h2>#{link_to title.to_s, action: "index"}</h2>
    END
  end

  def product_select_options(products)
    prod_map = products.reject { |p| p.name =~ /Cranberry/ }.map { |p| [p[:name], p[:id]] }
    options_for_select prod_map << ["Please select a product", -1], disabled: -1, selected: -1
  end
end
