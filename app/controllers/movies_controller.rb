class MoviesController < ApplicationController
  $count = 0
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if ($count == 0)
      session.clear
      $count += 1
    end
    
    @all_ratings = Movie.all_ratings
    @ratings_to_show = []
    @sort_by = ""
    redirect = false
    
    if (params[:sort] != nil) # first detect whether view passes new :sort params 
      @sort_by = params[:sort]
      session[:sort] = @sort_by
    elsif (session[:sort] != nil) # if no new :sort, check saved :sort status
      @sort_by = session[:sort]
      redirect = true
    else
      @sort_by = nil
    end
    
    if (@sort_by == 'title')
      @Movie_Title_CSS = 'hilite'
    elsif (@sort_by == 'release_date')
      @Release_Date_CSS = 'hilite'
    end
    
    if (params[:ratings] != nil) # similar to check :sort above 
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
#       @movies = Movie.with_ratings(@ratings_to_show).order(@sort_by)
    elsif (session[:ratings] != nil)
      if (redirect) 
        @ratings_to_show = session[:ratings]
        redirect = true
      else
        @ratings_to_show = []
        session[:ratings] = @ratings_to_show
      end
#     else
#       @movies = Movie.all.order(@sort_by)
    end
    
    if (redirect)
      redirect_to movies_path(sort: @sort_by, ratings: Hash[@ratings_to_show.collect{ |item| [item, 1]}])
    else
      return @movies = Movie.with_ratings(@ratings_to_show).order(@sort_by)    
    end
  
#     @movies = Movie.all
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
