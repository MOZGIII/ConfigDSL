require "configdsl/version"
require "active_support/concern"
require "forwardable"

module ConfigDSL
  module Memory
    class << self
      # Creates a new layer-level storage element
      def layers_factory
        # Try to use Hashie::Mash if defined (see hashie gem)
        return Hashie::Mash.new if defined?(Hashie::Mash)
        
        # Fallback to standart ruby Hash
        Hash.new
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
      false
    end
    
    def context
      @@context ||= []
    end
    
    def debug(text)
      puts text if DSL.debug?
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
end
