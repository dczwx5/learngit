package QFLib.Foundation
{

    public class CLoopList
    {
        private var _nodes : Vector.<Object>;
        private var _capcity : int = 0;
        private var _count : int = 0;
        private var _hIndex : int = 0;                  //head index
        private var _tIndex : int = 0;                  //tail index

        public function CLoopList ( capacity : int = 64 )
        {
            _capcity = capacity;

            _nodes = new Vector.<Object> ( _capcity );
            _nodes.fixed = true;
        }

        public function dispose () : void
        {
            _nodes.fixed = false;
            _nodes.length = 0;
            _nodes = null;
        }

        [Inline]
        public function get count () : int { return _count; }

        public function getObject ( index : int ) : Object
        {
            return _nodes[ (index + _tIndex) % _capcity ];
        }

        public function push ( node : Object ) : void
        {
            _nodes[ _hIndex ] = node;

            if ( _count < _capcity )
            {
                ++_count;
            }
            else if ( _hIndex == _tIndex )
            {
                _tIndex = (_tIndex + 1) % _capcity;
            }

            _hIndex = (_hIndex + 1) % _capcity;
        }

        public function pop ( count : int ) : Object
        {
            if ( _count == 0 ) return null;

            var popIndex : int;
            if ( _count < count )
            {
                if ( _count == 1 ) popIndex = _tIndex;
                clear ();
            }
            else
            {
                if ( _count == 1 ) popIndex = _tIndex;
                _tIndex = (_tIndex + count) % _capcity;
                _count -= count;
            }

            return _nodes[ popIndex ];
        }

        public function clear () : void
        {
            _count = 0;
            _hIndex = _tIndex = 0;
        }
    }
}
