#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'

engines = Hash.new
engines['jruby'] = Proc.new {
  url = 'http://jruby.org'

  doc = Nokogiri::HTML(open(url))

  jruby_string = (doc / "div[id='latest_release']/h3/a[2]/strong").first.content

  if (jruby_string =~ /\d[.]\d[.]\d/)
    $&
  else
    'latest jruby version unknown'
  end
}

engines['ruby'] = Proc.new {
  url = 'http://www.ruby-lang.org/en/downloads'

  doc = Nokogiri::HTML(open(url))

  ruby_string = (doc / "div[id='content']/ul/li[1]/a").first['href']

  if (ruby_string =~ /\d[.]\d[.]\d[-]p\d+/)
    $&
  else
    'latest ruby version unknown'
  end
}

engines['perl'] = Proc.new {
  url = 'http://www.perl.org'

  doc = Nokogiri::HTML(open(url))

  perl_string = (doc / "a[href='/get.html']").last.content

  if (perl_string =~ /^\d+[.]\d+[.]\d+/)
    $&
  else
    'latest perl version unknown'
  end
}

engines.each_pair do |k, v|
  puts "#{k}:#{v.call}"
end
