class StatsController < ActionController::Metal
  def index
    self.response_body = "#{Visit.maximum(:id)}"
    self.status = 200
  end
end
