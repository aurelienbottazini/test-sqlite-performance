class VisitController < ApplicationController
  def index
    Visit.create(referrer: "foo", user_agent: "bar")

    render status: 204, plain: nil
  end
end
