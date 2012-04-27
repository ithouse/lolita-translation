require 'rubygems'
require 'bundler/setup'
require 'cover_me'

CoverMe.config do |c|
    # where is your project's root:
    c.project.root = File.expand_path("../lolita-translation") # => "Rails.root" (default)
    
    # what files are you interested in coverage for:
    c.file_pattern =  [
      /(#{CoverMe.config.project.root}\/app\/.+\.rb)/i,
      /(#{CoverMe.config.project.root}\/lib\/.+\.rb)/i
    ] 
end
