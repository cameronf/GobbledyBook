class MainController < ApplicationController

  # methods arranged alphabetically
  # User needs to signin if they are going to edit a cookbook, edit a recipe, or see their list of cookbooks...
  before_filter :authenticate_user!, :only => [:myStuff, :recipeDetailsForm]
  
  def aboutUs
    
    @recipecount = Recipe.find(:all).length
    
    respond_to do |format|
      format.html
    end
  end
  
  def termsofuse
      
    respond_to do |format|
      format.html
    end
  end  
  
  def faq

      respond_to do |format|
        format.html
      end
  end
  
  def privacypolicy

      respond_to do |format|
        format.html
      end
  end

=begin  obsolete
  def addSynTags(thistag, thisrecipe)
    tags = Autotag.find_all_by_tags_id(thistag)
    tags.each do |tg|
        rt = Recipetags.find_or_create_by_tags_id_and_recipes_id(tg.autotag_id, thisrecipe)
    end
  end
=end

=begin  obsolete
  def autoTag(thisrecipe, tagtype)
    suggestedTags = Array.new
    
    if tagtype=="ing"
      onlyIngredients = 1
    else
      onlyIngredients = 0
    end
    
    tags = Tags.find(:all, :conditions => {:ingredient => onlyIngredients})
    rname = " " + thisrecipe.name.downcase + " "
    rname.gsub!(/[[:punct:]]/,' ') 
    tags.each do |tg|
      if tg.name != ""
        tgname = " "+ tg.name + " " 
        singlename = " "+ tg.name.singularize + " "  
        pluralname = " "+ tg.name.pluralize + " " 
        if (rname.include? tgname.downcase) || (rname.include? singlename.downcase) || (rname.include? pluralname.downcase) 
          suggestedTags << tg.name
          #addSynTags(tg.id, thisrecipe.id)
        end
      end
    end
    logger.debug('["'+suggestedTags.join('","')+'"]')
    return suggestedTags
  end
=end
   
  def browseTags
    @startswith = params[:startswith]  
       if !params[:tagtype].nil?
            #returns a string of the tags
            tags = findAllTagsbyTagType(params[:tagtype], @startswith)
            @searchTags = tags.split(";")
        end
        @tagtype = params[:tagtype]  
    render :partial => "browsetags"
  
  end
  
  
  def buildTagsbyCatArrays
     tags = Tag.find(:all)

     ing_tags = Array.new
     course_tags = Array.new
     dietary_tags = Array.new
     origin_tags = Array.new
     time_tags = Array.new
     meta_tags = Array.new

     
     tags.each do |tg|
       if tg.name != " "
         if tg.ingredient
           ing_tags << tg.name
         end
 #        if tg.dietary
#           dietary_tags << tg.name
#         end
         if tg.course
           course_tags << tg.name
         end
         if tg.origin
           origin_tags << tg.name
         end
         if tg.cooktime
           time_tags << tg.name
         end
         if tg.meta
           meta_tags << tg.name
         end
       end
   	end 
   	
   	#ing_tags.sort!
 #  	dietary_tags.sort!
   	course_tags.sort!
   	origin_tags.sort!
   	meta_tags.sort!

   	@ing_tags =  '["'+ing_tags.join('","')+'"]'
