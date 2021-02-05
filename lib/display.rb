class Display
    attr_accessor :hide_dealer

    def initialize(message="Welcome to Blackjack, Press Enter to begin", actions=[{"key": "Enter", "command": "Start Game"}])
        @width = 71
        @dealer_hand = nil
        @player_hand = nil
        @divider = "├" + ("─" *  @width) + "┤"
        @top = "┌" + ("─" *  @width) + "┐"
        @bottom = "└" + ("─" *  @width) + "┘"
        @card_top = "┌────┐"
        @card_bottom = "└────┘"
        @display = ""
        @hide_dealer = true
        draw_display(message, actions)
    end

    def draw_display(message, actions=[])
        @message = message
        @actions = actions
        Gem.win_platform? ? (system "cls") : (system "clear")
        header = self.build_header
        dealer = self.build_player_dealer_hand(@dealer_hand, "Dealer")
        player = self.build_player_dealer_hand(@player_hand, "Player")
        message = self.build_message
        action = self.build_action
        @display = header + dealer + player + message + action
        puts @display
    end

    def build_header()
        return @top + "\n" + self.center("BLACKJACK!") + "\n" + @divider + "\n"
        # return @top + "\n" + self.blank_rows(1) + @divider + "\n"
    end

    def build_player_dealer_hand(hand, player)
        if hand
            if player == 'Dealer' and @hide_dealer
                total = self.center("#{player} Showing: #{hand.dealer_showing}") + "\n"
            else
                total = self.center("#{player} Total: #{hand.card_total}") + "\n"
            end
            card_rows = self.build_cards(hand.cards, player)
            if hand.winner
                message = self.center("** #{player.upcase} WINS **") + "\n"
            elsif hand.bust
                message = self.center("** #{player.upcase} BUSTED **") + "\n"
            elsif hand.push
                message = self.center("** PUSH **") + "\n"
            else
                message = self.blank_rows(1)
            end
            if player == 'Dealer'
                return total + card_rows + message
            else
                return message + card_rows + total
            end
        else
            return self.blank_rows(5)
        end
    end

    def build_message()
        messages = @message.split("\n")
        message_line = ""
        if messages.length == 1
            messages.append("")
        end
        messages.each do |message|
            message_line += self.center(message) + "\n"
        end
        return @divider + "\n" + message_line
    end

    def build_action()
        if @actions.length == 1
            action_section = ''
            action_section += @divider + "\n"
            action_section += self.center("Press " + @actions[0][:key]) + "\n"
            action_section += self.center(@actions[0][:command]) + "\n"
            action_section += @bottom + "\n"
            return action_section
        elsif @actions.length == 2
            col1_key = "Press #{@actions[0][:key]}"
            col2_key = "Press #{@actions[1][:key]}"
            row1_middle_padding = " " * (@width - 2 - col1_key.length - col2_key.length)
            col1_command = "#{@actions[0][:command]}"
            col2_command = "#{@actions[1][:command]}"
            row2_middle_padding = " " * (@width - 2 - col1_command.length - col2_command.length)
            row1 = self.center(col1_key + row1_middle_padding + col2_key)
            row2 = self.center(col1_command + row2_middle_padding + col2_command)
            return @divider + "\n" + row1 + "\n" + row2 + "\n" + @bottom + "\n"
        else
            return @divider + "\n" + self.blank_rows(2) + @bottom + "\n"
        end
    end

    def add_hands(dealer_hand, player_hand)
        @player_hand = player_hand
        @dealer_hand = dealer_hand
    end

    def center(message, add_pipes=true, width=@width, strip=true)
        if strip
            message = message.strip
        end
        left_padding = " " * (((width - message.length) / 2.0).floor)
        right_padding = " " * (((width - message.length) / 2.0).ceil)
        if add_pipes
            return "│" + left_padding + message + right_padding + "│"
        end
        return left_padding + message + right_padding
    end

    def blank_rows(rows, add_pipes=true, width=@width)
        display_rows = ""
        1.upto(rows) do
            display_rows += center("", add_pipes, width) + "\n"
        end
        return display_rows
    end

    def build_cards(cards, player)
        top_row = self.center((@card_top + " ") * cards.length)
        center_row = ""
        cards.each_with_index do |card, index|
            if player == "Dealer" and @hide_dealer and index == 0
                center_row += "│ ** │ "
            else
                center_row += "│ #{card[:abbr]} │ "
            end
        end
        center_row = self.center(center_row)
        bottom_row = self.center((@card_bottom + " ") * cards.length)
        return top_row + "\n" + center_row + "\n" + bottom_row + "\n"
    end
end