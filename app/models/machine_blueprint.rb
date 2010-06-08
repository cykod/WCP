

class MachineBlueprint
  include SimplyStored::Couch

  has_many :machines

  property :recipie_name
  property :launcher_class

  property :instance_type
  property :machine_id

  
end
