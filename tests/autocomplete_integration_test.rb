require 'test_helper'

class AutocompleteTest < ActionDispatch::IntegrationTest

  test "autocomplete" do
    Capybara.current_driver = Capybara.javascript_driver
    visit "/"
    field = 'text_search'
    fill_in(field, with: 'Hot')
    page.execute_script %Q{ $('##{field}').trigger("focus") }
    suggestion = page.find('div.found_name')
    assert_contains "Hotel", suggestion.text
  end
end