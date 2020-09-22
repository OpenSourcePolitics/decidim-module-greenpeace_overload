# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    AGE_SLICE = %w(15-25 25-35 35-45 45-55 55-65 65-75 75-85)
    GROUP_MEMBERSHIP = [:local_group, :employee, :statutory_assembly, :volunteer_admin, :street_recruiter, :other]
    GENERIC_ANSWERS = [:answer_yes, :answer_no, :not_answering]

    attribute :name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    attribute :current_locale, String
    attribute :age_slice, String
    attribute :group_membership, String
    attribute :question_racialized, String
    attribute :question_gender, String
    attribute :question_sexual_orientation, String
    attribute :question_disability, String
    attribute :question_social_context, String

    validates :name, presence: true
    validates :nickname, presence: true, format: /\A[\w\-]+\z/, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validates :age_slice, inclusion: { in: AGE_SLICE }, if: ->(form){ form.age_slice.present? }
    validate :group_membership_inclusion, if: ->(form){ form.group_membership.present? }
    validate :questions_validation
    validate :email_unique_in_organization
    validate :nickname_unique_in_organization
    validate :no_pending_invitations_exist

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    private

    def questions_validation
      check_question_inclusion(:question_racialized, question_racialized) if defined? question_racialized
      check_question_inclusion(:question_gender, question_gender) if defined? question_gender
      check_question_inclusion(:question_sexual_orientation, question_sexual_orientation) if defined? question_sexual_orientation
      check_question_inclusion(:question_disability, question_disability) if defined? question_disability
      check_question_inclusion(:question_social_context, question_social_context) if defined? question_social_context
    end

    def check_question_inclusion(question_sym, answer, inclusion_ary=GENERIC_ANSWERS)
      return unless answer.present?

      errors.add question_sym, :inclusion unless inclusion_ary.include? answer.to_sym
    end

    def group_membership_inclusion
      return if group_membership.blank?

      group_membership.reject(&:empty?).map(&:to_sym).each do |elem|
        errors.add :group_membership, :inclusion unless GROUP_MEMBERSHIP.include? elem.to_sym
      end
    end

    def email_unique_in_organization
      errors.add :email, :taken if User.no_active_invitation.find_by(email: email, organization: current_organization).present?
    end

    def nickname_unique_in_organization
      errors.add :nickname, :taken if User.no_active_invitation.find_by(nickname: nickname, organization: current_organization).present?
    end

    def no_pending_invitations_exist
      errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
    end
  end
end
