/*
* name;
*/
function getScreenWidth(){
    return Laya.stage.width;
}
function getScreenHeight() {
    return Laya.stage.height;
}
function getStage() {
    return Laya.stage;
}


var autoLib = (function () {
    function autoLib() {
    }
    return autoLib;
}());

/** 类继承
new function() {
    var className = 'BackGround';
    window[className] = (function() {
        Laya.class(Class, className, Laya.Sprite);

        function Class() {
            Class.super(this);

           // this.img = [];

            //this.init();
        }
        Class.prototype.init = function() {
            Laya.stage.addChild(this);
            this.bg();
            Laya.timer.frameLoop(1, this, this.loop);
        };
        Class.prototype.bg = function() {
            for (var i = 0; i < 2; i++) {
                this.img[i] = new Laya.Image('background.png');
                this.addChild(this.img[i]);
            }
            this.img[0].y = 0;
            this.img[1].y = -852;
        }
        Class.prototype.loop = function() {
            for (var i = 0; i < this.img.length; i++) {
                this.img[i].y += 1;
                if (this.img[i].y >= 852) {
                    this.img[i].y = -852;
                }
            }
        };
        return Class;
    })();
}
*/
/**
rect.on(Event.MOUSE_DOWN, this, mouseHandler);
rect.on(Event.MOUSE_UP, this, mouseHandler);
rect.on(Event.CLICK, this, mouseHandler);
rect.on(Event.RIGHT_MOUSE_DOWN, this, mouseHandler);
rect.on(Event.RIGHT_MOUSE_UP, this, mouseHandler);
rect.on(Event.RIGHT_CLICK, this, mouseHandler);
rect.on(Event.MOUSE_MOVE, this, mouseHandler);
rect.on(Event.MOUSE_OVER, this, mouseHandler);
rect.on(Event.MOUSE_OUT, this, mouseHandler);
rect.on(Event.DOUBLE_CLICK, this, mouseHandler);
rect.on(Event.MOUSE_WHEEL, this, mouseHandler);*/