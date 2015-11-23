(function(module){

    var store = Module("store");
    var view = Module("view");

    module.index = function(){
        store.load(view.run);
    };

})(Module('main'));

