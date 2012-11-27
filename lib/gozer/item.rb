module Gozer
  class Item < Hashie::Mash
    def self.new *args
      if args.size == 1
        super(date: args.first)
      else
        super
      end
    end

    def <=> other
       other.date <=> self.date
    end
  end
end