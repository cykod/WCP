

namespace :wcp do
  desc "Run initial configure scripts in app/plans/configure to setup roles etc"
  task :configure => :environment do |t|
    require  Rails.root.join('app/plans/configure/base.rb')
    dir = Rails.root.join("app","plans","configure")
    Dir.glob(dir.join("*.rb")).each do |filepath|
      fl = filepath.gsub(dir.to_s + "/","").gsub(/\.rb$/,'')
      if fl != "base"
        require dir.join("#{fl}.rb")
        cls_name = "Configure::#{fl.camelcase}"
        cls = cls_name.constantize
        inst = cls.new
        inst.configure
      end
    end
  end
end
