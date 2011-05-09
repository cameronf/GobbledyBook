namespace :curl do
  desc 'Does a Json call, can take server (defaults to localhost:3000), controller (defaults to api), action and params'
  task :json => :environment do
    server = ENV['server'].nil? ? 'localhost:3000' : ENV['server']
    controller = ENV['controller'].nil? ? 'api' : ENV['controller']
    action = ENV['action']
    params = ENV['params']

    auth_shell = 'curl -c curlcookies.txt http://' + server + '/main/home'
    auth_resp = %x[#{auth_shell}]
    auth_token = auth_resp[/token.*>/][/content.*>/][/\".*\"/][1..-2] 

    params += "&authenticity_token=#{auth_token}"

    shell_cmd = 'curl -b curlcookies.txt -H "Accept:application/json" -d "' + params + '" http://' + server + '/' + controller + '/' + action
    puts %x[#{shell_cmd}]

  #end tasks
  end
#namespace
end
