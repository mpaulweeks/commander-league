(function(module){

    var store = Module("store");
    var binder = null;
    var from_decklist = {};
    var from_sideboard = {};


    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

    function init(){
        var user_id = "1";
        binder = store.load_binder(user_id);
    }
    module.init = init;

    function add_card_to_sideboard(card){
        if (!(card.name in binder.decklist)){
            binder.sideboard[card.name] = card;
        } else {
            console.log("cannot add card already in deck");
        }
    }
    module.add_card_to_sideboard = add_card_to_sideboard;

    function remove_card_from_sideboard(card){
        delete binder.sideboard[card.name];
    }

    function swap_from_decklist(card){
        if (card.name in binder.decklist){
            from_decklist[card.name] = card;
        }
    }

    function swap_from_sideboard(card){
        if (card.name in binder.sideboard){
            from_sideboard[card.name] = card;
        }
    }

    function is_legal_swap(){
        var num_from_deck = Object.keys(from_decklist).length;
        var num_from_side = Object.keys(from_sideboard).length;
        return num_from_deck > 0 && num_from_deck == num_from_side;
    }

    function swap_cards(){
        if (!is_legal_swap){
            console.log("cant swap");
            return;
        }

        for (var card_name in from_decklist){
            var card = binder.decklist[card_name];
            binder.sideboard[card.name] = card;
            delete binder.decklist[card.name];
        }
        for (var card_name in from_sideboard){
            var card = binder.sideboard[card_name];
            binder.decklist[card.name] = card;
            delete binder.sideboard[card.name];
        }
        from_decklist = {};
        from_sideboard = {};
        store.save_binder(user_id, binder);
    }

    var MOVE = '<input type="button" class="move_from_sideboard" value="<<"/>';
    var CARD = '<li data-id={1}>{3}{2}</li>';

    function draw(){
        var html_sideboard = "";
        for (var key in binder.sideboard){
            var card = binder.sideboard[key];
            html_sideboard += str_format(CARD, card.name, card.name, MOVE);
        }
        $("#sideboard").html(html_sideboard);

        var html_from_sideboard = "";
        for (var key in from_sideboard){
            var card = from_sideboard[key];
            html_from_sideboard += str_format(CARD, card.name, card.name, '');
        }
        $("#from_sideboard").html(html_from_sideboard);

        $(".move_from_sideboard").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = store.get_card(name);
            swap_from_sideboard(card);
            draw();
        });
    }
    module.draw = draw;

})(Module('binder'));

