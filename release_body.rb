#!/usr/bin/env ruby

require 'optparse'
require 'octokit'

options = {}
OptionParser.new do |opt|
  opt.on('-s', '--secret SECRET', 'GitHub access token') { |o| options[:secret] = o }
  opt.on('-b', '--body BODY', 'Release body') { |o| options[:body] = o }
  opt.on('-t', '--tag TAG', 'Tag name') { |o| options[:tag_name] = o }
end.parse!

client = Octokit::Client.new(:access_token => options[:secret])
user = client.user
user.login

unless client.scopes.include? 'public_repo' or client.scopes.include? 'repo'
  raise Error, "Insufficient permissions. Make sure your token contains the repo or public_repo scope."
end

releases = client.releases(context.env['TRAVIS_REPO_SLUG'])

releases.each do |release|
  if release.tag_name == options[:tag_name]
    client.update_release(release.rels[:self].href, { :name => options[:tag_name], :body => options[:body] })
  end
end