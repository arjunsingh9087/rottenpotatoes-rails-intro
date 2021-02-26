class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    session[:ratings] ||= @all_ratings
    
    #session[:sort] = params[:sort] unless params[:sort].nil?
    
    if params.has_key?('commit') && !params.has_key?('ratings') 
      params['ratings'] = @all_ratings
    end

    if params.has_key?('ratings')       
      session[:ratings] = params[:ratings]
    end
    
    if params.has_key? :sort
      session[:sort] = params[:sort]
    end
    
    if session[:ratings] == @all_ratings
      @movies = Movie.with_ratings(session[:ratings]).order(params[:sort])
      @ratings_to_show = []
      @sort_order = params[:sort]
    else
      #@sort_order = session[:sort]
      @movies = Movie.with_ratings(session[:ratings].keys).order(session[:sort])
      @ratings_to_show = session["ratings"]
      @sort_order = session[:sort]
    end
    
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
