# frozen_string_literal: true

module Decidim
  module GreenpeaceOverload
    # This is the engine that runs on the public interface of `GreenpeaceOverload`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::GreenpeaceOverload::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :greenpeace_overload do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "greenpeace_overload#index"
      end

      def load_seed
        nil
      end
    end
  end
end
