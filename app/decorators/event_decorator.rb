class EventDecorator < Draper::Decorator
  delegate_all

  def friendly_description
    field_helper(:description)
  end

  def email_info
    field_helper(:email_info)
  end

  def venue_name
    field_helper(:venue_name)
  end

  def venue_postcode
    field_helper(:venue_postcode)
  end

  def venue_info
    field_helper(:venue_info)
  end

  def friendly_venue_name
    if !object.venue_name.blank? && !object.venue_postcode.blank?
      "#{venue_name}, #{venue_postcode}"
    elsif !object.venue_name.blank?
      venue_name
    elsif !object.venue_postcode.blank?
      "(Not announced yet), #{venue_postcode}"
    else
      "Not announced yet"
    end
  end

  def google_map_url
    if !object.venue_name.blank? && !object.venue_postcode.blank?
      query_param = "#{venue_name}, #{venue_postcode}"
    elsif !object.venue_name.blank? || !object.venue_postcode.blank?
      query_param = "#{object.venue_name}#{object.venue_postcode}"
    end
    "https://maps.google.com/?q=" + h.u(query_param)
  end

  protected

  def field_helper(field)
    if object.public_send(field).blank?
      h.content_tag :span, "No #{field.to_s.humanize.downcase} yet", class: "system message"
    else
      object.public_send(field)
    end
  end
end
