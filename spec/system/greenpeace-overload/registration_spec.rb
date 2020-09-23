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

      context "with optional informations" do
        before do
          fill_registration_form
        end

        context "with all optional informations" do
          it "is valid" do
            select '45-55', from: :registration_user_age_slice
            check :registration_user_group_membership_local_group
            check :registration_user_group_membership_employee
            check :registration_user_group_membership_statutory_assembly
            check :registration_user_group_membership_volunteer_admin
            check :registration_user_group_membership_street_recruiter
            check :registration_user_group_membership_other
            select 'Yes', from: :registration_user_question_racialized
            select 'Yes', from: :registration_user_question_gender
            select 'Yes', from: :registration_user_question_sexual_orientation
            select 'Yes', from: :registration_user_question_disability
            select 'Yes', from: :registration_user_question_social_context
            check :registration_user_newsletter
            check :registration_user_tos_agreement

            within "form.new_user" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("You have signed up successfully.")
          end
        end

        context "with missing optional informations" do
          it "is valid" do
            check :registration_user_group_membership_other
            select 'Yes', from: :registration_user_question_disability
            select 'Yes', from: :registration_user_question_social_context
            check :registration_user_newsletter
            check :registration_user_tos_agreement

            within "form.new_user" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("You have signed up successfully.")
          end
        end
      end
    end
  end

  context "when newsletter checkbox is unchecked" do
    it "opens modal on submit" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :visible)
      expect(page).to have_current_path decidim.new_user_registration_path
    end

    it "checks when clicking the checking button" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Check and continue"
      expect(page).to have_current_path decidim.new_user_registration_path
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :hidden)
      expect(page).to have_field("registration_user_newsletter", checked: true)
    end

    it "submit after modal has been opened and selected an option" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      click_button "Keep uncheck"
      expect(page).to have_css("#sign-up-newsletter-modal", visible: :all)
      fill_registration_form
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("registration_user_newsletter", checked: false)
    end
  end

  context "when newsletter checkbox is checked but submit fails" do
    before do
      fill_registration_form
      page.check("registration_user_newsletter")
    end

    it "keeps the user newsletter checkbox true value" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_current_path decidim.user_registration_path
      expect(page).to have_field("registration_user_newsletter", checked: true)
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
