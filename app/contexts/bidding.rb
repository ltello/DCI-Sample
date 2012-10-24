class Bidding < Context
  EXTENDING_INTERVAL = 30.minutes

  class ValidationException < Exception; end

  # Role definitions
    role :bidder do
      def last_bidder?
        biddable.last_bidder == self
      end
    end

    role :biddable do
      def last_bidder
        last_bid.user if last_bid
      end

      def create_bid
        bid = make_bid(bidder, request.amount)

        if purchasing?(bid)
          close_auction
          listener.create_on_success "Purchased successfully performed."
        elsif auction_must_be_extended?
          extend_auction
          listener.create_on_success "Your bid is accepted, and the auction has been extended for 30 minutes."
        else
          listener.create_on_success "Your bid is accepted."
        end
      end

      def purchasing?(bid)
        buy_it_now_price == bid.amount
      end

      def close_auction
        assign_winner bidder
      end

      def auction_must_be_extended?
        almost_closed = end_date - Time.now < EXTENDING_INTERVAL
        almost_closed and started?
      end

      def extend_auction
        extend_end_date_for EXTENDING_INTERVAL
      end
    end

    role :request do
      def validate
        validate_bidding_against_yourself
        validate_status
        validate_presence
        validate_against_last_bid
        validate_against_buy_it_now
      end

      private

        def validate_bidding_against_yourself
          raise ValidationException, "Bidding against yourself is not allowed." if bidder.last_bidder?
        end

        def validate_status
          raise ValidationException, "Bidding on closed auction is not allowed." unless biddable.started?
        end

        def validate_presence
          raise ValidationException, errors.full_messages.join(", ") unless valid?
        end

        def validate_against_last_bid
          last_bid = biddable.last_bid
          raise ValidationException, "The amount must be greater than the last bid." if last_bid && last_bid.amount >= amount
        end

        def validate_against_buy_it_now
          buy_it_now_price = biddable.buy_it_now_price
          raise ValidationException, "Bid cannot exceed the buy it now price." if amount > buy_it_now_price
        end
    end

    role :listener do
    end


  # Interactions
    def bid
      begin
        request.validate
        biddable.create_bid
      rescue InvalidRecordException => e
        listener.create_on_error e.errors
      rescue ValidationException => e
        listener.create_on_error [e.message]
      end
    end

end
