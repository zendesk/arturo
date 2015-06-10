class BooksController < ApplicationController

  require_feature :books
  require_feature :book_holds, :only => :holds

  PLAIN_TEXT_RENDERER = (Rails::VERSION::MAJOR < 5 ? :text : :plain)

  # instead of a model:
  BOOKS = {}

  def show
    if (book = requested_book)
      render PLAIN_TEXT_RENDERER => book
    else
      render PLAIN_TEXT_RENDERER => 'Not Found', :status => 404
    end
  end

  def holds
    if (book = requested_book)
      render PLAIN_TEXT_RENDERER => "Added hold on #{book}"
    else
      render PLAIN_TEXT_RENDERER => 'Not Found', :status => 404
    end
  end

  protected

  def requested_book
    BOOKS[params[:id].to_s]
  end

  def current_user
    User.new(:name => "Fred")
  end

end
