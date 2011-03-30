# import RATES.xml into lookup table { [from, to] => rate }
# import TRANS.csv
#

require 'rexml/document'
require 'pp' # TODO REMOVE

rate_table = {}

rates_file = File.read('RATES.xml')

xml_doc = REXML::Document.new(rates_file)

xml_doc.elements.each('rates/rate') do |rate_elt|
  rate_data  = rate_elt.elements
  from, to   = rate_data['from'].text, rate_data['to'].text
  conversion = rate_data['conversion'].text.to_f

  rate_table[[from, to]] = conversion
end

pp rate_table


