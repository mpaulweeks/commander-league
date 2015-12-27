(function(module){

    var store = Module("store");
    var view = Module("view");

    module.index = function(){
        store.init(view.index);
    };

    module.diff = function(){
        view.diff();
    };

})(Module('main'));

