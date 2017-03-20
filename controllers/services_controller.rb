class ServicesController < ApplicationController
   
  require 'core_ext/alph'
  include ServicesHelper


  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :lister_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_action :lister_correct_edit, only: [:edit, :update, :destroy]
  before_action :set_lister
  before_action :find_or_create_location, only: [:edit, :update, :create]
  
  impressionist :actions=>[:show]

  def index
      @categories = Category.all
      @nearby_services = [] # ToDO

    if params[:cat_id]  # Handle links from HomePage, else run the search...
      @services = Service.category(params[:cat_id])
    else 

      if params[:search_location]
        location = Location.find(params[:search_location])
      end

      search = Service.search do
        
        fulltext params[:text_search]

        if params[:search_service]
        with :sub_category_id, params[:search_service] unless params[:search_service].empty?
        end

        if params[:search_location]
          if params[:search_location].to_i == 104 # NearMe in the dropdown
            with(:location).in_radius(lat_lng[0],lat_lng[1], params[:distance_from])
          else
            with(:location).in_radius(location.latitude, location.longitude, params[:distance_from])
          end
        end

        if params[:language]
          with :language_ids, params[:language]
        end
      end

      # apply map_pins, distance_from_user for for display in views
      count = 0
      @services_scope = search.results.each {|s| s.distance_from_user = s.distance_from(lat_lng); s.map_pin = (count += 1)  }
      # Sort Collection by distance from user applied above
      @services = @services_scope.sort_by{ |s| s.distance_from_user}

      if params[:search_service] && params[:text_search]
        # Avoid exposing all services when empty strings
        if params[:search_service] && params[:text_search] && params[:search_service].empty? && params[:text_search].empty?
          @services = []
        end
      end
    end 

    @hash = Gmaps4rails.build_markers(@services) do |service, marker|
      marker.lat service.latitude
      marker.lng service.longitude
      marker.title   service.title
      marker.picture({
        :url => ActionController::Base.helpers.image_url('locationicon_map.png'),
        :width   => 32,
        :height  => 32 })
    end
  end


       # GET /services/1
       # GET /services/1.json
  def show
    
    @rating = Rating.new(:service_id=>@service.id)
    @message = Message.new(:service_id=>@service.id)
 
    @hash =  [{
      "lat": "#{@service.latitude}",
      "lng": "#{@service.longitude}",
      "picture": {
        "url": "#{ActionController::Base.helpers.image_url('locationicon_map.png')}",
        "width":  32,
        "height": 32
        },
      "infowindow": "#{@service.title}"
      }]
  end

  # GET /services/new
  def new
    @lister = current_lister
    @service = Service.new(:lister_id=>@lister.id)
  end

  # GET /services/1/edit
  def edit

  end

  # POST /services
  # POST /services.json
  def create
    @service = Service.new(service_params)
    if @service.save
      session[:service_id] = @service.id
      redirect_to service_steps_path
    else
      render :new 
    end 
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    if @service.update(service_params)
       session[:service_id] = @service.id
       redirect_to service_steps_path
    else
      render :edit  
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to request.referer, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
  
  def lister_correct_edit
    if lister_signed_in?
      redirect_to services_path unless current_lister.services.pluck(:slug).include? (params[:id]) 
    else
      redirect_to services_path
    end
  end


  def lister_logged_in 
    unless lister_signed_in? 
      redirect_to services_path, notice: 'You must be logged in as a business to create service!'
    else
      return
    end
  end

  def find_or_create_location
    @loc = Location.find_or_initialize_by(:location => params[:service][:address2]) unless params[:service][:address2].nil?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_service
    if params[:id] == params[:id].to_i.to_s
      @service = Service.find(params[:id])
    else
      @service = Service.find_by_slug(params[:id])
    end
  end

  def set_lister
    @lister = current_lister if lister_signed_in? 
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def service_params
    params.require(:service).permit(*Service.globalize_attribute_names, :slug, :rating_count, :avarage_rating, :translations_attributes, :website , :facebook, :twitter, :google,:address3, :address4, :region,:active, :name, :email, :mobile, :description, :location_id, :title, :sub_category_id, :latitude, :longitude, :postcode, :address1, :address2, :logo, :lister_id, :listers_id,:languages,:language_ids => [], :translations_attributes => [:id =>[:locale, :title]], :post_attachments_attributes => [:id, :service_id, :image])
  end
end