# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Serializes a comment
      def serialize
        {
            id: resource.id,
            created_at: resource.created_at,
            body: resource.body,
            author: {
                id: resource.author.id,
                name: resource.author.name
            },
            alignment: resource.alignment,
            depth: resource.depth,
            user_group: {
                id: resource.user_group.try(:id),
                name: resource.user_group.try(:name) || empty_translatable
            },
            commentable_id: resource.decidim_commentable_id,
            commentable_type: resource.decidim_commentable_type,
            root_commentable_url: root_commentable_url
        }.merge(options_merge(admin_extra_fields))
      end

      private

      def root_commentable_url
        @root_commentable_url ||= Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
      end

      # Private: Returns a Hash with additional fields that administrator want to see in export
      #
      # Returns a Hash
      def admin_extra_fields
        {
            extended_data: {
                age_slice: resource.author[:extended_data]["age_slice"] || "",
                group_membership: resource.author[:extended_data]["group_membership"] || "",
                question_racialized: resource.author[:extended_data]["question_racialized"] || "",
                question_gender: resource.author[:extended_data]["question_gender"] || "",
                question_sexual_orientation: resource.author[:extended_data]["question_sexual_orientation"] || "",
                question_disability: resource.author[:extended_data]["question_disability"] || "",
                question_social_context: resource.author[:extended_data]["question_social_context"] || ""
            }
        }
      end
    end
  end
end
