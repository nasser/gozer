module Gozer
  class Stream < Array
    def self.new *args
      super.sort
    end

    def + other
      Stream.new(super(other))
    end
  end
end