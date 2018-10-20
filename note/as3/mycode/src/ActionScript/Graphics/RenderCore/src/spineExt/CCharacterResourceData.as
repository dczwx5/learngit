//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2018/1/5.
 */
package spineExt {
    public class CCharacterResourceData {
        public function CCharacterResourceData() {
        }

        private static var record:Object = {};
        public static function addResource(characterName:String, resourceName:String, size:int):void
        {
            if(!record[characterName]) record[characterName] = {};

            var data:Object = record[characterName];
            if(resourceName.indexOf("assets/fx/") != -1)
            {
                if(!data["fx"]) data["fx"] = {};
                data["fx"][resourceName] = size;
            }else if(resourceName.indexOf("assets/audio/") != -1)
            {
                if(!data["audio"]) data["audio"] = {};
                data["audio"][resourceName] = size;
            }else
            {
                if(!data["character"]) data["character"] = {};
                data["character"][resourceName] = size;
            }
        }

        public static function getRecord():Object
        {
            return record;
        }
    }
}
