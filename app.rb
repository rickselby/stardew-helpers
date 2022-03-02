# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

configure do
  set :erb, escape_html: true
  set :show_exceptions, :after_handler if development?
  disable :dump_errors unless development?
end

before do
  cache_control :no_cache
end
