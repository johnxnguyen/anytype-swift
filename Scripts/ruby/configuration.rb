require_relative 'library/shell_executor'
require_relative 'library/workers'
require_relative 'library/semantic_versioning'

module Commands
  class BaseCommand
    def to_json(*args)
      self.class.name
    end
  end

  class InstallCommand < BaseCommand
  end

  class UpdateCommand < BaseCommand
    attr_accessor :version
    def initialize(version = nil)
      self.version = version
    end
  end

  class ListCommand < BaseCommand
  end

  class CurrentVersionCommand < BaseCommand
  end
end
