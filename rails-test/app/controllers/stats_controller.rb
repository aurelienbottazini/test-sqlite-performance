class StatsController < ApplicationController
  def index
    render plain: Visit.maximum(:id)
  end
end
