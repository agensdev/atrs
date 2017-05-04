# frozen_string_literal: true

module Atrs
  class PluginNameTakenError < StandardError; end
  class PluginOptionKeywordTakenError < StandardError; end

  class << self
    attr_reader :plugins, :options
  end
  @plugins = {}
  @options = {}

  def self.register_plugin(name, mod)
    raise PluginNameTakenError, "Plugin #{name} already in use" if plugins[name]
    plugins[name] = mod
  end

  module Plugin
    def options
      @options ||= []
    end

    def option(name, klass, **kargs, &blk)
      raise PluginOptionKeywordTaken if Atrs.options[name]
      option_instance = Option.new(name, klass, self, **kargs, &blk)
      Atrs.options[name] = option_instance
      options << option_instance
      #
      # # TODO: Refactor this to apply only if plugin is in use
      # # THOUGHT: Should we support a set of default options enabled globaly?
      #
      # raise PluginOptionKeywordTaken if Atrs.options[:name]
      # # These needs to go somewhere else
      # @option_name = name
      # @option_klass = klass
      # @option_default = default
    end
  end
end
