require "configdsl/version"
require "active_support/concern"
require "forwardable"

module ConfigDSL
  module Memory
    class MemoryLayer < Hash
      def self.make_alias_method(meth)
        "original_#{meth}".to_sym
      end
    
      ALIASED_METHODS = [
        :[], :fetch
      ]
      
      ALIASED_METHODS.each do |meth|
        original_method = make_alias_method(meth)
        
        begin
          alias_method original_method, meth
          
          define_method meth do |*args, &block|
            lazy_value = __send__(original_method, *args, &block)
            lazy_value = lazy_value.value if lazy_value.kind_of?(LazyValue)
            lazy_value
          end
        rescue NameError
        end
      end
      
      # Give a more handy name
      alias_method :original_reader, make_alias_method(:[])
      
      # Allow methods invocation to read values
      def method_missing(meth, *args, &block)
        return self[meth] if has_key?(meth)
        super
      end
      
      # Allow methods invocation to read values, second part
      def respond_to?(meth)
        return true if has_key?(meth)
        super
      end
    end
  
    class << self
      # Creates a new layer-level storage element
      def layers_factory
        @factory_base_class ||= MemoryLayer
        @factory_base_class.new
      end
    
      # Main data container
      def data
        @data ||= layers_factory
      end

      # Stores a value in specified key for specified context
      def store(key, value, context = [])
        layer = expand_context(context)
        layer[key] = value
      end
      
      # Fetches a specified key for a specified context
      # Allows to provide a default value
      def fetch(key, defaul_value = nil, context = [])
        fetch!(key, context)
      rescue KeyError => e
        defaul_value
      end
      
      # Fetches a specified key for a specified context
      # Raises exception if something goes wrong
      def fetch!(key, context = [])
        layer = expand_context(context)
        raise KeyError, "In context #{context} key not found: #{key.inspect}" unless layer.has_key?(key)
        layer[key]
      end
      
      # Return a layer described by context or rises an exception
      # if any of parent layers is undefined
      def expand_context(context)
        context.inject(data) do |hash, level|
          hash[level]
        end
      end
      
      # Adds a new layer if it does not exist
      def add_layer(new_layer, context)
        current_layer = expand_context(context)
        current_layer[new_layer] ||= layers_factory
      end
    end
  end

  module DSL    
    extend ActiveSupport::Concern
    
    def self.debug?
      @debug ||= false
    end
    
    def self.debug!(value = true)
      @debug = value
    end
    
    def context
      @@context ||= []
    end
    
    def debug(text)
      puts text if DSL.debug?
    end
    
    def lazy!(*args, &block)
      LazyValue.new(block, args)
    end
    
    def assign!(sym, value = nil, &block)
      return sym.each { |key, val| assign!(key, val) } if sym.kind_of? Hash
      varibales_hook(sym, value, &block)
    end

    def varibales_hook(meth, *args, &block)
      debug "Hooked #{meth}"
      debug "Context is #{context}"
      if block_given?
        # Add list
        debug "Adding list #{meth}"
        evaluate_within_layer(meth, block, args)
      else
        if args.empty?
          # Read variable
          debug "Reading variable #{meth}"
          Memory.fetch!(meth, context)
        else
          # Add variable
          debug "Adding variable #{meth}"
          value = args.size == 1 ? args.first : args.dup
          Memory.store(meth, value, context)
        end
      end
    end

    def evaluate_within_layer(new_layer, block, args = [])
      Memory.add_layer(new_layer, context)
      begin
        context.push new_layer
        block.call(*args)
      ensure
        context.pop
      end
    end
    
    def method_missing(meth, *args, &block)
      if respond_to?(meth)
        super
      else
        varibales_hook(meth, *args, &block)
      end
    end

  end
  
  module Processor
    class Sandbox
      include DSL
    end

    def self.process(filename)
      sandbox = Sandbox.new
      sandbox.instance_eval(File.read(filename), filename)
      sandbox
    end
    
    def self.execute(&block)
      sandbox = Sandbox.new
      sandbox.instance_eval(&block)
      sandbox
    end
    
    def self.add_module(module_const)
      Sandbox.extend module_const
    end
  end
  
  class << self  
    def read(filename)
      Processor.process(filename)
    end
    
    def execute(&block)
      Processor.execute(&block)
    end
    
    def data
      Memory.data
    end
    
    def method_missing(meth, *args, &block)
      if data.respond_to?(meth)
        data.send(meth, *args, &block)
      else
        super
      end
    end
    
    def respond_to?(meth)
      super_value = super
      return super_value if super_value != false
      data.respond_to?(meth)
    end
  end
  
  class LazyValue
    def self.default_options
      {
        caching: true        
      }
    end
    
    attr_reader :block, :args, :options
  
    def initialize(block, args = [], options = {})
      @block = block
      @args = args
      @options = self.class.default_options.merge(options)
      @cached = false
    end
    
    def value(new_args = nil)
      return @cache if caching? && cached?
      value = block.call(*(new_args ? new_args : args))
      if caching?
        @cache = value
        @cached = true
      end
      value
    end
    
    def caching?
      !!options[:caching]
    end
    
    def flush_cache!
      @cache = nil # clean pointer so that GC can do it's work immediately
      @cached = true
    end
    
    def cached?
      @cached
    end
  end
end
