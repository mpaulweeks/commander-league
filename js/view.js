(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function run(){
        binder.init();
        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var val = $("#lookup-text").val();
            var card = store.get_card(val, function(card){
                binder.add_card_to_sideboard(card);
                binder.draw();
            });
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
            binder.draw();
        });
    }

    module.run = run;

})(Module('view'));

