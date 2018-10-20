package core.game.ecsLoop
{
    import laya.d3.math.Vector3;
    import laya.d3.math.Vector4;
    import core.character.display.IDisplay;
    import core.character.animation.CCharacterAnimation;
    import core.character.display.CCharacterDisplay;

    public class CTransform extends CGameComponent implements ITransform {
        public function CTransform() {
            super("transform");
        }

        override public function dispose() : void {
            super.dispose();

            m_pos = null;
            m_rotation = null;
            m_scale = null;

            m_pDisplayObject = null;
        }

        override protected virtual function onEnter() : void {
            var animation:CCharacterAnimation = owner.getComponentByClass(CCharacterAnimation) as CCharacterAnimation;
            m_pDisplayObject = animation.displayObject;

            m_pos = new Vector3(0, 0, 0);
            m_scale = new Vector3(1, 1, 1);
            m_rotation = new Vector4(0, 0, 0, 0);
        }

        override protected virtual function onDataUpdated() : void {
            if (data && 'position' in data) {
                m_pos.x = data.position.x;
                m_pos.y = data.position.y;
                m_pos.z = data.position.z;
            }

            if (data && 'rotation' in data) {
                m_rotation.x = data.rotation.x;
                m_rotation.y = data.rotation.y;
                m_rotation.z = data.rotation.z;
                m_rotation.w = data.rotation.w;
            }

            if (data && 'scale' in data) {
                m_scale.x = data.scale.x;
                m_scale.y = data.scale.y;
                m_scale.z = data.scale.z;
            }

        }

        override protected virtual function onExit() : void {
            m_pos = null;
            m_rotation = null;
            m_scale = null;
        }

        final public function get x() : Number {
            return m_pos.x;
        }
        final public function set x(v:Number) : void {
            if (m_pos.x == v) {
                return ;
            }
            m_pos.x = v;
            m_isDataDirty = true;

			
			m_pDisplayObject.pos(m_pos.x, m_pos.y);
        }   
        final public function get y() : Number {
            return m_pos.y;
        }
        final public function set y(v:Number) : void {
            if (m_pos.y == v) {
                return ;
            }
            m_pos.y = v;
            m_isDataDirty = true;
            m_pDisplayObject.pos(m_pos.x, m_pos.y);
        }   

        final public function get z() : Number {
            return m_pos.z;
        }
        final public function set z(v:Number) : void {
            if (m_pos.z == v) {
                return ;
            }
            m_pos.z = v;
            m_isDataDirty = true;
            m_pDisplayObject.pos(m_pos.x, m_pos.y);
        }   
        public function setPosition(x:Number, y:Number, z:Number) : void {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        // final public function get position() : Vector3 {
        //     return m_pos;
        // }
        final public function set position(v:Vector3) : void {
            if (v && m_pos.x == v.x && m_pos.y == v.y && m_pos.z == v.z) {
                return ;
            }
            m_pos = v;
            m_isDataDirty = true;

            m_pDisplayObject.pos(m_pos.x, m_pos.y);
        }   

        final public function get rotationX() : Number {
            return m_rotation.x;
        }
        final public function set rotationX(v:Number) : void {
            if (m_rotation.x == v) {
                return ;
            }
            m_rotation.x = v;
            m_isDataDirty = true;

        }   

        final public function get rotationY() : Number {
            return m_rotation.y;
        }
        final public function set rotationY(v:Number) : void {
            if (m_rotation.y == v) {
                return ;
            }
            m_rotation.y = v;
            m_isDataDirty = true;
        }   

        final public function get rotationZ() : Number {
            return m_rotation.z;
        }
        final public function set rotationZ(v:Number) : void {
            if (m_rotation.z == v) {
                return ;
            }
            m_rotation.z = v;
            m_isDataDirty = true;
        }   

        final public function get rotationW() : Number {
            return m_rotation.w;
        }
        final public function set rotationW(v:Number) : void {
            if (m_rotation.w == v) {
                return ;
            }
            m_rotation.w = v;
            m_isDataDirty = true;
        }

        final public function get rotation() : Vector4 {
            return m_rotation;
        }
        final public function set rotation(v:Vector4) : void {
            if (v && m_rotation.x == v.x && m_rotation.y == v.y && m_rotation.z == v.z && m_rotation.w == v.w) {
                return ;
            }
            m_rotation = v;
            m_isDataDirty = true;
        }

        final public function get scale() : Vector3 {
            return m_scale;
        }
        final public function set scale(v:Vector3) : void {
            if (v && m_scale.x == v.x && m_scale.y == v.y && m_scale.z == v.z) {
                return ;
            }
            m_scale = v;
            m_isDataDirty = true;

            m_pDisplayObject.scale(m_scale.x, m_scale.y);
        }   

        final public function get scaleX() : Number {
            return m_scale.x;
        }
        final public function set scaleX(v:Number) : void {
            if (m_scale.x == v) {
                return ;
            }
            m_scale.x = v;
            m_isDataDirty = true;

            m_pDisplayObject.scaleX = m_scale.y;

        }   
        
        final public function get scaleY() : Number {
            return m_scale.y;
        }
        final public function set scaleY(v:Number) : void {
            if (m_scale.y == v) {
                return ;
            }
            m_scale.y = v;
            m_isDataDirty = true;

            m_pDisplayObject.scaleY = m_scale.y;
        }   

        final public function get scaleZ() : Number {
            return m_scale.z;
        }
        final public function set scaleZ(v:Number) : void {
            if (m_scale.z == v) {
                return ;
            }
            m_scale.z = v;
            m_isDataDirty = true;
            
        }

        internal function update() : void {
            if (m_isDataDirty == false) {
                return ;
            }

            var data:Object = this.data;
            if ('position' in data) {
                data.position.x = m_pos.x;
                data.position.y = m_pos.y;
                data.position.z = m_pos.z;
            }
            if ('rotation' in data) {
                data.rotation.x = m_rotation.x;
                data.rotation.y = m_rotation.y;
                data.rotation.z = m_rotation.z;
                data.rotation.w = m_rotation.w;
            }
            if ('scale' in data) {
                data.scale.x = m_scale.x;
                data.scale.y = m_scale.y;
                data.scale.z = m_scale.z;
            }
        }

        private var m_pos:Vector3;
        private var m_rotation:Vector4;
        private var m_scale:Vector3;

        private var m_isDataDirty:Boolean;

        private var m_pDisplayObject:CCharacterDisplay;
    }   
 }