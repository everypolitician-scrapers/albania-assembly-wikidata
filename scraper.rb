#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'

def members
  morph_api_key = ENV["MORPH_API_KEY"]
  en_api_url = 'https://api.morph.io/tmtmtmtm/albania-assembly-wp/data.json'
  al_api_url = 'https://api.morph.io/tmtmtmtm/albania-kuvendi-wikipedia/data.json'

  en = JSON.parse(RestClient.get(en_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(wikiname) AS wikiname from data"
  }), symbolize_names: true).map { |n| n[:wikiname] }

  al = JSON.parse(RestClient.get(al_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(wikiname) AS wikiname from data"
  }), symbolize_names: true).map { |n| n[:wikiname] }

  return (en+al).uniq
end

WikiData.ids_from_pages('en', members).each_with_index do |p, i|
  data = WikiData::Fetcher.new(id: p.last).data rescue nil
  unless data
    warn "No data for #{p}"
    next
  end
  data[:orig] = p.first
  ScraperWiki.save_sqlite([:id], data)
end

require 'rest-client'
warn RestClient.post ENV['MORPH_REBUILDER_URL'], {} if ENV['MORPH_REBUILDER_URL']
