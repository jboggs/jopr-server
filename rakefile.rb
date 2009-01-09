require 'net/http'
require 'rake/clean'
require 'rake/packagetask'

# Globals 
JPOR_SOURCE = "http://downloads.sourceforge.net/rhq/jopr-server-2.1.0.GA.zip"
APPLIANCELIB = "sources/lib"
DIR = File::expand_path(".")
SOURCEDIR = File.join(DIR,"sources")
RPMDIR = File.join(DIR,"rpms")
SRPMDIR = File.join(DIR,"srpms")
TMPDIR = File.join(DIR,"tmp")
JPOR_ZIP = File.join(SOURCEDIR, "jopr-server-2.1.0.GA.zip")
PKG_VERSION="0.0.3"
PACKAGE_DIR = SOURCEDIR
	
# clean up.
CLEAN.include "**/*~", "buildlogs", "rpms", "srpms", "tmp"
CLOBBER.include "sources"

# Basic setup
directory "sources" 
directory "buildlogs"
directory "srpms" 
directory "rpms"
directory "tmp"


task :init => ["buildlogs", "rpms", "srpms", "tmp", "sources"] 

# Copying the sources over.
file JPOR_ZIP => ["sources"] do |t|
	url = URI.parse(JPOR_SOURCE)
	res = Net::HTTP.get_response(url) 
    if(res.kind_of?(Net::HTTPRedirection))  
      new_url = res['Location']  
      res = Net::HTTP.get_response(URI.parse(new_url))  
    end    	
	File.open(JPOR_ZIP, "wb") do |file|
		file.write(res.body) 
	end
	Dir::chdir(SOURCEDIR) do |dir|
        `unzip *.zip`
    end
end

# RPM Building
def build_rpm(dir, sourcedir, specfile)
	specFileName = File::basename(specfile)
	puts ("Building rpms with spec file #{specFileName}")
	system("rpmbuild --define '_topdir #{dir}' --define '_sourcedir #{sourcedir}' --define '_srcrpmdir #{SRPMDIR}' --define '_rpmdir #{RPMDIR}' --define '_builddir #{TMPDIR}' -ba #{specfile} >  #{File.join(DIR, "buildlogs", specFileName)}.buildlog 2>&1")
		if $? != 0
			raise "rpmbuild failed"
		end
end

desc "Build the sugar source rpm"
task :jopr_rpm => [JPOR_ZIP, "init"] do |t|
	build_rpm(DIR, SOURCEDIR, "specs/jopr-server.spec")
end

Rake::PackageTask.new("jboxx", PKG_VERSION) do |pkg|
    file_list = ["appliances/**/*"]
    pkg.package_dir = PACKAGE_DIR
    pkg.need_tar_gz = true
    pkg.package_files.include(file_list)
end 


#desc "Build the appliance rpm"
#task :appliance_rpm => ["init", "package"] do |t|
#	build_rpm(DIR, SOURCEDIR, "specs/jboxx.spec")
#end

desc "Build all rpms"
task :rpm => ["jopr_rpm"]  do |t|
    Dir::chdir("rpms/noarch") do |dir|
        `/usr/bin/createrepo .`
    end
end
