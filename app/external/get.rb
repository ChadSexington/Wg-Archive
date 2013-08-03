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

#Make necessary directories
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

#Function to download individual files per the url
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

#Function downloads an entire thread of images and create thumbnails
def get_thread(thread)
	thread_num = thread.split("/").last
	make_dir(thread_num)
	Dir.chdir("#{$wgdir}/#{thread_num}")

	#Open the thread html file, search for image locatoins
	doc = Nokogiri::HTML(open(thread))
	doc.css('div.fileInfo a').each do |link|
        	link_s = link['href'].gsub("//", "http://")
        	download(link_s)
        	img_file_name = link_s.split("/").last
        	img = ImageList.new img_file_name
        	thumb = img.scale(240,135)
        	thumb.write "#{$thumbdir}/#{thread_num}/thumb_#{img_file_name}"
	end

end

#The main loop
loop {
doc = Nokogiri::HTML(open("http://boards.4chan.org/wg/8"))

#Search for number of images in each thread.
#Will download any that has => 20 images
doc.css('span.summary').each do |thing|
	if thing.content.match(/[\ ,0-9][2-9][0-9]\ image\ replies/)
		thread_loc = thing.css('a').attr('href').value
		if !Dir.exists?("#{$wgdir}/#{thread_loc.split("/").last}")
			thread_url = "http://boards.4chan.org/wg/#{thread_loc}"
			get_thread(thread_url)
		end
	end
end

#Sleep for 1 hour
sleep(3600)
}
