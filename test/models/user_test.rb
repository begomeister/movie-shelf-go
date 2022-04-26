require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = User.create( email: "user@example.com",
                          password: "foobar",
                          password_confirmation: "foobar")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "email should be present" do
  	@user.email = ""
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org, user.name@example. foo@bar_baz.com foo@bar+baz.com]
    
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should not be valid"
    end
  end
  
  test "email address should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present" do
  	@user.password = ""
  end

	test "authenticated? should return false for a user with nil digest" do
		@user.password = ""
    assert_not User.authenticate(@user.email, @user.password)
  end

  test "default_list should return true for having a default movie list" do
    list = @user.movie_lists.find_by_name("default")
  	assert_not_nil list
  end

end
