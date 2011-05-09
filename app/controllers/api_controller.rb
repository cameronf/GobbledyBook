class ApiController < ApplicationController
  require 'pp'

# For now, set a test user, until we do the right login stuff
  before_filter :set_test_user

  def find_recipe_ingredients
    r_tags = Recipetag.find_all_by_recipe_id(params[:id], :include => [:tags, :units])

    recipe_detail = {}
    recipe_detail['id'] = params[:id]
    
    ingredients = []
    r_tags.each do |r_tag|
      unit = r_tag.units.nil? ? "" : r_tag.units.unit
      ingredients << {:id => r_tag.tag.id, :name => r_tag.tag.name, :unit => unit, :amount => r_tag.amount}
    end

    recipe_detail['ingredients'] = ingredients

    respond_to do |format|
      format.json { render :json => recipe_detail.to_json }
    end
  end

  def find_recipe
    direct_match = Tag.find(:all, :conditions => ["name LIKE ? and ingredient=1", '%' + params[:ingredient] + '%'])

    r_tags = Recipetag.find(:all, :conditions => ["tag_id IN (?)", direct_match.map {|x| x.id}], :group => "recipe_id", :include => [ :recipes, {:recipes => {:cookbooks => :authors}}])

    recipes = []
    r_tags.each do |r_tag|
      # For some reason in dev there is a tag that isn't associated with any recipes
      if !r_tag.recipes.nil?
        recipes << {:id => r_tag.recipes_id, :title => r_tag.recipes.name, :image_isbn => r_tag.recipes.cookbooks.ISBN, :cookbook_title => r_tag.recipes.cookbooks.title, :cookbook_author => r_tag.recipes.cookbooks.authors.name, :pagenum => r_tag.recipes.page }
      end
    end

    respond_to do |format|
      format.json { render :json => recipes.to_json }
    end
    
  end
  
  
end
