# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :registration_user_name, with: "Nikola Tesla"
  fill_in :registration_user_nickname, with: "the-greatest-genius-in-history"
  fill_in :registration_user_email, with: "nikola.tesla@example.org"
  fill_in :registration_user_password, with: "sekritpass123"
  fill_in :registration_user_password_confirmation, with: "sekritpass123"
end

describe "Registration", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Sign up to participate")
        expect(page).to have_field("registration_user_name", with: "")
        expect(page).to have_field("registration_user_nickname", with: "")
        expect(page).to have_field("registration_user_email", with: "")
        expect(page).to have_field("registration_user_password", with: "")
        expect(page).to have_field("registration_user_password_confirmation", with: "")
        expect(page).to have_field("registration_user_newsletter", checked: false)
      end

      it "shows additionals fields" do
        checkboxes_presence %w(registration_user_group_membership_local_group
                             registration_user_group_membership_employee
                             registration_user_group_membership_statutory_assembly
                             registration_user_group_membership_volunteer_admin
                             registration_user_group_membership_street_recruiter
                             registration_user_group_membership_other
                            )

        select_presence %w(
                          registration_user_age_slice
                          registration_user_question_racialized
                          registration_user_question_gender
                          registration_user_question_sexual_orientation
                          registration_user_question_disability
                          registration_user_question_social_context
                        )
      end
    end
  end
end

def checkboxes_presence(ids, checked=false)
  ids.each do |id|
    expect(page).to have_field(id, checked: checked)
  end
end

def select_presence(ids, first_option_text="Select")
  ids.each do |id|
    expect(page).to have_field(id)
    expect(find("##{id} > option:nth-child(1)").text).to eq(first_option_text)
  end
end
