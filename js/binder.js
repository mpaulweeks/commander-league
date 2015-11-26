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
        card.sideboard = 0;
        card.from_sideboard = 0;
    }

    function delete_card_from_sideboard(card){
        card.from_sideboard = 0;
    }

    function delete_card_from_decklist(card){
        card.from_decklist = 0;
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
    var DELETE_SIDEBOARD = '<input type="button" class="delete_sideboard" value="X"/>';
    var DELETE_FROM_DECKLIST = '<input type="button" class="delete_from_decklist" value="X"/>';
    var DELETE_FROM_SIDEBOARD = '<input type="button" class="delete_from_sideboard" value="X"/>';
    var CARD = '<li data-id={1}>{2}</li>';

    function draw(){
        var html_decklist = "";
        var html_from_decklist = "";
        var html_sideboard = "";
        var html_from_sideboard = "";
        for (var key in binder.cards){
            var card = binder.cards[key];
            if (card.decklist > 0){
                html_decklist += str_format(CARD, card.name, SWAP_FROM_DECKLIST + card.name);
            }
            if (card.from_decklist > 0){
                html_from_decklist += str_format(CARD, card.name, DELETE_FROM_DECKLIST + card.name);
            }
            if (card.sideboard > 0){
                html_sideboard += str_format(CARD, card.name, DELETE_SIDEBOARD + SWAP_FROM_SIDEBOARD + card.name);
            }
            if (card.from_sideboard > 0){
                html_from_sideboard += str_format(CARD, card.name, DELETE_FROM_SIDEBOARD + card.name);
            }
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
    }

})(Module('binder'));

