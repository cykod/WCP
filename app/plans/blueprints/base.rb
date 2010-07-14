


class Blueprints::Base

  def self.blueprint_details(nm,options={})

    cls = class<<self;self;end
    cls.send(:define_method,:blueprint_name) { nm }
    cls.send(:define_method,:blueprint_options) { options }
  end


end
