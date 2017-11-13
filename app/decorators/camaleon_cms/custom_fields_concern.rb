module CamaleonCms::CustomFieldsConcern
  # ======================CUSTOM FIELDS=====================================
  # render as html the custom fields marked for frontend
  def render_fields
    object.cama_fetch_cache("render_fields") do
      h.controller.render_to_string(partial: "partials/render_custom_field", :locals => {fields: object.get_fields_object(true)})
    end
  end

  # return custom field content with key field_key
  # translated and short codes evaluated like the content
  # default_val: default value returned when this field was not registered
  def the_field(field_key, default_val = '')
    h.do_shortcode(object.get_field(field_key, default_val).to_s.translate(@_deco_locale), object)
  end
  alias_method :the_field!, :the_field

  # return custom field contents with key field_key
  # translated and short codes evaluated like the content
  # this is for multiple values
  def the_fields(field_key)
    r = []
    object.get_fields(field_key).each do |text|
      r << h.do_shortcode(text.to_s.translate(@_deco_locale), object)
    end
    r
  end

  # the same function as get_fields_grouped(..) but this returns translated and shortcodes evaluated
  def the_fields_grouped(field_keys, is_json_format = false)
    res = []
    object.get_fields_grouped(field_keys).each do |_group|
      group = {}.with_indifferent_access
      _group.keys.each do |k|
        if is_json_format
          group[k] = _group[k].map{|v| parse_html_json(v) }
        else
          group[k] = _group[k].map{|v| h.do_shortcode(v.to_s.translate(@_deco_locale), object) }
        end
      end
      res << group
    end
    res
  end

  # return custom field contents with key field_key (only for type attributes)
  # translated and short codes evaluated like the content
  # this is for multiple values
  def the_json_fields(field_key)
    r = []
    object.get_fields(field_key).each do |text|
      r << parse_html_json(text)
    end
    r
  end
  alias_method :the_attribute_fields, :the_json_fields

  # return custom field content with key field_key (only for type attributes)
  # translated and short codes evaluated like the content
  # default_val: default value returned when this field was not registered
  def the_json_field(field_key, default_val = '')
    parse_html_json(object.get_field(field_key, default_val))
  end
  alias_method :the_attribute_field, :the_json_field
  
  private
  def parse_html_json(json)
    r = JSON.parse(json || '{}').with_indifferent_access
    r.keys.each do |k|
      r[k] = h.do_shortcode(r[k].to_s.translate(@_deco_locale), object)
    end
    r
  end
end
