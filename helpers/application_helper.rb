module ApplicationHelper
  require 'iconv'

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def location_drop_down
    @locations = Location.all.drop(1).collect{ |a| [ a.location , a.id] }
    @locations = @locations.sort_by { |e,k| I18n.transliterate e }
    @locations.unshift([Location.first.location, Location.first.id])
  end

  def avg_rating(service)
    unless service.ratings.count == 0
      sum = service.ratings.collect { |r| r.rating }
      avg = sum.reduce(0, :+)/service.ratings.count
      return avg
    end
  end

  def total_views(lister)
    @lister = Lister.find(lister.id)
    total_views = 0
    @lister.services.each {|s| total_views += s.impressionist_count }
    return total_views
  end

  def lang_lookup(locale)
    lookup = {:en=>"English", :es=>"Espaniol"}
    return lookup[locale]
  end

  def lang_inverse(locale)
    lookup = {:en=>:es, :es=>:en}
    return lookup[locale]
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when :success
        "alert alert-success" # Green
      when :error
        "alert alert-danger" # Red
      when :alert
        "alert alert-warning" # Yellow
      when :notice
        "alert alert-info" # Blue
      else
        flash_type.to_s
    end
  end

 
  def distance_from_me(service)
    unless session[:location].blank?
      dist = service.distance_from(session[:location])
      return sprintf('%.0f', dist)
    end
  end

  def cat_lookup(id)
    subcat = SubCategory.find(id).name
  end 

  def location_lookup(id)
    location = Location.find(id).location
  end
    
  def other_subcategories(id)
    other_subcat = SubCategory.find(id).category.sub_categorys
  end
end
