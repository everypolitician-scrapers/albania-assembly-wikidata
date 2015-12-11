#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'


def en_members
  morph_api_key = ENV["MORPH_API_KEY"]
  en_api_url = 'https://api.morph.io/tmtmtmtm/albania-assembly-wp/data.json'
  en = JSON.parse(RestClient.get(en_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(wikiname) AS wikiname from data"
  }), symbolize_names: true).map { |n| n[:wikiname] }
  return WikiData.ids_from_pages('en', en)
end

def al_members
  morph_api_key = ENV["MORPH_API_KEY"]
  al_api_url = 'https://api.morph.io/tmtmtmtm/albania-kuvendi-wikipedia/data.json'
  al = JSON.parse(RestClient.get(al_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(wikiname) AS wikiname from data"
  }), symbolize_names: true).map { |n| n[:wikiname] }
  return WikiData.ids_from_pages('sq', al)
end

(en_members.values + al_members.values).uniq.each do |wid|
  data = WikiData::Fetcher.new(id: wid).data('en', 'sq') rescue nil
  unless data
    warn "No data for #{wid}"
    next
  end
  # TODO check if there's been a redirect
  ScraperWiki.save_sqlite([:id], data)
end

require 'rest-client'
warn RestClient.post ENV['MORPH_REBUILDER_URL'], {} if ENV['MORPH_REBUILDER_URL']
