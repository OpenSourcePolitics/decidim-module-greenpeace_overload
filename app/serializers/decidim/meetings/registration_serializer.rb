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
                age_slice: extended_data_key(resource.user, "age_slice"),
                group_membership: extended_data_key(resource.user, "group_membership"),
                question_racialized: extended_data_key(resource.user, "question_racialized"),
                question_gender: extended_data_key(resource.user, "question_gender"),
                question_sexual_orientation: extended_data_key(resource.user, "question_sexual_orientation"),
                question_disability: extended_data_key(resource.user, "question_disability"),
                question_social_context: extended_data_key(resource.user, "question_social_context")
            }
        }
      end

      def extended_data_key(user, key)
        return "" if user.try(:extended_data).blank?
        return "" if user[:extended_data].fetch(key, nil).blank?

        user[:extended_data][key]
      end
    end
  end
end
