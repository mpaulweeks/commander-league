(function(module){

    var view = Module("view");

    module.index = function(){
        view.index();
    };

    module.view = function(){
        view.view();
    };

    module.diff = function(){
        view.diff();
    };

})(Module('main'));

