class HelloController < ApplicationController
  def index
    render plain: 'Hello world from Rails!'
  end
end
