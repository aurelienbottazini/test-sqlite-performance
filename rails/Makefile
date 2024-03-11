build:
	bundle
	RAILS_ENV=production bundle exec rails db:migrate
serve:
        # https://www.speedshop.co/2017/10/12/appserver.html
	WEB_CONCURRENCY=5 RAILS_MAX_THREADS=5 rails server -e production -p 3030
