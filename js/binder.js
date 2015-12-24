(function(module){

    var store = Module("store");
    var autocard = Module("autocard");
    var user_slug = null;
    var binder = null;
    // for debug
    module.get_binder = function(){return binder;};

    var valid_multiples = {
        "Forest": true,
        "Plains": true,
        "Swamp": true,
        "Island": true,
        "Mountain": true,
    }

    function multiples_ok(card){
        return card.name in valid_multiples;
    }

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

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

    function init(){
        var data_str = $('#server_data').html()
        $('#server_data').empty()
        binder = JSON.parse(data_str);
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

    function add_card_to_sideboard(new_card){
        if (!(new_card.name in binder.cards)){
            new_card.sideboard = 0;
            new_card.maindeck = 0;
            new_card.sideboard_swap = 0;
            new_card.maindeck_swap = 0;
            binder.cards[new_card.name] = new_card;
        }
        var card = binder.cards[new_card.name];
        if ("maindeck" in card && card.maindeck > 0 && !multiples_ok(card)){
            console.log("cannot add card already in deck");
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
                console.log('error');
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
            console.log("cant swap");
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
    var INCREMENT_SIDEBOARD = '<input type="button" class="action" data-func="increment_sideboard" value="+"/>';
    var DELETE_MAINDECK_SWAP = '<input type="button" class="action" data-func="delete_maindeck_swap" value="-"/>';
    var DELETE_SIDEBOARD_SWAP = '<input type="button" class="action" data-func="delete_sideboard_swap" value="-"/>';
    var CARD = '<div class="col-md-12"></div><div class="col-md-{5}" data-id="{1}">{2} {3}x <a href="" class="mtgcard">{1}</a></div>{4}';
    var CATEGORY = '<div class="col-md-12 category text-center">{1} ({2})</div>';
    var PRICE = '<div class="col-md-3 price text-right">{1}</div>';

    function format_price(price){
        if (price == null){
            return 'FREE';
        }
        return price.toFixed(2);
    }

    function get_card_html(card, property, display){
        var count = card[property];
        if (multiples_ok(card) && property == "sideboard"){
            display += INCREMENT_SIDEBOARD;
        }
        var price_html = '';
        var card_width = 12;
        if (property == 'sideboard' || property == 'sideboard_swap'){
            var price_str = format_price(card.price);
            price_html = str_format(PRICE, price_str);
            card_width = 9;
        }
        return str_format(CARD, card.name, display, count, price_html, card_width);
    }

    function get_cards_html(cards, list_type){
        var html_out = "";
        for (var i = 0; i < cards.length; i++){
            var card = cards[i];
            html_out += get_card_html(card, list_type[0], list_type[1]);
        }
        return html_out;
    }

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

    var categories = ['Land', 'Creature', 'Spell'];

    function draw(){

        var cards_by_category_then_list = {};
        categories.forEach(function (category){
            var matching_cards = [];
            for (var key in binder.cards){
                var card = binder.cards[key];
                if (card.category == category){
                    matching_cards.push(card);
                }
            }
            matching_cards.sort(function (a,b){
                return a.name > b.name;
            });
            var sub_dict = {};
            list_types.forEach(function (list_type){
                var cards_in_list = [];
                var total_count = 0;
                var list_label = list_type[0];
                matching_cards.forEach(function (card){
                    var card_count = card[list_label];
                    if (card_count > 0){
                        total_count += card_count;
                        cards_in_list.push(card);
                    }
                });
                sub_dict[list_label] = {
                    cards: cards_in_list,
                    count: total_count,
                };
            });
            cards_by_category_then_list[category] = sub_dict;
        });

        $('#balance').html(format_price(binder.user.balance));
        var swap_total = 0.0;
        categories.forEach(function (category){
            var cards = cards_by_category_then_list[category]['sideboard_swap'].cards;
            cards.forEach(function (card){
                swap_total += card.sideboard_swap * card.price;
            });
        });
        $('#cost').html(format_price(swap_total));

        list_types.forEach(function (list_type){
            var total_html = '';
            var list_label = list_type[0];
            categories.forEach(function (category){
                var matching_dict = cards_by_category_then_list[category][list_label];
                if (matching_dict.count > 0){
                    var cards_html = get_cards_html(matching_dict.cards, list_type);
                    total_html += str_format(CATEGORY, category, matching_dict.count) + cards_html;
                }
            });
            $('#' + list_label).html(total_html);
        });

        $(".action").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            var action = $(this).data("func");
            card_actions[action](card);
            draw();
        });

        autocard.init();
    }

})(Module('binder'));

