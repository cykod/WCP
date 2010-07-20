


class Machines::Base
  attr_reader :machine, :blueprint

  def initialize(machine)
   @blueprint = machine.machine_blueprint
   @machine = machine
  end
 

  def company; machine.company; end
  def cloud; machine.cloud; end


  def self.machine_launcher_name; "Default"; end
  def self.machine_launcher_options; {}; end
  def self.machine_info(name,options = {})
    cls = class<<self;self;end

    cls.send(:define_method,:machine_launcher_name) do
      name
    end

    cls.send(:define_method,:machine_launcher_options) do
      options
    end

  end

  def self.machine_parameters
    []
  end

  def self.parameter(name,opts = {})
    sing = class << self; self; end

    current_parameters = self.machine_parameters
    current_parameters << [ name.to_sym, opts ] 

    sing.send(:define_method,:machine_parameters) do 
      current_parameters
    end
  end
end
