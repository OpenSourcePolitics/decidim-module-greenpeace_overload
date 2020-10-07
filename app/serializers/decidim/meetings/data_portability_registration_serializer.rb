# frozen_string_literal: true

module Decidim
  module Meetings
    class DataPortabilityRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for data portability
      def serialize
        {
          id: resource.id,
          code: resource.code,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          meeting: {
            title: resource.meeting.title,
            description: resource.meeting.description,
            start_time: resource.meeting.start_time,
            end_time: resource.meeting.end_time,
            address: resource.meeting.address,
            location: resource.meeting.location,
            location_hints: resource.meeting.location_hints,
            reference: resource.meeting.reference,
            attendees_count: resource.meeting.attendees_count,
            attending_organizations: resource.meeting.attending_organizations,
            closed_at: resource.meeting.closed_at,
            closing_report: resource.meeting.closing_report
          }
        }.merge(options_merge(admin_extra_fields))
      end

      private

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
