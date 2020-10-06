# frozen_string_literal: true

# This module is use to add customs methods to the original "proposal_vote.rb"

module DummySerializerExtend
  def initialize(id, private_scope = false)
    @id = id
    @private_scope = private_scope
  end
end

DummySerializer.class_eval do
  prepend(DummySerializerExtend)
end
