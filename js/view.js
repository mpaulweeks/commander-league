(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function run(){
        binder.init();
        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var val = $("#lookup-text").val();
            store.get_card(val, binder.add_card_to_sideboard);
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
        });
    }

    module.run = run;

})(Module('view'));

