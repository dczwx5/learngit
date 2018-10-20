/**
  * 场景切换特效类
  * by skave
  * (c) copyright 2018 - 2035
  * All Rights Reserved.
 //切换场景的特效
 //1.卷帘特效
 //2.左右切换移动
 //3.直接翻
 //4.旋转掉落
 //5.随机一种
  */

namespace Utils{
    export class ChangeSceneEffect{
        
        /**
         * 切换场景的特效
         * @param style 
         *  1.卷帘特效
         *  2.左右切换移动
         *  3.直接翻
         *  4.旋转掉落
         *  5.随机一种
         */
        public static play(style:number) {
            //创建一个截图Bitmap
            var target = StageUtils.getStage();
            var w = target.width;
            var h = target.height;
            //新建一个group
            var loadTxGrp = new eui.Group();
            loadTxGrp.width = w;
            loadTxGrp.height = h;
            target.addChild(loadTxGrp);
            //循环创建多个截图bitmap 这里num自由设置
            var tx1Number = 40;
            //每个横着的数量
            var Xnumber = 5;
            //高数量自动计算
            var Ynumber = tx1Number / Xnumber;
            for (var i = 0; i < tx1Number; i++) {
                //计算每个的XY及宽高
                var _mcW = w / Xnumber;
                var _mcH = h / Ynumber;
                var _mcX = i % Xnumber * _mcW;
                var _mcY = Math.floor(i / Xnumber) * _mcH;
    
                var renderTexture: egret.RenderTexture = new egret.RenderTexture();
                var mypic = renderTexture.drawToTexture(target, new egret.Rectangle(_mcX, _mcY, _mcW, _mcH));
                var bmp = new egret.Bitmap;
                bmp.texture = renderTexture;
                bmp.anchorOffsetX = _mcW >> 1;
                bmp.anchorOffsetY = _mcH >> 1;
                bmp.x = _mcX + _mcW >> 1;
                bmp.y = _mcY + _mcH >> 1;
                loadTxGrp.addChild(bmp);
                if (style == 5) {
                    style = Math.ceil(Math.random() * 4)
                }
                //开始特效
                switch (style) {
                    case 1:
                        var tw = egret.Tween.get(bmp);
                        tw.to({ scaleX: 0, scaleY: 0, alpha: 0, rotation: 359 }, 800, egret.Ease.circIn).call(onComplete, this);
                        break;
                    case 2:
                        var my_x = -w
                        if (!(i % 2)) {
                            my_x = w * 2
                        }
                        var tw = egret.Tween.get(bmp);
                        tw.to({ x: my_x, alpha: 0 }, 800, egret.Ease.circIn).call(onComplete, this);
                        break;
                    case 3:
                        var tw = egret.Tween.get(bmp);
                        tw.to({ scaleX: 0.2, scaleY: 1, alpha: 0, blurFliter: 0 }, 800, egret.Ease.backInOut).call(onComplete, this);
                        break;
                    case 4:
                        var tw = egret.Tween.get(bmp);
                        tw.to({ alpha: 0}, 900, egret.Ease.circIn).call(onComplete, this);
                        break;
                    default:
                        var tw = egret.Tween.get(bmp);
                        tw.to({ scaleX: 1, scaleY: 0, alpha: 0 }, 800, egret.Ease.circIn).call(onComplete, this);
                }
            }
            var upNumber = 0;
            function onComplete(evt: Comment) {
                upNumber++;
                if (upNumber == tx1Number) {
                    target.removeChild(loadTxGrp)
                }
            }
        }
    }
}
