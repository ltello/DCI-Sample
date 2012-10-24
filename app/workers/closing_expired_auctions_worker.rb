class ClosingExpiredAuctionsWorker
  include Sidekiq::Worker

  def perform
    Auction.find_in_batches do |auctions|
      ClosingExpiredAuctions.new(:expirable_auctions => auctions).close
    end
  end
end
