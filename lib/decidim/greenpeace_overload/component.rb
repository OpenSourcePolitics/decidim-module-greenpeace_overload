# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:greenpeace_overload) do |component|
  component.engine = Decidim::GreenpeaceOverload::Engine
  component.admin_engine = Decidim::GreenpeaceOverload::AdminEngine
  component.icon = "decidim/greenpeace_overload/icon.svg"

  # component.on(:before_destroy) do |instance|
  #   # Code executed before removing the component
  # end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  # component.settings(:global) do |settings|
  #   # Add your global settings
  #   # Available types: :integer, :boolean
  #   # settings.attribute :vote_limit, type: :integer, default: 0
  # end

  # component.settings(:step) do |settings|
  #   # Add your settings per step
  # end

  # component.register_resource(:some_resource) do |resource|
  #   # Register a optional resource that can be references from other resources.
  #   resource.model_class_name = "Decidim::GreenpeaceOverload::SomeResource"
  #   resource.template = "decidim/greenpeace_overload/some_resources/linked_some_resources"
  # end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
