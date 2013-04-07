#!/usr/bin/env ruby
require 'pathname'
require 'fileutils'

TESTING = true

TVSHOWS_FOLDERS = [
  "/Volumes/Data/Videos/TV\ Shows"
].freeze

ALLOWED_CHARS = /[^0-9A-Za-z]/

files = [
  "/Volumes/Downloads/TV Shows/TV Shows - Favorites/The.Walking.Dead.S03E10.HDTV.XviD-AFG.avi",
]

logfile = File.open('/filemover-shows.log','a')

files.each do |file|
  file_clean = file.gsub(ALLOWED_CHARS, '').downcase
  moved = false
  error = "No show folder founded for #{File.basename(file)}"
  Pathname.new(TVSHOWS_FOLDERS[0]).children.select do |dir|
    if dir.directory?
      show_name = dir.basename.to_s.gsub(ALLOWED_CHARS, '').downcase
      if file_clean.match(show_name)
        season_number = file.scan(/\.S(\d{2})E\d{2}\./)[0]
        if season_number
          FileUtils.mkdir dir.to_s + "/Season #{season_number[0].to_i}", :noop => TESTING, :verbose => true unless File.directory?(dir.to_s + "/Season #{season_number[0].to_i}")
          dest = dir.to_s + "/Season #{season_number[0].to_i}/#{File.basename(file)}"
          FileUtils.cp file, dest, :noop => TESTING, :verbose => true
          logfile.puts "#{Time.new.to_s} -- Moved! #{File.basename(file)} --> #{dest}"
          moved = true
        else
          error = "No season number founded in #{File.basename(file)}"
        end
        break
      end
    end
  end
  if moved == false
    logfile.puts "#{Time.new.to_s} -- #{error}"
  end
end