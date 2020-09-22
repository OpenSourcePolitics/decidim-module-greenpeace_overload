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

        expect(page).to have_field("registration_user_age_slice")

        checkboxes_presence %w(registration_user_group_membership_groupe_local
                             registration_user_group_membership_salariées
                             registration_user_group_membership_assemblée_statutaire__board
                             registration_user_group_membership_bénévoles_admin
                             registration_user_group_membership_recruteureuses_de_rue__dd
                             registration_user_group_membership_recruteureuses_de_rue__dd
                            )

        expect(page).to have_field("registration_user_question_racialized")
        expect(page).to have_field("registration_user_question_gender")
        expect(page).to have_field("registration_user_question_sexual_orientation")
        expect(page).to have_field("registration_user_question_disability")
        expect(page).to have_field("registration_user_question_social_context")
      end
    end
  end
end

def checkboxes_presence(ids, checked=false)
  ids.each do |id|
    expect(page).to have_field(id, checked: checked)
  end
end
