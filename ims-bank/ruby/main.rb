require 'sinatra'
require 'sinatra/reloader'

require 'uri'
require 'net/http'
require 'json'

set :protection, :except => :frame_options
set :bind, '0.0.0.0'
set :port, 8080

get '/' do
  # Your implementation goes here
  uri = URI('https://quietstreamfinancial.github.io/eng-recruiting/transactions.json')
  response = Net::HTTP.get_response(uri)
  transactions = JSON.parse(response.body)
  @accounts = {}
  transactions.each do |t|
    if !@accounts.keys.include?(t['customer_id'])
      @accounts[t['customer_id']] = {'name' => t['customer_name'], 'total_saving' => 0.0, 'total_checking' => 0.0, 'remaining' => 0.0} 
    else
      @accounts[t['customer_id']]['name'] ||= t['customer_name']
    end
    if t['account_type'] == 'savings'
      @accounts[t['customer_id']]['total_saving'] += t['transaction_amount'][1..-1].to_f 
    elsif t['account_type'] == 'checking'
      @accounts[t['customer_id']]['total_checking'] += t['transaction_amount'][1..-1].to_f 
    else
      @accounts[t['customer_id']]['remaining'] += t['transaction_amount'][1..-1].to_f 
    end
  end
  erb :table
end