class ClosingExpiredAuctions < Context

  # Role definitions

    role :expirable_auctions do
      def close_those_expired
        each(&:close_if_expired)
      end
    end

  # Interactions
    def close
      expirable_auctions.close_those_expired
    end

end
