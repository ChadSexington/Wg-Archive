# This small application should scour a directory at a certain interval
# and create thumbnails for the images within. The thumbnails should be organized
# but in a seperate directory tree

require 'RMagick'
include Magick

image_dir = Dir.new "/home/tiwillia/Pictures/4chan/wg/"
thumb_dir = Dir.new "/home/tiwillia/Thumbnails/4chan/wg/"

image_dir.each { |cat|
if ! cat.match(/^\.+$/)
	cat_dir = Dir.new "#{image_dir.path}#{cat}"
	cat_dir.each { |image|
	if ! image.match(/^\.+$/)
		img = ImageList.new "#{image_dir.path}#{cat}/#{image}"
		thumb = img.scale(180, 120)
		if ! Dir.exists? "#{thumb_dir.path}#{cat}"
			Dir.mkdir "#{thumb_dir.path}#{cat}"
		end
		Dir.chdir "#{thumb_dir.path}#{cat}"
		thumb.write "thumb_#{image}"
	end
	}
end
}
