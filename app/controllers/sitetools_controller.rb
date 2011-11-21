
class SitetoolsController < ApplicationController
  helper :all # include all helpers, all the time
  require 'amazon/ecs'
  require 'open-uri'
  
  Amazon::Ecs.options = {:associate_tag => 'fullycomplete-20', :aWS_access_key_id => 'AKIAJDA6AQVK5KP7FTYQ', :aWS_secret_key => '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', :response_group => 'Medium', :operation => 'ItemLookup'}
 
    
  def index
    redirect_to :action => :home
  end

  def home
  end
  
  
  def addCookbook
    
     title = params[:cbtitle]
      isbn = params[:isbn]
    logger.debug(title.nil?)
        logger.debug(isbn)

      if !title.nil?
        res = Amazon::Ecs.item_search(title, :response_group => 'Medium', :search_index => 'Books', :browse_node=> '6')
        logger.debug("title lookup")
        logger.debug(title)

      else
        if !isbn.nil?
          logger.debug("isbn lookup")
          res = Amazon::Ecs.item_lookup(isbn, :IdType =>'ASIN', :response_group => 'Medium', :search_index => 'Books', :browse_node=> '6' )
          logger.debug(res.nil?)
          logger.debug(res.is_valid_request?)
        end
      end

      logger.debug(res.nil?)

      if !res.nil?
        
        #if it is a cookbook
        
       @added_cbs = Array.new
        
        res.items.each do |item|
      
          #logger.debug(item.get('asin'))
     
          # bnode = item.get('BrowseNodeId')
      
      
      
           
          #if (!bnode.nil?)
            
            #if (dd.to_i > 640 && dd.to_i < 642) || (dd.to_i > 617 && dd.to_i < 619)
           # if (bnode == "6")
              logger.debug(item.get('title'))
              logger.debug('isbn')
              
              logger.debug(item.get('isbn'))
              bookTitle = item.get('title')
              
              authors = item.get_array('author')
              if authors.length == 0
                author_name = "Not Available"
              else
                author_name = authors.join(';')
              end
              author = Author.find_or_create_by_name(author_name)

               #create a new cookbook record
              newBook = Cookbook.find_or_create_by_title_and_author_id(bookTitle, author.id)

              #get publisher id, and create if necessary
              publisherName = item.get('publisher')
              if newBook.publisher_id.nil?
                if !publisherName.nil?
                  storeNameAs = publisherName.gsub(/&amp|[[:punct:][:space:]]/,'')
                else
                  storeNameAs = "NA"
                  publisherName = "Not Available"
                end 
                publisher = Publisher.find_or_create_by_name(storeNameAs)
                if publisher.displayname.nil?
                  publisher.displayname = publisherName
                  publisher.save
                end if
                newBook.publisher_id = publisher.id
              end 

              #set the other fields
              if newBook.publicationdate.nil?
                newBook.publicationdate = item.get('publicationdate') unless item.get('publicationdate').nil?
              end
  
               if newBook.ISBN.nil?
                  newBook.ISBN = item.get('isbn') unless item.get('isbn').nil?
                  logger.debug('ISBN')
                  logger.debug(newBook.ISBN)
                  # books have up to 3 different images, this will get the largest image available.
                  # if you need width height, you can get that as well, but I couldn't decide if you did
                  # I would probably post process all of the images to make them all the same size...

                  image_url = item.get('smallimage/url') unless item.get('smallimage').nil?
                  image_url = item.get('mediumimage/url') unless item.get('mediumimage').nil?
                  #probably don't need the big one
                  # image_url = item.get('largeimage/url') unless item.get('largeimage').nil?
                  if !image_url.nil? && !newBook.ISBN.nil?
                    # this downloads the image, and saves it in the public/images directory as ISBN.jpg
                    img = open(image_url)
                    #f = File.open('public/images/covers/'+item.get('isbn')+'.jpg','w')
                    f = File.open('/var/www/sites/bookimages/'+newBook.ISBN+'.jpg','wb')
                    f.write(img.read)
                    f.close                 
                  end

                # if newBook.ISBN.nil? 
                end
            
                newBook.isvisible = true
                #newBook.relatedto = ""
                newBook.save

                cbtitle = newBook.title.gsub(/^(.{50}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}

                cb_details = {
                  :id => newBook.id,
                  :ISBN => newBook.ISBN,
                  :title => cbtitle,
                  :author => author_name
                }
            
                @added_cbs << cb_details
                    
          #end if a cookbook
         # end 
       # end
          
        # end res loop  
        end
        
      # end if res  
      end
      
      respond_to do |format|
        format.html
      end
  end
  
  
  def convertSDs
    
    sd = Tag.find_by_name("vegan")
    
    sdrecipes = Recipetag.find_all_by_tag_id(sd.id)
    sdrecipes.each do |sdr|
      r = Recipe.find_by_id(sdr.recipe_id)
      if !r.nil?
      r.isVegan = 1
      r.save
      end
    end
    
    sd = Tag.find_by_name("vegetarian")
    
    sdrecipes = Recipetag.find_all_by_tag_id(sd.id)
    sdrecipes.each do |sdr|
      r = Recipe.find_by_id(sdr.recipe_id)
      if !r.nil?
      r.isOvo = 1
      r.save
      end
    end
    
    sd = Tag.find_by_name("gluten free")
    
    sdrecipes = Recipetag.find_all_by_tag_id(sd.id)
    sdrecipes.each do |sdr|
      r = Recipe.find_by_id(sdr.recipe_id)
      if !r.nil?
      r.isGF = 1
      r.save
      end
    end
    redirect_to :action => :manageTags
    
  end
  
  
  
  def getRatings
    go = params[:go]
    
    if !go.nil?
    @numRatings = 0
    all_cbs = Cookbook.find(:all)
    
    all_cbs.each do |cookbook|
        res = Amazon::Ecs.item_lookup(cookbook.ISBN, :IdType =>'ASIN', :response_group => 'Reviews' )
        res.items.each do |item|
           average_rating = item.get('/CustomerReviews/AverageRating') 
                   logger.debug(average_rating)
           if !average_rating.nil?
              cookbook.rating = average_rating
              cookbook.save
              @numRatings = @numRatings + 1
           end
           
           if @numRatings.modulo(500).zero?
             #pause so we don't overwhelm the Amazon servers
             sleep(10)
           end
        end
    end
  end
      
      respond_to do |format|
        format.html
      end
  
  end
  
  def manageTags
    @selTag = params[:selTag]
    @sortorder = params[:sortorder]
    
   
    if !@sortorder.nil?
      if @sortorder == "alpha"
        @all_tags = Tag.find(:all, :order => "name")
      elsif @sortorder == "newest"
        @all_tags = Tag.find(:all, :order => "id DESC")
      elsif @sortorder == "ing"
        @all_tags = Tag.find(:all, :order => "name", :conditions => ["ingredient =?", 1])
      elsif @sortorder =="course"
        @all_tags = Tag.find(:all, :order => "name", :conditions => ["course =?", 1])
      elsif @sortorder == "origin"
        @all_tags = Tag.find(:all, :order => "name", :conditions => ["origin =?", 1])
      end
    else
      @all_tags = Tag.find(:all, :order => "name")
    end
    if @selTag.nil?
      #get the first tag if none is selected
      firstTag = @all_tags[0]
      
      @selTag = firstTag.id
    end
    
    respond_to do |format|
      format.html
    end
    
  end
  
  def getDetails
    tagid = params[:tagid]
    @tg = Tag.find_by_id(tagid)
    
    @tagSynonyms = getSynonymTags(tagid)
    @tagParents = getParentTags(tagid)
    @autoTags = getAutoTags(tagid)

     render :partial => "tagdetails"
    
  end
  
  def setTagName
    tagname = params[:tagname]
    tagid = params[:tagid]
    @tg = Tag.find_by_id(tagid)
    @tg.name = tagname
    @tg.save
    render :text => ""
  end
  
  def setTagAltName
    tagaltname = params[:tagaltname]
    tagid = params[:tagid]
    @tg = Tag.find_by_id(tagid)
    @tg.altname = tagaltname
    @tg.save
    render :text => ""
  end

  
  def setTagTypes
    tagid = params[:tagid]
    @tg = Tag.find_by_id(tagid)
    
    @tg.ingredient = (!params[:ing].nil?)
    @tg.course = (!params[:course].nil?)
    @tg.origin = (!params[:origin].nil?)    
    @tg.save
    
    render :text => ""
  end
  
  def setTagType
    tagid = params[:tagid]
    @tg = Tag.find_by_id(tagid)
     
     if !params[:ing].nil?
       @tg.ingredient = (params[:ing]=="1")
     end

     if !params[:course].nil?
       @tg.course = (params[:course]=="1")
     end
     
     if !params[:origin].nil?
       @tg.origin = (params[:origin]=="1")
     end

   @tg.save
    
    render :text => ""
  end
  
  
  def singularlizeTags
    all_tags = Tag.find(:all)
    all_tags.each do |tg|
      tg.name = tg.name.singularize
      tg.save
    end
    redirect_to :action => :manageTags
  end
  
  def pluralizeTags
    all_tags = Tag.find(:all)
    all_tags.each do |tg|

      if tg.ingredient
        logger.debug(tg.name)
        tg.altname = tg.name.pluralize
        logger.debug(tg.altname)
        tg.save
      end
    end
    redirect_to :action => :manageTags
  end
  
  
  def tagEditor
    page = params[:page].to_i
    @sortorder = params[:sortorder]
    
    logger.debug(@sortorder)
     
    if @sortorder.nil?
      @sortorder = "alpha"
    end
    
    if page.nil?
      page = 0
      @nextpage = 1
      @prevpage = 0
    else
      @nextpage = page + 1
      @prevpage = page - 1
      
      if @prevpage < 0
        @prevpage = 0
      end
      
    end
    
    if @sortorder == "alpha"
      @all_tags = Tag.find(:all, :order => "name", :limit => 50, :offset => (page*50))
    else
        @all_tags = Tag.find(:all, :order => "id DESC", :limit => 50, :offset => (page*50))
    end
    
    @tagSynonyms = Array.new
    @tagParents = Array.new
    @autoTags = Array.new
    @all_tags.each do |tg|
      @tagSynonyms[tg.id] = getSynonymTags(tg.id)
      @tagParents[tg.id] = getParentTags(tg.id)
      @autoTags[tg.id] = getAutoTags(tg.id)
    end
    @tagdropdown = setTagDropdown
    
    respond_to do |format|
      format.html
    end
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
    
   
   def listallTags
        @items = Tag.all(:conditions => ["name LIKE ?", params[:query].downcase + '%' ], 
                              :order => :name,
                              :select => :name)
        @items +=  Tag.all(:conditions => ["name LIKE ?", '%' + params[:query].downcase + '%'],
                                :order => :name,
                                :select => :name)
        render :text => @items.collect { |x| x.name }.join("\n")   
    end
   
   
  def findOrphans

    
    
  end
  
   
  
  def replaceTag
    @all_tags = Tag.find(:all, :order => "name")
    @tagdropdown = setTagDropdown
    
    respond_to do |format|
      format.html
    end
  
  end
  
  
  def replaceTags
    oldtag = params[:oldtag]
    newtag = params[:newtag]
    
    if !oldtag.nil? || !newtag.nil?
      ot = Tag.find_by_name(oldtag)
      nt = Tag.find_by_name(newtag)
      
      logger.debug(nt.id)
      logger.debug(ot.id)
      recswitholdtag = Recipetag.find_all_by_tag_id(ot.id)

      recswitholdtag.each do |r|
        r.tag_id = nt.id
        r.save
      end
      
      cookbookswitholdtag = Cookbooktag.find_all_by_tag_id(ot.id)
      cookbookswitholdtag.each do |cb|
        cb.tag_id = nt.id
        cb.save
      end
      
      synwitholdtag = Tagsynonym.find_all_by_tag_id(ot.id)
      synwitholdtag.each do |syn|
          syn.tag_id = nt.id
          syn.save
      end
          
      synwitholdtag = Tagsynonym.find_all_by_sameas_id(ot.id)
      synwitholdtag.each do |syn|
          syn.sameas_id = nt.id
          syn.save
      end
          
      synwitholdtag = Autotag.find_all_by_tag_id(ot.id)
      synwitholdtag.each do |syn|
          syn.tag_id = nt.id
          syn.save
      end
      
      synwitholdtag = Autotag.find_all_by_autotag_id(ot.id)
      synwitholdtag.each do |syn|
          syn.autotag_id = nt.id
          syn.save
      end
      
      Tag.delete_all(["id = ?", ot.id])
      
    end
    
    @selTag = nt.id
    redirect_to :action => :manageTags, :selTag => nt.id
    
  end
  
  
  def killbadTags
    recipes = Recipetag.find(:all)
    
    recipes.each do |r|
      if Tag.find_by_id(r.tag_id).nil?
            Recipetag.delete_all(["tag_id = ?", r.tag_id])
      end
    end
    
    
    cbs = Cookbooktag.find(:all)
    
    cbs.each do |cb|
      if Tag.find_by_id(cb.tag_id).nil?
            Cookbooktag.delete_all(["tag_id = ?", cb.tag_id])
      end
    end
  
    syns = Tagsynonym.find(:all)
    
    syns.each do |syn|
      thistag = syn.tag_id
      if Tag.find_by_id(thistag).nil?
            Tagsynonym.delete_all(["tag_id = ?", thistag])
            Tagsynonym.delete_all(["sameas_id = ?", thistag])
            Autotag.delete_all(["tag_id = ?"], thistag)
            Autotag.delete_all(["autotag_id = ?"], thistag)
      end
    end
    redirect_to :action => :tagEditor
  
    
  end
      
  def saveTags
    tagname = params[:tagname]
    tagid = params[:id]  
    tagIngredient = !params[:ingredient].nil?
    tagOrigin = !params[:origin].nil?
    tagCourse = !params[:course].nil?
        
    @tg = Tag.find_by_id(tagid)
    @tg.name = tagname.strip
    @tg.ingredient = tagIngredient
    @tg.course = tagCourse
    @tg.origin = tagOrigin
    @tg.save
    
    @gotosyn = false
    if !params["gbtag"+tagid].nil?
      syntag = Tag.find_or_create_by_name(params["gbtag"+tagid])   
      synname = syntag.name
      if synname != ""
        Tagsynonym.find_or_create_by_tag_id_and_sameas_id(@tg.id, syntag.id )
      end
      @gotosyn = true
      @gotoparentsyn = false
    end
    @tagSynonym = Array.new
    @tagSynonym[@tg.id] = getSynonymTags(@tg.id)
    
     if !params["parenttag"+tagid].nil?
       syntag = Tag.find_or_create_by_name(params["parenttag"+tagid])   
       synname = syntag.name
       if synname != ""
         #these are backwards because we are adding to the parent...
         Tagsynonym.find_or_create_by_sameas_id_and_tag_id(@tg.id, syntag.id )
       end
       @gotoparentsyn = true
       @gotosyn = false
     end
     @tagParents = Array.new
     @tagParents[@tg.id] = getParentTags(@tg.id)
  
    @all_tags = Tag.find(:all)
    @tagdropdown = setTagDropdown 
    
    render :partial => "tagline"
    
    #render :text => ""
    
  end 
  
  def deleteTag
    tagid = params[:id]
    logger.debug(tagid)
    Recipetag.delete_all(["tag_id = ?", tagid])
    Cookbooktag.delete_all(["tag_id = ?", tagid])
    Tagsynonym.delete_all(["tag_id = ?", tagid])
    Tagsynonym.delete_all(["sameas_id = ?", tagid])
    Autotag.delete_all(["tag_id = ?", tagid])
    Autotag.delete_all(["autotag_id = ?", tagid])
    Tag.delete_all(["id = ?", tagid])
    
    #top=Tag.first
    
    redirect_to :action => :manageTags

  end
  
  #for both parent and syn tags... the params will be passed in appropriately
  
  def removeSynTag
    syntag = Tag.find_by_name(params[:lookupname])
    if !syntag.nil?
      if params[:syntype] == "sameas"
        Tagsynonym.delete_all(["tag_id = ? AND sameas_id = ?", params[:tag_id], syntag.id])
      else
        Tagsynonym.delete_all(["sameas_id = ? AND tag_id = ?", params[:tag_id], syntag.id])    
      end
    end
    
    @tg = Tag.find_by_id(params[:tag_id])
        
    @tagSynonyms = getSynonymTags(@tg.id)
    @tagParents = getParentTags(@tg.id)
    @autoTags = getAutoTags(@tg.id)

     render :partial => "tagdetails"
  end
  
  
  def updateTagSyns
    syntag = Tag.find_or_create_by_name(params[:lookupname])   
    if !syntag.nil?
      if params[:syntype] == "sameas"
        Tagsynonym.find_or_create_by_tag_id_and_sameas_id(params[:tag_id], syntag.id)
      else
        Tagsynonym.find_or_create_by_tag_id_and_sameas_id(syntag.id, params[:tag_id])  
      end
    end
    
    @tg = Tag.find_by_id(params[:tag_id])
        
    @tagSynonyms = getSynonymTags(@tg.id)
    @tagParents = getParentTags(@tg.id)
    @autoTags = getAutoTags(@tg.id)
    @selField = params[:selField]

     render :partial => "tagdetails"
  end
  
  def deleteSynTag
    #depricate
    syntag = Tag.find_by_name(params[:syntag_name])
    if !syntag.nil?
      Tagsynonym.delete_all(["tag_id = ? AND sameas_id = ?", params[:tag_id], syntag.id])
    end
    
    @tg = Tag.find_by_id(params[:tag_id])
    
    @tagSynonyms = Array.new
    @tagParents = Array.new
    @autoTags = Array.new
        
    @tagSynonyms[@tg.id] = getSynonymTags(@tg.id)
    @tagParents[@tg.id] = getParentTags(@tg.id)
    @autoTags[@tg.id] = getAutoTags(@tg.id)

     @all_tags = Tag.find(:all)
     @tagdropdown = setTagDropdown 
    
     render :partial => "tagline"
  
  end
  
  def deleteParentTag
        #depricate
    syntag = Tag.find_by_name(params[:parenttag_name])
    if !syntag.nil?
      Tagsynonym.delete_all(["sameas_id = ? AND tag_id = ?", params[:tag_id], syntag.id])
    end
    
    @tg = Tag.find_by_id(params[:tag_id])
    
    @tagSynonyms = Array.new
    @tagParents = Array.new
    @autoTags = Array.new
        
    @tagSynonyms[@tg.id] = getSynonymTags(@tg.id)
    @tagParents[@tg.id] = getParentTags(@tg.id)
    @autoTags[@tg.id] = getAutoTags(@tg.id)

     @all_tags = Tag.find(:all)
     @tagdropdown = setTagDropdown 
    
    
      render :partial => "tagline"
  end
  
  
  def deleteAutoTag
        #depricate
    syntag = Tag.find_by_name(params[:autotag_name])
    if !syntag.nil?
      Autotag.delete_all(["tag_id = ? AND autotag_id = ?", params[:tag_id], syntag.id])
    end
    
    @tg = Tag.find_by_id(params[:tag_id])
    
    @tagSynonyms = Array.new
    @tagParents = Array.new
    @autoTags = Array.new
        
    @tagSynonyms[@tg.id] = getSynonymTags(@tg.id)
    @tagParents[@tg.id] = getParentTags(@tg.id)
    @autoTags[@tg.id] = getAutoTags(@tg.id)


     @all_tags = Tag.find(:all)
     @tagdropdown = setTagDropdown 
    
    
      render :partial => "tagline"
  end
  
  
  def getAutoTags(tagid)
    syntags = Array.new
    stags = Array.new
    stags = Autotag.find_all_by_tag_id(tagid)
    if !stags.nil?
      stags.each do |tg|
        unless tg.tag_id.nil?
          tag = Tag.find_by_id(tg.autotag_id)
          if !tag.nil?
            syntags << tag.name
          else
            syntags << tg.autotag_id.to_s()
          end
        end
      end
    end
    
    return syntags
  
  end

  def getParentTags(tagid)
    syntags = Array.new
    stags = Array.new
    stags = Tagsynonym.find_all_by_sameas_id(tagid)
    if !stags.nil?
      stags.each do |tg|
        logger.debug(tg.sameas_id)
        unless tg.tag_id.nil?
          tag = Tag.find_by_id(tg.tag_id)
          if !tag.nil?
            syntags << tag.name
          else
            syntags << tg.tag_id.to_s()
          end
        end
      end
    end
    
    return syntags
  
  end
  
  def getSynonymTags(tagid)
    syntags = Array.new
    stags = Array.new
    stags = Tagsynonym.find_all_by_tag_id(tagid)
    if !stags.nil?
      stags.each do |tg|
        logger.debug(tg.sameas_id)
        unless tg.sameas_id.nil?
          tag = Tag.find_by_id(tg.sameas_id)
          if !tag.nil?
            syntags << tag.name
          else
            syntags << tg.sameas_id.to_s()
          end
        end
      end
    end
    
    return syntags
  
  end
  
  
  def setTagDropdown
    tags = Tag.find(:all)

    all_tags= Array.new

    tags.each do |tg|
  			all_tags << tg.name
  	end 

  	return '["'+all_tags.join('","')+'"]'

  end
  
end
