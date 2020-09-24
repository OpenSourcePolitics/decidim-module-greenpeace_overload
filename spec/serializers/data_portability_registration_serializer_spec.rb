# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe DataPortabilityRegistrationSerializer do
    let(:resource) { create(:registration) }
    let(:subject) { described_class.new(resource) }

    let(:age_slice) { "15-25" }
    let(:group_membership) { %w(local_group employee) }
    let(:question_racialized) { "answer_yes" }
    let(:question_gender) { "answer_yes" }
    let(:question_sexual_orientation) { "answer_yes" }
    let(:question_disability) { "answer_yes" }
    let(:question_social_context) { "answer_yes" }

    describe "#serialize" do
      before do
        resource.user.update!(extended_data: {
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
        expect(subject.serialize).to include(id: resource.id)
      end

      it "includes the registration code" do
        expect(subject.serialize).to include(code: resource.code)
      end

      it "includes the user" do
        expect(subject.serialize[:user]).to(
            include(name: resource.user.name)
        )
        expect(subject.serialize[:user]).to(
            include(email: resource.user.email)
        )
      end

      it "includes the meeting" do
        expect(subject.serialize[:meeting]).to(
            include(title: resource.meeting.title)
        )

        expect(subject.serialize[:meeting]).to(
            include(description: resource.meeting.description)
        )

        expect(subject.serialize[:meeting]).to(
            include(start_time: resource.meeting.start_time)
        )

        expect(subject.serialize[:meeting]).to(
            include(end_time: resource.meeting.end_time)
        )

        expect(subject.serialize[:meeting]).to(
            include(address: resource.meeting.address)
        )

        expect(subject.serialize[:meeting]).to(
            include(location: resource.meeting.location)
        )

        expect(subject.serialize[:meeting]).to(
            include(location_hints: resource.meeting.location_hints)
        )

        expect(subject.serialize[:meeting]).to(
            include(reference: resource.meeting.reference)
        )

        expect(subject.serialize[:meeting]).to(
            include(attendees_count: resource.meeting.attendees_count)
        )

        expect(subject.serialize[:meeting]).to(
            include(attending_organizations: resource.meeting.attending_organizations)
        )

        expect(subject.serialize[:meeting]).to(
            include(closed_at: resource.meeting.closed_at)
        )

        expect(subject.serialize[:meeting]).to(
            include(closing_report: resource.meeting.closing_report)
        )
      end

      context "when user is admin" do
        subject do
          described_class.new(resource, true)
        end

        it "serializes the extended data" do
          expect(subject.serialize).to include(:extended_data)
          expect(subject.serialize[:extended_data]).to include(age_slice: resource.user[:extended_data]["age_slice"],
                                                               group_membership: resource.user[:extended_data]["group_membership"],
                                                               question_racialized: resource.user[:extended_data]["question_racialized"],
                                                               question_gender: resource.user[:extended_data]["question_gender"],
                                                               question_sexual_orientation: resource.user[:extended_data]["question_sexual_orientation"],
                                                               question_disability: resource.user[:extended_data]["question_disability"],
                                                               question_social_context: resource.user[:extended_data]["question_social_context"]
                                                       )
        end

        context "when optional extended_data field is empty" do
          let(:age_slice) { "" }
          let(:question_sexual_orientation) { "" }

          it "serializes the extended data" do
            expect(subject.serialize).to include(:extended_data)
            expect(subject.serialize[:extended_data]).to include(age_slice: "",
                                                                 group_membership: resource.user[:extended_data]["group_membership"],
                                                                 question_racialized: resource.user[:extended_data]["question_racialized"],
                                                                 question_gender: resource.user[:extended_data]["question_gender"],
                                                                 question_sexual_orientation: "",
                                                                 question_disability: resource.user[:extended_data]["question_disability"],
                                                                 question_social_context: resource.user[:extended_data]["question_social_context"]
                                                         )
          end
        end

        context "when user does not have extended_data" do
          before do
            resource.user.update!(extended_data: "")
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
