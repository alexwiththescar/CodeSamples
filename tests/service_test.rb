
require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  
  def setup
    @service = services(:valid_service)
  end

  test 'valid service' do
    assert @service.valid?
  end

  test 'invalid without name' do
    @service.update_attribute(:name, nil )
    refute @service.valid?, 'saved service without a name'
    assert_not_nil @service.errors[:name], 'no validation error for name present'
  end

  test 'invalid without title' do
    @service.update_attribute(:title, nil )
    refute @service.valid?, 'saved service without a title'
    assert_not_nil @service.errors[:title], 'no validation error for title not present'
  end

  test 'must create slug' do
   	@service.slug = nil
  	assert @service.valid?
    assert_not_nil @service.errors[:slug], 'no validation error for slug not present'
  end


  test 'invalid without email' do
    @service.email = nil
    refute @service.valid?, 'saved service without a email'
    assert_not_nil @service.errors[:email], 'no validation error for email' 
  end

  test 'belongs to lister' do 
  	assert @service.respond_to?(:lister)
  end

  test 'can have ratings' do 
  	assert @service.respond_to?(:ratings)
  end

  test 'can have messages' do 
  	assert @service.respond_to?(:messages)
  end

  test 'belongs to a category' do
  	assert @service.respond_to?(:category)
  end

  test 'has languages' do
  	assert @service.respond_to?(:languages)
  end

  test 'adds http to web address' do
  	@service.update_attribute(:website,"example.com")
  	assert_equal  "http://example.com", @service.website
  end	

	test 'globalize working' do
  	 @service.attributes = { title: 'Spanish', locale: :es }
  	 @service.attributes = { title: 'English', locale: :en }
  	 I18n.locale = :en
  	 assert_equal  "English", @service.title
  	 I18n.locale = :es
  	 assert_equal  "Spanish", @service.title
	end

  test 'globalise-accsessors gem' do
  	assert @service.respond_to?(:title_es)
  	assert @service.respond_to?(:description_es)
	end

  

end
