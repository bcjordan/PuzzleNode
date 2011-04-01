require 'rexml/document'
require 'csv'

target_item = 'DM1182'
target_currency = 'USD'
rate_file = 'RATES.xml'
transaction_file = 'TRANS.csv'
solution_file = 'OUTPUT.txt'

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

#
# Perform breadth-first search for rate from currency to target currency,
# given an initial rate. Uses rate as an accumulating parameter.
#
def get_rate (currency, target_currency, rate)
  if currency == target_currency
    rate
  elsif @rate_table[[currency, target_currency]] != nil
    @rate_table[[currency, target_currency]] * rate
  else
    @rate_table.each do |k, v|
      if k[0] == currency
         rate = get_rate(k[1], target_currency, rate * v)
         return rate if rate
      end
    end
    nil 
  end
end

def bankers_rounder n
  cents                = n.to_s.split('.')[1]
  thousandth, hundreth = cents[2..2].to_i, cents[1..1].to_i

  if    thousandth < 5
    (n * 100).truncate / 100.0
  elsif thousandth > 5
    ((n * 100).truncate + 1) / 100.0
  else
    if hundreth.odd?
      ((n * 100).truncate + 1) / 100.0
    elsif hundreth.even? 
      ((n * 100).truncate + 1) / 100.0
    end
  end
end

costs_list.each do |cost|
  number, currency = cost.split[0].to_f, cost.split[1]
  if currency == target_currency
    total += number
  else
    total += bankers_rounder(number * get_rate(currency, target_currency, 1))
  end
end

open(solution_file, 'w') { |f| f << "#{total}\n" }
