(function(module){

    var store = Module("store");
    var binder = null;
    module.get_binder = function(){return binder;};

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
        });
    }
    module.init = init;

    function add_card_to_sideboard(card){
        if (!(card.name in binder.cards)){
            card.sideboard = 1;
            card.decklist = 0;
            card.from_sideboard = 0;
            card.from_decklist = 0;
            binder.cards[card.name] = card;
        } else {
            console.log("cannot add card already in binder");
        }
    }
    module.add_card_to_sideboard = add_card_to_sideboard;

    // function remove_card_from_sideboard(card){
    //     delete binder.sideboard[card.name];
    // }

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
        // store.save_binder(user_id, binder);
    }
    module.swap_cards = swap_cards;

    var MOVE = '<input type="button" class="move_from_sideboard" value="<<"/>';
    var CARD = '<li data-id={1}>{3}{2}</li>';

    function draw(){
        var html_sideboard = "";
        var html_from_sideboard = "";
        for (var key in binder.cards){
            var card = binder.cards[key];
            if (card.sideboard > 0){
                html_sideboard += str_format(CARD, card.name, card.name, MOVE);
            }
            if (card.from_sideboard > 0){
                html_from_sideboard += str_format(CARD, card.name, card.name, '');
            }
        }
        $("#sideboard").html(html_sideboard);
        $("#from_sideboard").html(html_from_sideboard);

        $(".move_from_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = binder.cards[name];
            swap_from_sideboard(card);
            draw();
        });
    }
    module.draw = draw;

})(Module('binder'));

