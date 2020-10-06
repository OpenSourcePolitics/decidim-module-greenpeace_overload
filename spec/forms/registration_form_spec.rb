# frozen_string_literal: true

require "spec_helper"

module Decidim
  shared_examples "with missing attribute" do |attr, expectation|
    context "when the #{attr} is not present" do
      let(attr.to_sym) { nil }

      if expectation == :valid
        it { is_expected.to be_valid }
      elsif expectation == :invalid
        it { is_expected.to be_invalid }
      end
    end
  end

  shared_examples "with questions" do |question|
    context "when responds to #{question}" do
      it { is_expected.to be_valid }

      context "and is not included in list" do
        let(question.to_sym) { "yes_or_no" }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "User" }
    let(:nickname) { "justme" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }
    let(:age_slice) { "15-25" }
    let(:group_membership) { %w(local_group employee) }
    let(:question_racialized) { "answer_yes" }
    let(:question_gender) { "answer_yes" }
    let(:question_sexual_orientation) { "answer_yes" }
    let(:question_disability) { "answer_yes" }
    let(:question_social_context) { "answer_yes" }

    let(:attributes) do
      {
        name: name,
        nickname: nickname,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement,
        age_slice: age_slice,
        group_membership: group_membership,
        question_racialized: question_racialized,
        question_gender: question_gender,
        question_sexual_orientation: question_sexual_orientation,
        question_disability: question_disability,
        question_social_context: question_social_context
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.to be_invalid }
    end

    it_behaves_like "with missing attribute", "name", :invalid

    it_behaves_like "with missing attribute", "nickname", :invalid

    it_behaves_like "with missing attribute", "email", :invalid

    it_behaves_like "with missing attribute", "age_slice", :valid

    it_behaves_like "with missing attribute", "group_membership", :valid

    it_behaves_like "with missing attribute", "question_racialized", :valid

    it_behaves_like "with missing attribute", "question_gender", :valid

    it_behaves_like "with missing attribute", "question_sexual_orientation", :valid

    it_behaves_like "with missing attribute", "question_disability", :valid

    it_behaves_like "with missing attribute", "question_social_context", :valid

    context "when respond to age_slice" do
      it { is_expected.to be_valid }

      context "and is not included in list" do
        let(:age_slice) { "150-250" }

        it { is_expected.to be_invalid }
      end
    end

    context "when respond to group_membership" do
      it { is_expected.to be_valid }

      context "and is not included in list" do
        let(:group_membership) { %w(local_group inexistant_value) }

        it { is_expected.to be_invalid }
      end
    end

    it_behaves_like "with questions", "question_racialized"

    it_behaves_like "with questions", "question_gender"

    it_behaves_like "with questions", "question_sexual_orientation"

    it_behaves_like "with questions", "question_disability"

    it_behaves_like "with questions", "question_social_context"

    context "when the email already exists" do
      let!(:user) { create(:user, organization: organization, email: email) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, email: email, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_invalid }
      end
    end

    context "when the nickname already exists" do
      let!(:user) { create(:user, organization: organization, nickname: nickname) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, nickname: nickname, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_valid }
      end
    end

    context "when the nickname is too long" do
      let(:nickname) { "verylongnicknamethatcreatesanerror" }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is not present" do
      let(:password_confirmation) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
    end
  end
end
