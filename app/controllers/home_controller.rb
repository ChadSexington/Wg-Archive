class HomeController < ApplicationController

def index
	@image_dirs = Array.new
	Dir.foreach("/tmp/wg") do |dir|
		if !dir.match(/\.+/)
		@image_dirs << dir
		end
	end
end

end
