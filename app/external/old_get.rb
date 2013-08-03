#!/usr/bin/env ruby


$tmpdir = "/tmp"
$wgdir = "/tmp/test"

require 'net/https'
require 'uri'
require 'rexml/document'

include REXML

class Get

def initialize()
end

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def orange(text); colorize(text, 33); end

=begin
def make_dir(casenum)
	if ! Dir.exists?($tmpdir)
        	Dir.mkdir($tmpdir)
	end
	if ! Dir.exists?($casedir)
		Dir.mkdir($casedir)
	end
	if Dir.exists?("#{$casedir}/#{casenum}")
		return "exists"
	else
		Dir.mkdir("#{$casedir}/#{casenum}")
		return "new"
	end

end
=end
def download(url)
	filedl = url.split("/").last
	uri = URI.parse(url)
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Get.new(uri.request_uri)
	response = http.request(request)
	open(filedl, "w") do |file|
		file.write(response.body)
	end
	return filedl	
end

# This will get the attachment xml file, parse it
# And place the filename and uri of each file into a hash table
def create_list(file)
        list = Hash.new
        location_a = Array.new
        filenames_a = Array.new
        xml_file = File.new (file)
        xml = Document.new xml_file
        num_of_attachments = xml.root.elements.count
        # Need to change these. See 4get.
	xml.root.elements.each("a") { |e| p e.text }
#	xml.root.elements.each("attachment/fileName") { |e| filenames_a.push(e.text) }
#       xml.root.elements.each("attachment/uri") { |e| list[filenames_a.pop] = e.text  }
        return list
end
end

#================================================================================

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def orange(text); colorize(text, 33); end

# Create object
get = Get.new
# Create Directories
if get.make_dir(@case).eql?("exists")
	puts orange "Directory exists~"
else
	puts green "Created directory: #{$casedir}/#{@case}"
end

Dir.chdir($tmpdir)

# Download xml file list
xml_list = get.download(ARGV.first)
#file_list = get.create_list(xml_list)
=begin
# Download teh files!
Dir.chdir("#{$casedir}/#{@case}")
num_of_files = file_list.length
puts "Number of files to download: #{num_of_files}" 
file_list.each_pair {|filename, uri| 
	Thread.new(filename, uri, get) do |filename, uri, get| 
		file = get.download(uri)
		File.rename(file, filename)
		puts green "#{filename} sucessfully downloaded!"
	end
}
file_count=((Dir.entries("#{$casedir}/#{@case}").length) - 2)
## REMOVE THIS BLOCK ##
if file_count != 0
	puts red "Deleting files in case"
	`rm -rf #{$casedir}/#{@case}/*`	
	sleep 5
end
## REMOVE THIS BLOCK ##

#Stay Alive until all files finish downloading
while ! num_of_files.eql?(file_count)
 sleep 1
 file_count=((Dir.entries("#{$casedir}/#{@case}").length) - 2)
end

#COMPLETE!!
puts "Number of files in the folder: #{file_count}"
puts green "Download Complete"

#end
=end
