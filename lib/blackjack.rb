require_relative 'display.rb'

class Blackjack
    def initialize(shoe_size=6)
        @shoe = Shoe.new(shoe_size)
        @shoe_size = shoe_size
        @hit_stand_action = [{"key": "1", "command": "Hit"}, {"key": "0", "command": "Stand"}]
        @new_hand_action = [{"key": "Y", "command": "New Game"}, {"key": "Any Key", "command": "Exit"}]
        self.new_game
    end

    def new_game()
        Gem.win_platform? ? (system "cls") : (system "clear")
        @display = Display.new()
        gets
        self.fsm
    end
    
    def fsm()
        Gem.win_platform? ? (system "cls") : (system "clear")
        while true do
            @display.hide_dealer = true
            puts @display.hide_dealer
            restart = false
            input = 0
            self.deal
            print "Dealing"
            @display.add_hands(@dealer_hand, @player_hand)
            # @display.draw_display("Would you like to hit (1) or Stand (2)")
            while input != "0" do
                if @player_hand.bust
                    self.hand_over
                    restart = true
                    break
                end
                @display.draw_display("Would you like to Hit or Stand", @hit_stand_action)
                input = gets.strip
                if input == "1"
                    puts
                    self.hit(@player_hand)
                    @display.draw_display("Would you like to Hit or Stand", @hit_stand_action)
                elsif input == "0"
                    break
                end
            end
            next if restart
            @display.hide_dealer = false
            @display.draw_display("Dealer has #{@dealer_hand.card_total}")
            while @dealer_hand.card_total < 17
                sleep(3)
                self.hit(@dealer_hand)
                if not @dealer_hand.bust
                    @display.draw_display("Dealer has #{@dealer_hand.card_total}")
                    # sleep(3) if @dealer_hand.card_total < 17
                end
            end
            if @player_hand.bust
                @dealer_hand.winner = true
                @display.draw_display("Dealer Wins")
            elsif @dealer_hand.bust
                @player_hand.winner = true
                @display.draw_display("Player Wins")
            elsif @player_hand.card_total > @dealer_hand.card_total
                @player_hand.winner = true
                @display.draw_display("Player Wins")
            elsif @player_hand.card_total < @dealer_hand.card_total
                @dealer_hand.winner = true
                @display.draw_display("Dealer Wins")
            elsif @player_hand.card_total == @dealer_hand.card_total
                @dealer_hand.push = true
                @display.draw_display("Push")
            end
            sleep(2)
            self.hand_over
        end
    end

    def hand_over()
        @display.draw_display("Would you like to play another game?", @new_hand_action)
        input = gets.strip
        if input != "Y" and input != "y"
            puts "Thanks for playing"
            exit
        end
    end

    def deal()
        if @shoe.penetration_complete
            @shoe = Shoe.new(@shoe_size)
        end
        @dealer_hand = Hand.new(dealer=true)
        @player_hand = Hand.new()
        @shoe.burn_card
        @dealer_hand.add_card(@shoe.deal_card)
        @player_hand.add_card(@shoe.deal_card)
        @dealer_hand.add_card(@shoe.deal_card)
        @player_hand.add_card(@shoe.deal_card)
    end

    def hit(hand)
        if hand.dealer
            message = 'Dealer has'
        else
            message = 'You have'
        end
        hand.add_card(@shoe.deal_card)
        puts "#{message} been dealt: #{hand.cards[-1][:full_name]}"
        if hand.bust
            puts "#{message} Busted with #{hand.abbr_card_list} totaling: #{hand.card_total}"
        else
            puts "#{message} #{hand.card_total} with #{hand.abbr_card_list}"
        end
    end
end

