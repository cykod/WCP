

class BaseModel


  include ActiveModel::Conversion
  include ModelExtension::OptionsExtension

  def persisted?
    self.id ? true : false
  end


  def generate_hash(string)
    Digest::SHA1.hexdigest(string)
  end

  def has_attribute?(v)
    self.attributes.has_key?(v.to_sym)
  end

  def self.select_options
    self.all.map { |itm| [ itm.name, itm.id ] }
  end

  def self.select_options_with_nil(name = nil)
    name ||= self.to_s.titleize
    [["-- Select #{name} --",nil]] + self.select_options
  end
 
 end
