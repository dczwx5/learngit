/*
* name;
*/
var texList = {};
new function() {
    var fillStyle = '#000000';
    var className = 'CContext';
    window[className] = (function() {
        Laya.class(Class, className, Laya.Sprite);

        function Class() {
            Class.super(this);

            this.init();
        }
        
        Class.prototype.init = function() {
            
        };
        // 从tex的srcx, srcy, 取srcw, srcw, 画到target的tx, ty上
        Class.prototype.drawImage = function (tex, srcx, srcy, srcw, srch, tx, ty) {
            // var mat = new Laya.Matrix();
            // mat.tx  = tx;
            // mat.ty  = ty;
            var texEnd;
            if (!(srcw > 0) || !(srch > 0)) {
                srcw = tex.width;
                srch = tex.height;
                texEnd = tex;
                
                

            } else {
                var id = tex.url + "_" + srcx + "_" + srcy;
                var temp = texList[id];
                if (temp != null) {
                    texEnd = temp;
                    
                } else {
                    texEnd = Texture.create(tex,srcx,srcy,srcw,srch);
                    trace("Texture.create id --->" + id);
                    texList[id] = texEnd;
                }
            }
            
            this.graphics.drawTexture(texEnd, tx, ty);
        };
        Class.prototype.clearRect = function (x, y, width, height) {
            this.graphics.clear();
        };
        Class.prototype.save = function () {

        };
        Class.prototype.restore = function () {

        };
        Class.prototype.fillRect = function (x, y, w, h) {
            // 这东西　drawCall非常　高。而且只增不减
        //    this.graphics.drawRect(x, y, w, h, fillStyle);
        };
        
    
        return Class;
    })();
}

