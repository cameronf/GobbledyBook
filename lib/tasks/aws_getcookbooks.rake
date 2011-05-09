namespace :aws do
  desc 'Gets Cookbook Info'
  task :getcookbooks => :environment do
    require 'amazon/ecs'
    require 'open-uri'

    # set the default options; options will be camelized and converted to REST request parameters.
    # replace aWS_access_key_id with your access key from amazon

    Amazon::Ecs.options = {:aWS_access_key_id => '015S8J3HSX1PRSWBN902', :response_group => 'Medium'}

    # Browse nodes are the ids for the subcategory pages to navigate
    # you want this to be a comma separated list of all of them, no quotes
    # right now I have it set to 6 just to get it working on your machine - you should delete the 6

    browse_nodes = Array.new
    #baking 
    #browse_nodes << this_node = [4196, ["baking"]] 
    #browse_nodes << this_node = [4197, ["baking", "breads"]] 
    #browse_nodes << this_node = [4196, ["baking", "cakes"]] 
    #browse_nodes << this_node = [4199, ["baking", "chocolate"]] 
    #browse_nodes << this_node = [4200, ["baking","cookies"]] 
    #browse_nodes << this_node = [4201, ["baking","desserts"]] 
    #browse_nodes << this_node = [4203, ["baking", "muffins"]] 
    #browse_nodes << this_node = [4204, ["baking", "pastry"]] 
    #browse_nodes << this_node = [4205, ["baking", "pies"]] 
    #browse_nodes << this_node = [4206, ["baking", "pizza"]]
    #misc (canning, culinary arts, gastronomy, natural foods, organic, outdoor, pro, quick, reference, special apliances)
    #browse_nodes << this_node = [4207, ["canning"]]
    #browse_nodes << this_node = [4252,["culinary", "arts"]]
    #browse_nodes << this_node = [4229, ["gastronomy"]]
    #browse_nodes << this_node = [4340, ["natural"]]
    #browse_nodes << this_node = [332055011, ["organics"]]
    #browse_nodes << this_node = [4245, ["outdoor"]]
    #browse_nodes << this_node = [4251, ["professional"]]
    #browse_nodes << this_node = [4257, ["quick"]]
    #browse_nodes << this_node = [4261, ["reference"]]
    #browse_nodes << this_node = [4256, ["appliance"]]
    #by Ingredient
    #browse_nodes << this_node = [4208,[""]] 
    #browse_nodes << this_node = [4209,["cheeses","dairy"]] 
    #browse_nodes << this_node = [4210,["fruits"]] 
    #browse_nodes << this_node = [4211,["herbs", "spice", "condiments"]] 
    #browse_nodes << this_node = [4212, ["meat"]] 
    #browse_nodes << this_node = [4214, ["meat","game"]] 
    #browse_nodes << this_node = [4215, ["meat","poultry"]] 
    #browse_nodes << this_node = [4216, ["meat","seafood"]] 
    #browse_nodes << this_node = [4217,["pasta"]] 
    #browse_nodes << this_node = [170102,["rice","grains"]] 
    #browse_nodes << this_node = [4218,["sauces"]]
    
    #Drinks
    #browse_nodes << this_node = [4219,["drinks","beverages"]] 
    #browse_nodes << this_node = [4220,["drinks","beverages","bartending","liquor","alcohol", "cocktail"]] 
    #browse_nodes << this_node = [4221,["drinks","beverages","beer","liquor","alcohol"]] 
    #browse_nodes << this_node = [4222,["drinks","beverages","coffee", "tea"]] 
    #browse_nodes << this_node = [172403,["drinks","beverages", "juices"]] 
    #browse_nodes << this_node = [173192,["drinks","beverages","smoothies"]]
    #browse_nodes << this_node = [4223,["drinks","beverages","spirits","liquor","alcohol", "cocktail"]]
    #browse_nodes << this_node = [4224,["drinks","beverages","liquor","alcohol","wine"]]
    #Meals
    #browse_nodes << this_node = [4234,[""]]
    #browse_nodes << this_node = [4235,["appetizers"]]
    #browse_nodes << this_node = [4236,["breakfast"]]
    #browse_nodes << this_node = [4328,["brunch"]]
    #browse_nodes << this_node = [4238,["soups","stews"]]
    #browse_nodes << this_node = [4239,["sweets","desserts"]]
    #Regional
    #browse_nodes << this_node = [4262,[""]]
    #browse_nodes << this_node = [4263,["african"]]
    #browse_nodes << this_node = [4264,["asian"]]
    #browse_nodes << this_node = [4273,["canadian"]]
    #browse_nodes << this_node = [4274,["caribbean"]]
    #browse_nodes << this_node = [4275,["european"]]
    #browse_nodes << this_node = [4296,[""]]
    #browse_nodes << this_node = [4297,["latino"]]
    #browse_nodes << this_node = [4298,["mexican"]]
    #browse_nodes << this_node = [691990,["middle eastern"]]
    #browse_nodes << this_node = [4299,["native american"]]
    #browse_nodes << this_node = [4300,["american"]]
    
    #Special Diet
    #browse_nodes << this_node = [4317,[""]]
    #browse_nodes << this_node = [4318,["diabetic"]]
    #browse_nodes << this_node = [4618,[""]]
    #browse_nodes << this_node = [4320,["healthy"]]
    #browse_nodes << this_node = [4321,["kosher"]]
    #browse_nodes << this_node = [4322,["low cholesterol"]]
    #browse_nodes << this_node = [4323,["low fat"]]
    #browse_nodes << this_node = [4324,["low salt"]]
    
    #Special Occasion
    #browse_nodes << this_node = [4329,["holidys"]]
    #browse_nodes << this_node = [4332,["holidys"]]
    #browse_nodes << this_node = [4333,["party"]]
    #browse_nodes << this_node = [4334,["seasonal"]]
    
    #vegetarian
    #browse_nodes << this_node = [4336,["vegetables","vegetarian"]] 
    browse_nodes << this_node = [4210,["vegetables","vegetarian","fruits"]]
    browse_nodes << this_node = [4320,["vegetables","vegetarian"]]
    browse_nodes << this_node = [4341,["vegetables","vegetarian","potatoes"]]
    browse_nodes << this_node = [4342,["vegetables","vegetarian","salads"]]
    browse_nodes << this_node = [4619,["vegetables","vegetarian","vegan"]]
    browse_nodes << this_node = [4344,["vegetables","vegetarian"]]
    
    bindings = ['Hardcover', 'Paperback','Board Book']
    
    browse_nodes.each do |bn|
      
      puts browse_nodes[0]
      
      item_page = 1
      begin

        # options provided on method call will merge with the default options
        # note right now I'm just searching for barefoot contessa cookbooks to get it working
        # once you are ready to scrape all of them, then change 'garten' to ''

        res = Amazon::Ecs.item_search('', {:browse_node => bn[0], :item_page => item_page})
  
        res.items.each do |item|
          if !item.get('isbn').nil?
            # I wouldn't save it unless binding == 'Hardcover' or 'Paperback' - maybe 'Spiral Bound'
            bindingType = item.get('binding')

            if bindings.include?(bindingType)
              bookTitle = item.get('title')
               #puts('Publisher: ' + item.get('publisher')) unless item.get('publisher').nil?
            
              if !bookTitle.nil?
                puts(bookTitle)
              
                #first, find the author so we can check to see if it's already been added. Create as needed.
                authors = item.get_array('author')
                if authors.length == 0
                  author_name = "Not Available"
                else
                  author_name = authors.join(';')
                end
                puts(author_name)
                author = Authors.find_or_create_by_name(author_name)
                
                #create a new cookbook record
                newBook = Cookbooks.find_or_create_by_title_and_authors_id(bookTitle, author.id)

                #get publisher id, and create if necessary
                publisherName = item.get('publisher')
                if !publisherName.nil?
                  storeNameAs = publisherName.gsub(/&amp|[[:punct:][:space:]]/,'')
                else
                  storeNameAs = "NA"
                  publisherName = "Not Available"
                end 
                publisher = Publishers.find_or_create_by_name(storeNameAs)
                if publisher.displayname.nil?
                  publisher.displayname = publisherName
                  publisher.save
                end if
                newBook.publishers_id = publisher.id
                        
                #set the other fields
                if newBook.publicationdate.nil?
                  newBook.publicationdate = item.get('publicationdate') unless item.get('publicationdate').nil?
                end
                if newBook.binding.nil?
                  newBook.binding = bindingType
                end
 
                bn[1].each do |tg|
                  tag = Tags.find_or_create_by_name(tg)
                  cbt = Cookbooktags.find_or_create_by_tags_id_and_cookbooks_id(tag.id, newBook.id)  
                end  
              
                #AID is the same as the ISBN
                if newBook.ISBN.nil?
                  newBook.ISBN = item.get('isbn') unless item.get('isbn').nil?
               
                  # books have up to 3 different images, this will get the largest image available.
                  # if you need width height, you can get that as well, but I couldn't decide if you did
                  # I would probably post process all of the images to make them all the same size...

                  image_url = item.get('smallimage/url') unless item.get('smallimage').nil?
                  image_url = item.get('mediumimage/url') unless item.get('mediumimage').nil?
                  #probably don't need the big one
                  # image_url = item.get('largeimage/url') unless item.get('largeimage').nil?
                  if !image_url.nil?
                    # this downloads the image, and saves it in the public/images directory as ISBN.jpg
                    img = open(image_url)
                    f = File.open('public/images/'+item.get('isbn')+'.jpg','w')
                    f.write(img.read)
                    f.close                 
                  end
                  
                # if newBook.ISBN.nil? 
                end  
                
                newBook.isvisible = true
                #newBook.relatedto = ""
                
                newBook.save
                
                
              #if !bookTitle.nil?  
              end
              
            #if bindings.include?(bindingType)  
            end
            
          #if !item.get('isbn').nil?  
          end
        
        #res.items.each do |item|
        end
        item_page += 1
      sleep(3)
      # begin  
      end until item_page > res.total_pages.to_i or item_page > 400 # loop - 10 at a time, until no pages left
  
     #browse_nodes.each do |bn|
     end
    
  #end tasks
  end
#namespace
end
