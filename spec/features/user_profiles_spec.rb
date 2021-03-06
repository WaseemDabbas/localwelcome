require 'rails_helper'

feature "User profiles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:empty_user) { FactoryGirl.create(:empty_user) }
  let(:more_info_required_user) { FactoryGirl.create(:user, more_info_required: true) }
  let(:name) { Faker::Name.name }
  let(:telephone) { Faker::PhoneNumber.phone_number }
  let(:bio) { Faker::Lorem.paragraph }
  let(:postcode) { Faker::Address.postcode }
  let(:life_skills) { Faker::Lorem.paragraph }
  let(:language_skills) { Faker::Lorem.paragraph }

  scenario "A user's profile details are visible on the profile page" do
    login user
    visit profile_path

    [:name, :email, :telephone, :bio, :postcode, :life_skills, :language_skills].each do |attr|
      expect(page).to have_content user.send(attr)
    end
  end

  scenario "A user can fill out some of their profile" do
    login empty_user
    visit profile_path
    expect(page).not_to have_content bio
    expect(page).not_to have_content telephone

    click_link "Edit your profile..."
    fill_in :user_bio, with: bio
    fill_in :user_telephone, with: telephone
    click_button "Save"

    # Page should show new profile values
    expect(page).to have_success_notice
    expect(page).to have_content bio
    expect(page).to have_content telephone

    # User record should be updated
    empty_user.reload
    expect(empty_user.bio).to eq bio
    expect(empty_user.telephone).to eq telephone
  end

  scenario "A user can fill out all of their profile" do
    login empty_user
    visit edit_profile_path
    fill_in :user_name, with: name
    fill_in :user_telephone, with: telephone
    fill_in :user_bio, with: bio
    fill_in :user_postcode, with: postcode
    fill_in :user_life_skills, with: life_skills
    fill_in :user_language_skills, with: language_skills
    click_button "Save"

    # Page and user should have been updated.
    empty_user.reload
    expect(page).to have_success_notice
    [:name, :telephone, :bio, :postcode, :life_skills, :language_skills].each do |attr|
      expect(page).to have_content self.send(attr)
      expect(empty_user.send(attr)).to eq self.send(attr)
    end
  end

  scenario "A user flagged as 'more info required' gets that flag removed when they update their profile" do
    expect(more_info_required_user).to be_more_info_required

    login more_info_required_user
    visit edit_profile_path
    fill_in :user_bio, with: Faker::Lorem.paragraph
    click_button "Save"
    more_info_required_user.reload

    expect(page).to have_success_notice
    expect(more_info_required_user).not_to be_more_info_required
  end
end
