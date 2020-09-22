# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/greenpeace_overload/version"

Gem::Specification.new do |s|
  s.version = Decidim::GreenpeaceOverload.version
  s.authors = ["quentinchampenois"]
  s.email = ["26109239+Quentinchampenois@users.noreply.github.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-greenpeace_overload"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-greenpeace_overload"
  s.summary = "A decidim greenpeace_overload module"
  s.description = "Overload for greenpeace instance v0.22-stable."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::GreenpeaceOverload.version
end
