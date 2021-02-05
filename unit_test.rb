require_relative 'lib/blackjack.rb'
require "test/unit/assertions"
include Test::Unit::Assertions

# Test Set 1: Deck length
puts "Testing Deck Lengths"
1.upto(10) do |num_decks|
    shoe = Shoe.new(num_decks)
    assert_equal num_decks * 52, shoe.length, "Incorrect Length of shoe, expecting: #{num_decks * 52} got: #{shoe.length()}"
end
puts "Test Set 1 complete"

# Test Set 2: Dealing and Penetration
puts "Testing Deck Dealing and Penetration points"
1.upto(10) do |num_decks|
    shoe = Shoe.new(num_decks)
    max_penetration = ((num_decks * 52) * 0.81).round
    min_penetration = ((num_decks * 52) * 0.69).round
    1.upto(max_penetration) do |cards|
        shoe.deal_card
        if cards < min_penetration
            assert_equal false, shoe.need_new_shoe, "Should not need new shoe until at least #{max_penetration} cards dealt"
        end
    end
    assert_equal true, shoe.need_new_shoe, "Should need new shoe after #{max_penetration} cards dealt"
end
puts "Test Set 2 complete"

# Test Set 3: Shuffle
puts "Testing that shuffle and cut are working"
1.upto(10) do |num_decks|
    shoe = Shoe.new(num_decks)
    test_shoe = []
    (52 * num_decks).times { test_shoe.append(shoe.deal_card) }
    assert_equal test_shoe.length, ([*0..51] * num_decks).length, "Something wrong with test case, shoe sizes not equal"
    assert_equal false, test_shoe == [*0..51] * num_decks, "Doesn't appear shoe was shuffled correctly"
end
puts "Test Set 3 complete"


# Test Set 4: Blackjack
# take all possible combinations of 10 and Ace and validate they add up appropriately
puts "Testing Blackjacks"
shoe = Shoe.new(3)
tens = [8, 9, 10, 11, 21, 22, 23, 24, 34, 35, 36, 37, 47, 48, 49, 50]
aces = [12, 25, 38, 51]
combos = tens.product(aces) + aces.product(tens)
combos.each do |combo|
    hand = Hand.new()
    hand.add_card(shoe.card_index[combo[0]])
    hand.add_card(shoe.card_index[combo[1]])

    assert_equal 21, hand.card_total, "Expected hand to total 21, cards: #{combo}"
    assert_equal true, hand.blackjack, "Expected blackjack to be true"
    assert_equal false, hand.bust, "Expected bust to be false"
end
puts "Test Set 4 complete"


# Test Set 5: Hand Addition without Aces
puts "Testing Hand addition without Aces"
# shoe = Shoe.new(3)
cards = [*0..11] + [*13..24] + [*26..37] + [*39..50]
combos = cards.product(cards)
combos += cards.product(cards, cards).sample(1000)
combos += cards.product(cards, cards, cards).sample(1000)
combos += cards.product(cards.sample(10), cards.sample(10), cards.sample(10), cards.sample(10)).sample(1000)
combos += cards.product(cards.sample(10), cards.sample(10), cards.sample(10), cards.sample(10), cards.sample(10)).sample(1000)
combos += cards.product(cards.sample(5), cards.sample(5), cards.sample(5), cards.sample(5), cards.sample(5), cards.sample(5)).sample(1000)
puts "Length of combos #{combos.length}"

combos.each do |combo|
    hand = Hand.new()
    hand_value = 0
    blackjack = false
    bust = false
    combo.each do |card|
        hand.add_card(shoe.card_index[card])
        hand_value += shoe.card_index[card][:value]
        if hand_value > 21
            bust = true
        end
    end

    assert_equal hand_value, hand.card_total, "Expected hand to total #{hand_value}, cards: #{combo}"
    assert_equal false, hand.blackjack, "Expected blackjack to be false, cards: #{combo}"
    assert_equal bust, hand.bust, "Expected bust to be false, cards: #{combo}"
end
puts "Test Set 5 complete"
