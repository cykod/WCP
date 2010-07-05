

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
 
 end
