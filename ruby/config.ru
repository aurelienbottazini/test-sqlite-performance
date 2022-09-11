require 'roda'

class App < Roda
  route do |r|
    r.root do
      'Hello World!'
    end

    r.is 'visit' do
      r.get do
      end
    end

    r.is 'stats' do
      r.get do
        "stats: "
      end
  end
