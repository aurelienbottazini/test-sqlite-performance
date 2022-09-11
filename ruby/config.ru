require 'roda'

class App < Roda
  route do |r|
    r.is 'hello' do
      r.get do
        'Hello World!'
      end
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
  end
end

run App.freeze.app
