# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      # Serializes a registration
      def serialize
        {
            id: resource.id,
            code: resource.code,
            user: {
                name: resource.user.name,
                email: resource.user.email,
                user_group: resource.user_group&.name || ""
            },
            registration_form_answers: serialize_answers
        }.merge(options_merge(admin_extra_fields))
      end

      private

      def serialize_answers
        questions = resource.meeting.questionnaire.questions
        answers = resource.meeting.questionnaire.answers.where(user: resource.user)
        questions.each_with_index.inject({}) do |serialized, (question, idx)|
          answer = answers.find_by(question: question)
          serialized.update("#{idx + 1}. #{translated_attribute(question.body)}" => normalize_body(answer))
        end
      end

      def normalize_body(answer)
        return "" unless answer

        answer.body || answer.choices.pluck(:body)
      end

      # Private: Returns a Hash with additional fields that administrator want to see in export
      #
      # Returns a Hash
      def admin_extra_fields
        {
            extended_data: {
                age_slice: resource.user[:extended_data]["age_slice"] || "",
                group_membership: resource.user[:extended_data]["group_membership"] || "",
                question_racialized: resource.user[:extended_data]["question_racialized"] || "",
                question_gender: resource.user[:extended_data]["question_gender"] || "",
                question_sexual_orientation: resource.user[:extended_data]["question_sexual_orientation"] || "",
                question_disability: resource.user[:extended_data]["question_disability"] || "",
                question_social_context: resource.user[:extended_data]["question_social_context"] || ""
            }
        }
      end
    end
  end
end
