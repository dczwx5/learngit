﻿//----------------------------------------------------------------
// Generated by Excel Table exporter in 2018/9/7 - 18:07:04
//----------------------------------------------------------------


package table
{
    
    public class Chapter
    {
        final public function get ID() : int { 
          return _data.ID;
        }

        final public function get Type() : int { 
          return _data.Type;
        }

        final public function get Name() : String { 
          return _data.Name;
        }

        final public function get OpenLevel() : int { 
          return _data.OpenLevel;
        }

        final public function get Reward() : int { 
          return _data.Reward;
        }

        private var _data:Object;
        
        public function Chapter( data:Object ) : void 
        {
          this._data = data;
        
        }
   }
}

