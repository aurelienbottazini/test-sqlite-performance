class StatsController < ActionController::Metal
  def index
    self.response_body = Visit.maximum(:id)
  end
end
