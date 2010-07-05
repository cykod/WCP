
=begin rdoc
HashModel's are used throughout webiva 


=end
class HashModel 
  include ActiveModel::Validations
  
  def self.defaults
    {}
  end
  
  def defaults
    self.class.defaults
  end
  
  def self.attributes(hsh) 
    hsh.symbolize_keys!
    
    int_opts = []
    class_eval do
      hsh.each do |atr,val|
        attr_accessor atr.to_sym
        
#        if atr.to_s =~ /_(id|number)$/ 
#          int_opts << atr.to_sym
#        end
      end
      
      df = self.defaults.merge(hsh)
      class << self; self end.send(:define_method,"defaults") do
        df
      end
    end
    integer_options(int_opts)
  end
  
  def self.default_options(hsh)
    hsh.symbolize_keys!
    
    int_opts = []
    class_eval do
      hsh.each do |atr,val|
        attr_accessor atr.to_sym
      end
    
      define_method "defaults" do
         return hsh
      end 
      
    end
  end
  
  def self.current_integer_opts; []; end
  def self.current_boolean_opts; []; end
  def self.current_float_opts; []; end
  def self.current_integer_array_opts; []; end

  def self.integer_options(*objs)
    if objs[0].is_a?(Array)
      objs = current_integer_opts + objs[0]
    else
      objs = current_integer_opts + objs
    end
    objs.uniq!
    
    class << self; self end.send(:define_method,"current_integer_opts") do
      objs
    end
  end


   def self.integer_array_options(*objs)
    if objs[0].is_a?(Array)
      objs = current_integer_array_opts + objs[0]
    else
      objs = current_integer_array_opts + objs
    end
    objs.uniq!
    
    class << self; self end.send(:define_method,"current_integer_array_opts") do
      objs
    end
  end
  
  def self.boolean_options(*objs)
    objs = current_boolean_opts + objs
    
    objs.uniq!
    class << self; self end.send(:define_method,"current_boolean_opts") do
      objs
    end

    objs.each do |obj|
      self.class_eval <<-EOF
      def #{obj}?
        ! @#{obj}.blank?
      end
      EOF
    end
  end

  def self.float_options(*objs)
    objs = current_float_opts + objs

    objs.uniq!
    class << self; self end.send(:define_method,"current_float_opts") do
      objs
    end
  end
  
  
  def initialize(hsh)
  	hsh ||= {}
    sym_hsh = {}
    hsh.each do |key,val| 
      sym_hsh[key.to_sym] = val
    end
    @passed_hash = sym_hsh
    @hsh = self.defaults.merge(sym_hsh)
    @hsh.each do |key,value|
      self.send("#{key.to_s}=",value) if defaults.has_key?(key.to_sym) || self.respond_to?("#{key.to_s}=")
    end
    
    
    @additional_vars = []
  end

  def attributes
    to_h
  end

  def attributes=(hsh)
    hsh.each do |key,value|
      self.send("#{key.to_s}=",value) if defaults.has_key?(key.to_sym) || self.respond_to?("#{key.to_s}=")
    end
  end

  def additional_vars(vars)
    @additional_vars += vars
    
    vars.each do |key|
      val = hsh[key.to_sym]
      if key.to_s =~ /_(id|number)$/ 
        val = val.blank? ? nil : val.to_i
      end
      
      self.instance_variable_set "@#{key}",val
    end
  end

  def to_passed_hash
    to_h.slice( *@passed_hash.keys )
  end
  
  def to_h
    self.valid?
    hsh = {}
    
    self.instance_variables.each do |var|
      key = var.to_s.slice(1,var.length-1).to_sym
      if key && (self.defaults.has_key?(key) || @additional_vars.include?(key))
        hsh[key] = self.instance_variable_get(var)  
      end
    end
    hsh
  end
  
  def to_hash
    to_h
  end
  
  def option_to_i(opt)
    val = self.send(opt)
    self.instance_variable_set "@#{opt.to_s}",val.to_i
  end
  
  def method_missing(arg, *args)
    arg = arg.to_s
    if arg == 'hsh=' || arg == 'errors='
      #
    elsif arg[-1..-1] == "="
      raise "Undeclared HashModel variable: #{arg[0..-2]}"
    elsif self.strict?
      raise "Missing hash model method #{arg}" unless self.instance_variables.include?("@#{arg}")
      self.instance_variable_get "@#{arg}"
    else
      self.instance_variable_get "@#{arg}"
    end
  end
  
  def strict?; false; end

  def valid?
    format_data
    super
  end
  
  def format_data
   int_opts = self.class.current_integer_opts
    int_opts.each do |opt|
      val = self.send(opt)
      val = val.blank? ? nil : val.to_i
        self.instance_variable_set "@#{opt.to_s}",val
    end
    bool_opts = self.class.current_boolean_opts
    bool_opts.each do |opt|
      val = self.send(opt)
      if val.is_a?(String) # Assume we're a bool if not a val
        val  = (val == 'true' || val.to_i == 1) ? true : false
        self.instance_variable_set "@#{opt.to_s}",val
      end
    end
    float_opts = self.class.current_float_opts
    float_opts.each do |opt|
      val = self.send(opt)
      if val.is_a?(String)
        val = val.blank? ?  nil : val.to_f
        self.instance_variable_set "@#{opt.to_s}",val
      end
    end
    int_arr_opts = self.class.current_integer_array_opts
    int_arr_opts.each do |opt|
      val = self.send(opt)
      if val.is_a?(Array)
        val = val.map { |elm| elm.blank? ? nil : elm.to_i }.compact
      else
        val = []
      end
      self.instance_variable_set "@#{opt.to_s}",val
    end
    
    
  end
     
  def self.self_and_descendants_from_active_record
    [  ]
  end 
  
  def self.human_name
    self.name.underscore.titleize
  end  
  
  def self.human_attribute_name(attribute)
    attribute.to_s.humanize
  end  

end
