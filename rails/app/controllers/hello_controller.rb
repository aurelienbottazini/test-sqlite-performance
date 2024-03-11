class HelloController < ActionController::Metal
  def index
    self.response_body = 'Hello world from Rails!'
  end
end
