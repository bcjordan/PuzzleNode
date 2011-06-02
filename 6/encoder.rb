class String
  def hide_in_file (infile, outfile)
    to_hide = string_to_binary

    pp to_hide
    original_image = File.open(infile).readlines.to_s

    start_bit = original_image.unpack('@10L')[0] * 8

    orig_binary = original_image.to_binary
    out_image = original_image.to_binary

    to_hide.length.times { |b|
      out_image[start_bit + (8 * b) .. start_bit + (8 * b)] = to_hide[b .. b]
    }

    (((out_image.length - start_bit) / 8) - (to_hide.length)).times { |b|
      out_image[start_bit + 8 * (to_hide.length + b)] = '0'
    }
    pp orig_binary[0..50]
    pp out_image[0..50]
    out_image = [out_image].pack('b*')
    
    #pp "Original: ", original_image
    #pp "Out: ", out_image

    out = File.new(outfile, "wb")
    out.write(out_image)
    out.close
  end

  def self.read_from_file (infile)
    image_string = File.open(infile).readlines.to_s

    bits = image_string.to_binary

    start_bit = image_string.unpack('@10L')[0] * 8

    message = ""

    ((image_string.length - start_bit) / 8).times { |b|
      message += bits[start_bit + (8*b) .. start_bit + (8*b)]
    }

    message.from_binary
  end

  def to_binary
    self.unpack('b*')[0]
  end

  def string_to_binary
    self.split("").inject(""){ |string, c| string += c[0].to_s(2).rjust(8, '0') }
  end

  def from_binary
    [self].pack('B*').delete "\000"
  end
end