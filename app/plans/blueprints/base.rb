


class Blueprints::Base

  def initialize(blueprint)
    @blueprint = blueprint
  end

  def self.blueprint_details(nm,options={})

    cls = class<<self;self;end
    cls.send(:define_method,:blueprint_name) { nm }
    cls.send(:define_method,:blueprint_details_options) { options }
  end

  def self.blueprint_options_class; Options; end
  def self.blueprint_options_partial; "/common/empty"; end
  def self.blueprint_options(cls,partial=nil)
    cls = class<<self;self;end
    cls.send(:define_method,:blueprint_options_class) { cls }
    cls.send(:define_method,:blueprint_options_partial) { partial } if partial
  end

  def self.deployment_options_class; Options; end
  def self.deployment_options_partial; "/common/empty"; end
  def self.deployment_options(cls,partial=ni)
    cls = class<<self;self;end
    cls.send(:define_method,:deployment_options_class) { cls } 
    cls.send(:define_method,:deployment_options_partial) { partial } if partial
  end

  def blueprint_options(val = nil)
    return @blueprint_options if @blueprint_options && !val
    @blueprint_options = self.class.blueprint_options_class.new(val || @blueprint.blueprint_options_data)
  end

  def deployment_options(opts)
    self.class.deployment_options_class.new(opts)
  end

  class Options < HashModel

  end

end
