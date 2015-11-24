(function(module){

    var store = Module("store");
    var binder = null;
    var from_decklist = {};
    var from_sideboard = {};

    function init(){
        var user_id = "mpw";
        binder = store.load_binder(user_id);
    }

    function add_card_to_sideboard(card){
        if (!card.name in binder.decklist){
            binder.sideboard[card.name] = card;
        } else {
            console.log("cannot add card already in deck");
        }
    }

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

    function draw(){

    }

})(Module('binder'));

