#!/usr/bin/env ruby
require 'pp'

@acc = {}
[ 'clojure', 'clojurescript', 'go', 'js-bun', 'js-deno', 'js', 'rails', 'ruby', 'rust' ].map do |v|
  hello = File.read("./stats/#{v}_hello.txt").lines[5].strip.split(' ')[0]
  stats = File.read("./stats/#{v}_stats.txt").lines[5].strip.split(' ')[0]
  visit = File.read("./stats/#{v}_visit.txt").lines[5].strip.split(' ')[0]
  @acc[v] = { hello: hello.to_i, visit: visit.to_i, stats: stats.to_i }
end

def result(key:, description:)
  puts "==============================================="
  puts "sorted by #{key} (#{description})"
  result = @acc.to_a.sort_by { |a| a[1][key] }
  max = result.max_by { |a| a[1][key] }[1][key]

  result = result.map { |a| { "#{a[0]}": a[1][key], diff_from_top: ((a[1][key] * 100 / max) - 100).to_s + "%" } }

  pp max
  pp result
end

result(key: :hello, description: 'http call that renders a string')
result(key: :stats, description: 'sqlite count')
result(key: :visit, description: 'sqlite insert')
# >> ===============================================
# >> sorted by hello (http call that renders a string)
# >> 6312513
# >> [{:rails=>236217, :diff_from_top=>"-97%"},
# >>  {:ruby=>1853785, :diff_from_top=>"-71%"},
# >>  {:clojurescript=>2509221, :diff_from_top=>"-61%"},
# >>  {:js=>2566365, :diff_from_top=>"-60%"},
# >>  {:"js-deno"=>2779668, :diff_from_top=>"-56%"},
# >>  {:clojure=>3091502, :diff_from_top=>"-52%"},
# >>  {:rust=>5640779, :diff_from_top=>"-11%"},
# >>  {:"js-bun"=>5716754, :diff_from_top=>"-10%"},
# >>  {:go=>6312513, :diff_from_top=>"0%"}]
# >> ===============================================
# >> sorted by stats (sqlite count)
# >> 1608070
# >> [{:"js-deno"=>1940, :diff_from_top=>"-100%"},
# >>  {:rails=>77001, :diff_from_top=>"-96%"},
# >>  {:clojure=>80124, :diff_from_top=>"-96%"},
# >>  {:rust=>653962, :diff_from_top=>"-60%"},
# >>  {:ruby=>676998, :diff_from_top=>"-58%"},
# >>  {:go=>1279516, :diff_from_top=>"-21%"},
# >>  {:clojurescript=>1386747, :diff_from_top=>"-14%"},
# >>  {:js=>1403103, :diff_from_top=>"-13%"},
# >>  {:"js-bun"=>1608070, :diff_from_top=>"0%"}]
# >> ===============================================
# >> sorted by visit (sqlite insert)
# >> 1608070
# >> [{:"js-deno"=>1940, :diff_from_top=>"-100%"},
# >>  {:rails=>77001, :diff_from_top=>"-96%"},
# >>  {:clojure=>80124, :diff_from_top=>"-96%"},
# >>  {:rust=>653962, :diff_from_top=>"-60%"},
# >>  {:ruby=>676998, :diff_from_top=>"-58%"},
# >>  {:go=>1279516, :diff_from_top=>"-21%"},
# >>  {:clojurescript=>1386747, :diff_from_top=>"-14%"},
# >>  {:js=>1403103, :diff_from_top=>"-13%"},
# >>  {:"js-bun"=>1608070, :diff_from_top=>"0%"}]
