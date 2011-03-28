

class DeploymentLog < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :deployment

  field :messages, :type => Array, :default => []


end
