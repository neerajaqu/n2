Given /^a (.+) classifed user exists$/ do |user_status|
  case user_status
  when "owner"
    @user = model('user')
    stub(@user).friends_of_friends_with? { true }
    stub(@user).friends_with? { true }
  when "generic"
    @user = Factory.build(:user)
    stub(@user).friends_of_friends_with?(is_a(User)) { false }
    stub(@user).friends_with?(is_a(User)) { false }
  when "friend"
    @user = Factory.build(:user)
    stub(@user).friends_of_friends_with?(is_a(User)) { true }
    stub(@user).friends_with?(is_a(User)) { true }
  when "friend_of_friend"
    @user = Factory.build(:user)
    stub(@user).friends_of_friends_with?(is_a(User)) { true }
    stub(@user).friends_with?(is_a(User)) { false }
  when "anonymous"
    @user = nil
  else
  	raise "Unknown user status:: #{user_status}"
  end
end

Then /^the user is_allowed\? should return "([^\"]*)"$/ do |return_val|
  classified = model('classified')
  classified.is_allowed?(@user).to_s.should == return_val
end

Then /^the user should be able to view the page: (.+)$/ do |allowed|
  classified = model('classified')
  any_instance_of(ClassifiedsController) do |controller|
    stub(controller).current_user { @user }
    stub(controller).update_last_active { true }
  end

  if allowed == "true"
    lambda { visit classified_path(classified) }.should_not raise_error(Acl9::AccessDenied)
  else
    lambda { visit classified_path(classified) }.should raise_error(Acl9::AccessDenied)
  end
end
