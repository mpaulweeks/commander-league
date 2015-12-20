(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

    var CARD_OPTION = '<option value="{1}">{2}</option>';

    function run(){
        message = $('#server_data').html()
        console.log(message);

        binder.init();

        var card_choices = store.get_cards_by_colors(["White", "Red"]);
        for (var i = 0; i < card_choices.length; i++){
            var card = card_choices[i];
            var card_html = str_format(CARD_OPTION, card.name, card.name);
            $('#lookup-select').append(card_html);
        }
        $('#lookup-select').select2({
            placeholder: "Click to type"
        });

        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            // var val = $("#lookup-text").val();
            var val = $("#lookup-select").val();
            store.get_card(val, binder.add_card_to_sideboard);
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
        });
    }
    module.run = run;

})(Module('view'));

