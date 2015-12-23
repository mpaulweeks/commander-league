(function(module){

    var store = Module("store");
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

    function _load_binder_obj(data){
        binder = data;
        draw();
    }

    function load_binder_str(data_str){
        data = JSON.parse(data_str);
        _load_binder_obj(data);
    }

    function load_new_card_data(data_str){
        var data = JSON.parse(data_str);
        for (card_name in data){
            var new_card = data[card_name];
            if (card_name in binder.cards){
                var old_card = binder.cards[card_name];
                new_card.maindeck_swap = old_card.maindeck_swap;
                new_card.sideboard_swap = old_card.sideboard_swap;
            }
            binder.cards[card_name] = new_card;
        }
        draw();
    }

    function init(){
        var data_str = $('#server_data').html()
        $('#server_data').empty()
        var data = JSON.parse(data_str);
        user_slug = data.user.slug
        _load_binder_obj(data);
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
            store.create_statuses(user_slug, [card], load_new_card_data);
        }
    }

    function increment_card_sideboard(card){
        if (card.sideboard == 0 || multiples_ok(card)){
            card.sideboard += 1;
            store.create_statuses(user_slug, [card], load_new_card_data);
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
        for (var key in binder.cards){
            var card = binder.cards[key];
            num_from_deck += card.maindeck_swap;
            num_from_side += card.sideboard_swap;
            if (card.maindeck_swap > 0 && card.sideboard_swap > 0){
                console.log('error');
                return false;
            }
        }
        return num_from_deck > 0 && num_from_deck == num_from_side;
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
        store.create_statuses(user_slug, to_swap, load_new_card_data);
    }
    module.swap_cards = swap_cards;

    var SWAP_FROM_SIDEBOARD = '<input type="button" class="action" data-func="swap_from_sideboard" value="<<"/>';
    var SWAP_FROM_MAINDECK = '<input type="button" class="action" data-func="swap_from_maindeck" value=">>"/>';
    var DELETE_SIDEBOARD = '<input type="button" class="action" data-func="delete_sideboard" value="-"/>';
    var INCREMENT_SIDEBOARD = '<input type="button" class="action" data-func="increment_sideboard" value="+"/>';
    var DELETE_MAINDECK_SWAP = '<input type="button" class="action" data-func="delete_maindeck_swap" value="-"/>';
    var DELETE_SIDEBOARD_SWAP = '<input type="button" class="action" data-func="delete_sideboard_swap" value="-"/>';
    var CARD = '<li data-id="{1}">{2} {3}x {1}</li>';

    function get_card_html(card, property, display){
        var count = card[property];
        if (count < 1){
            return '';
        }
        if (multiples_ok(card) && property == "sideboard"){
            display += INCREMENT_SIDEBOARD;
        }
        return str_format(CARD, card.name, display, count);
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

    function compare(a, b){
        if (a < b){
            return -1;
        }
        if (a > b){
            return 1;
        }
        return 0;
    }

    function draw(){
        var cards_by_category = {};
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
            cards_by_category[category] = matching_cards;
        });
        list_types.forEach(function (list_type){
            var total_html = '';
            categories.forEach(function (category){
                var matching_cards = cards_by_category[category];
                var cards_html = get_cards_html(matching_cards, list_type);
                if (cards_html.length > 0){
                    total_html += '<p>' + category + '</p>' + cards_html;
                }
            });
            $('#' + list_type[0]).html(total_html);
        });

        $(".action").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            var action = $(this).data("func");
            card_actions[action](card);
            draw();
        });
    }

})(Module('binder'));

