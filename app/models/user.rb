# Much of this code come vertbatim from the clearance gem
# http://github.com/thoughtbot/clearance


class User < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :company

  attr_accessor :password, :password_confirmation, :account_edit

  field :email
  field :encrypted_password
  field :salt
  field :admin, :type => Boolean, :default => false

  before_save :generate_salt
  before_save :encrypt_password

  validates_presence_of :email
  validates_confirmation_of :password, :if => Proc.new { |u| u.account_edit && !u.password.blank? }
    
  def logged_in?
    !self.id.blank?
  end


  def self.authenticate(email,password)
    user = self.where(:email => email).first
    if user && user.password_matches?(password) && (user.admin? || (user.company && user.company.active?))
      user
    else
      nil
    end
  end

  def password_matches?(pw)
    self.encrypted_password == encrypt(pw)
  end


  # Put us in edit account mode so we validate password_confirmation
  def edit_account; self.account_edit=true; end

  protected


  def encrypt(str)
    generate_hash(self.salt + '--' + str)
  end


  def encrypt_password
    return if password.blank?
    self.encrypted_password = encrypt(self.password)
  end

  def generate_salt
    if new_record?
      self.salt = generate_hash("--#{Time.now.utc}--#{password}--#{rand}--")
    end
  end
  
end

