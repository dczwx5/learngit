//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/8/24.
 */

package kof.game.fightui.compoment
{
    import flash.display.Graphics;
    import flash.display.Sprite;

    /**
     * 扇形
     * @author lyman
     *
     */
    public class Sector extends Sprite
    {
        private var _x0:Number;//圆心横坐标
        private var _y0:Number;//圆心纵坐标
        private var _r:Number;//圆半径
        private var _a0:Number;//起始角度 0度开始顺时针方向
        private var _lineWidth:Number;//线条宽度
        private var _lineColor:Number;//线条颜色
        private var _fillColor:Number;//填充颜色
        private var _gh:Graphics;

        public function Sector()
        {
            _gh = this.graphics;
        }

        /**
         *
         * @param x0 //圆心横坐标
         * @param y0 //圆心纵坐标
         * @param r  //圆半径
         * @param a0 //起始角度 0度开始顺时针方向
         * @param a  //扇形的角度
         * @param lineWidth //线条宽度
         * @param lineColor //线条颜色
         * @param fillColor //填充颜色
         *
         */
        public function init(x0:Number,y0:Number,r:Number,a0:Number,a:Number,lineWidth:Number=1,lineColor:Number=0x000000,fillColor:Number=0x000000):void
        {
            clear();
            _x0 = x0;
            _y0 = y0;
            _r = r;
            _a0 = a0*Math.PI/180;
            _lineWidth = lineWidth;
            _lineColor = lineColor;
            _fillColor = fillColor;
            if(a>0&&a<=360)
            {
                drawSector(a);
            }
        }

        private function drawSector(a:Number):void
        {
            _gh.lineStyle(_lineWidth,_lineColor,1);
            _gh.beginFill(_fillColor);
            _gh.moveTo(_x0,_y0);
            _gh.lineTo(_x0+_r*Math.cos(_a0),_y0+_r*Math.sin(_a0));//曲线绘制起始点
            var n:uint = Math.floor(a/45);//分段绘制接近Bezier曲线的曲线，分段越细，曲线越接近真实圆弧线
            var a0:Number = _a0;//记录初始角度
            while(n-- > 0)
            {
                a0 += Math.PI/4;
                var cX:Number = _x0+_r/Math.cos(Math.PI/8)*Math.cos(a0-Math.PI/8);
                var cY:Number = _y0+_r/Math.cos(Math.PI/8)*Math.sin(a0-Math.PI/8);
                var moveX:Number = _x0+_r*Math.cos(a0);
                var moveY:Number = _y0+_r*Math.sin(a0);
                _gh.curveTo(cX,cY,moveX,moveY);
            }
            if(a%45)
            {
                var am:Number = a%45*Math.PI/180;

                var n1:Number = _x0+_r/Math.cos(am/2)*Math.cos(a0+am/2);
                var n2:Number = _y0+_r/Math.cos(am/2)*Math.sin(a0+am/2);

                var n3:Number = _x0+_r*Math.cos(a0+am);
                var n4:Number = _y0+_r*Math.sin(a0+am);

                _gh.curveTo(n1,n2,n3,n4);
            }
            _gh.lineTo(_x0,_y0);
            _gh.endFill();
        }

        public function reDraw(r:Number,a0:Number,a:Number):void
        {
            if(a >= 0 && a <= 360)
            {
                clear();
                _r = r;
                _a0 = a0*Math.PI/180;
                drawSector(a);
            }
        }

        public function clear():void
        {
            _gh.clear();
        }
    }
}
