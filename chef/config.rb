$LOAD_PATH << File.expand_path("../lib", __dir__)

require "zz"

cookbook_path   ZZ::Path.chef_cookbooks
json_attribs    ZZ::Path.chef_run_list
file_cache_path ZZ::Path.chef_cache
