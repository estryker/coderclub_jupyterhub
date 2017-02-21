#!/bin/env ruby

require 'opt_simple'
require 'github_api'

defaults = {
  github_user: "estryker",
  github_repo: "coderclub",
  github_path: "lessons",
  github_pattern: "\.ipynb$"
}

opts = OptSimple.new(defaults).parse_opts do
  option %w[-l --lesson-num], "Lesson number to update" do | arg |
    num = arg.to_i
    if num > 0
      set_opt num
    else
      error "Lesson number must be greater than 0"
    end
  end
  option "--github-path", "Github path (within the repo) to pull notebook files from"
  option "--github-repo", "Github repo (within the users account) to pull notebook files from"
  option "--github-user", "Github user to pull notebook files from"
  
end

#TODO: filter for the requested lesson number. 
github.repos.contents.get(user: opts.github_user, repo: opts.github_repo, path: opts.github_path).grep(Regexp.compile(opts.github_path)).each do | file |
  new_file_exists = true
  if File.readable? file["path"]
    sha1 = `sha1 #{file['path']}`
    if file["sha"] == sha1
      puts "#{file['path']} is already up-to-date"
      new_file_exists = false
    else
      backup_name = file['path'] + "_#{Time.now.strftime('%Y%m%d%H%M')}"
      puts "Saving off current file to #{backup_name}"
      FileUtils.cp(file['path'],backup_name)
    end
  end
  if new_file_exists
    puts "Getting: #{file['path']}"
    `wget file['download_url']`
  end
end
