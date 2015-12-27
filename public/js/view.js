(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

    var CARD_OPTION = '<option value="{1}">{1}</option>';

    function run(){
        binder.init();
        var colors = binder.get_binder().user.colors;
        store.get_cards_by_colors(colors).forEach(function (card_name){
            var card_html = str_format(CARD_OPTION, card_name);
            $('#lookup-select').append(card_html);
        });
        $('#lookup-select').select2({
            placeholder: "Click to type"
        });

        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var card_name = $("#lookup-select").val();
            binder.add_card_to_sideboard(card_name);
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
        });
    }
    module.run = run;

})(Module('view'));

