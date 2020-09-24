# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentSerializer do
      let(:comment) { create(:comment) }
      let(:subject) { described_class.new(comment) }

      let(:age_slice) { "15-25" }
      let(:group_membership) { %w(local_group employee) }
      let(:question_racialized) { "answer_yes" }
      let(:question_gender) { "answer_yes" }
      let(:question_sexual_orientation) { "answer_yes" }
      let(:question_disability) { "answer_yes" }
      let(:question_social_context) { "answer_yes" }

      describe "#serialize" do
        before do
          comment.author.update!(extended_data: {
              age_slice: age_slice,
              group_membership: group_membership,
              question_racialized: question_racialized,
              question_gender: question_gender,
              question_sexual_orientation: question_sexual_orientation,
              question_disability: question_disability,
              question_social_context: question_social_context
          })
        end

        it "includes the id" do
          expect(subject.serialize).to include(id: comment.id)
        end

        it "includes the creation date" do
          expect(subject.serialize).to include(created_at: comment.created_at)
        end

        it "includes the body" do
          expect(subject.serialize).to include(body: comment.body)
        end

        it "includes the author" do
          expect(subject.serialize[:author]).to(
              include(id: comment.author.id, name: comment.author.name)
          )
        end

        it "includes the alignment" do
          expect(subject.serialize).to include(alignment: comment.alignment)
        end

        it "includes the depth" do
          expect(subject.serialize).to include(alignment: comment.depth)
        end

        it "includes the root commentable's url" do
          expect(subject.serialize[:root_commentable_url]).to match(/http/)
        end


        it "does not include extended data" do
          expect(subject.serialize).not_to include(:extended_data)
        end

        context "when user is admin" do
          subject do
            described_class.new(comment, true)
          end

          it "serializes the extended data" do
            expect(subject.serialize).to include(:extended_data)
            expect(subject.serialize[:extended_data]).to include(age_slice: comment.author[:extended_data]["age_slice"],
                                                   group_membership: comment.author[:extended_data]["group_membership"],
                                                   question_racialized: comment.author[:extended_data]["question_racialized"],
                                                   question_gender: comment.author[:extended_data]["question_gender"],
                                                   question_sexual_orientation: comment.author[:extended_data]["question_sexual_orientation"],
                                                   question_disability: comment.author[:extended_data]["question_disability"],
                                                   question_social_context: comment.author[:extended_data]["question_social_context"]
                                           )
          end

          context "when optional extended_data field is empty" do
            let(:age_slice) { "" }
            let(:question_sexual_orientation) { "" }

            it "serializes the extended data" do
              expect(subject.serialize).to include(:extended_data)
              expect(subject.serialize[:extended_data]).to include(age_slice: "",
                                                                   group_membership: comment.author[:extended_data]["group_membership"],
                                                                   question_racialized: comment.author[:extended_data]["question_racialized"],
                                                                   question_gender: comment.author[:extended_data]["question_gender"],
                                                                   question_sexual_orientation: "",
                                                                   question_disability: comment.author[:extended_data]["question_disability"],
                                                                   question_social_context: comment.author[:extended_data]["question_social_context"]
                                                           )
            end
          end

          context "when user does not have extended_data" do
            before do
              comment.author.update!(extended_data: "")
            end

            it "serializes the author and extended data" do
              expect(subject.serialize).to include(:extended_data)
              expect(subject.serialize[:extended_data]).to include(age_slice: "",
                                                     group_membership: "",
                                                     question_racialized: "",
                                                     question_gender: "",
                                                     question_sexual_orientation: "",
                                                     question_disability: "",
                                                     question_social_context: ""
                                             )
            end
          end
        end
      end
    end
  end
end

