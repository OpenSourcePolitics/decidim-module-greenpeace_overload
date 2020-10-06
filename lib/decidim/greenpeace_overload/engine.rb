# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module GreenpeaceOverload
    # This is the engine that runs on the public interface of greenpeace_overload.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GreenpeaceOverload

      routes do
        # Add engine routes here
        # resources :greenpeace_overload
        # root to: "greenpeace_overload#index"
      end

      initializer "decidim_greenpeace_overload.assets" do |app|
        app.config.assets.precompile += %w(decidim_greenpeace_overload_manifest.js decidim_greenpeace_overload_manifest.css)
      end

      initializer "decidim_greenpeace_overload.overrides" do
        require "decidim/comments/comment_serializer"
        require "decidim/proposals/proposal_serializer"
        require "decidim/meetings/meeting_serializer"
        require "decidim/exporters/csv"
        require "decidim/exporters/json"
        require "decidim/exporters/exporter"
      end
    end
  end
end
