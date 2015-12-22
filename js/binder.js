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

    function init(){
        data_str = $('#server_data').html()
        $('#server_data').empty()
        data = JSON.parse(data_str);
        user_slug = data.user.slug
        console.log(user_slug);
        _load_binder_obj(data);
    }
    module.init = init;

    function add_card_to_sideboard(new_card){
        if (!(new_card.name in binder.cards)){
            new_card.sideboard = 1;
            new_card.maindeck = 0;
            new_card.from_sideboard = 0;
            new_card.from_maindeck = 0;
            binder.cards[new_card.name] = new_card;
        }
        var card = binder.cards[new_card.name];
        if ("maindeck" in card && card.maindeck > 0 && !multiples_ok(card)){
            console.log("cannot add card already in deck");
            return;
        }
        increment_card_sideboard(card);
        store.modify_sideboard(user_slug, card.name, card.sideboard, load_binder_str);
    }
    module.add_card_to_sideboard = add_card_to_sideboard;

    function delete_card_sideboard(card){
        card.sideboard -= 1;
        if (card.from_sideboard > card.sideboard){
            card.from_sideboard -= 1;
        }
    }

    function increment_card_sideboard(card){
        if (multiples_ok(card)){
            card.sideboard += 1;
        }
    }

    function delete_card_from_sideboard(card){
        card.from_sideboard -= 1;
    }

    function delete_card_from_maindeck(card){
        card.from_maindeck -= 1;
    }

    function swap_from_maindeck(card){
        if (card.from_maindeck < card.maindeck){
            card.from_maindeck += 1;
        }
    }

    function swap_from_sideboard(card){
        if (card.from_sideboard < card.sideboard){
            card.from_sideboard += 1;
        }
    }

    function is_legal_swap(){
        var num_from_deck = 0;
        var num_from_side = 0;
        for (var key in binder.cards){
            var card = binder.cards[key];
            num_from_deck += card.from_maindeck;
            num_from_side += card.from_sideboard;
            if (card.from_maindeck > 0 && card.from_sideboard > 0){
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

        for (var key in binder.cards){
            var card = binder.cards[key];
            card.maindeck -= card.from_maindeck;
            card.maindeck += card.from_sideboard;
            card.sideboard += card.from_maindeck;
            card.sideboard -= card.from_sideboard;
            card.from_maindeck = 0;
            card.from_sideboard = 0;
        }
        store.save_binder(binder, refresh);
    }
    module.swap_cards = swap_cards;

    var SWAP_FROM_SIDEBOARD = '<input type="button" class="action" data-func="swap_from_sideboard" value="<<"/>';
    var SWAP_FROM_MAINDECK = '<input type="button" class="action" data-func="swap_from_maindeck" value=">>"/>';
    var DELETE_SIDEBOARD = '<input type="button" class="action" data-func="delete_sideboard" value="-"/>';
    var INCREMENT_SIDEBOARD = '<input type="button" class="action" data-func="increment_sideboard" value="+"/>';
    var DELETE_FROM_MAINDECK = '<input type="button" class="action" data-func="delete_from_maindeck" value="-"/>';
    var DELETE_FROM_SIDEBOARD = '<input type="button" class="action" data-func="delete_from_sideboard" value="-"/>';
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

    var card_actions = {
        "swap_from_maindeck": swap_from_maindeck,
        "swap_from_sideboard": swap_from_sideboard,
        "delete_from_maindeck": delete_card_from_maindeck,
        "delete_from_sideboard": delete_card_from_sideboard,
        "delete_sideboard": delete_card_sideboard,
        "increment_sideboard": increment_card_sideboard,
    }

    function draw(){
        var html_maindeck = "";
        var html_from_maindeck = "";
        var html_sideboard = "";
        var html_from_sideboard = "";
        for (var key in binder.cards){
            var card = binder.cards[key];
            html_maindeck += get_card_html(card, "maindeck", SWAP_FROM_MAINDECK);
            html_from_maindeck += get_card_html(card, "from_maindeck", DELETE_FROM_MAINDECK);
            html_sideboard += get_card_html(card, "sideboard", SWAP_FROM_SIDEBOARD + DELETE_SIDEBOARD);
            html_from_sideboard += get_card_html(card, "from_sideboard", DELETE_FROM_SIDEBOARD);
        }
        $("#maindeck").html(html_maindeck);
        $("#from_maindeck").html(html_from_maindeck);
        $("#sideboard").html(html_sideboard);
        $("#from_sideboard").html(html_from_sideboard);

        $(".action").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            var action = $(this).data("func");
            card_actions[action](card);
            draw();
        });
    }

})(Module('binder'));

