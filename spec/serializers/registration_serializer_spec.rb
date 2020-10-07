# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  shared_examples "extended_data for admin user" do
    context "when user is admin" do
      subject do
        described_class.new(registration, true)
      end

      it "serializes the extended data" do
        expect(subject.serialize).to include(:extended_data)
        expect(subject.serialize[:extended_data]).to include(age_slice: registration.user[:extended_data]["age_slice"],
                                                             group_membership: registration.user[:extended_data]["group_membership"],
                                                             question_racialized: registration.user[:extended_data]["question_racialized"],
                                                             question_gender: registration.user[:extended_data]["question_gender"],
                                                             question_sexual_orientation: registration.user[:extended_data]["question_sexual_orientation"],
                                                             question_disability: registration.user[:extended_data]["question_disability"],
                                                             question_social_context: registration.user[:extended_data]["question_social_context"])
      end

      context "when optional extended_data field is empty" do
        let(:age_slice) { "" }
        let(:question_sexual_orientation) { "" }

        it "serializes the extended data" do
          expect(subject.serialize).to include(:extended_data)
          expect(subject.serialize[:extended_data]).to include(age_slice: "",
                                                               group_membership: registration.user[:extended_data]["group_membership"],
                                                               question_racialized: registration.user[:extended_data]["question_racialized"],
                                                               question_gender: registration.user[:extended_data]["question_gender"],
                                                               question_sexual_orientation: "",
                                                               question_disability: registration.user[:extended_data]["question_disability"],
                                                               question_social_context: registration.user[:extended_data]["question_social_context"])
        end
      end

      context "when user does not have extended_data" do
        before do
          registration.user.update!(extended_data: "")
        end

        it "serializes the author and extended data" do
          expect(subject.serialize).to include(:extended_data)
          expect(subject.serialize[:extended_data]).to include(age_slice: "",
                                                               group_membership: "",
                                                               question_racialized: "",
                                                               question_gender: "",
                                                               question_sexual_orientation: "",
                                                               question_disability: "",
                                                               question_social_context: "")
        end
      end
    end
  end
  describe RegistrationSerializer do
    describe "#serialize" do
      let!(:registration) { create(:registration) }
      let!(:subject) { described_class.new(registration) }
      let(:age_slice) { "15-25" }
      let(:group_membership) { %w(local_group employee) }
      let(:question_racialized) { "answer_yes" }
      let(:question_gender) { "answer_yes" }
      let(:question_sexual_orientation) { "answer_yes" }
      let(:question_disability) { "answer_yes" }
      let(:question_social_context) { "answer_yes" }

      before do
        registration.user.update!(extended_data: {
                                    age_slice: age_slice,
                                    group_membership: group_membership,
                                    question_racialized: question_racialized,
                                    question_gender: question_gender,
                                    question_sexual_orientation: question_sexual_orientation,
                                    question_disability: question_disability,
                                    question_social_context: question_social_context
                                  })
      end

      context "when there are not a questionnaire" do
        it "includes the id" do
          expect(subject.serialize).to include(id: registration.id)
        end

        it "includes the registration code" do
          expect(subject.serialize).to include(code: registration.code)
        end

        it "includes the user" do
          expect(subject.serialize[:user]).to(
            include(name: registration.user.name)
          )
          expect(subject.serialize[:user]).to(
            include(email: registration.user.email)
          )
        end

        it "does not include the extended_data" do
          expect(subject.serialize).not_to include(:extended_data)
        end

        it_behaves_like "extended_data for admin user"
      end

      context "when questionaire enabled" do
        let(:meeting) { create :meeting, :with_registrations_enabled }
        let!(:user) { create(:user, organization: meeting.organization) }
        let!(:registration) { create(:registration, meeting: meeting, user: user) }

        let!(:questions) { create_list :questionnaire_question, 3, questionnaire: meeting.questionnaire }
        let!(:answers) do
          questions.map do |question|
            create :answer, questionnaire: meeting.questionnaire, question: question, user: user
          end
        end

        let!(:multichoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "multiple_option" }
        let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
        let!(:multichoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: multichoice_question, user: user, body: nil
        end
        let!(:multichoice_answer_choices) do
          multichoice_answer_options.map do |answer_option|
            create :answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
          end
        end

        let!(:singlechoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option" }
        let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
        let!(:singlechoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: singlechoice_question, user: user, body: nil
        end
        let!(:singlechoice_answer_choice) do
          answer_option = singlechoice_answer_options.first
          create :answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end

        let!(:subject) { described_class.new(registration) }
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          expect(serialized[:registration_form_answers]).to include(
            "1. #{translated(questions.first.body, locale: I18n.locale)}" => answers.first.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "3. #{translated(questions.last.body, locale: I18n.locale)}" => answers.last.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "4. #{translated(multichoice_question.body, locale: I18n.locale)}" => multichoice_answer_choices.map(&:body)
          )

          expect(serialized[:registration_form_answers]).to include(
            "5. #{translated(singlechoice_question.body, locale: I18n.locale)}" => [singlechoice_answer_choice.body]
          )
        end

        it "does not include the extended_data" do
          expect(subject.serialize).not_to include(:extended_data)
        end

        it_behaves_like "extended_data for admin user"
      end
    end
  end
end
