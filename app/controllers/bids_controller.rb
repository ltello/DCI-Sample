class BidsController < ApplicationController
  before_filter :authenticate_user!

  def create
    Bidding.new(:bidder   => current_user,
                :biddable => Auction.find(params[:auction_id]),
                :request  => bid_params,
                :listener => self).bid
  end

  def buy
    auction = Auction.find(params[:auction_id])
    request = bid_params
    request.amount = auction.buy_it_now_price
    Bidding.new(:bidder   => current_user,
                :biddable => auction,
                :request  => request,
                :listener => self).bid
  end

  def create_on_success message
    flash[:notice] = message
    redirect_to auction_path(params[:auction_id])
  end

  def create_on_error errors
    flash[:error] = errors.join("\n")
    redirect_to auction_path(params[:auction_id])
  end

  private

  def bid_params
    p = {auction_id: params[:auction_id]}
    p.merge!(params[:bid_params]) if params[:bid_params]
    BidParams.new(p)
  end
end
