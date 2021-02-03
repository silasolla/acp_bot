#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'twitter'
require 'oauth'
require 'json'
require 'pp'
require 'cgi'
require 'timeout'
require 'dotenv'

Dotenv.load

consumer_key        = ENV['TWITTER_CONSUMER_KEY']
consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
access_token        = ENV['TWITTER_ACCESS_TOKEN']
access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']

$self_screen_name = ENV['SELF_SCREEN_NAME']
$path_to_minisat  = ENV['PATH_TO_MINISAT']
$path_to_yices    = ENV['PATH_TO_YICES']
$path_to_acp_heap = ENV['PATH_TO_ACP_HEAP']

consumer = OAuth::Consumer::new(
  consumer_key,
  consumer_secret,
  site: 'https://api.twitter.com/'
)

$endpoint = OAuth::AccessToken::new(
  consumer,
  access_token,
  access_token_secret
)

# GET
def get_Tweet
  response = $endpoint.get('https://api.twitter.com/1.1/statuses/mentions_timeline.json?tweet_mode=extended')
  return result = JSON.parse(response.body)
end

# POST
def post_Tweet(tweet)
  response = $endpoint.post(
    'https://api.twitter.com/1.1/statuses/update.json',
    status: tweet
  )
  return result = JSON.parse(response.body)
end

$old_id = ''

loop do
  new_get = get_Tweet
  new_id = new_get[0]['id_str']
    
  if $old_id != new_id then
    $old_id = new_id

    File.open("tweet.trs", "w") do |f| 
      f.puts ((CGI.unescapeHTML(new_get[0]['full_text'])).gsub!(/@#{$self_screen_name}/, ''))
    end
    url = 'https://twitter.com/' + new_get[0]['user']['screen_name'] + '/status/' + new_get[0]['id_str']
    
    begin
      Timeout.timeout(20) do
        $judge_unc = `sml @SMLload=#{$path_to_acp_heap} tweet.trs -p unc --minisat-path=#{$path_to_minisat} --yices-path=#{$path_to_yices} --tmp-dir=tmp | head -1 | tail -1`
      end
    rescue Timeout::Error
      $judge_unc = "TIME OUT\n"
    end

    if $judge_unc == "Error: read file error" then
      post_Tweet("Error!!")
    else    
      begin
        Timeout.timeout(20) do
          $judge_cr = `sml @SMLload=#{$path_to_acp_heap} tweet.trs -p cr --minisat-path=#{$path_to_minisat} --yices-path=#{path_to_yices} --tmp-dir=tmp | head -1 | tail -1`
        end
      rescue Timeout::Error
        $judge_cr = "TIME OUT\n"
      end
      
      if $judge_cr=='' then
        $judge_cr="??\n"
      end
      
      post_Tweet($judge_unc + "(Unique Normal forms w.r.t. Conversion)\n---\n" + $judge_cr + "(Church-Rosser)\n" + url)
    end
  end
  
  sleep(36)
end
