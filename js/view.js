(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function run(){
        binder.init();
        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var val = $("#lookup-text").val();
            var card = store.get_card(val);
            binder.add_card_to_sideboard(card);
            binder.draw();
        });
    }

    module.run = run;

})(Module('view'));

