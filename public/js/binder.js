(function(module){

    var store = Module("store");
    var visual = Module("visual");
    var user_slug = null;
    var binder = null;

    multiples_ok = visual.multiples_ok;
    str_format = visual.str_format;
    format_price = visual.format_price;

    function load_update_data(data_str){
        var data = JSON.parse(data_str);
        var cards = data.cards;
        for (card_name in cards){
            var new_card = cards[card_name];
            if (card_name in binder.cards){
                var old_card = binder.cards[card_name];
                new_card.maindeck_swap = old_card.maindeck_swap;
                new_card.sideboard_swap = old_card.sideboard_swap;
            }
            binder.cards[card_name] = new_card;
        }
        if ('user' in data){
            binder.user = data.user;
        }
        draw();
    }

    function init(data){
        binder = data;
        user_slug = binder.user.slug;
        var cards = binder.cards;
        for (card_name in cards){
            var card = cards[card_name];
            card.maindeck_swap = 0;
            card.sideboard_swap = 0;
        }
        draw();
    }
    module.init = init;

    function add_card_to_sideboard(new_card_name){
        if (!(new_card_name in binder.cards)){
            var new_card = {};
            new_card.name = new_card_name;
            new_card.sideboard = 0;
            new_card.maindeck = 0;
            new_card.sideboard_swap = 0;
            new_card.maindeck_swap = 0;
            binder.cards[new_card_name] = new_card;
        }
        var card = binder.cards[new_card_name];
        if ("maindeck" in card && card.maindeck > 0 && !multiples_ok(card)){
            alert("cannot add card already in deck");
            return;
        }
        increment_card_sideboard(card);
    }
    module.add_card_to_sideboard = add_card_to_sideboard;

    function decrement_card_sideboard(card){
        if (card.sideboard > 0){
            card.sideboard -= 1;
            if (card.sideboard_swap > card.sideboard){
                decrement_card_sideboard_swap(card);
            }
            store.create_statuses(user_slug, [card], load_update_data);
        }
    }

    function increment_card_sideboard(card){
        if (card.sideboard == 0 || multiples_ok(card)){
            card.sideboard += 1;
            store.create_statuses(user_slug, [card], load_update_data);
        }
    }

    function decrement_card_sideboard_swap(card){
        card.sideboard_swap -= 1;
    }

    function decrement_card_maindeck_swap(card){
        card.maindeck_swap -= 1;
    }

    function swap_from_maindeck(card){
        if (card.maindeck_swap < card.maindeck){
            card.maindeck_swap += 1;
        }
    }

    function swap_from_sideboard(card){
        if (card.sideboard_swap < card.sideboard){
            card.sideboard_swap += 1;
        }
    }

    function is_legal_swap(){
        var num_from_deck = 0;
        var num_from_side = 0;
        var total_price = 0;
        for (var key in binder.cards){
            var card = binder.cards[key];
            num_from_deck += card.maindeck_swap;
            num_from_side += card.sideboard_swap;
            if (card.maindeck_swap > 0 && card.sideboard_swap > 0){
                alert('cannot swap with a card in both maindeck and sideboard');
                return false;
            }
            if (card.sideboard_swap > 0){
                total_price += card.price * card.sideboard_swap;
            }
        }
        return (
            num_from_deck > 0 &&
            num_from_deck == num_from_side &&
            total_price <= binder.user.balance
        );
    }

    function swap_cards(){
        if (!is_legal_swap()){
            alert("cant swap. check the cost and ensure same # of cards");
            return;
        }

        var to_swap = []
        for (var key in binder.cards){
            var card = binder.cards[key];
            if (card.maindeck_swap > 0 || card.sideboard_swap > 0){
                card.maindeck -= card.maindeck_swap;
                card.maindeck += card.sideboard_swap;
                card.sideboard += card.maindeck_swap;
                card.sideboard -= card.sideboard_swap;
                card.maindeck_swap = 0;
                card.sideboard_swap = 0;
                to_swap.push(card);
            }
        }
        store.create_statuses(user_slug, to_swap, load_update_data);
    }
    module.swap_cards = swap_cards;

    var SWAP_FROM_SIDEBOARD = '<input type="button" class="action" data-func="swap_from_sideboard" value="<<"/>';
    var SWAP_FROM_MAINDECK = '<input type="button" class="action" data-func="swap_from_maindeck" value=">>"/>';
    var DELETE_SIDEBOARD = '<input type="button" class="action" data-func="delete_sideboard" value="-"/>';
    var DELETE_MAINDECK_SWAP = '<input type="button" class="action" data-func="delete_maindeck_swap" value="-"/>';
    var DELETE_SIDEBOARD_SWAP = '<input type="button" class="action" data-func="delete_sideboard_swap" value="-"/>';

    var card_actions = {
        "swap_from_maindeck": swap_from_maindeck,
        "swap_from_sideboard": swap_from_sideboard,
        "delete_maindeck_swap": decrement_card_maindeck_swap,
        "delete_sideboard_swap": decrement_card_sideboard_swap,
        "delete_sideboard": decrement_card_sideboard,
        "increment_sideboard": increment_card_sideboard,
    };

    var list_types = [
        ['maindeck', SWAP_FROM_MAINDECK],
        ['maindeck_swap', DELETE_MAINDECK_SWAP],
        ['sideboard', SWAP_FROM_SIDEBOARD + DELETE_SIDEBOARD],
        ['sideboard_swap', DELETE_SIDEBOARD_SWAP],
    ];

    function draw(){
        visual.cards = binder.cards;
        var cards_by_category_then_list = visual.draw_cards(list_types, card_actions, draw);

        $('#balance').html(format_price(binder.user.balance));
        var swap_total = 0;
        for (var category in cards_by_category_then_list){
            var cards = cards_by_category_then_list[category]['sideboard_swap'].cards;
            cards.forEach(function (card){
                swap_total += card.sideboard_swap * card.price;
            });
        }
        $('#cost').html(format_price(swap_total));
    }

})(Module('binder'));

