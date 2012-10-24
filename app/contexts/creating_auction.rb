class CreatingAuction < Context

  # Role definitions

    role :seller do
      def start_auction
        auction = auction_creator.create_auction(self)
        auction.start
        auction
      end
    end

    role :auction_creator do
      def create_auction(seller)
        Auction.make creation_attributes(create_item, seller)
      end

      private

        def creation_attributes(item, seller)
          basic_attrs = attributes.slice(:buy_it_now_price, :extendable, :end_date)
          basic_attrs.merge(item: item, seller: seller)
        end

        def create_item
          Item.make(item_name, item_description)
        end
    end

    role :listener do
    end

  def run
    begin
      auction = seller.start_auction
      listener.create_on_success(auction.id)
    rescue InvalidRecordException => e
      listener.create_on_error(e.errors)
    end
  end

end