#   	@dietary_tags =  '["'+dietary_tags.join('","')+'"]'
    @course_tags =  '["'+course_tags.join('","')+'"]'
    @origin_tags =  '["'+origin_tags.join('","')+'"]'
    @time_tags =  '["'+time_tags.join('","')+'"]'
    @meta_tags = '["'+meta_tags.join('","')+'"]'

   end

   def byAuthorCookbooks

     if !params[:authorID].nil?
       @author = Author.find_by_id(params[:authorID])    
     else
       @author = Author.find_by_name(params[:author_name])
       
     end
  
     @indexedbooks = Array.new
     
     if !@author.nil?
       
       @authorname = @author.name
       cbs = Cookbook.find_all_by_author_id(@author.id)
       cbs.each do |cb|
         cbtitle = cb.title.gsub(/^(.{50}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
         cb_details = {
            :id => cb.id,
            :ISBN => cb.ISBN,
            :author => @author.name,
            :title => cbtitle
          }

          @indexedbooks << cb_details

          @indexedbooks = @indexedbooks.sort_by { |cookbook| cookbook[:title] }
        end
     else
      @authorname = params[:author_name]
      @possibleauthors = Author.find(:all,:conditions => ["name like ?", @authorname+"%"]) 
      if @possibleauthors.size == 0
        partname = @authorname[0,3]
        @possibleauthors = Author.find(:all,:conditions => ["name like ?", partname+"%"])         
      end 

     end
     respond_to do |format|
       format.html
     end
   end
   
   
   def byCookbookName

     @titlestring = params[:title]
     if @titlestring.nil?
       startsWith = "A"
     else
       startsWith = @titlestring[0,3]
     end
     
     startsWith = startsWith+"%"
     
     cbs = Cookbook.find(:all,:conditions => ["title like ?", startsWith]) 
    
     @indexedbooks = Array.new
     cbs.each do |cb|
       cbtitle = cb.title.gsub(/^(.{50}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
       cb_details = {
            :id => cb.id,
            :ISBN => cb.ISBN,
            :title => cbtitle
          }

       @indexedbooks << cb_details

       @indexedbooks = @indexedbooks.sort_by { |cookbook| cookbook[:title] }
     end
     respond_to do |format|
       format.html
     end
   end

  def cbResultLimit(thisRecipe, onlymine)
    
       if !thisRecipe.nil?
#PERF    This is still going to be slow, since we do SQL call for every recipe
#PERF    but since this isn't used yet I'm pushing off rewriting it

         #have to check each recipe (because they will come from different cookbooks) to see if the user owns them or not, if they have filtered the list
         showit = true
         if onlymine == "1"
                    
           showit = false
           ucb = Usercookbook.find_by_cookbook_id_and_user_id(thisRecipe.cookbook_id,current_user.id)
           
           showit = (ucb.owns) unless ucb.nil? 
         end
       else
         showit = false
       end
     return showit
  end

=begin  obsolete. was using this to copy all tags from one recipe to another on Suggested tag page but it is currently not in use.
 def copyRecipeTags
  recipeid = params[:id]
  copyfrom = params[:copyfrom]
  thisrecipe = Recipes.find_by_id(recipeid) 
  copyRecipe = Recipes.find_by_cookbooks_id_and_name(thisrecipe.cookbooks_id, copyfrom)
  
  addthese = Recipetags.find_all_by_recipes_id(copyRecipe.id)
  addthese.each do |tag|
     if !tag.tags.dietary
       
      if tag.tags.ingredient 
        rt = Recipetags.create()
        rt.tags_id = tag.tags_id
        rt.recipes_id = recipeid
        rt.amount = tag.amount
        rt.units_id = tag.units_id
      else
        rt = Recipetags.find_or_create_by_tags_id_and_recipes_id(tag.tags_id, recipeid)
      end
      rt.save
    end
  end 
  
  thisrecipe = Recipes.find_by_id(recipeid)
   @recipe = getRecipeTags(thisrecipe, "all")
   @cookbook = Cookbooks.find_by_id(@recipe[:cookbook])  
   @recipenotes = getRecipeNotes(thisrecipe)  
   @prevrecipe = getNextRecipe(thisrecipe,-1)
   @nextrecipe = getNextRecipe(thisrecipe,1)
   @units = Units.all   
   buildTagsbyCatArrays()
  
  render :partial => "recipe_details_form_tags"
  
 end
=end
 
 
 def cookbookshelf
   
     cbs = Recipe.find_by_sql "SELECT DISTINCT cookbook_id FROM recipes"
     @indexedbooks = Array.new
     cbs.each do |cb|
       cbtitle = cb.cookbook.title.gsub(/^(.{50}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
       cb_details = {
            :id => cb.cookbook_id,
            :ISBN => cb.cookbook.ISBN,
            :author => cb.cookbook.author.name,
            :title => cbtitle
          }
          
       @indexedbooks << cb_details
       
       @indexedbooks = @indexedbooks.sort_by { |cookbook| cookbook[:author] }
     end
     respond_to do |format|
       format.html
     end
 end
 
 
  def deleteRecipe
    
    # note to self. might want to change this so it isn't actually deleting the recipe, but just hiding it. That way, if you have a recipe that is linked to a bunch of other recipes and you delete it by mistake, you don't screw everything up. 
    @cookbook_id = params[:cookbooks_id]
    @cookbook = Cookbook.find_by_id(@cookbook_id)
    #cleanup our tags first
    Recipetags.delete_all(["recipe_id = ?", params[:id]])
    Relatedrecipes.delete_all(["recipe_id = ?", params[:id]])
    Relatedrecipes.delete_all(["required_recipe_id = ?", params[:id]])
    Recipes.delete(params[:id])
    #update our current recipeList
       
  end

=begin  
  def deleteTag
    thisrecipe = Recipes.find_by_id(params[:recipe_id])
    
    Recipetags.delete_all(["recipes_id = ? AND tags_id = ?", params[:recipe_id], params[:tags_id]])
    @recipe = getRecipeTags(thisrecipe, "all")
    @cookbook = Cookbooks.find_by_id(thisrecipe.cookbooks_id)
    
    #refresh the tag list in case it was a new one
    buildTagsbyCatArrays()
    @lastrecipediv = params[:lastrecipediv]
    @stayintag = params[:tagtype]
    
    render :partial => "recipetaglist"
 
  end
=end  
  
  def deleteCookbookDetailTag
    @cookbook = Cookbook.find_by_id(params[:cookbook_id])
    
    Cookbooktag.delete_all(["cookbook_id = ? AND tag_id = ?", params[:cookbook_id], params[:tags_id]])
    @cookbookTags = getCBTags(@cookbook)
    render :partial => "cookbook_details_tags"
 
  end
  
  def deleteRelatedRecipe
      thisrecipe = Recipe.find_by_id(params[:recipe_id])
      Relatedrecipe.delete_all(["recipe_id = ? AND required_recipe_id = ?", params[:recipe_id], params[:rrid]])
      recipeDetailFormPagePrep(thisrecipe)
      render :partial => "recipe_details_form_tags"
  end
  
  def deleteRecipeDetailTag
    thisrecipe = Recipe.find_by_id(params[:recipe_id])
    
    Recipetag.delete_all(["recipe_id = ? AND tag_id = ?", params[:recipe_id], params[:tags_id]])

    recipeDetailFormPagePrep(thisrecipe)

    @stayintag = params[:tagtype]
    @tagtype = @stayintag
    render :partial => "recipe_details_form_tags"
 
  end

  def editCookbook

    require 'amazon/ecs'  
    @userid = current_user.id if user_signed_in?
   
    if !params[:cookbookID].nil?
      @cookbook = Cookbook.find_by_id( params[:cookbookID], :include => [:recipes, :cookbooktags] )
    else
      @cookbook = Cookbook.find_by_title(params[:cookbook_title], :include => [:recipes, :cookbooktags] ) 
    end
 
    
    if !@cookbook.nil?
      @cookbookTags = getCBTags(@cookbook)
      
      lastdate= @cookbook.lastrating
      
      if lastdate.nil?
        timesince = 6
      else
        timesince = Date.now - lastdate
      end
      
      if timesince.to_i > 25
        begin
          res = Amazon::Ecs.item_lookup(@cookbook.ISBN, :IdType =>'ASIN', :response_group => 'Reviews' )
          res.items.each do |item|
             average_rating = item.get('/CustomerReviews/AverageRating') 
             if !average_rating.nil?
                @cookbook.rating = average_rating
                @cookbook.lastrating = Date.now
                @cookbook.save
             end
           end
        #just in case the Amazon service is giving us trouble
        rescue
             
        end
      end  #timesince

      if isNewUser(@userid) && params[:doneTutorial] != "1"
          redirect_to :action => :newUser, "cookbookid" => @cookbook.id
      else
      
        uc = Usercookbook.find_by_user_id_and_cookbook_id(@userid, @cookbook.id)
        if uc.nil?
          @setOwned = false
          @setWant = false
        else
          @setOwned = uc.owns
          @setWant = uc.wishlist
        end
        @selrecipeid = 1

        @recipes = Array.new
        @recipes = getAllRecipeTagsForCookbook(@cookbook)

        respond_to do |format|
          format.html
        end
      end #isNewUser && Params
    else
      title = params[:cookbook_title]
      redirect_to :action => :byCookbookName, "title" => title
     end #cookbooknil
    
  end
  
  def findAllTagsbyTagType(tagtype, starts)
    #returns a sorted array of tag names based on a particular type

    if !starts.nil?
      tags = Tag.all(:conditions => [ tagtype+" = ? AND name like ?", 1, "#{starts}%"])
    else
      tags = Tag.all(:conditions => [tagtype+"= ?", 1])
    end
    tagarray = Array.new
    tags.each do |tg|
      tagarray << tg.name.downcase
    end
    tagarray.sort!
    return tagarray.join(";")
  end



  def findRecipes
    #finds the recipes based on tag or words in the recipe title

     #params can be tagtype, othertags, gbtags, hidetags, signedin, onlymine
      # :tagtype - is used for returning a list of tags by type for browsing
      # :othertags - is used for passing in any current search terms (which assumes that this is a 2nd or later search term)
      # :gbtags - is the most recent search terms. It could be one tag, or it may not be an existing tag
      # :hidetags - 
      # :signedin - determines whether to show the find in my cookbooks or not (requires sign in)
      # :onlymine
      # :findVegan, findOvo, findGF - limit by dietary constraint

   	  #by default, we should show just the user's cookbooks if they are signed in
   	  if user_signed_in?
   	    #setting to 1 because we are returning to javascript on client
        @onlymine = "1"
      else
        @onlymine = false
      end 
      
      #default the checkboxes to unchecked (they'll be checked later, and set appropriately)
      @findVegan = "false"
      @findOvo = "false"
      @findGF = "false"
      
      
      @findVegan = (params[:findVegan] =="true")
      @findOvo = (params[:findOvo] =="true")
      @findGF = (params[:findGF] =="true")


            
  	 # if we have a specificed tag type, then we are browsing rather than searching. Just return a list of tags for that tagtype
      if !params[:tagtype].nil?
          alltags = findAllTagsbyTagType(params[:tagtype])
      else
  		  #else, we are searching
    		#unless :othertags and :gbtags are empty, add the othertags and gbtags togther to make a single string that we can iterate through later, 
    		#necessary so we have the appropriate ; delineation.
     		 alltags = params[:othertags] + ";" unless params[:othertags].nil?
    	   alltags = (alltags + params[:gbtags]) unless params[:gbtags].nil?
      end #!params[:tagtype].nil?
     	
  		#strip out the blanks
  	  alltags = alltags.strip unless alltags.nil?

  		# :hidetags is for something in the UI. Can't remember what right now.
  	    if params[:hidetags].nil?
  	        @hidetags = false
  	    else
  	        @hidetags = true
  	    end

  		# create the arrays for our recipeList (ids of recipes with the tags) and for the searchTags (for display in UI)
  	    @recipesList = Array.new
  	    @searchTags = Array.new

  
  		  #if we have sometags...
  	    if !alltags.nil?

  	       	@notag = false

  	       	#convert the tags string to the array
  	       	sTags = alltags.split(";")

  	       	#deal with the onlymine stuff
  	       	if user_signed_in?
  	        	#see if we are limiting to just owned cookbooks
  	        	@onlymine = params[:onlymine] unless params[:onlymine].nil?
  	       	end

  	 	  	# cycle through the array of search tags passed in 
  		  	# Try the tag string in lots of different ways to see if we can find a match to something in our tag table
  	     	# tagArray holds the tag ids (from the tags table) for the search strings passed in

  	    	tagArray = Array.new
  	 	  	tagArray = buildSearchTagArray(sTags)

  	      	if tagArray.length == 0
  	        	@notag = true
  	        	#need to add code to search in the title if there isn't a matching tag.
  	        	
  	      	else
  		  		  #if we have something to search for...
  	        	#build an array with each tag and its associated recipes
  	        	recipesWithTagList = Array.new

  	        	tagArray.each_with_index do |tg, i|
                   logger.debug(tg)
  	              # rtlist is an array of the recipes ids of recipes that have this tag
  					      # recipeids is an array of Recipetag records that match the tag id
  					      # tagwithrecipes is an array that has a tag id as the first item and an array of recipeids as the second item
  					      rtlist = Array.new
  		 			      recipeids = Array.new

  		            tagwithrecipes = Array.new
  		            tagwithrecipes << tg

  		            #find all the recipe ids for that tag... except limit it to 1000 results
  		            recipeids = Recipetag.find_all_by_tag_id(tg, :limit => 1000)
  	              #find all by title as well (in case it isn't tagged)
  					      rtlist = rtlist + FindbyTitle(tg)

  				      	#add the synonym tags for this tag (need to do this separately so we can find the best matches later)
        					synArray = Tagsynonym.find_all_by_tag_id(tg)
        				  synArray.each do |syn|
        						#append any results to the existing recipeids array
        						recipeids = recipeids + Recipetag.find_all_by_tag_id(syn.sameas_id, :limit => 1000)
        						rtlist = rtlist + FindbyTitle(syn.sameas_id)
        				  end 

        		   		#cycle through the list we've built of recipe ids to make sure we should be adding the recipe (and add it to rtlist)
        		      recipeids.each do |r|  			
    		                rtlist << r.recipe_id 
        		      end #each recipeids

    					    #make sure we have a unique set of recipes (since the recipe could be tagged with the search tag and a synonym)
    		          rtlist.uniq!
    		          
    		          #find all recipes that have these recipes as required recipes, and add those to the list too. Only for ingredients.
                  tag = Tag.find_by_id(tg)
                  if tag.ingredient
                    rrlist = Relatedrecipe.find(:all, :conditions => ["required_recipe_id IN (?)", rtlist]).map { |x| x.recipe_id }
                  
                  #append the required recipe list to rtlist
                    rtlist = rtlist + rrlist
                  end
                  rtlist.uniq!
                  
                  if @onlymine
                    recipe_results = Recipe.find(:all, :conditions => ["id IN (?)", rtlist])
                    haveCB = Array.new
                    recipe_results.each do |r|
                      #have to check each recipe (because they will come from different cookbooks) to see if the user owns them or not, if they have filtered the list
    		              if cbResultLimit(r, @onlymine)
    		                haveCB << r.id
    		              end
   		              end 
 		              
   		              rtlist = rtlist & haveCB
	                end
    		          
  		            tagwithrecipes << rtlist

        					#recipesWithTagList = [tagid, rtlist[]]
        					recipesWithTagList << tagwithrecipes
  		        end #each tagArray

  	    		#grab the recipe list for the first tag
  		        bestmatch = recipesWithTagList[0][1]
  		        recipesWithTagList.each_with_index do |rl, i|
  		            if recipesWithTagList.length >= i+1
  		            	#reduce the bestmatch set with the intersection of recipe list of this tag with the next tag. This will give us a list of only recipes that are in all tags.
  		           		bestmatch = bestmatch & rl[1]
  		            end
  		        end #end recipesWithTagList.each
  		        
  		        filter_conditions = ["id IN (?)"]
              filter_conditions[0] += " AND isVegan = ?" if @findVegan
              filter_conditions[0] += " AND isOvo = ?" if @findOvo
              filter_conditions[0] += " AND isGF = ?" if @findGF
              
              filter_conditions << bestmatch
              filter_conditions << 1 if @findVegan
              filter_conditions << 1 if @findOvo
              filter_conditions << 1 if @findGF


              bestmatch_recipes = Recipe.find(:all, :conditions => filter_conditions, :include => [:cookbook,:tags] , :order => :name)
              bestmatch_recipes.each do |recipe|
  					    #build our recipeList for the UI
  		            @recipesList << getRecipeInfo(recipe)
  		        end  #end bestmatch.each

  		        #need to build list of other tags too, these are grouped by each tag, with the bestmatch recipes removed
  		        @otherRecipes = Array.new

  		        recipesWithTagList.each do |rl|
  		            #remove the recipes we've already listed in bestmatch
  		            rl[1] = rl[1] - bestmatch
  		            if rl[1].length > 0
 		              rlist = Array.new
 		              
 		              filter_conditions = ["id IN (?)"]
                  filter_conditions[0] += " AND isVegan = ?" if @findVegan
                  filter_conditions[0] += " AND isOvo = ?" if @findOvo
                  filter_conditions[0] += " AND isGF = ?" if @findGF

                  filter_conditions << rl[1]
                  filter_conditions << 1 if @findVegan
                  filter_conditions << 1 if @findOvo
                  filter_conditions << 1 if @findGF

                  recipes = Recipe.find(:all, :conditions => filter_conditions, :include => [:cookbook, :tags], :order => :name)
                  recipes.each do |recipe|
  		              rlist << getRecipeInfo(recipe)
 		              end #each rl[1]

  		              innerArray = Array.new
  		              #tag
  		              innerArray << Tag.find_by_id(rl[0]).name
  		              #detailed list of recipes
  		              innerArray << rlist
  		              @otherRecipes << innerArray
  		            end
  		        end  #end recipesWithTagList.each

  			end  #end all tags > 0    
  		else
  		  @notag = true
  		end #alltags.nil?

    respond_to do |format|
        format.html
    end
  end


  def buildSearchTagArray(sTags)

    tagArray = Array.new
    

    sTags.each do |tg|
      if tg != ""
        sq = Searchqueries.find_or_create_by_querystring(tg)
        if !sq.nil?
          sq.count = sq.count + 1
          sq.save
        end
      end
      
  	 #unless the tg is blank (not sure why this would be, just a weird corner case)
       unless tg == ""      
  	   	#look for the singularlized version of the tag string
         	tag =  Tag.find_by_name(tg.singularize)
  		#if we don't find the singularized version, look for the version we have passed in
  		#why? sometimes singularize does stupid things (ie changes pasta to pastum). 
  	   	if tag.nil?
         		tag =  Tag.find_by_name(tg)  
        	end

          if !tag.nil?
      		# if we found a tag, put it in our tagArray array, so we can search recipetags 
           	# and searchTags so we can display the string we searched for in the UI
           	@searchTags << tg    
  	       	tagArray << tag.id
         	else
  			#if we haven't found anything, split the search string into multiple tags (ie, apple pie versus apple and pie)
           	multiTags = tg.split(" ")
           	multiTags.each_with_index do |mtg, i|
             		mtag =  Tag.find_by_name(mtg.singularize)
  			   	    if mtag.nil?
  	           		mtag =  Tag.find_by_name(mtg)  
  	          	end
             		if !mtag.nil?
               		@searchTags << mtg    
               		tagArray << mtag.id
             		else
  					      #if we still haven't found anything, add the next word if it exists (ie, chocolate chip cookies versus chocolate and chip versus chocolate chip)
               		if (multiTags.size > i+1)
                 			comboname = mtg + " " + multiTags[i+1]
                 			mtag = Tag.find_by_name(comboname.singularize)
  				   		      if mtag.nil?
  		           			  mtag =  Tag.find_by_name(comboname)  
  		          		  end
                 			if !mtag.nil?
                   			@searchTags << mtag.name    
                   			tagArray << mtag.id
                 			end
               		end
               		
             		end #!mtag.nil?
           	end #multiTags.each
         	end #!tag.nil?

  		#make sure we don't have duplicate tags
  	 	tagArray.uniq!
       end #unless tg = ""	
     end #end sTags.each

     return tagArray

  end #end def



  def FindbyTitle(tg)
  	rtlist = Array.new
  	#we check the title for the tag string too, just in case the recipe is not completely tagged
  	tagname = "%"+getTagName(tg)+"%"
  	logger.debug(tagname)
  	bytitle = Recipe.find(:all,:conditions => ["name like ?", tagname]) 
  	logger.debug(bytitle.size)
  	bytitle.each do |r|
  	  rtlist << r.id 
  	end #end bytitle
  	return rtlist
  end
  
  def getAllRecipeTagsForCookbook(cookbook)
  
      recipes = Array.new
      recipesList = Recipe.find_all_by_cookbook_id(cookbook.id, :order => :page)  

       recipesList = cookbook.recipes
       recipesList.each do |recipe|
         recipeInfo =  getRecipeTags(recipe, "all")
         recipes << recipeInfo
       end
       return recipes
  end
  
  
  def getRecipeInfo(thisRecipe)
    # thisRecipe = Recipe.find_by_id(recid)
     #now, build up the info we need for this recipe to list it properly
     if !thisRecipe.name.nil?
        recipename = thisRecipe.name.gsub(/^(.{30}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
      else
        recipename = ""
      end
     recipeInfo = {
     "recipeid" => thisRecipe.id,  
     "recipename"    =>  recipename,
     "cookbooktitle" =>  thisRecipe.cookbook.title.gsub(/^(.{30}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'},
     "cookbookid" =>  thisRecipe.cookbook_id,
     "cookbookpage"  =>  thisRecipe.page,
     "cookbookimg" => thisRecipe.cookbook.ISBN,
     "vegan" => thisRecipe.isVegan,
     "ovo" => thisRecipe.isOvo,
     "gf" => thisRecipe.isGF,
      }
     return recipeInfo
  end
  

  
  def getCBTags(cookbook)
    cookbookTags = Array.new
    cbtags = cookbook.cookbooktags

    cbtags.each do |cbtag|
      cookbookTags << {:tid => cbtag.tag_id, :name => cbtag.tag.name}
      cookbookTags = cookbookTags.sort_by { |tag| tag[:name] }
    end
     return cookbookTags
  end

  def getRecipeTags(recipe, tagtype)

    ingTags = Array.new
    dietTags =Array.new
    courseTags = Array.new
    metaTags = Array.new
    originTags = Array.new
    timeTags = Array.new
    relatedRecipes = Array.new
    cooktime = "0"
    isVegan = false
    isOvo = false
    isGF = false
    stickynote = false
    rating = 0
     
    if user_signed_in?
      rUser = recipe.userrecipes.select {|x| x.user_id == current_user.id}
      if !rUser.empty?
        stickynote = rUser[0].stickynote
        rating = rUser[0].rating
      end
    end
 
    rrecipes = recipe.relatedrecipes
    rrecipes.each do |rr|
      
      rrname = rr.required_recipe.name
      relatedRecipes << {:rrid => rr.required_recipe_id, :rrname => rrname, :isGF => rr.required_recipe.isGF, :isVegan => rr.required_recipe.isVegan, :isOvo => rr.required_recipe.isOvo }
    end
 
    rtags = recipe.recipetags
    rtags.each do |rtag|

      if rtag.tag.ingredient
        display_unit = ""
        if !rtag.unit.nil?
          display_unit = rtag.unit.unit
        end

        ingTags << {:tid => rtag.tag_id, :name => rtag.tag.name, :amt => rtag.amount, :unit => display_unit, :rt => rtag.id}
      end

      if rtag.tag.course
        courseTags << {:tid => rtag.tag_id, :name => rtag.tag.name}
      end

      if rtag.tag.cooktime
        timeTags << {:tid => rtag.tag_id, :name => rtag.tag.name}
        cooktime = "0"
        if rtag.tag.name.include? "quick"
          cooktime = "1"
        elsif rtag.tag.name.include? "average"
          cooktime = "2"
        elsif rtag.tag.name.include? "extended"
          cooktime = "3"
        end
      end

      if rtag.tag.meta
        metaTags << {:tid => rtag.tag_id, :name => rtag.tag.name}
      end

      if rtag.tag.origin
        originTags << {:tid => rtag.tag_id, :name => rtag.tag.name}
      end
    end
     
    #ingTags = ingTags.sort_by { |tag| tag[:name] }
    dietTags = dietTags.sort_by { |tag| tag[:name] }
    courseTags = courseTags.sort_by { |tag| tag[:name] }
    metaTags = metaTags.sort_by { |tag| tag[:name] }
    originTags = originTags.sort_by { |tag| tag[:name]}
     
    # logger.debug(tagtype)
    if tagtype != "all"
      if tagtype == "new_ing_tag"
        theseTags = ingTags
        logger.debug("ingredients")
      elsif tagtype == "new_course_tag"
        theseTags = courseTags
      elsif tagtype == "new_origin_tag"
         theseTags = originTags
      end
    else
      theseTags = ""
    end
      
    recipeInfo = {
      :cookbook=>recipe.cookbook_id,
      # :cookbooktitle => recipe.cookbook.title,   
      :name => recipe.name,
      :page => recipe.page, 
      :quantity => recipe.quantity,
      :id    =>  recipe.id,
      :ingTags =>  ingTags,
      :courseTags =>  courseTags,
      :dietTags  =>  dietTags,
      :isVegan  =>  recipe.isVegan,
      :isOvo  =>  recipe.isOvo || recipe.isVegan,
      :isGF  =>  recipe.isGF,
      :timeTags  =>  timeTags,
      :cookTime => cooktime,
      :metaTags  =>  metaTags,
      :originTags  =>  originTags,
      :relatedRecipes => relatedRecipes,
      :stickynote => stickynote,
      :rating => rating,
      :Tags => theseTags
    }
   
    return recipeInfo

  end
  
  def getRecipeNotes(thisrecipe)
  allNotes = Userrecipe.find_all_by_recipe_id(thisrecipe)
  
  myNotes = Array.new
  otherNotes = Array.new
  
  allNotes.each do |note|
    if note.user_id == current_user.id
        myNotes << note
    else
        otherNotes << note
    end
  end

  allNotes = {
    :myNotes => myNotes, 
    :otherNotes => otherNotes
  }
  
    return allNotes
  end


  def getTagName(tagid)
      return Tag.find_by_id(tagid).name
  end  
  
  def getNextRecipe(thisrecipe, direction)
     cbrecipes = Recipe.find(:all, :conditions => [ "cookbook_id = ?", thisrecipe.cookbook_id], :order => :page)

     x = cbrecipes.index(thisrecipe)

     nextrec = x + direction
     logger.debug(cbrecipes.length)
     logger.debug(nextrec)

     if nextrec > cbrecipes.length
        nextrec = 0 
     end

     return cbrecipes[nextrec]
   end
   
  
  def home
    @recentList = Array.new
    @recentcookbooks = Recipe.find(:all, :order=>"id DESC",  :group=>"cookbook_id", :limit=>8, :include => :cookbook)
    @recipecount = Recipe.count
    @cbcount = Cookbook.count 


    if user_signed_in?
    #setting to 1 because we are returning to javascript on client
      @onlymine = "1"
    else
      @onlymine = false
    end 


    @searchTags = Array.new
  
    @stayintag = true
    respond_to do |format|
      format.html
    end
  end


  def index
    redirect_to :action => :home
  end

 def isNewUser(userid)
  newUser = true
  if userid.nil?
    # ignore if we don't have a logged in user. They can't edit anyway.
    newUser = false
  else
    ur = User.find_by_id(userid)

    if !ur.nil?
      if ur.tutorial
        newUser = false 
      end
    end
  end
  return newUser
 end

=begin
  def isSDiet(tagname,recid)

    tagid = Tag.find_all_by_name(tagname)
    hastag = Recipetag.find_by_recipe_id_and_tag_id(recid,tagid)
    if hastag.nil?
      return false
    else
      return true
    end

    recid.tags.each do |rt|
      return true if rt.name == tagname
    end
    return false
 end
=end
 
 def listAuthors
     @items = Author.all(:conditions => ["name LIKE ?", params[:query].downcase + '%' ], 
                           :order => :name,
                           :select => :name)
     @items +=  Author.all(:conditions => ["name LIKE ?", '%' + params[:query].downcase + '%'],
                             :order => :name,
                             :select => :name)
     render :text => @items.collect { |x| x.name }.uniq.join("\n")   
 end  
 
 
  def listCookbooks
      @items = Cookbook.all(:conditions => ["title LIKE ?", params[:query].downcase + '%' ], 
                            :order => :title,
                            :select => :title)
      @items +=  Cookbook.all(:conditions => ["title LIKE ?", '%' + params[:query].downcase + '%'],
                              :order => :title,
                              :select => :title)
      render :text => @items.collect { |x| x.title }.uniq.join("\n")   
  end  

   

  def listTags
       @items = Tag.all(:conditions => ["name LIKE ?", params[:query].downcase + '%' ], 
                             :order => :name,
                             :select => :name)
       @items +=  Tag.all(:conditions => ["name LIKE ?", '%' + params[:query].downcase + '%'],
                               :order => :name,
                               :select => :name)
       render :text => @items.collect { |x| x.name }.uniq.join("\n")   
   end
   
 
   def listIngTags
        @items = Tag.all(:conditions => ["name LIKE ? && ingredient = ?", params[:query].downcase + '%', 1 ], 
                              :order => :name,
                              :select => :name)
        @items +=  Tag.all(:conditions => ["name LIKE ? && ingredient = ?", '%' + params[:query].downcase + '%', 1 ], 
                                :order => :name,
                                :select => :name)
        render :text => @items.collect { |x| x.name }.uniq.join("\n")   
    end
    
    def listCourseTags
         @items = Tag.all(:conditions => ["name LIKE ? and course = ?", params[:query].downcase + '%', 1 ], 
                               :order => :name,
                               :select => :name)
         @items +=  Tag.all(:conditions => ["name LIKE ? and course = ?", '%' + params[:query].downcase + '%', 1 ], 
                                 :order => :name,
                                 :select => :name)
         render :text => @items.collect { |x| x.name }.uniq.join("\n")   
     end

=begin     
     def listDietTags
          @items = Tag.all(:conditions => ["name LIKE ? and dietary = ?", params[:query].downcase + '%', 1 ], 
                                :order => :name,
                                :select => :name)
          @items +=  Tag.all(:conditions => ["name LIKE ? and dietary = ?", '%' + params[:query].downcase + '%', 1 ], 
                                  :order => :name,
                                  :select => :name)
          render :text => @items.collect { |x| x.name }.uniq.join("\n")   
      end
=end
      
      def listOriginTags
           @items = Tag.all(:conditions => ["name LIKE ? and origin = ?", params[:query].downcase + '%', 1 ], 
                                 :order => :name,
                                 :select => :name)
           @items +=  Tag.all(:conditions => ["name LIKE ? and origin = ?", '%' + params[:query].downcase + '%', 1 ], 
                                   :order => :name,
                                   :select => :name)
           render :text => @items.collect { |x| x.name }.uniq.join("\n")   
       end
      
      def listMetaTags
           @items = Tag.all(:conditions => ["name LIKE ? and meta = ?", params[:query].downcase + '%', 1 ], 
                                 :order => :name,
                                 :select => :name)
           @items +=  Tag.all(:conditions => ["name LIKE ? and meta = ?", '%' + params[:query].downcase + '%', 1 ], 
                                   :order => :name,
                                   :select => :name)
           render :text => @items.collect { |x| x.name }.uniq.join("\n")   
       end
    
       def listRecipes
          logger.debug(params[:cbid])
            @items = Recipe.all(:conditions => ["name LIKE ? and cookbook_id = ?", params[:query].downcase + '%', params[:cbid] ], 
                                  :order => :name,
                                  :select => :name)
            @items +=  Recipe.all(:conditions => ["name LIKE ? and cookbook_id = ?", '%' + params[:query].downcase + '%', params[:cbid]  ], 
                                    :order => :name,
                                    :select => :name)
            render :text => @items.collect { |x| x.name }.uniq.join("\n")   
        end
    
  def myStuff
    
    @userid = current_user.id

    if !@userid.nil?
      
      @myStuffList = Array.new
      
      users_cbs = Array.new
      users_stickies = Array.new
      
      numrecipes = Recipe.find(:all, :conditions => [ "user_id = ?", @userid]).length    
      ucbs = Usercookbook.find(:all, :conditions => [ "user_id = ? and owns=?", @userid, true])
      ucbs.each do |cookbook|
      cb = Cookbook.find(:first, :conditions => ["id = ?", cookbook.cookbook_id])
        
      cbtitle = cb.title.gsub(/^(.{50}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
        
      cb_details = {
          :id => cb.id,
          :ISBN => cb.ISBN,
          :title => cbtitle,
          :author => cb.author.name,
        }
        users_cbs << cb_details
      end
      
      ustks = Userrecipe.find(:all, :conditions => [ "user_id=? and stickynote=?", @userid, true])
      
      ustks.each do |recipe|
        r = Recipe.find(:first, :conditions => ["id = ?", recipe.recipe_id])
        if !r.nil?
        cbtitle = r.cookbook.title.gsub(/^(.{30}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
        r_details = {
          :id => r.id,
          :name => r.name,
          :page => r.page,
          :cookbookid => r.cookbook_id,
          :cookbook => cbtitle,
          :author => r.cookbook.author.name,
          :ISBN => r.cookbook.ISBN
        }
        users_stickies << r_details
       end
      end
      
      users_cbs = users_cbs.sort_by { |x| x[:author] }
      users_stickies = users_stickies.sort_by { |x| x[:cookbook] }
      
      @myStuffList = {
          :numrecipes => numrecipes,  
           :cookbooks => users_cbs,
           :stickies => users_stickies
      }
      
    end
  
    pp @userid
    respond_to do |format|
      format.html
    end
  end
  
def newUser
  
  @userid = current_user.id
  logger.debug(@userid)
  cookbookid = params[:cookbookid]
  if !@userid.nil?
    # Shouldn't need create here, since if we got here, there should be a user
    # ur = User.find_or_create_by_id(@userid)
    ur = User.find(@user_id)
    if !ur.nil?
      ur.tutorial = 1
      ur.save
    end
   if !cookbookid.nil?
     @cookbook = Cookbook.find_by_id(cookbookid)    
     logger.debug(@cookbook.title)
   end
  
    respond_to do |format|
      format.html
    end
  end
end
 
 
 def recipeDetails
   
     recid = params[:recid]
     
     if recid == ""
       #thisrecipe = Recipe.find_or_create()
       thisrecipe= Recipe.find_or_create_by_cookbook_id_and_name_and_page(params[:cookbook], nil,nil)
       thisrecipe.save
     else
      thisrecipe = Recipe.find_by_id(params[:recid])
     end 
     
      @recipe = getRecipeTags(thisrecipe, "all")
      @cookbook = Cookbook.find_by_id(@recipe[:cookbook])  
      @recipenotes = getRecipeNotes(thisrecipe)  
      @prevrecipe = getNextRecipe(thisrecipe,-1)
      @nextrecipe = getNextRecipe(thisrecipe,1)
      units = Unit.all
      @units = units.sort_by { |x| x["unit"] }
         
      buildTagsbyCatArrays()
   
   
    respond_to do |format|
      format.html
    end
  end
  
 def recipeDetailsForm
   
     recid = params[:recid]
     @userid = current_user.id
         
     if recid == ""
       thisrecipe= Recipe.find_or_create_by_cookbook_id_and_name_and_page(params[:cookbook], nil,nil)
       thisrecipe.user_id = @userid 
       thisrecipe.save
     else
      thisrecipe = Recipe.find_by_id(params[:recid])
     end 
     
      @recipe = getRecipeTags(thisrecipe, "all")
      @cookbook = Cookbook.find_by_id(@recipe[:cookbook])  
      @recipenotes = getRecipeNotes(thisrecipe)  
      @prevrecipe = getNextRecipe(thisrecipe,-1)
      @nextrecipe = getNextRecipe(thisrecipe,1)
      
      cookbookTags = getCBTags(@cookbook)
      cookbookTags.each do |tg|
        logger.debug("tag added")
        Recipetag.find_or_create_by_tag_id_and_recipe_id(tg[:tid], thisrecipe.id)
      end
      
      units = Unit.all
      @units = units.sort_by { |x| x["unit"] }
         
      buildTagsbyCatArrays()
   
      respond_to do |format|
        format.html
      end
  end
  
  def recipeDetailFormPagePrep(thisrecipe)
    @recipe = getRecipeTags(thisrecipe, "all")
    @cookbook = Cookbook.find_by_id(thisrecipe.cookbook_id)
    #refresh the tag list in case it was a new one
    buildTagsbyCatArrays()
    @units = Unit.all  
    @units = @units.sort_by { |x| x["unit"] }
    
  end
 
  def addRecipePhoto

    rp = RecipePhoto.new(params[:recipe_photo])

    if rp.photo.errors.empty?
      logger.info "I AM SUCCESSFUL?"
      rp.save
    else
      logger.info "ERRORS IN IMAGE UPLOAD"
    end

    redirect_to :action => :editCookbook, "cookbookID" => params[:cb_id]
  end
 
 
  def setSD
    recid = params[:recipe_id]
    tagname = params[:tag]
    ischecked = params[:sd]
    
    @userid = current_user.id
    
    
    tag = Tag.find_or_create_by_name(tagname.downcase.strip)
    
    if ischecked == "true"
      rt = Recipetag.find_or_create_by_tag_id_and_recipe_id(tag.id, recid)
    else
        Recipetag.delete_all(["recipe_id = ? AND tag_id = ?", recid, tag.id])
    end
    
    render :text => ""
    
  end
  
  def setOwned
    
    cookbook_id = params[:cookbook_id]
    
    @userid = current_user.id
    @setOwned = params[:own_it]
    
    ucb = Usercookbook.find_or_create_by_user_id_and_cookbook_id(@userid, cookbook_id)
    
    ucb.owns = (@setOwned=="true")
    ucb.save
    
    render :text => ""
    
  end
  
  
  def setWant
    
    cookbook_id = params[:cookbook_id]
    
    @userid = current_user.id
    @setWant = params[:want_it]
    
    ucb = Usercookbook.find_or_create_by_user_id_and_cookbook_id(@userid, cookbook_id)
    
    ucb.wishlist = (@setWant=="true")
    ucb.save
    
    render :text => ""
    
  end
    
    
=begin
  def set_facebook_user
    begin
      @facebook_session = session[:facebook_session]
      traperr = facebook_session.user.name
      thisuser = User.find_or_create_by_fb_id(facebook_session.user.id)
      session[:fbuser] =  session[:facebook_session].user
      session[:userid] = thisuser.id
      session[:signedin] = 'facebook'
      if thisuser.nickname.nil?
        thisuser.nickname = facebook_session.user.name
        thisuser.save
      end
      
    rescue StandardError=>exc
      reset_session
      session[:signedin] = false
    rescue Exception => exc2
      reset_session
      session[:signedin] = false
    end
    return true
  end
  
  def set_test_user
    session[:userid] = User.find(:first).id
    session[:signedin] = 'test'
    return true
  end
=end
    
 
  def showAllRecipes
    @cookbook_id = params[:id]
    @cookbook = Cookbook.find_by_id(@cookbook_id)
  
    @recipes = getAllRecipeTagsForCookbook(@cookbook)
 
    render :partial => "recipeslist"
  end



  def updateRecipeComments

    logger.debug(params[:recipe_comments])
    recipe = Userrecipe.find_or_create_by_recipe_id_and_user_id(params[:recipe_id], current_user.id)
    recipe.comments = params[:recipe_comments]
    recipe.save

   render :text => ""
  end
   
  def updateRecipeName

    recipe = Recipe.find_by_id(params[:recipe_id])
    oldrecipename = recipe.name
    recipe.name = params[:recipe_name]
    recipe.save

     @cookbookid = recipe.cookbook_id
     if !params[:lastrecipediv].nil?
       @lastrecipediv=  params[:lastrecipediv]
     end 
     @recipe= {:id => params[:recipe_id]}
     
     render :text => ""
    
  end
 
  def updateRecipePage

    recipe = Recipe.find_by_id(params[:recipe_id])
    recipe.page = params[:recipe_page]
    recipe.save

    @recipeid = recipe.id

    render :text => ""
   end
   
   def updateRecipeisVegan
      @isVegan = params[:isVegan]  
     recipe = Recipe.find_by_id(params[:recipe_id])    
     recipe.isVegan = (@isVegan=="true")
     #this is a little wonky because we aren't updating the UI, but if it isVegan it is also isOvo
     recipe.isOvo = (@isVegan=="true")
     recipe.save
     render :text => ""
    end
   
   def updateRecipeisOvo
      @isOvo = params[:isOvo]  
     recipe = Recipe.find_by_id(params[:recipe_id])    
     recipe.isOvo = (@isOvo=="true")
     recipe.save
     render :text => ""
    end
    
    def updateRecipeisGF
      @isGF = params[:isGF]  
      recipe = Recipe.find_by_id(params[:recipe_id]) 
      logger.debug(params[:recipe_id])   
      if !recipe.nil?
        recipe.isGF = (@isGF=="true")
        recipe.save
      end
      render :text => ""
     end
     
     
   def updateStickyNote

     recipeid = params[:id]
     
      @recipe = {
        :id    =>  recipeid,
        :stickynote => (params[:isOn] == 'true')
      }
     
      ur = Userrecipe.find_or_create_by_recipe_id_and_user_id(recipeid, current_user.id)
      ur.stickynote = params[:isOn]
      ur.save!
      render :partial => "stickynote", :locals => { :recipe => @recipe }
     
    end
    
    
     def updateRecipeRating

       recipeid = params[:id].to_i

       urate = params[:rating].to_i

       ur = Userrecipe.find_or_create_by_recipe_id_and_user_id(recipeid, current_user.id)

        ur.rating = urate
        ur.save!

       render :text => ""
      end
      
      def updateRecipeQuantity

        recipe = Recipe.find_by_id(params[:recipe_id])
         recipe.quantity = params[:recipe_qty]
         recipe.save

         @recipeid = recipe.id

         render :text => ""

       end

    def updateRelatedRecipes
      @stayintag = false
      
      thisrecipe = Recipe.find_by_id(params[:recipe_id])
      relatedrecipe = Recipe.find_by_name_and_cookbook_id(params[:related_name], thisrecipe.cookbook_id)
      Relatedrecipe.find_or_create_by_recipe_id_and_required_recipe_id(thisrecipe.id, relatedrecipe.id)
      
      recipeDetailFormPagePrep(thisrecipe)
              
      if params[:lastkey] != "9" 
          @stayintag = "new_related_recipe"
      end
       
      render :partial => "recipe_details_form_tags"
      
    end
    
    def updateIngAmounts
        rt = Recipetag.find_by_id(params[:recipetag_id])
        tagamount=params[:tagamount]
        tagunit=params[:tagunit]
    
        if tagunit != ""
          unit = Unit.find_or_create_by_id(tagunit)
          rt.unit_id = unit.id
        end
        
        rt.amount = params[:tagamount]
        rt.save
        
        render :text => ""    
    end
    

  def updateCookbookTags
    
    @cookbook = Cookbook.find_by_id(params[:cookbooks_id])
     newtag = params[:recipe_tag]
     
     @stayintag = true

     if !newtag.nil?
       if newtag.length > 1
         #logger.debug(newtag)
         tag = Tag.find_or_create_by_name(newtag.downcase.strip)
         ct = Cookbooktag.find_or_create_by_tag_id_and_cookbook_id(tag.id, @cookbook.id)
       end
      @cookbookTags = getCBTags(@cookbook)
        #refresh the tag list in case it was a new one
      end
      
      render :partial => "cookbook_details_tags"
      
  end

    def updateRecipeDetailTags
        thisrecipe = Recipe.find_by_id(params[:recipe_id])
        newtag = params[:recipe_tag]
        tagtype=params[:tagtype]
        tagamount=params[:tagamount]
        tagunit=params[:tagunit]
        
        basetag = newtag.downcase.strip
        @tagtype = tagtype
        @stayintag = false

        if !newtag.nil?
          if newtag.length > 1
            
            if tagtype != "new_ing_tag"
              tag = Tag.find_or_create_by_name(newtag.downcase.strip)
            else
              #need to make sure that we don't already have a different case of the tag (ie, egg versus eggs)
              tag = Tag.find_by_name(basetag)
              if tag.nil?
                tag = Tag.find_by_altname(basetag)
                if tag.nil?
                  tag = Tag.create()
                  tag.name = basetag.singularize
                  tag.altname = basetag.pluralize
                  tag.save
                end
              end
            end
            
            if !tagtype.nil?
              tag.ingredient = (tagtype=="new_ing_tag")
              tag.course = (tagtype=="new_course_tag")
              tag.origin = (tagtype=="new_origin_tag")
              tag.cooktime = (tagtype=="new_time_tag")

              tag.save

              if tagtype=="new_time_tag"
                timetags = Tag.find(:all, :conditions => { :cooktime => true})
                #if we are setting a time tag, we need to delete the old one for this recipe
                timetags.each do |timetag|
                Recipetag.delete_all(["recipe_id = ? AND tag_id = ?", params[:recipe_id], timetag.id])
              end
            end
          end

          if tagtype != "new_ing_tag"
              rt = Recipetag.find_or_create_by_tag_id_and_recipe_id(tag.id, thisrecipe.id)
          else
              #because ingredients can be listed more than once with different amounts
              rt = Recipetag.create()
              rt.tag_id = tag.id
              rt.recipe_id = thisrecipe.id
              rt.save
          end
          #addSynTags(tag.id, recipe.id)

          if !tagamount.nil?
            
            #just overwriting right now... need to make sure we are adding as appropriate. eek.
              rt.amount = tagamount
              if tagunit != ""
                unit = Unit.find_or_create_by_id(tagunit)
                rt.unit_id = unit.id
              end
              rt.save
          end

          recipeDetailFormPagePrep(thisrecipe)

          if params[:lastkey] != "9"
             if tagtype == "new_ing_tag"
                @stayintag = "new_ing_amt"
             else   
                @stayintag = tagtype
              end
            end
         end
        end

        render :partial => "recipe_details_form_tags"

       end

  def yuitest
      @all_tags=findAllTags()

    respond_to do |format|
      format.html
    end
  end

end
