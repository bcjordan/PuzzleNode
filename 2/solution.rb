# import RATES.xml into lookup table { [from, to] => rate }
# import TRANS.csv
#

require 'rexml/document'
require 'pp' # TODO REMOVE
require 'csv'

target_item = 'DM1182'
target_currency = 'USD'
rate_file = 'SAMPLE_RATES.xml'
transaction_file = 'SAMPLE_TRANS.csv'

@rate_table = {}
costs_list = []
total = 0.0

rates_file = File.read(rate_file)

xml_doc = REXML::Document.new(rates_file)

xml_doc.elements.each('rates/rate') do |rate_elt|
  rate_data  = rate_elt.elements
  from, to   = rate_data['from'].text, rate_data['to'].text
  conversion = rate_data['conversion'].text.to_f

  @rate_table[[from, to]] = conversion
end

CSV.read(transaction_file)[1..-1].each do |row|
  costs_list << row[2] if row[1] == target_item
end

def get_rate (currency, target_currency, rate)
  if currency == target_currency
    rate
  elsif @rate_table[[currency, target_currency]] != nil
    @rate_table[[currency, target_currency]]
  else
    @rate_table.each do |k, v|
      if k[0] == currency
         rate = get_rate(k[1], target_currency, rate * v)
         return rate if rate
      end
    end
    return nil 
  end
end

def truncator n
  pp (n * 100).round.to_f / 100
  (n * 100).round.to_f / 100
end

costs_list.each do |cost|
  number, currency = cost.split[0].to_f, cost.split[1]
  if currency == target_currency
    total += number
    pp number
  else
    total += truncator(number * get_rate(currency, target_currency, 1))
  end
end

pp total


