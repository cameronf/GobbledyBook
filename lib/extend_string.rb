class String
  def is_gt_one?
    if self['/'].nil?                # not a fraction
      if self['.'].nil?              # not a decimal
        return true if self.to_i > 1
      else                           # a decimal
        return true if self.to_f > 1
      end
    else                             # has a fraction
      if self[' '].nil?              # not a mixed number
        if self.split('/')[0].to_i > self.split('/')[1].to_i  
          return true                # numerator is greater than denominator
        end
      else                           # a mixed number
        return true
      end
    end
    return false
  end
end
