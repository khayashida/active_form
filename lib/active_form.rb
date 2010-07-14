class ActiveForm
  def initialize(attributes = nil)
    self.attributes = attributes
    yield self if block_given?
  end
  
  def attributes=(attributes)
    attributes.each { |key,value| self[key] = value } if attributes
  end
  
  def attributes
    attributes = instance_variables
    attributes.delete("@errors")
    Hash[*attributes.collect { |attribute| [attribute[1..-1], instance_variable_get(attribute)] }.flatten]
  end
  
  def [](key)
    instance_variable_get("@#{key}")
  end
  
  def []=(key, value)
    instance_variable_set("@#{key}", value)
  end
  
  def method_missing(method_id, *params)
    # Implement _before_type_cast accessors
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self[attr_name] if self.respond_to?(attr_name)
    end
    super
  end

  alias_method :respond_to_without_attributes?, :respond_to?

  def new_record?
    true
  end

  def id
    nil
  end

  def raise_not_implemented_error(*params)
    self.class.raise_not_implemented_error(params)
  end
  
  alias save raise_not_implemented_error
  alias save! raise_not_implemented_error
  alias update_attribute raise_not_implemented_error
  alias update_attributes raise_not_implemented_error

  include ActiveRecord::Validations
  
  alias save valid?
  alias save! raise_not_implemented_error
  alias update_attribute raise_not_implemented_error
  alias update_attributes raise_not_implemented_error
  
  class <<self
    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}"
      end
      defaults << self.name.humanize
      I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
    end

    def human_attribute_name(attribute_key_name, options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}.#{attribute_key_name}"
      end
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << attribute_key_name.to_s.humanize
      options[:count] ||= 1
      I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
    end

    def raise_not_implemented_error(*params)
      raise NotImplementedError
    end
    
    alias create raise_not_implemented_error
    alias create! raise_not_implemented_error
    alias validates_acceptance_of raise_not_implemented_error
    alias validates_uniqueness_of raise_not_implemented_error
    alias validates_associated raise_not_implemented_error
    alias validate_on_create raise_not_implemented_error
    alias validate_on_update raise_not_implemented_error
    alias save_with_validation raise_not_implemented_error
  end
end
