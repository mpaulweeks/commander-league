(function(module){

    var store = Module("store");
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

    function init(){
        var user_id = "1";
        store.load_binder(user_id, function (data){
            binder = data;
            draw();
        });
    }
    module.init = init;

    function add_card_to_sideboard(new_card){
        if (!(new_card.name in binder.cards)){
            binder.cards[new_card.name] = new_card;
        }
        var card = binder.cards[new_card.name];
        if ("decklist" in card && card.decklist > 0){
            console.log("cannot add card already in binder");
            return;
        }
        card.sideboard = 1;
        card.decklist = 0;
        card.from_sideboard = 0;
        card.from_decklist = 0;
        store.save_binder(binder, draw);
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

    function delete_card_from_decklist(card){
        card.from_decklist -= 1;
    }

    function swap_from_decklist(card){
        if (card.from_decklist < card.decklist){
            card.from_decklist += 1;
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
            num_from_deck += card.from_decklist;
            num_from_side += card.from_sideboard;
            if (card.from_decklist > 0 && card.from_sideboard > 0){
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
            card.decklist -= card.from_decklist;
            card.decklist += card.from_sideboard;
            card.sideboard += card.from_decklist;
            card.sideboard -= card.from_sideboard;
            card.from_decklist = 0;
            card.from_sideboard = 0;
        }
        store.save_binder(binder, draw);
    }
    module.swap_cards = swap_cards;

    var SWAP_FROM_SIDEBOARD = '<input type="button" class="swap_from_sideboard" value="<<"/>';
    var SWAP_FROM_DECKLIST = '<input type="button" class="swap_from_decklist" value=">>"/>';
    var DELETE_SIDEBOARD = '<input type="button" class="delete_sideboard" value="-"/>';
    var INCREMENT_SIDEBOARD = '<input type="button" class="increment_sideboard" value="+"/>';
    var DELETE_FROM_DECKLIST = '<input type="button" class="delete_from_decklist" value="-"/>';
    var DELETE_FROM_SIDEBOARD = '<input type="button" class="delete_from_sideboard" value="-"/>';
    var CARD = '<li data-id={1}>{2} {3}x {1}</li>';

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

    function draw(){
        var html_decklist = "";
        var html_from_decklist = "";
        var html_sideboard = "";
        var html_from_sideboard = "";
        for (var key in binder.cards){
            var card = binder.cards[key];
            html_decklist += get_card_html(card, "decklist", SWAP_FROM_DECKLIST);
            html_from_decklist += get_card_html(card, "from_decklist", DELETE_FROM_DECKLIST);
            html_sideboard += get_card_html(card, "sideboard", SWAP_FROM_SIDEBOARD + DELETE_SIDEBOARD);
            html_from_sideboard += get_card_html(card, "from_sideboard", DELETE_FROM_SIDEBOARD);
        }
        $("#decklist").html(html_decklist);
        $("#from_decklist").html(html_from_decklist);
        $("#sideboard").html(html_sideboard);
        $("#from_sideboard").html(html_from_sideboard);

        $(".swap_from_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            swap_from_sideboard(card);
            draw();
        });
        $(".swap_from_decklist").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            swap_from_decklist(card);
            draw();
        });
        $(".delete_from_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            delete_card_from_sideboard(card);
            draw();
        });
        $(".delete_from_decklist").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            delete_card_from_decklist(card);
            draw();
        });
        $(".delete_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            delete_card_sideboard(card);
            draw();
        });
        $(".increment_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            increment_card_sideboard(card);
            draw();
        });
    }

})(Module('binder'));

