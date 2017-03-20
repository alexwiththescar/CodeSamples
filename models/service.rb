# == Schema Information
#
# Table name: services
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  mobile          :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sub_category_id :integer
#  title           :string(255)
#  description     :text(65535)
#  location_id     :integer
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  postcode        :string(255)
#  address1        :string(255)
#  address2        :string(255)
#  image           :string(255)
#  lister_id       :integer
#  active          :boolean
#  address3        :string(255)
#  address4        :string(255)
#  region          :string(255)
#  expire_by       :date
#  facebook        :string(255)
#  twitter         :string(255)
#  website         :string(255)
#  google          :string(255)
#  logo            :string(255)
#  rating_count    :integer
#  avg_rating      :integer
#  slug            :string(255)
#  banner          :string(255)
#

class Service < ActiveRecord::Base

	include Wicked::Wizard::Validations

	has_many :ratings,  dependent: :destroy
	has_many :offers,  dependent: :destroy
	belongs_to :sub_category
	belongs_to :lister
	has_one :category, through: :sub_category

	is_impressionable

	has_many :messages, dependent: :destroy
	has_and_belongs_to_many :languages

	def self.wizard_steps
	 [:description_and_location, 
	  :images, 
	  :filters, 
	  :contact_and_socail]
	end

	def self.description_and_location_validations   
    { description: { presence: { message: "Don't be shy! Tell us what you do." } } }
  end

  def self.contact_and_socail_validations   
    { description: { presence: { message: "Don't be shy! Tell us a bit more about you." } } }
  end


  before_save :smart_add_url_protocol
  before_save :create_slug
# validates :website, :format => { :with => /^((http|https):\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]+).[a-z]{2,5}(:[0-9]{1,5})?(\/.)?$/ix, :message => " is not valid" }
  validates :title, uniqueness: true, presence: true
	validates :email, :mobile, :name, :longitude, :latitude, presence: true

	translates :name, :title, :description
	globalize_accessors :locales => [:en, :es], :attributes => [:name, :title, :description]
	accepts_nested_attributes_for :translations 

	reverse_geocoded_by :latitude, :longitude 

	mount_uploader :logo, LogoUploader
	mount_uploader :banner, BannerPictureUploader
	
	has_many :service_attachments
  accepts_nested_attributes_for :service_attachments

  has_many :service_video_attachments
  accepts_nested_attributes_for :service_video_attachments

  attr_accessor :map_pin, :distance_from_user, :avg_rating

# opening_hours_hash = {"Monday"=>[{:start_time=>2017-02-27 10:00:00 +0100, :duration=>600}, {:start_time=>2017-02-27 16:00:00 +0100, :duration=>600}], "Tuseday"=>{:start_time=>2017-02-27 16:05:11 +0100, :duration=>600}} 
  store :opening_hours_hash, accessors: [ :day ], coder: JSON

  scope :active, -> { where(active: true) }
  scope :english, -> { Language.find(1).services }
  scope :spanish, -> { Language.find(2).services }
  scope :russian, -> { Language.find(3).services }
  scope :german, 	-> { Language.find(4).services }
  scope :french, 	-> { Language.find(5).services }

  scope :category, -> (cat_id) {Category.find(cat_id).services }
  scope :language, -> (lang_id) {Language.find(lang_id).services }
 	
 	searchable do

    text :title, as: :title_ac 
    text :description 

	  integer :language_ids, :multiple => true
		integer :sub_category_id 
	  integer :location_id     

    latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }

  end


private

  def create_slug
    self.slug = title.downcase.gsub!(/[^0-9a-z]/i, "-") 
  end

  def smart_add_url_protocol
    unless self.website.nil? 
      unless self.website.empty? 
        logger.info "Called"
        unless self.website[/\Ahttp:\/\//] || self.website[/\Ahttps:\/\//]
          self.website = "http://#{self.website}"
        end
      end
    end
  end
  
end