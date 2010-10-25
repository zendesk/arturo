class BooksController < ApplicationController

  require_feature :books
  require_feature :book_holds, :only => :holds

  # instead of a model:
  BOOKS = {}

  def show
    if (book = requested_book)
      render :text => book
    else
      render :text => 'Not Found', :status => 404
    end
  end

  def holds
    if (book = requested_book)
      render :text => "Added hold on #{book}"
    else
      render :text => 'Not Found', :status => 404
    end
  end

  protected

  def requested_book
    BOOKS[params[:id].to_s]
  end

  def current_user
    "Fred"
  end

end
