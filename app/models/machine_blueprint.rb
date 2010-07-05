

class MachineBlueprint
  include SimplyStored::Couch

  has_many :machines

  property :name
  property :identifier

  property :recipie_name
  property :launcher_class

  property :instance_type
  property :machine_image


  def self.fetch(identifier)
    self.find_by_identifier(identifier)
  end
  
end
