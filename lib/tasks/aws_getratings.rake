namespace :aws do
  desc 'Gets Cookbook Info'
  task :getcookbooks => :environment do
    require 'amazon/ecs'
    require 'open-uri'

    # set the default options; options will be camelized and converted to REST request parameters.
    # replace aWS_access_key_id with your access key from amazon

    Amazon::Ecs.options = {:aWS_access_key_id => '015S8J3HSX1PRSWBN902', :response_group => 'Medium'}

    books = Cookbooks.find_all
    
    books.each do |book|
      
      puts books.title
   
        # options provided on method call will merge with the default options
        # note right now I'm just searching for barefoot contessa cookbooks to get it working
        # once you are ready to scrape all of them, then change 'garten' to ''

        res = Amazon::Ecs.item_search('', {:browse_node => bn[0], :item_page => item_page})
  
  
        il = ItemLookup.new( 'ASIN', { 'ItemId' => books.ISDN } )
  
        if !il.get('rating').nil?
            Cookbooks.rating = il.get('rating')
        end
        
  
     #cookbooks
     end
    
  #end tasks
  end
#namespace
end
