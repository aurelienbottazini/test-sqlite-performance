class VisitController < ActionController::Metal
  def index
    Visit.create(referrer: "foo", user_agent: "bar")

    self.response_body = nil
    self.status = 204
  end
end
