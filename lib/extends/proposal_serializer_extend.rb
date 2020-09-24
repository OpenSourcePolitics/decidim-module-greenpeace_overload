# frozen_string_literal: true
require "active_support/concern"


module ProposalSerializerExtend
      extend ActiveSupport::Concern

      included do
        # Public: Initializes the serializer with a proposal.
        def initialize(proposal, private_scope = false)
          @proposal = proposal
          @private_scope = private_scope
        end

        # Public: Exports a hash with the serialized data for this proposal.
        def serialize
          {
              id: proposal.id,
              category: {
                  id: proposal.category.try(:id),
                  name: proposal.category.try(:name) || empty_translatable
              },
              scope: {
                  id: proposal.scope.try(:id),
                  name: proposal.scope.try(:name) || empty_translatable
              },
              participatory_space: {
                  id: proposal.participatory_space.id,
                  url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
              },
              component: { id: component.id },
              title: present(proposal).title,
              body: present(proposal).body,
              state: proposal.state.to_s,
              reference: proposal.reference,
              answer: ensure_translatable(proposal.answer),
              supports: proposal.proposal_votes_count,
              endorsements: {
                  total_count: proposal.endorsements.count,
                  user_endorsements: user_endorsements
              },
              comments: proposal.comments.count,
              attachments: proposal.attachments.count,
              followers: proposal.followers.count,
              published_at: proposal.published_at,
              url: url,
              meeting_urls: meetings,
              related_proposals: related_proposals,
              is_amend: proposal.emendation?,
              original_proposal: {
                  title: proposal&.amendable&.title,
                  url: original_proposal_url
              }
          }.merge(options_merge(admin_extra_fields))
        end

        private

        # Private: Returns a Hash with additional fields that administrator want to see in export
        #
        # Returns a Hash
        def admin_extra_fields
          {
              author: {
                  id: proposal.creator_author[:id] || "",
                  age_slice: extended_data_key(proposal.creator_author, "age_slice"),
                  group_membership: extended_data_key(proposal.creator_author, "group_membership"),
                  question_racialized: extended_data_key(proposal.creator_author, "question_racialized"),
                  question_gender: extended_data_key(proposal.creator_author, "question_gender"),
                  question_sexual_orientation: extended_data_key(proposal.creator_author, "question_sexual_orientation"),
                  question_disability: extended_data_key(proposal.creator_author, "question_disability"),
                  question_social_context: extended_data_key(proposal.creator_author, "question_social_context")
              }
          }
        end
      end

      def extended_data_key(user, key)
        return "" if user.try(:extended_data).blank?
        return "" if user[:extended_data].fetch(key, nil).blank?

        user[:extended_data][key]
      end
end

Decidim::Proposals::ProposalSerializer.send(:include, ProposalSerializerExtend)
