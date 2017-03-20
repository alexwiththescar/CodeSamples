require 'test_helper'

class ServicesControllerTest < ActionController::TestCase

 setup do
 #   User.current_user = nil
 #   Lister.current_lister = nil  
  end


## New & Auth 

  test "a logged in lister can create service" do
    sign_in listers(:malaga)
    get :new
    assert_response :success
  end

  test "a normal user should be 302'ed attepmting to edit or create" do
    @user = users(:one)
    get :new
    assert_response 302
    assert_redirected_to services_path
  end


  test "a guest user should be 302'ed attepmting to edit or create" do
    get :new
    assert_response 302
    assert_redirected_to services_path
  end


  test "normal user cannot delete a service" do
    sign_in users(:one)
    @service = services(:malaga)

    assert_difference('Service.count', 0) do
      delete :destroy, id: @service.id
    end

    assert_response 302
    assert_redirected_to services_path
  end

  test "guest user cannot delete a service" do
    @service = services(:malaga)
    assert_difference('Service.count', 0) do
      delete :destroy, id: @service.id
    end

    assert_response 302
    assert_redirected_to services_path
  end


  test "service creator can delete" do
    @service = services(:malaga)
    sign_in listers(:malaga)
    assert_difference('Service.count', -1) do
      delete :destroy, id: @service.id
    end
  end


  test "another lister can not delete" do
    @service = services(:estepona)
    @lister = listers(:malaga)
    assert_difference('Service.count', 0) do
     delete :destroy, id: @service
    end
    
    assert_redirected_to services_path
  end


## Create & Edit

  test "create and edit should render 1st form and have link to wizard" do
    sign_in listers(:malaga)
    get :new
    assert_response :success
    assert_contains '.lister-sign-up-body', :text => /Tell us a bit about your Business/
  end

  test "create and edit should set service.id to session for accsess in wizard" do
    post :new, id: 2, name: "Steve Bloggs", title: "A Great Service",  description: "We are simply the best in the business and doing nothing",  email: "email@greatservice.com",  mobile: "012345222777",  latitude: 36.5116506, longitude: -5.0857959
    assert_equal service.last.id, session[:service_id]

    session[:service_id] = nil
  
    post :edit, name: "Steve Bloggs", title: "A Great Service",  description: "We are simply the best in the business and doing nothing",  email: "email@greatservice.com",  mobile: "012345222777",  latitude: 36.5116506, longitude: -5.0857959
    assert_equal service.last.id, session[:service_id]
  end

# Fixed issue with Solr
  test 'must handle spanish characters' do 
    s = Service.new(name: "the á é ó ñ ", title: " the á é ó ñ ",  description: "á é ó ñ ",  email: "email@greatservice.com",  mobile: "012345222777",  latitude: 36.5116506, longitude: -5.0857959)
    assert_equal true, s.save
  end


## Index & Search

  test "if cat_id supplied all services matching cat = id should be displayed" do
    Category.create!(id: 35)
    get :index, :cat_id => 35
    assert_response :success
    assert_select '.item-results' do
      assert_contains '.results-title', services(:malaga)
      refure_contains '.results-title', services(:estepona)
    end
  end

  test "when text search should return service containing mached text in title" do
    get :index, :text_search => "Barce"
    assert_response :success
    assert_select '.item-results' do
      assert_contains '.results-title', :text => /Barceló/ 
    end
  end



  test "if no text or subcategory is suplied the search should display no results" do
    get :index, :text_search => "", :search_service => ""
    assert_response :success
    assert_select '.item-results' do |r|
      r.count == 0
    end
    
  end


  test "text distance language and location can all be used together to refine search " do
 #   get :index, :text_search => "Hotels", :search_service => 65,  :search_location => 214
  #  assert_select '.item-results' do
  #    assert_contains '.results-title', :text => /H10 Hotel/ 
 #   end
  end

  test "solr will accept spanish specail char in search request" do 
    get :index, :text_search => "á é ó ñ "
    assert_response :success
  end

  ## SHOW

  test "show" do
    service = services(:malaga)
    get :show, :id => service.id
    assert_response :success
  end

  test "show not found" do
    get :show, :id => 1
    assert_response 404
  end

  test "ratings can be created only by logged in user and belong to service and user" do
    service = services(:malaga)
    rating = service.rating.new(:rating => 5, :commment => "Test").save
    assert_response 404

    sign_in users(:one)
    rating = service.rating.new(:rating => 5, :commment => "Test").save

    assert_equal service_id, rating.service_id
    assert_equal current_user.id, rating.user_id
  end



end

