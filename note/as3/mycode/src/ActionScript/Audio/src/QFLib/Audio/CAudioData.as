﻿//----------------------------------------------------------------
// Generated by Excel Table exporter in 2016/8/23 - 16:11:39
//----------------------------------------------------------------


package QFLib.Audio
{
    
    public class CAudioData
    {
        final public function get name() : String {
            return _data.name;
        }

        final public function get fileName() : String { 
          return _data.fileName;
        }

        final public function get preLoad() : Boolean { 
          return _data.preLoad;
        }

        private var _data:Object;
        
        public function CAudioData(data:Object ) : void
        {
          this._data = data;
        
        }
   }
}

