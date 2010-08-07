module RubyRanges
  module Range

    def self.included(base)
      base.send(:define_method, :include?) do |object|
        object.is_a?(Range) ? include_range?(object) : super(object)
      end
    end
    
    def +(range)
      add_range(range)
    end

    def -(range)
      subtract_range(range)
    end

    def include_range?(range)
      case
      when self.include?(range.begin) && self.include?(range.end) # wholly inclusive
        RubyRanges::WhollyIncluded
      when range.include?(self.begin) && range.include?(self.end) # inverse wholly inclusive
        RubyRanges::InverseWhollyIncluded
      when self.include?(range.begin) && self.end < range.end # upload inclusive
        RubyRanges::UpwardIncluded
      when self.include?(range.end) && self.begin > range.begin # downward inclusive
        RubyRanges::DownwardIncluded
      else # exclusive range
        RubyRanges::MutuallyExcluded
      end
    end

    private
    def add_range(range)
      case self.include?(range).to_value
      when TrueClass # self swallows smaller range
        self
      when NilClass # self swallowed by larger range
        range
      when 1 # add upward inclusive range
        self.begin..range.end
      when -1 # add downward inclusive range
        range.begin..self.end
      else # mutually exclusive
        ArrayOfRanges.new(self, range)
      end
    end

    def subtract_range(range)
      case self.include?(range).to_value
      when NilClass # self removed by larger range
        nil
      when TrueClass # self split by wholly inclusive range
        ArrayOfRanges.new(self.begin..range.begin, range.end..self.end)
      when 1 # self shortened by upload inclusive range
        self.begin..range.begin
      when -1 # self shortened by downward inclusive range
        range.end..self.end
      else # mutually exclusive
        self
      end
    end
  end
end