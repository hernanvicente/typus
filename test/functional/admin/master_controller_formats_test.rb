require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def setup
    @typus_user = typus_users(:admin)
    @request.session[:typus_user_id] = @typus_user.id
  end

  def test_should_generate_xml

    expected = <<-RAW
<?xml version="1.0" encoding="UTF-8"?>
<posts type="array">
  <post>
    <status type="boolean">false</status>
    <title>Owned by admin</title>
  </post>
  <post>
    <status type="boolean">false</status>
    <title>Owned by editor</title>
  </post>
  <post>
    <status type="boolean">true</status>
    <title>Title One</title>
  </post>
  <post>
    <status type="boolean">false</status>
    <title>Title Two</title>
  </post>
</posts>
    RAW

    get :index, :format => 'xml'
    assert_equal expected, @response.body

  end

  def test_should_generate_csv

    begin
      require 'fastercsv'
    rescue LoadError
      return
    end

    expected = <<-RAW
Title,Status
Owned by admin,false
Owned by editor,false
Title One,true
Title Two,false
     RAW

    get :index, :format => 'csv'
    assert_equal expected, @response.body

  end

end