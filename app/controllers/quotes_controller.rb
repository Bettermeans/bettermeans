class QuotesController < ApplicationController
  ssl_required :all

  def index # spec_me cover_me heckle_me
    @quotes = Quote.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @quotes }
    end
  end

  def show # spec_me cover_me heckle_me
    @quote = Quote.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @quote }
    end
  end

  def new # spec_me cover_me heckle_me
    @quote = Quote.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @quote }
    end
  end

  def edit # spec_me cover_me heckle_me
    @quote = Quote.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
    @quote = Quote.new(params[:quote])
    @quote.user_id = User.current.id

    respond_to do |format|
      if @quote.save
        flash.now[:success] = 'Quote was successfully created.'
        format.html { redirect_to(@quote) }
        format.xml  { render :xml => @quote, :status => :created, :location => @quote }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    @quote = Quote.find(params[:id])

    respond_to do |format|
      if @quote.update_attributes(params[:quote])
        flash.now[:success] = 'Quote was successfully updated.'
        format.html { redirect_to(@quote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @quote = Quote.find(params[:id])
    @quote.destroy

    respond_to do |format|
      format.html { redirect_to(quotes_url) }
      format.xml  { head :ok }
    end
  end
end
