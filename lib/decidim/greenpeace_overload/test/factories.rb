# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/proposals/test/factories"
require "decidim/comments/test/factories"
require "decidim/accountability/test/factories"

FactoryBot.define do
  factory :greenpeace_overload_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :greenpeace_overload).i18n_name }
    manifest_name { :greenpeace_overload }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
