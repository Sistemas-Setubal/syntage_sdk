module SyntageSdk
  class Headers
    def initialize(raw)
      @raw = Hash(raw).transform_keys { |key| key.to_s.downcase }
    end

    def get(name)
      @raw[name.to_s.downcase]
    end
  end
end