class Shoe
    attr_reader :card_index, :shoe, :penetration_complete, :penetration_point

    def initialize(num_decks, debug=false)
        @card_index = {
            0 => {card: '2', suit: :clubs, suit_abbr: :C, full_name: '2 of Clubs', abbr: '2♣', value: 2},
            1 => {card: '3', suit: :clubs, suit_abbr: :C, full_name: '3 of Clubs', abbr: '3♣', value: 3},
            2 => {card: '4', suit: :clubs, suit_abbr: :C, full_name: '4 of Clubs', abbr: '4♣', value: 4},
            3 => {card: '5', suit: :clubs, suit_abbr: :C, full_name: '5 of Clubs', abbr: '5♣', value: 5},
            4 => {card: '6', suit: :clubs, suit_abbr: :C, full_name: '6 of Clubs', abbr: '6♣', value: 6},
            5 => {card: '7', suit: :clubs, suit_abbr: :C, full_name: '7 of Clubs', abbr: '7♣', value: 7},
            6 => {card: '8', suit: :clubs, suit_abbr: :C, full_name: '8 of Clubs', abbr: '8♣', value: 8},
            7 => {card: '9', suit: :clubs, suit_abbr: :C, full_name: '9 of Clubs', abbr: '9♣', value: 9},
            8 => {card: 'T', suit: :clubs, suit_abbr: :C, full_name: '10 of Clubs', abbr: 'T♣', value: 10},
            9 => {card: 'J', suit: :clubs, suit_abbr: :C, full_name: 'Jack of Clubs', abbr: 'J♣', value: 10},
            10 => {card: 'Q', suit: :clubs, suit_abbr: :C, full_name: 'Queen of Clubs', abbr: 'Q♣', value: 10},
            11 => {card: 'K', suit: :clubs, suit_abbr: :C, full_name: 'King of Clubs', abbr: 'K♣', value: 10},
            12 => {card: 'A', suit: :clubs, suit_abbr: :C, full_name: 'Ace of Clubs', abbr: 'A♣', value: 11},
            13 => {card: '2', suit: :diamonds, suit_abbr: :D, full_name: '2 of Diamonds', abbr: '2♦', value: 2},
            14 => {card: '3', suit: :diamonds, suit_abbr: :D, full_name: '3 of Diamonds', abbr: '3♦', value: 3},
            15 => {card: '4', suit: :diamonds, suit_abbr: :D, full_name: '4 of Diamonds', abbr: '4♦', value: 4},
            16 => {card: '5', suit: :diamonds, suit_abbr: :D, full_name: '5 of Diamonds', abbr: '5♦', value: 5},
            17 => {card: '6', suit: :diamonds, suit_abbr: :D, full_name: '6 of Diamonds', abbr: '6♦', value: 6},
            18 => {card: '7', suit: :diamonds, suit_abbr: :D, full_name: '7 of Diamonds', abbr: '7♦', value: 7},
            19 => {card: '8', suit: :diamonds, suit_abbr: :D, full_name: '8 of Diamonds', abbr: '8♦', value: 8},
            20 => {card: '9', suit: :diamonds, suit_abbr: :D, full_name: '9 of Diamonds', abbr: '9♦', value: 9},
            21 => {card: 'T', suit: :diamonds, suit_abbr: :D, full_name: '10 of Diamonds', abbr: 'T♦', value: 10},
            22 => {card: 'J', suit: :diamonds, suit_abbr: :D, full_name: 'Jack of Diamonds', abbr: 'J♦', value: 10},
            23 => {card: 'Q', suit: :diamonds, suit_abbr: :D, full_name: 'Queen of Diamonds', abbr: 'Q♦', value: 10},
            24 => {card: 'K', suit: :diamonds, suit_abbr: :D, full_name: 'King of Diamonds', abbr: 'K♦', value: 10},
            25 => {card: 'A', suit: :diamonds, suit_abbr: :D, full_name: 'Ace of Diamonds', abbr: 'A♦', value: 11},
            26 => {card: '2', suit: :spades, suit_abbr: :S, full_name: '2 of Spades', abbr: '2♠', value: 2},
            27 => {card: '3', suit: :spades, suit_abbr: :S, full_name: '3 of Spades', abbr: '3♠', value: 3},
            28 => {card: '4', suit: :spades, suit_abbr: :S, full_name: '4 of Spades', abbr: '4♠', value: 4},
            29 => {card: '5', suit: :spades, suit_abbr: :S, full_name: '5 of Spades', abbr: '5♠', value: 5},
            30 => {card: '6', suit: :spades, suit_abbr: :S, full_name: '6 of Spades', abbr: '6♠', value: 6},
            31 => {card: '7', suit: :spades, suit_abbr: :S, full_name: '7 of Spades', abbr: '7♠', value: 7},
            32 => {card: '8', suit: :spades, suit_abbr: :S, full_name: '8 of Spades', abbr: '8♠', value: 8},
            33 => {card: '9', suit: :spades, suit_abbr: :S, full_name: '9 of Spades', abbr: '9♠', value: 9},
            34 => {card: 'T', suit: :spades, suit_abbr: :S, full_name: '10 of Spades', abbr: 'T♠', value: 10},
            35 => {card: 'J', suit: :spades, suit_abbr: :S, full_name: 'Jack of Spades', abbr: 'J♠', value: 10},
            36 => {card: 'Q', suit: :spades, suit_abbr: :S, full_name: 'Queen of Spades', abbr: 'Q♠', value: 10},
            37 => {card: 'K', suit: :spades, suit_abbr: :S, full_name: 'King of Spades', abbr: 'K♠', value: 10},
            38 => {card: 'A', suit: :spades, suit_abbr: :S, full_name: 'Ace of Spades', abbr: 'A♠', value: 11},
            39 => {card: '2', suit: :hearts, suit_abbr: :H, full_name: '2 of Hearts', abbr: '2♥', value: 2},
            40 => {card: '3', suit: :hearts, suit_abbr: :H, full_name: '3 of Hearts', abbr: '3♥', value: 3},
            41 => {card: '4', suit: :hearts, suit_abbr: :H, full_name: '4 of Hearts', abbr: '4♥', value: 4},
            42 => {card: '5', suit: :hearts, suit_abbr: :H, full_name: '5 of Hearts', abbr: '5♥', value: 5},
            43 => {card: '6', suit: :hearts, suit_abbr: :H, full_name: '6 of Hearts', abbr: '6♥', value: 6},
            44 => {card: '7', suit: :hearts, suit_abbr: :H, full_name: '7 of Hearts', abbr: '7♥', value: 7},
            45 => {card: '8', suit: :hearts, suit_abbr: :H, full_name: '8 of Hearts', abbr: '8♥', value: 8},
            46 => {card: '9', suit: :hearts, suit_abbr: :H, full_name: '9 of Hearts', abbr: '9♥', value: 9},
            47 => {card: 'T', suit: :hearts, suit_abbr: :H, full_name: '10 of Hearts', abbr: 'T♥', value: 10},
            48 => {card: 'J', suit: :hearts, suit_abbr: :H, full_name: 'Jack of Hearts', abbr: 'J♥', value: 10},
            49 => {card: 'Q', suit: :hearts, suit_abbr: :H, full_name: 'Queen of Hearts', abbr: 'Q♥', value: 10},
            50 => {card: 'K', suit: :hearts, suit_abbr: :H, full_name: 'King of Hearts', abbr: 'K♥', value: 10},
            51 => {card: 'A', suit: :hearts, suit_abbr: :H, full_name: 'Ace of Hearts', abbr: 'A♥', value: 11}
        }
        @shoe = []
        @debug = debug
        @penetration_complete = false
        @penetration_point = 0
        num_decks.times do
            52.times { |card| @shoe.append card}
        end
        @shoe = @shoe.shuffle
        self.cut_shoe
        self.set_penetration
    end

    def deal_card()
        if @debug
            puts "Dealing Card"
            puts "Penetration Point: #{@penetration_point}"
            puts "Shoe Length after deal: #{@shoe.length() - 1}"
        end
        if @shoe.length() - 1 < @penetration_point
            @penetration_complete = true
        end
        @card_index[@shoe.pop]
    end
    
    def burn_card()
        self.deal_card()
        return nil
    end
    
    def cut_shoe()
        # pick a random number between 10 length of the shoe minus 10
        # this will be where we cut the shoe
        cut = rand(10..(@shoe.length - 10))
        @shoe = @shoe[cut..] + @shoe[0..cut - 1]
    end

    def set_penetration()
        random_penetration = rand(20..30) * 0.01
        @penetration_point = (@shoe.length() * random_penetration).round()
        if @debug
            puts "Penetration Point: #{@penetration_point}"
        end
    end

    def length()
        @shoe.length()
    end

    def need_new_shoe()
        @penetration_complete
    end
end


class Hand
    attr_reader :card_total, :dealer, :dealer_showing, :cards, :bust, :blackjack, :abbr_card_list
    attr_accessor :winner, :push

    def initialize(dealer=false)
        @card_total = 0
        @dealer = dealer
        @dealer_showing = 0
        @cards = []
        @bust = false
        @blackjack = false
        @abbr_card_list = ''
        @winner = false
        @push = false
    end

    def add_card(card)
        @cards.append(card)
        self.total_cards
        if @cards.length == 2
            @dealer_showing = card[:value]
            if @card_total == 21
                @blackjack = true
            end
        end
        @abbr_card_list += card[:abbr] + ' '
    end

    def total_cards()
        @card_total = 0
        @cards.each { |card| @card_total += card[:value]}
        if @card_total > 21
            @cards.each do |card|
                if card[:card] == 'A'
                    @card_total -= 10
                    if @card_total <= 21
                        break
                    end
                end
            end
        end
        if @card_total > 21
            @bust = true
        end
    end
end