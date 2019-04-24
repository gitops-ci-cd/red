#!/usr/bin/env ruby
# frozen_string_literal: true

require 'slop'
# require 'byebug'
require '/creation.rb'
Dir["/templates/*.rb"].each { |file| require file }

$opts = Slop.parse do |o|
  o.banner = 'usage: feature_overlay [options]'
  o.separator 'example: feature_overlay --service my-service --cluster-repo my-company/my-cluster --target-image my-company/my-service'
  o.separator ''
  o.separator 'options:'
  o.string '-s', '--service', 
    'the service to deploy to your cluster', default: ENV['SERVICE']
  o.string '-r', '--cluster-repo', 
    'GitHub repository that controls your cluster', default: ENV['CLUSTER_REPO']
  o.string '-t', '--token', 
    'GitHub access token with repos access, _NOT_ GITHUB_TOKEN', default: ENV['TOKEN']
  o.string '-i', '--target-image', 
    'remotely hosted target image', default: ENV['TARGET_IMAGE']
  o.string '-n', '--namespace', 
    'desired namespace, or inferred from GITHUB_REF', default: ENV['GITHUB_REF']&.split('/')&.reject{ |i| %w(refs heads).include? i }&.join('-') # TODO: include special chars
  o.string '-T', '--tag', 
    'image tag, or inferred from GITHUB_SHA', default: ENV['GITHUB_SHA']&.[](0..6)
  o.string '-f', '--env-file', 
    'location of environment file', default: File.join(Dir.home.to_s, '.profile')
end

def exit_code(message, number)
  puts
  puts message
  puts
  puts $opts
  puts
  exit number
end

missing = $opts.to_hash.select { |k, v| v.nil? }
exit_code("Missing required arguments: #{missing.values.join(', ')}", 2) if missing.any?

Creation.perform
