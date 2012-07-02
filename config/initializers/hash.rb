class Hash
  def +(hash2)
    hash2.each do |key, value|
      if self.has_key? key
        self[key] += value
      else
        self[key] = value
      end
    end
  end

  def to_array_conditions
    new_conditions = []
    new_conditions[0] = self.map {|k,v| v.is_a?(Array) ? "#{k} in (?)" : "#{k} = ?"}.join(" AND ")
    self.values.each do |v|
      v.is_a?(Array) ? new_conditions.push(v.flatten) : new_conditions.push("#{v}")
    end
    new_conditions
  end
end
