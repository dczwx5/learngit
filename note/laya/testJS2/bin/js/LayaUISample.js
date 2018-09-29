var Loader = laya.net.Loader;
var Handler = laya.utils.Handler;
var Sprite  = Laya.Sprite;
var Stage   = Laya.Stage;
var Texture = Laya.Texture;
var Browser = Laya.Browser;
var WebGL   = Laya.WebGL;
var Event = Laya.Event;

var MENU_IMAGE;
var RESOURCE_IMAGE;


//初始化微信小游戏
Laya.MiniAdpter.init();
//程序入口
Laya.init(512, 448, WebGL);
Laya.stage.scaleMode = Stage.SCALE_EXACTFIT;
Laya.Stat.show();

//激活资源版本控制
Laya.ResourceVersion.enable("version.json", Handler.create(null, beginLoad), Laya.ResourceVersion.FILENAME_VERSION);


function beginLoad(){
    var imageList = ["images/menu.gif", "images/tankAll.gif"];
    Laya.loader.load(imageList, Handler.create(this, _onLoaded), null, Loader.IMAGE);
}

function _onStart(e) {
    switch(gameState) {
        case GAME_STATE_MENU:
            Laya.stage.off(Event.CLICK, this, _onStart);
            gameState = GAME_STATE_INIT;
            //只有一个玩家
            if(menu.playNum == 1){
                player2.lives = 0;
            }
            break;
        // case GAME_STATE_START:
        //     //射击
        //     player1.shoot(BULLET_TYPE_PLAYER);
        //     break;
    }
}

var root = new Sprite();
function _onLoaded() {
    RESOURCE_IMAGE = Laya.loader.getRes("images/tankAll.gif");
    MENU_IMAGE = Laya.loader.getRes("images/menu.gif");
    root.width = SCREEN_WIDTH;
    root.height = SCREEN_HEIGHT;
    root.graphics.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, '#000000');
    Laya.stage.addChild(root);
    
    initScreen();
    initObject();
    setInterval(gameLoop, 20);

    Laya.stage.on(Event.CLICK, this, _onStart);
}
