# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user through the sign up form.
  class CreateRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      if form.invalid?
        user = User.has_pending_invitations?(form.current_organization.id, form.email)
        user.invite!(user.invited_by) if user
        return broadcast(:invalid)
      end

      create_user

      broadcast(:ok, @user)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end

    private

    attr_reader :form

    def create_user
      @user = User.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          password: form.password,
          password_confirmation: form.password_confirmation,
          organization: form.current_organization,
          tos_agreement: form.tos_agreement,
          newsletter_notifications_at: form.newsletter_at,
          email_on_notification: true,
          accepted_tos_version: form.current_organization.tos_version,
          locale: form.current_locale,
          extended_data: extended_data
      )
    end

    def extended_data
      {
          age_slice: form.try(:age_slice) || "",
          group_membership: form.try(:group_membership) || "",
          question_racialized: form.try(:question_racialized) || "",
          question_gender: form.try(:question_gender) || "",
          question_sexual_orientation: form.try(:question_sexual_orientation) || "",
          question_disability: form.try(:question_disability) || "",
          question_social_context: form.try(:question_social_context) || "",
      }
    end
  end
end
