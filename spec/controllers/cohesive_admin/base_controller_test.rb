require 'spec_helper'

module CohesiveAdmin
  class BaseControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    # test "the truth" do
    #   assert true
    # end
  end
end
