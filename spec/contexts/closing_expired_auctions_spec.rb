require 'model_spec_helper'

describe ClosingExpiredAuctions do
  context "expired auction" do
    let(:bidder){stub("Bidder")}
    let(:bid){stub(user: bidder)}

    it "closes an auction if its end date is in the past and it's started" do
      auction = expired_auction
      auction.bids = nil
      auction.should_receive(:close)
      ClosingExpiredAuctions.new(:expirable_auctions => [auction]).close
    end

    it "assigns a winner when auction has a bid" do
      auction = expired_auction
      auction.bids << bid
      auction.should_receive(:assign_winner).with(bidder)
      ClosingExpiredAuctions.new(:expirable_auctions => [auction]).close
    end
  end

  context "not expired auction" do
    it "doesn't close an auction if its end date is in the future" do
      auction = expired_auction(end_date: DateTime.current + 1.day, status: 'started')
      ClosingExpiredAuctions.new(:expirable_auctions => [auction]).close
    end

    it "doesn't close an auction if it's not started" do
      auction = expired_auction(end_date: DateTime.current - 1.day, status: 'pending')
      ClosingExpiredAuctions.new(:expirable_auctions => [auction]).close
    end
  end

  private

  def expired_auction attrs = {}
    params = {seller: ObjectMother.create_user, item: Item.create, buy_it_now_price: 10, extendable: true, end_date: (DateTime.current - 1.day), status: 'started'}
    Auction.make params.merge(attrs)
  end
end
