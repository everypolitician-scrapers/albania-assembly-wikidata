#!/bin/env ruby
# encoding: utf-8

require 'pry'
require 'wikidata/fetcher'

names_en = EveryPolitician::Wikidata.morph_wikinames(source: 'tmtmtmtm/albania-kuvendi-wikipedia', column: 'wikiname__en')
names_sq = EveryPolitician::Wikidata.morph_wikinames(source: 'tmtmtmtm/albania-kuvendi-wikipedia', column: 'wikiname__sq')

EveryPolitician::Wikidata.scrape_wikidata(names: { 
  en: names_en,
  sq: names_sq,
}, output: false)

warn EveryPolitician::Wikidata.notify_rebuilder

