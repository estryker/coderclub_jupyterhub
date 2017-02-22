#!/usr/bin/env ruby

require 'opt_simple'
require 'github_api'
require 'openssl'

defaults = {
  github_user: "estryker",
  github_repo: "coderclub",
  github_path: "lessons"
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

github = Github.new

file_pattern = "\.ipynb$"
if opts.include? "lesson-num"
  file_pattern = "lesson#{sprintf('%02d',opts.lesson_num)}.*" + file_pattern
end
puts "file pattern: " + file_pattern
regexp = Regexp.compile(file_pattern)

github.repos.contents.get(user: opts.github_user, repo: opts.github_repo, path: opts.github_path).find_all {|f| f['path'].match(regexp)}.each do | file |
  new_file_exists = true
  github_file = File.basename(file["path"])
  if File.readable? github_file
    digest = `git hash-object #{github_file}`.strip # this is a sha1 aftre prefixing 'blob length_of_file\0'
    puts digest
    if file["sha"] == digest
      puts "#{file['path']} is already up-to-date"
      new_file_exists = false
    else
      backup_name = github_file + "_#{Time.now.strftime('%Y%m%d%H%M')}"
      puts "Saving off current file to #{backup_name}"
      FileUtils.mv(github_file,backup_name)
    end
  end
  if new_file_exists
    puts "Getting: #{file['path']}"
    `wget #{file['download_url']}`
  end
end
