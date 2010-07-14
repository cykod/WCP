


class Machines::Base
  attr_reader :machine, :blueprint

  def initialize(machine)
   @blueprint = machine.machine_blueprint
   @machine = machine
  end
 

  def company; machine.company; end
  def cloud; machine.cloud; end

end
