#!/usr/bin/env ruby

# The goal of this script is to automatically scour the last page of 4chan.org/wg
# And download all of the images from threads with more than ~20 images. It should organize these
# into folders and include the title and text from the very first post. It should also exclude
# image modification threads. AFter it downloads and organizes the images, it should then create
# thumbnails (16:9) so that they can be easily displayed as a list in a rails application.

require 'nokogiri'
require 'open-uri'
require 'RMagick'
include Magick

$wgdir="/tmp/wg"
$thumbdir="/tmp/thumbs"
def make_dir(threadnum)
        if ! Dir.exists?($wgdir)
                Dir.mkdir($wgdir)
        end
        if ! Dir.exists?("#{$wgdir}/#{threadnum}")
                Dir.mkdir("#{$wgdir}/#{threadnum}")
        end
	if ! Dir.exists?($thumbdir)
                Dir.mkdir($thumbdir)
        end
        if ! Dir.exists?("#{$thumbdir}/#{threadnum}")
                Dir.mkdir("#{$thumbdir}/#{threadnum}")
        end
end

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

thread = ARGV.first
thread_num = thread.split("/").last
make_dir(thread_num)
Dir.chdir("#{$wgdir}/#{thread_num}")

doc = Nokogiri::HTML(open(thread))
doc.css('div.fileInfo a').each do |link|
	link_s = link['href'].gsub("//", "http://")
	download(link_s)
	img_file_name = link_s.split("/").last
	img = ImageList.new img_file_name
	thumb = img.scale(160,90)
	thumb.write "#{$thumbdir}/#{thread_num}/thumb_#{img_file_name}"
end
