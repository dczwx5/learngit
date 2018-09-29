/*
* name;
*/
var CPlayControlView = function () {
    this.m_root = null;
    this.m_fire = null;
    this.m_lastX = 0;
    this.m_lastY = 0;
    this.m_isMove = false;
    this.m_moveDir = 0;

    this.initialize = function () {
        // m_dirSp.alpha = 0.75;

        m_fire = new Sprite();
        m_fire.size(200, 200);
        m_fire.graphics.drawCircle(50, 50, 50, '#ffff00');
        m_fire.alpha = 0.75;
        m_fire.x = SCREEN_WIDTH - 100;
        m_fire.y = SCREEN_HEIGHT - 100;

        m_root = new Sprite();
        m_root.addChild(m_fire);

        m_fire.on(Laya.Event.MOUSE_DOWN, this, _fireMouseHandler);
        m_fire.on(Laya.Event.MOUSE_UP, this, _fireMouseHandler);

        
        getStage().on(Laya.Event.MOUSE_DOWN, this, _moveMouseHandler);
    };
    this.initialize();

    function _fireMouseHandler(e) {
        switch (e.type) {
            case Laya.Event.MOUSE_DOWN :
                player1.shoot(BULLET_TYPE_PLAYER);
                break;
            case Laya.Event.MOUSE_UP :
                break;
        }
    };

    function _moveMouseHandler(e) {
        switch (e.type) {
            case Laya.Event.MOUSE_DOWN :
                getStage().on(Laya.Event.MOUSE_UP, this, _moveMouseHandler);
                getStage().on(Laya.Event.MOUSE_MOVE, this, _moveMouseHandler);
                m_lastX = getStage().mouseX;
                m_lastY = getStage().mouseY;
                break;
            case Laya.Event.MOUSE_UP :
                m_isMove = false;
                getStage().off(Laya.Event.MOUSE_UP, this, _moveMouseHandler);
                getStage().off(Laya.Event.MOUSE_MOVE, this, _moveMouseHandler);
                break;
            case Laya.Event.MOUSE_MOVE : 
                m_isMove = true;
                var subX = getStage().mouseX - m_lastX;
                var subY = getStage().mouseY - m_lastY;
                if (subX == subY && subY == 0) {
                    break;
                }

                if (Math.abs(subX) > Math.abs(subY)) {
                    // 水平移动
                    if (subX > 0) {
                        // 向右移动　
                        m_moveDir = RIGHT;
                    } else {
                        // 左
                        m_moveDir = LEFT;
                    }
                } else {
                    // 垂直移动
                    if (subY > 0) {
                        // 下
                        m_moveDir = DOWN;
                    } else {
                        // 上
                        m_moveDir = UP;
                    }
                }
                break;
        }
    };
    this.isMove = function () {
        return m_isMove;
    };
    this.moveDir = function () {
        return m_moveDir;
    };
    this.getDisplayObject = function () {
        return m_root;
    };
    

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

};