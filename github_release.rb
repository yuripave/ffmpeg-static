#!/usr/bin/env ruby

require 'optparse'
require 'octokit'
require 'pathname'
require 'mime-types'

options = {}
OptionParser.new do |opt|
  opt.on('-s', '--secret SECRET', 'GitHub access token') { |o| options[:secret] = o }
  opt.on('-r', '--repo-slug REPO_SLUG', 'Repo slug. i.e.: apple/swift') { |o| options[:repo_slug] = o }
  opt.on('-b', '--body BODY', 'Release body') { |o| options[:body] = o }
  opt.on('-t', '--tag TAG', 'Tag name') { |o| options[:tag_name] = o }
  opt.on('-g', '--glob GLOB', 'File glob') { |o| options[:file_glob] = o }
  opt.on('-f', '--file File', 'File Path') { |o| options[:file] = o }
  opt.on('-o', '--overwrite OVERWRITE', 'Overwrite') { |o| options[:overwrite] = o }
end.parse!

raise OptionParser::MissingArgument if options[:secret].nil?
raise OptionParser::MissingArgument if options[:repo_slug].nil?
raise OptionParser::MissingArgument if options[:tag_name].nil?

client = Octokit::Client.new(:access_token => options[:secret])
user = client.user
user.login

unless client.scopes.include? 'public_repo' or client.scopes.include? 'repo'
  raise Error, "Insufficient permissions. Make sure your token contains the repo or public_repo scope."
end

puts "Logged in as #{user.name}"
puts "Deploying to repo: #{options[:repo_slug]}"

tag_matched = false
release_url = nil
releases = client.releases(options[:repo_slug])
body = ""
if options[:body]
  body = options[:body]
end

releases.each do |release|
  if release.tag_name == options[:tag_name]
    release_url = release.rels[:self].href
    tag_matched = true
  end
end

# if tag has been pushed directly to git, create a github release
if tag_matched == false
  release_url = client.create_release(options[:repo_slug], options[:tag_name], { :name => options[:tag_name], :body => body })
else
  client.update_release(release_url, { :name => options[:tag_name], :body => body })
end

def files(options)
  if options[:file_glob] == true
    Array(options[:file]).map do |glob|
      Dir.glob(glob)
    end.flatten
  else
    Array(options[:file])
  end
end

def upload_file(client, file, filename, release_url)
  content_type = MIME::Types.type_for(file).first.to_s
  if content_type.empty?
    # Specify the default content type, as it is required by GitHub
    content_type = "application/octet-stream"
  end
  client.upload_asset(release_url, file, {:name => filename, :content_type => content_type})
end

if options[:file]
  puts files(options).inspect
  files(options).each do |file|
    existing_url = nil
    filename = Pathname.new(file).basename.to_s
    client.release(release_url).rels[:assets].get.data.each do |existing_file|
      if existing_file.name == filename
        existing_url = existing_file.url
      end
    end
    if !existing_url
      puts "#{filename} uploading."
      upload_file(client, file, filename, release_url)
    elsif existing_url && options[:overwrite]
      puts "#{filename} already exists, overwriting."
      client.delete_release_asset(existing_url)
      upload_file(client, file, filename, release_url)
    else
      puts "#{filename} already exists, skipping."
    end
  end
end

client.update_release(release_url, {:draft => false}.merge(options))